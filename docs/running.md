```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter pub run build_runner build --delete-conflicting-outputs
flutter test
flutter build apk --dart-define=API_BASE_URL=https://localpro-api.railway.app
```
