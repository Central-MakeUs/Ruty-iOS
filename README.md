# 프로젝트 소개
- AI 에게 1인 가구의 생활을 개선할 수 있는 루틴을 추천받거나 직접 루틴을 작성하여 저장할 수 있습니다.
- 추천받은 루틴을 설정하여 매일매일 해야 하는 일을 To-Do LIst 형태로 안내하는 서비스입니다.
  
# 제작 기간
- 2025.01 - 2025.03 (2개월)

# 팀 구성
- 4명 (iOS 1명, Backend 1명, Deisgn 1명, Planning 1명)
- 맡은 역할 : iOS 개발자

# 기능 소개
### AI 에게 추천받은 루틴 설정
- 사용자가 선택한 개선하고 싶은 점을 기반으로 AI 에게 루틴을 추천받습니다.
- 추천받은 루틴 리스트를 사용자에게 보여주며 사용자는 원하는 루틴을 골라 내 루틴으로 담아 실행할 수 있습니다.
<img width="268" alt="스크린샷 2025-03-24 오후 4 50 58" src="https://github.com/user-attachments/assets/676f5bb8-fc0f-4fcc-9d5c-85feef114c3a" />

<br><br><br>

### 루틴 정보 저장
- 수행할 루틴의 내용와 수행할 요일, 실천 기간을 설정합니다.
<img width="270" alt="스크린샷 2025-03-24 오후 4 51 17" src="https://github.com/user-attachments/assets/129164a8-3848-40ed-9d82-4d45b127b2ff" />

<br><br><br>

### 오늘 수행해야 하는 루틴 (메인 페이지)
- 오늘 수행햐야 하는 루틴의 리스트가 보여집니다.
- 루틴을 누르면 루틴이 완료(수행됨)되고, 해당 루틴이 해당되는 카테고리의 점수가 오르게 됩니다.
- 카테고리 별 점수가 오르면 레벨이 오르게 됩니다.
<img width="275" alt="스크린샷 2025-03-24 오후 4 51 33" src="https://github.com/user-attachments/assets/2b40744e-10ca-4ae3-8e37-db073b7aef74" />

<br><br><br>

### 나의 모든 루틴 확인
- 저장한 모든 루틴을 리스트 형태로 보여줍니다.
- 루틴 정보보기 버튼을 통해 루틴 상세정보를 확인하는 페이지로 이동이 가능합니다.

<br><br><br>

### 루틴 상세정보 확인
- 해당 루틴에 대한 정보를 보여줍니다.
- 달력을 통해 루틴에 대한 실행도를 한눈에 확인할 수 있습니다.

<br><br><br>

# 기술
- iOS 16.6 +
- Swift 5
- UIKit, CodeBase, MVC
- SnapKit, Then, FSCalendar

# 구현 내용
- Apple/Google 소셜 회원가입, 로그인, 회원탈퇴
- AccessToken, RefreshToken 을 이용한 자동 로그인
- TableView 를 활용해 루틴을 보여주고 루틴의 글자수에 맞춰 cell 의 크기를 동적으로 변경
- 네트워크 오류 핸들링
- AI 데이터 전송할 동안 보여줄 무한 로딩 뷰
- CollectionView 를 이용한 카테고리 분류가 가능한 뷰
- FSCalendar 를 이용한 커스텀 달력

# AppSotre 링크
[AppSotre 바로가기](https://apps.apple.com/kr/app/%EB%A3%A8%ED%8B%B0/id6742365699)
