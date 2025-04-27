# astraval_smart

## Version
- **Java**: 17
- **Gradle**: 8.7
- **Dart SDK**: 3.6.2
- **Flutter**: 3.27.4
- **DevTools**: 2.40.3
## Dependencies
### Flutter Dependencies
```bash
flutter pub add firebase_core google_sign_in firebase_auth flutter_signin_button
flutter pub add flutter_bluetooth_serial geolocator permission_handler
```
### Dart Dependencies
- **flutter_test**: sdk: flutter
- **flutter_lints**: ^5.0.0

## Firebase Config

### Config firebase project 
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<PROJECT_ID>
```

### Add SHA value to Firebase RTDB
for Ubuntu 
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
```
for Windows
```bash
keytool -list -v -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" -storepass android -keypass android
```