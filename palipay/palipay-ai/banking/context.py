from __future__ import annotations

from typing import Any, Callable, Dict, List, Optional, Pattern

from .types import PatternRule

AccountsToTryFn = Callable[[Any, Optional[str], str], List[str]]


class BankPatternContext:
    """패턴 사전·별칭·프롬프트 힌트·계좌 변형 전략을 묶어 점수/매칭 API를 제공한다."""

    def __init__(
        self,
        *,
        bank_account_patterns: Dict[str, List[PatternRule]],
        bank_name_aliases: Dict[str, str],
        llm_rule_hints: Dict[str, str],
        accounts_to_try_fn: AccountsToTryFn,
    ) -> None:
        self.bank_account_patterns = bank_account_patterns
        self.bank_name_aliases = bank_name_aliases
        self._llm_rule_hints = llm_rule_hints
        self._accounts_to_try_fn = accounts_to_try_fn
        self._aliases_cf = {k.casefold(): v for k, v in bank_name_aliases.items()}

    def resolve_bank_name(self, name: Optional[str]) -> Optional[str]:
        if not name:
            return None
        key = name.strip().replace(" ", "").replace("\n", "").replace("\t", "")
        if not key:
            return None
        if key in self.bank_account_patterns:
            return key
        kcf = key.casefold()
        if kcf in self._aliases_cf:
            return self._aliases_cf[kcf]
        for canon in self.bank_account_patterns:
            if canon.casefold() == kcf:
                return canon
        return name

    def get_bank_patterns(self, bank_name: Optional[str]) -> List[PatternRule]:
        if not bank_name:
            return []
        resolved = self.resolve_bank_name(bank_name)
        if not resolved or resolved not in self.bank_account_patterns:
            return []
        return self.bank_account_patterns[resolved]

    def _accounts_to_try(self, bank_name: Optional[str], account_number: str) -> List[str]:
        return self._accounts_to_try_fn(self, bank_name, account_number)

    def score_account_pattern(
        self, bank_name: Optional[str], account_number: Optional[str]
    ) -> float:
        if not bank_name or not account_number:
            return 0.0

        patterns = self.get_bank_patterns(bank_name)
        if not patterns:
            return 0.0

        candidates = self._accounts_to_try(bank_name, account_number)
        best_score = 0.0
        for pattern in patterns:
            regex: Pattern[str] = pattern["regex"]  # type: ignore[assignment]
            for cand in candidates:
                if regex.match(cand):
                    score = float(pattern["score"])  # type: ignore[arg-type]
                    if score > best_score:
                        best_score = score
                    break

        return best_score

    def get_pattern_match_info(
        self, bank_name: Optional[str], account_number: Optional[str]
    ) -> Dict[str, object]:
        resolved = self.resolve_bank_name(bank_name) if bank_name else bank_name
        if not bank_name or not account_number:
            return {
                "bank_name": resolved,
                "account_number": account_number,
                "matched": False,
                "matched_rules": [],
                "best_score": 0.0,
            }

        patterns = self.get_bank_patterns(bank_name)
        candidates = self._accounts_to_try(bank_name, account_number)

        matched_rules: List[str] = []
        best_score = 0.0

        for pattern in patterns:
            regex: Pattern[str] = pattern["regex"]  # type: ignore[assignment]
            hit = False
            for cand in candidates:
                if regex.match(cand):
                    hit = True
                    break
            if hit:
                rule_name = str(pattern["name"])
                rule_score = float(pattern["score"])  # type: ignore[arg-type]
                matched_rules.append(rule_name)
                if rule_score > best_score:
                    best_score = rule_score

        return {
            "bank_name": resolved,
            "account_number": account_number,
            "matched": len(matched_rules) > 0,
            "matched_rules": matched_rules,
            "best_score": best_score,
        }

    def build_bank_account_rules_for_prompt(self) -> str:
        lines: List[str] = []
        for bank in sorted(self.bank_account_patterns.keys()):
            hints: List[str] = []
            for rule in self.bank_account_patterns[bank]:
                n = str(rule["name"])
                hints.append(self._llm_rule_hints.get(n, n))
            seen: set[str] = set()
            uniq: List[str] = []
            for h in hints:
                if h not in seen:
                    seen.add(h)
                    uniq.append(h)
            lines.append(f"- {bank}: " + "; ".join(uniq))
        return "\n".join(lines)
