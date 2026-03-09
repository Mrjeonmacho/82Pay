
# A606 Git Convention

## Branch Rule

- **PM을 제외하고 develop 브랜치에 직접 Merge 금지**
- **같은 팀원 또는 PM의 승인 후 Merge**

---

# Commit Convention

커밋 메시지는 아래 **Tag 형식**을 사용합니다.

### Commit Format

```

Tag: 내용

```

### Example

```

Feat: 로그인 API 구현
Fix: 로그인 NullPointerException 해결
Docs: README 실행 방법 추가

```

---

## Commit Tag 종류

| Tag | Description | Example |
|-----|-------------|--------|
| Feat | 새로운 기능을 추가할 때 (가장 많이 사용) | Feat: 로그인 API 구현 |
| Fix | 버그를 수정할 때 | Fix: 로그인 NullPointerException 해결 |
| Docs | 문서(README 등)만 수정했을 때 | Docs: README 실행 방법 추가 |
| Chore | 빌드 설정, 패키지 매니저 설정 등 (코드 로직 변경 없음) | Chore: build.gradle 의존성 추가 |
| Refactor | 기능 변경 없이 코드 구조만 개선했을 때 | Refactor: 중복 코드 제거 |
| Style | 코드 포맷팅, 세미콜론 누락 등 (코드 로직 변경 없음) | Style: 코드 줄바꿈 정리 |
| Test | 테스트 코드 추가/수정 (실제 코드 변경 없음) | Test: 회원가입 서비스 테스트 코드 작성 |

---

## Commit Message Example

```

Feat: 회원가입 API 구현
Fix: 로그인 시 NullPointerException 해결
Docs: 프로젝트 실행 방법 README에 추가
Refactor: 회원 서비스 중복 코드 제거

```

---

# Merge Rule

- **PM 제외 develop 직접 Merge 금지**
- **동일 팀원 또는 PM 승인 후 Merge**
- **PR(Pull Request)을 통해 코드 리뷰 후 Merge 진행**


---
## Git Workflow

본 프로젝트는 **Git Flow 방식**을 사용합니다.

### 기본 브랜치 구조

- `main`
- `develop`
- `feature/*`
- `hotfix/*`
- `release/*`

---