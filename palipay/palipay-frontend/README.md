# +82Pay - Frontend

외국인을 위한 대한민국 결제 및 가계부 서비스, **+82Pay**의 프론트엔드 저장소

---

## 시작하기 (Getting Started)

1. **저장소 클론**

   ```bash
   git clone https://lab.ssafy.com/.../S14P21A208.git
   ```

2. **패키지 설치**

   ```
   flutter pub get
   ```

3. **폰트 확인**

- assets/fonts/ 폴더에 SUIT 폰트 파일 존재

🏗️ 폴더 구조 (Feature-driven)
우리 프로젝트는 협업 시 Git 충돌을 최소화하기 위해 기능 중심 구조를 따릅니다.

lib/core/: 공통 테마, 상수, 유틸리티 및 공통 위젯 (PaliButton 등)

lib/features/: 실제 앱 기능 모듈

auth/: 로그인, 회원가입 관련

payment/: OCR 스캔 및 결제 관련

diary/: 거래 내역 및 가계부 관련

assets/: 이미지, 아이콘, 폰트 자산

🎨 디자인 시스템 (Design System)
모든 UI 작업은 아래 정의된 상수를 사용하여 작성합니다. (자세한 사항은 팀 노션 - 스타일 가이드)

Primary Color: #121380 (Main Blue)

Point Color: #D32426 (Warning Red)

Font: SUIT (Heavy 900 ~ Thin 100)

규격: AppBar/NavBar 64h, Button 56h, Radius 12pt 등

🤝 협업 규칙 (Convention)

1. 브랜치 전략
   main: 배포용 브랜치 (관리자만 접근)

develop: 기능 통합 브랜치

feature/기능명: 각자 기능을 개발하는 브랜치 (예: feature/login)

2. 커밋 메시지 규칙 (Conventional Commits)

- 팀 노션 참고
