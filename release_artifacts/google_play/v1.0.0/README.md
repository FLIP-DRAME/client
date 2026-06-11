# 모두의 드론 Mode Google Play Release v1.0.0

Upload AAB:
- mode-google-play-v1.0.0+1.aab

Version:
- versionName: 1.0.0
- versionCode: 1

Included support files:
- mode_data_safety_upload_20260605.csv
- google_play_launch_checklist_ko.md
- store_assets_draft/*.png

Verification:
- fvm flutter analyze --no-pub: passed
- fvm flutter test --no-pub: passed
- fvm flutter build appbundle --release --no-pub --build-name=1.0.0 --build-number=1: passed

Notes:
- store_assets_draft phone screenshots are draft graphics. Replace with real app screenshots when possible.
- release signing uses android/upload-keystore.jks and android/key.properties, which are ignored by git. Back them up separately.

Play readiness score:
- 84 / 100

Main remaining risks:
- Draft phone images are not real in-app screenshots. Use real screenshots for the safest review.
- Confirm Google Play Console shows data deletion as supported after CSV upload.
- Confirm tablet screenshot requirements on the Console page. If marked required, upload tablet assets.
- Keep the reviewer accounts active until review is finished.
- Gradle/AGP/Kotlin warnings are not current blockers, but should be upgraded after first release.
