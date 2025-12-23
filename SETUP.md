# Setup Instructions

## Quick Start Guide

Follow these steps to get your Flutter app running:

### 1. Install Flutter SDK

**Windows:**
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract the zip file to a location like `C:\src\flutter`
3. Add Flutter to your PATH:
   - Search for "Environment Variables" in Windows
   - Edit the "Path" variable
   - Add: `C:\src\flutter\bin`
4. Verify installation:
   ```bash
   flutter doctor
   ```

**Important:** Install Android Studio or VS Code with Flutter extensions for the best development experience.

### 2. Install Project Dependencies

Open a terminal in this project folder and run:

```bash
flutter pub get
```

This installs all packages listed in `pubspec.yaml`.

### 3. Configure Backend URL

1. Open `lib/config/app_config.dart`
2. Find this line:
   ```dart
   static const String backendBaseUrl = 'http://localhost:8080';
   ```
3. Update it with your Spring Boot backend URL:
   - **Local development (Android Emulator)**: `http://10.0.2.2:8080`
   - **Local development (iOS Simulator)**: `http://localhost:8080`
   - **Physical device**: `http://YOUR_COMPUTER_IP:8080`
   - **Production**: `https://your-backend-domain.com`

### 4. Run the App

**Option 1: Using Command Line**
```bash
flutter run
```

**Option 2: Using VS Code**
- Press `F5` or click the Run button

**Option 3: Using Android Studio**
- Click the green play button

### 5. Test the Connection

1. Make sure your Spring Boot backend is running
2. Tap the "Test API Connection" button in the app
3. Check if the connection works

## Troubleshooting

### Flutter Doctor Issues

Run `flutter doctor` and fix any issues it reports:
- Install missing Android SDK components
- Accept Android licenses: `flutter doctor --android-licenses`
- Install Xcode (for iOS development on Mac)

### Connection Issues

**Problem:** Cannot connect to backend

**Solutions:**
- Check if backend is running
- Verify backend URL in `app_config.dart`
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, ensure both devices are on the same WiFi network
- Check firewall settings

### Build Errors

**Problem:** Build fails

**Solutions:**
```bash
flutter clean
flutter pub get
flutter run
```

### Network Security (Android)

If you're using HTTP (not HTTPS) for local development, you may need to allow cleartext traffic:

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add `android:usesCleartextTraffic="true"` to the `<application>` tag if needed

## Next Steps

1. ✅ Install Flutter SDK
2. ✅ Run `flutter pub get`
3. ✅ Update backend URL
4. ✅ Test the app
5. ⏭️ Provide your Spring Boot endpoints to integrate them

## Development Tips

- **Hot Reload**: Press `r` in terminal while app is running
- **Hot Restart**: Press `R` in terminal
- **Stop App**: Press `q` in terminal
- **View Logs**: Check the terminal output or use `flutter logs`

## File Structure Overview

```
lib/
├── config/
│   └── app_config.dart          ← Update backend URL here
├── services/
│   └── api_service.dart         ← HTTP service (ready to use)
├── screens/
│   └── home_screen.dart          ← Main screen
├── models/                       ← Add your data models here
├── widgets/                      ← Add reusable widgets here
└── main.dart                     ← App entry point
```

---

**Need Help?** Check the main `README.md` for more detailed information.

