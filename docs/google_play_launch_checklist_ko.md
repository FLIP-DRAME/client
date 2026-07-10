# Google Play 출시 체크리스트

모두의 드론 Mode 출시 준비용 메모입니다. Google Play Console에 입력할 값과 제출 전 코드 확인 항목을 한곳에 모아 둡니다.

## 기본 스토어 등록정보

앱 이름:

```text
모두의 드론 Mode
```

간단한 설명:

```text
드론 작업 견적 요청부터 운용자 매칭·채팅까지 한곳에서 진행하세요.
```

자세한 설명:

```text
모두의 드론 Mode는 드론 작업이 필요한 고객과 드론 운용자를 연결하는 드론 서비스 매칭 플랫폼입니다.

항공촬영, 방제, 측량, 시설 점검 등 다양한 드론 작업을 원하는 지역과 작업 목적에 맞춰 탐색하고, 운용자 포트폴리오를 확인한 뒤 견적을 요청할 수 있습니다.

주요 기능
- 지역과 작업 분야별 드론 운용자 탐색
- 운용자 포트폴리오 및 작업 이력 확인
- 드론 작업 견적 요청 및 진행 상태 확인
- 고객과 운용자 간 채팅
- 운용자 등록 및 프로필 관리
- 피드와 포트폴리오를 통한 작업 사례 공유
- 계정 관리 및 계정 삭제 요청 지원

모두의 드론 Mode는 드론 서비스 이용 과정을 더 쉽고 투명하게 만들기 위해 만들어졌습니다. 고객은 필요한 작업에 맞는 운용자를 찾고, 운용자는 자신의 전문 분야와 활동 지역을 바탕으로 새로운 작업 기회를 확인할 수 있습니다.

드론 촬영, 농업 방제, 공간 측량, 현장 점검 등 드론이 필요한 순간에 Mode에서 적합한 운용자를 만나보세요.
```

현재 Console 입력 문구 검토:

```text
간단한 설명과 자세한 설명은 전반적으로 정책 리스크가 낮습니다.
다만 "검증된 드론 운용자"는 실제 운용자 심사/승인 절차가 운영되고 있음을 앱 안에서 확인할 수 있을 때만 유지하세요.
심사 리스크를 더 낮추려면 "전문 드론 운용자" 또는 "드론 운용자"로 바꾸는 것을 권장합니다.
```

추천 카테고리:

```text
앱 > 비즈니스
```

추천 태그:

```text
비즈니스
구직
생산성
지도/내비게이션
사진
```

스토어 등록정보 필수 그래픽 상태:

```text
앱 아이콘: Console에 1/1 업로드됨
그래픽 이미지: 초안 생성 완료, play_store_assets/draft/feature_graphic_1024x500.png
휴대전화 스크린샷: 초안 4장 생성 완료, play_store_assets/draft/phone_*.png
7인치 태블릿 스크린샷: Console에서 * 표시가 있으면 필요함
10인치 태블릿 스크린샷: Console에서 * 표시가 있으면 필요함
동영상: 선택사항
Chromebook, Android XR: 앱에서 해당 기기를 타겟팅하지 않으면 보통 선택사항
```

생성한 초안 이미지:

```text
play_store_assets/draft/feature_graphic_1024x500.png
play_store_assets/draft/phone_01_home_search_1080x1920.png
play_store_assets/draft/phone_02_portfolio_1080x1920.png
play_store_assets/draft/phone_03_quote_chat_1080x1920.png
play_store_assets/draft/phone_04_operator_mode_1080x1920.png
```

주의:

```text
위 phone_*.png는 등록정보를 빠르게 채우기 위한 초안 이미지입니다.
Google Play 스크린샷은 실제 앱 사용 경험을 반영해야 하므로, 내부 테스트 앱을 실행해 실제 화면 캡처로 교체하는 것이 가장 안전합니다.
그래픽 이미지(feature graphic)는 실제 화면 캡처가 아니어도 가능하지만, 앱 기능을 과장하지 않아야 합니다.
```

프로젝트 내 원본 이미지 후보:

```text
web/og-image.png: 1267x865, 그래픽 이미지 규격 1024x500과 맞지 않음
web/icons/Icon-512.png: 512x512, 앱 아이콘 규격에는 맞음
ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png: 1024x1024, iOS 아이콘용
assets/onboarding/*.png: 스토어 스크린샷이 아니라 온보딩 일러스트 자산
```

그래픽/스크린샷 업로드 전 확인:

```text
실제 앱 화면이 보이는 스크린샷을 사용하세요.
로그인 전/홈/운용자 탐색/견적 요청/채팅 또는 마이페이지처럼 핵심 플로우가 드러나야 합니다.
과장 문구, 가격 할인, 순위, "최고", "1위" 같은 검증 어려운 표현은 넣지 마세요.
스크린샷에 보이는 기능은 리뷰 계정으로 실제 접근 가능해야 합니다.
```

외부 마케팅:

```text
Google Play 외부 광고를 원하면 사용, 원하지 않으면 사용 중지
```

## 앱 액세스 권한

앱에 로그인 후 접근 가능한 기능이 있으므로 아래 옵션을 권장합니다.

```text
앱의 전체 또는 일부 기능이 제한됨
```

안내 이름:

```text
Client reviewer account
```

사용자 이름, 이메일 주소 또는 전화번호:

```text
리뷰용 데모 계정 이메일 입력
```

비밀번호:

```text
리뷰용 데모 계정 비밀번호 입력
```

앱 액세스에 필요한 기타 정보:

```text
Please use the demo account above to sign in. No two-factor authentication, OTP, paid subscription, location restriction, QR code, or biometric authentication is required. The reviewer can access customer features after signing in. To review operator features, switch to operator mode or use the operator menu after signing in with the same demo account.
```

현재 Play Console에 입력한 리뷰 계정은 실제 Supabase Auth에 생성되어 있어야 합니다. 생성되지 않은 상태로 제출하면 Google 검토자가 로그인할 수 없어 거절될 가능성이 큽니다.

필수 생성 계정:

```text
Client reviewer account: 고객 플로우 접근 가능
Operator reviewer account: 운용자 플로우 접근 가능, operator_profiles 등록 완료 상태
```

주의:

```text
실제 리뷰 계정 비밀번호는 저장소에 커밋하지 말고 Google Play Console에만 입력하세요.
Operator 계정은 단순 회원가입만으로 부족할 수 있습니다. 운용자 프로필, 활동 지역, 포트폴리오, 피드, 요청 확인 화면이 열리는지 실제 앱에서 로그인 테스트해야 합니다.
```

리뷰 계정 생성 체크:

```text
1. Client 리뷰 계정 생성 완료: review-client@modedrone.kr
2. Operator 리뷰 계정 생성 완료: review-operator@modedrone.kr
3. Operator 계정 operator_profiles 생성 완료
4. Operator 계정 status: approved
5. 두 계정 모두 Google Play Console에 입력한 비밀번호로 Supabase Auth 로그인 확인 완료
6. 2FA, OTP, 위치 제한, 유료 결제, QR 코드 없음
```

Supabase CLI를 사용하는 경우 배포 전 확인:

```powershell
supabase functions deploy delete-user
```

배포 상태:

```text
delete-user Edge Function 배포 완료
Project ref: wgujitwmipifuhxavmsn
Function status: ACTIVE
Version: 4
Updated at: 2026-06-06 10:01:16 UTC
```

`delete-user` Edge Function 배포 후 확인:

```text
1. 테스트 계정으로 이미지 또는 문서를 업로드합니다.
2. 앱 내 계정 삭제를 실행합니다.
3. Supabase Auth에서 사용자가 삭제되었는지 확인합니다.
4. profiles, operator_profiles, feed_posts, portfolio_items, user_push_tokens 관련 행이 삭제되었는지 확인합니다.
5. Storage avatars/{userId}, documents/{userId} 객체가 삭제되었는지 확인합니다.
```

`앱에 액세스하는 데 다른 정보가 필요하지 않음`:

```text
위 기타 정보에 이미 안내를 입력했다면 체크하지 않음.
정말 추가 안내가 하나도 없고 아이디/비밀번호만 있으면 체크 가능.
```

## 데이터 보안 설문

데이터 수집 여부:

```text
예
```

전송 중 암호화:

```text
예
```

계정 생성 방법:

```text
사용자 이름 및 비밀번호
```

계정 삭제 URL:

```text
https://modeofficial.net/#/delete-account
```

개인정보처리방침 URL:

```text
https://modeofficial.net/#/privacy
```

사용자가 계정 삭제 없이 일부 또는 전체 데이터 삭제를 요청할 수 있는지:

```text
예
```

업로드용 데이터 보안 CSV:

```text
mode_data_safety_upload_20260605.csv
```

이 CSV는 최신 export를 기준으로 아래 항목을 보정했습니다.

```text
데이터 삭제 지원: 예
데이터 삭제 URL: https://modeofficial.net/#/delete-account
공유됨: 이름, 기타 정보, 대략적인 위치, 인앱 메시지, 사진, 파일 및 문서, 사용자 제작 콘텐츠
```

선택할 데이터 유형:

```text
개인 정보 > 이름
개인 정보 > 이메일 주소
개인 정보 > 사용자 ID
개인 정보 > 기타 정보
위치 > 대략적인 위치
메시지 > 기타 인앱 메시지
사진 및 동영상 > 사진
파일 및 문서 > 파일 및 문서
앱 활동 > 기타 사용자 제작 콘텐츠
기기 또는 기타 ID > 기기 또는 기타 ID
```

공통 처리 답변:

```text
수집됨: 예
공유됨: 다른 이용자에게 프로필, 활동 지역, 피드, 포트폴리오, 채팅 내용 등이 표시되는 항목은 예
임시 처리: 아니요
필수 여부: 계정/서비스 핵심 기능에 필요한 항목은 필수, 프로필 이미지/포트폴리오/피드 등 사용자가 올리는 항목은 선택 가능
수집 목적: 앱 기능, 계정 관리
```

항목별 권장 답변:

| 데이터 유형 | 수집 | 공유 | 필수 여부 | 목적 |
| --- | --- | --- | --- | --- |
| 이름 | 예 | 프로필에 표시되면 예 | 필수 | 앱 기능, 계정 관리 |
| 이메일 주소 | 예 | 아니요 | 필수 | 앱 기능, 계정 관리, 보안 |
| 사용자 ID | 예 | 필요한 경우 예 | 필수 | 앱 기능, 계정 관리 |
| 기타 정보 | 예 | 프로필/운용자 정보에 표시되면 예 | 일부 선택 | 앱 기능 |
| 대략적인 위치 | 예 | 활동 지역이 다른 이용자에게 보이면 예 | 선택 가능 | 앱 기능, 맞춤설정 |
| 인앱 메시지 | 예 | 채팅 상대에게 전송되므로 예 | 선택 가능 | 앱 기능 |
| 사진 | 예 | 피드/프로필/포트폴리오에 표시되면 예 | 선택 가능 | 앱 기능 |
| 파일 및 문서 | 예 | 견적/포트폴리오 공유 대상이면 예 | 선택 가능 | 앱 기능 |
| 앱 상호작용 | 예 | 아니요 | 필수 또는 선택 | 앱 기능, 분석 |
| 기기 또는 기타 ID | 예 | 푸시 알림 제공자와 처리되면 예 | 필수 | 앱 기능, 보안 |

## 타겟층 및 콘텐츠

권장 대상 연령:

```text
만 18세 이상
```

이유:

```text
드론 작업 의뢰, 견적, 사업자/운용자 매칭, 작업 상담 성격의 서비스라 성인 대상 비즈니스 앱으로 제출하는 것이 안전합니다.
```

## 출시 전 코드 확인

현재 확인된 값:

```text
Android applicationId: com.modu.drone
Android app label: 모두의 드론
개인정보처리방침 route: /privacy
계정 삭제 route: /delete-account
Play 업로드 AAB: build/app/outputs/bundle/release/app-release.aab
```

## UGC 모더레이션 (신고/차단/제재)

채팅과 피드가 있는 앱이라 Google Play 심사에서 가장 먼저 확인하는 항목입니다.
구현 상태:

```text
신고 기능: 채팅 상대, 피드 게시글, 게시글 작성자를 신고 가능 (content_reports 테이블)
차단 기능: 사용자 차단 시 피드 게시글/채팅방이 서로 안 보임 (user_blocks 테이블)
계정 정지: profiles.account_status = 'suspended'로 로그인 자체를 막음
콘텐츠 숨김: feed_posts.is_hidden = true로 피드에서 즉시 숨김
차단 관리 화면: 마이페이지 > 차단 관리 (/blocked-users)에서 차단 해제 가능
```

관리자 패널이 따로 없으므로, 실제 검토·제재는 Supabase SQL Editor에서 직접 처리합니다:

```sql
-- 신고 검토
select * from content_reports where status = 'pending' order by created_at desc;

-- 게시글 숨기기
update feed_posts set is_hidden = true where id = '<post-id>';

-- 계정 정지
update profiles set account_status = 'suspended' where id = '<user-id>';
```

`supabase_moderation_migration.sql`(저장소 루트, gitignored)을 Supabase SQL Editor에서 실행해야
위 테이블/컬럼이 생기고 기능이 동작합니다. 아직 실행 전이면 앱은 신고/차단 API 호출 시
오류를 반환합니다(테이블 없음).

출시 전 필수 확인:

```text
1. android/key.properties와 release keystore가 실제 배포 키를 가리키는지 확인 완료
2. 리뷰어 데모 계정이 실제 앱에서 로그인 가능한지 확인
3. https://modeofficial.net/#/privacy 접속 확인
4. https://modeofficial.net/#/delete-account 접속 확인
5. 앱 아이콘 512x512, 그래픽 이미지 1024x500, 휴대전화 스크린샷 2장 이상 업로드
6. Google Play 데이터 보안 CSV를 업로드할 경우 반드시 Play Console 샘플 CSV의 헤더를 그대로 사용
7. Supabase Edge Function delete-user 최신 버전 배포
```

Release signing 상태:

```text
android/upload-keystore.jks 생성 완료
android/key.properties 생성 완료
release signing으로 app-release.aab 빌드 성공
두 파일은 .gitignore에 의해 커밋되지 않습니다.
업로드 키스토어와 key.properties는 안전한 위치에 별도 백업하세요.
```

현재 남겨둔 Android 빌드 경고:

```text
Gradle 8.10.2, Android Gradle Plugin 8.7.0, Kotlin Gradle Plugin 관련 경고가 있습니다.
Gradle 8.14.5 / AGP 8.11.1 / Kotlin 2.2.20 업그레이드는 이 환경에서 릴리즈 빌드가 타임아웃되어 되돌렸습니다.
현재 조합은 AAB 빌드가 성공한 검증된 제출용 조합입니다.
```
