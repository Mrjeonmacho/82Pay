// =============================================================================
// kr/kr_view.dart
// ─────────────────────────────────────────────────────────────────────────────
// [디자인 레퍼런스] Toss / KakaoBank
// [핵심 특징]
//   - BusinessModel 주입 필수 — KR만 갖는 사업자 정보 표시
//   - "[상현 마켓] 사장님" 형식의 헤더
//   - 파스텔 블루 그라디언트, 16dp 라운드, 카드형 리스트
//   - 폰트: Noto Sans KR
// =============================================================================

import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import 'package:worldbank_app/views/components/shared/animate_balance.dart';
import 'package:worldbank_app/views/components/shared/animated_tx_list.dart';
import 'package:worldbank_app/views/components/shared/country_toggle.dart';
import 'package:worldbank_app/views/components/shared/simulate_fab.dart';

// ── 색상 팔레트 ───────────────────────────────────────────────────────────
class _KrColors {
  static const primary = Color(0xFF3182F6);
  static const primaryDeep = Color(0xFF1B64DA);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F7FA);
  static const textMain = Color(0xFF191F28);
  static const textSub = Color(0xFF6B7684);
  static const textHint = Color(0xFFADB5BD);
  // divider: Color(0xFFF2F4F6) — reserved for future use
  static const income = Color(0xFF3182F6);
  static const expense = Color(0xFFFF6B6B);
  static const tagBg = Color(0xFFEBF3FF);
}

// ── 타이포그래피 ──────────────────────────────────────────────────────────
class _KrText {
  static TextStyle greeting() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(255, 255, 255, 0.85),
  );
  static TextStyle accountName() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static TextStyle balanceLabel() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(255, 255, 255, 0.7),
  );
  static TextStyle balance() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -1.0,
  );
  static TextStyle accountNo() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color.fromRGBO(255, 255, 255, 0.75),
  );
  static TextStyle sectionTitle() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: _KrColors.textMain,
  );
  static TextStyle txTitle() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _KrColors.textMain,
  );
  static TextStyle txSub() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _KrColors.textSub,
  );
  static TextStyle txAmount({required bool isCredit}) => TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: isCredit ? _KrColors.income : _KrColors.expense,
  );
  static TextStyle txBalance() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _KrColors.textHint,
  );
  static TextStyle quickLabel() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle tag() => const TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: _KrColors.primary,
  );
}

// =============================================================================
// KrView — 메인 위젯
// [파라미터]
//   business: BusinessModel — KR 전용, 반드시 non-null로 전달
//   user    : 공통 사용자 정보
//   account : 공통 계좌 정보
// =============================================================================
class UnifiedBankView extends StatelessWidget {
  final BankNationality nationality;
  final UserModel user;
  final BankAccount account;
  final BusinessModel? business;
  final List<TransactionHistory> transactions;

  const UnifiedBankView({
    super.key,
    required this.nationality,
    required this.user,
    required this.account,
    this.business,
    required this.transactions,
  });

  static String formatCurrency(double amount, BankNationality nat) {
    final formatted = amount
        .toStringAsFixed(
          nat == BankNationality.kr || nat == BankNationality.jp ? 0 : 2,
        )
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    switch (nat) {
      case BankNationality.kr:
        return '₩$formatted';
      case BankNationality.us:
        return '\$$formatted';
      case BankNationality.jp:
        return '¥$formatted';
      case BankNationality.cn:
        return '$formatted 元';
    }
  }

  static String formatCurrencySafe(double amount, BankNationality nat) {
    final formatted = amount
        .toStringAsFixed(
          nat == BankNationality.kr || nat == BankNationality.jp ? 0 : 2,
        )
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    switch (nat) {
      case BankNationality.kr:
        return '₩$formatted';
      case BankNationality.us:
        return '\$$formatted';
      case BankNationality.jp:
        return '¥$formatted';
      case BankNationality.cn:
        return '$formatted 元';
    }
  }

  static String formatCurrencyNoSymbol(double amount, BankNationality nat) {
    return amount
        .toStringAsFixed(
          nat == BankNationality.kr || nat == BankNationality.jp ? 0 : 2,
        )
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  static String formatDate(DateTime dt, BankNationality nat) {
    final diff = DateTime.now().difference(dt);
    if (nat == BankNationality.kr) {
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${dt.month}.${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (nat == BankNationality.us) {
      return '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (nat == BankNationality.jp) {
      const wd = ['日', '月', '火', '水', '木', '金', '土'];
      final day = wd[(dt.weekday - 1) % 7];
      return '${dt.year}年${dt.month}月${dt.day}日($day) ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    // cn
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String t(String key, BankNationality nat) {
    return switch (key) {
      'recentTransactions' => switch (nat) {
        BankNationality.kr => '최근 거래내역',
        BankNationality.us => 'Recent Transactions',
        BankNationality.jp => 'お取引履歴',
        BankNationality.cn => '近期流水',
      },
      'depositSim' => switch (nat) {
        BankNationality.kr => '입금 시뮬레이션',
        BankNationality.us => 'Simulate Deposit',
        BankNationality.jp => '入金シミュレーション',
        BankNationality.cn => '模拟收款',
      },
      'balance' => switch (nat) {
        BankNationality.kr => '잔액',
        BankNationality.us => 'Balance',
        BankNationality.jp => '残高',
        BankNationality.cn => '可用余额',
      },
      _ => '',
    };
  }

  String _headerTitle() {
    if (nationality == BankNationality.kr) {
      return business?.headerTitle ?? user.userName;
    }
    return '${user.userName}님';
  }

  String _bankName() {
    return switch (nationality) {
      BankNationality.kr => account.bankName,
      BankNationality.us => 'World Bank US',
      BankNationality.jp => 'World Bank JP',
      BankNationality.cn => 'World Bank CN',
    };
  }

  @override
  Widget build(BuildContext context) {
    final balance = transactions.isEmpty
        ? account.balance
        : transactions.first.balanceAfter;
    return Scaffold(
      backgroundColor: _KrColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _KrHeader(
              nationality: nationality,
              account: account,
              balance: balance,
              title: _headerTitle(),
              balanceLabel: t('balance', nationality),
              bankName: _bankName(),
            ),
          ),
          SliverToBoxAdapter(
            child: CountryToggle(
              activeColor: _KrColors.primary,
              inactiveTextColor: _KrColors.textSub,
              backgroundColor: _KrColors.primary.withValues(alpha: 0.07),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Text(
                    t('recentTransactions', nationality),
                    style: _KrText.sectionTitle(),
                  ),
                  const Spacer(),
                  Text(
                    '${transactions.length}건',
                    style: _KrText.txSub().copyWith(color: _KrColors.textHint),
                  ),
                ],
              ),
            ),
          ),
          AnimatedTxList(
            transactions: transactions,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            itemBuilder: (_, tx, __) => _KrTxTile(
              nationality: nationality,
              tx: tx,
              formatAmount: (ay) => formatCurrency(ay, nationality),
              formatDate: (dt) => formatDate(dt, nationality),
            ),
          ),
        ],
      ),
      floatingActionButton: SimulateDepositFab(
        backgroundColor: _KrColors.primary,
        foregroundColor: Colors.white,
        label: t('depositSim', nationality),
      ),
    );
  }
}

class _KrHeader extends StatelessWidget {
  final BankNationality nationality;
  final String title;
  final String bankName;
  final BankAccount account;
  final double balance;
  final String balanceLabel;

  const _KrHeader({
    required this.nationality,
    required this.title,
    required this.bankName,
    required this.account,
    required this.balance,
    required this.balanceLabel,
  });

  String _greetingText() {
    return switch (nationality) {
      BankNationality.kr => '안녕하세요 👋',
      BankNationality.us => 'Hello 👋',
      BankNationality.jp => 'こんにちは 👋',
      BankNationality.cn => '你好 👋',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_KrColors.primaryDeep, _KrColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greetingText(), style: _KrText.greeting()),
              const SizedBox(height: 2),
              Text(title, style: _KrText.accountName()),
              const SizedBox(height: 12),
              Text(bankName, style: _KrText.accountNo()),
              const SizedBox(height: 18),
              Text(balanceLabel, style: _KrText.balanceLabel()),
              const SizedBox(height: 6),
              AnimateBalance(
                balance: balance,
                style: _KrText.balance(),
                formatter: (value) =>
                    UnifiedBankView.formatCurrency(value, nationality),
              ),
              const SizedBox(height: 14),
              _AccountChip(account: account),
              const SizedBox(height: 22),
              // _QuickActions(nationality: nationality),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final BankAccount account;
  const _AccountChip({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_rounded,
            size: 13,
            color: Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(account.accountNumber, style: _KrText.accountNo()),
          const SizedBox(width: 8),
          Text('|', style: _KrText.accountNo()),
          const SizedBox(width: 8),
          Text(account.accountName, style: _KrText.accountNo()),
        ],
      ),
    );
  }
}

// ── KR 거래 타일 ──────────────────────────────────────────────────────────────
class _KrTxTile extends StatelessWidget {
  final BankNationality nationality;
  final TransactionHistory tx;
  final String Function(double) formatAmount;
  final String Function(DateTime) formatDate;

  const _KrTxTile({
    required this.nationality,
    required this.tx,
    required this.formatAmount,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(tx.type);
    final isCredit = tx.isCredit;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _KrColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // 아이콘 배지
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tx.type.icon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 12),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tx.counterParty, style: _KrText.txTitle()),
                      Text(
                        '$sign${formatAmount(tx.amount)}',
                        style: _KrText.txAmount(isCredit: isCredit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // 유형 태그
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _KrColors.tagBg,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                tx.type.labelFor(nationality),
                                style: _KrText.tag(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (tx.memo ?? '').trim().isEmpty
                                    ? '메모 없음'
                                    : (tx.memo ?? '').trim(),
                                style: _KrText.txSub(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          formatDate(tx.transactedAt),
                          style: _KrText.txSub(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '잔액 ${formatAmount(tx.balanceAfter)}',
                    style: _KrText.txBalance(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(TransactionType t) {
    switch (t) {
      case TransactionType.deposit:
        return const Color(0xFF3182F6);
      case TransactionType.withdrawal:
        return const Color(0xFFFF6B6B);
      case TransactionType.transfer:
        return const Color(0xFF9B59B6);
      case TransactionType.payment:
        return const Color(0xFFFF9F43);
      case TransactionType.refund:
        return const Color(0xFF1ABC9C);
      case TransactionType.fee:
        return const Color(0xFF95A5A6);
    }
  }
}
