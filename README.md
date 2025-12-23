# Flutter Frontend App

A simple Flutter frontend application designed to connect with a Spring Boot backend.

## 📋 Prerequisites

Before you begin, make sure you have the following installed:

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **VS Code** with Flutter extensions (recommended)

4. **Spring Boot Backend** running (you'll provide endpoints later)

## 🚀 Getting Started

### Step 1: Install Flutter

If you haven't installed Flutter yet, follow these steps:

1. Download Flutter SDK from https://flutter.dev/docs/get-started/install
2. Extract the zip file to a location (e.g., `C:\src\flutter`)
3. Add Flutter to your PATH environment variable
4. Run `flutter doctor` to check if everything is set up correctly

### Step 2: Install Dependencies

Open a terminal in this project directory and run:

```bash
flutter pub get
```

This will install all the required packages listed in `pubspec.yaml`.

### Step 3: Configure Backend URL

1. Open `lib/config/app_config.dart`
2. Update the `backendBaseUrl` with your Spring Boot backend URL:
   ```dart
   static const String backendBaseUrl = 'http://localhost:8080';
   ```
   - For Android emulator: `http://10.0.2.2:8080`
   - For iOS simulator: `http://localhost:8080`
   - For physical device: `http://YOUR_COMPUTER_IP:8080`

### Step 4: Run the App

```bash
flutter run
```

Or use your IDE's run button.

## 📁 Project Structure

```
lib/
├── config/
│   └── app_config.dart          # App configuration (backend URL, etc.)
├── services/
│   └── api_service.dart         # HTTP service for API calls
├── models/                      # Data models (to be added)
├── screens/
│   └── home_screen.dart         # Main home screen
├── widgets/                     # Reusable widgets (to be added)
└── main.dart                    # App entry point
```

## 🔌 How to Use the API Service

The `ApiService` class in `lib/services/api_service.dart` provides methods to interact with your Spring Boot backend:

### GET Request
```dart
final apiService = ApiService();
final response = await apiService.get('/users');
print(response);
```

### POST Request
```dart
final apiService = ApiService();
final response = await apiService.post('/users', {
  'name': 'John Doe',
  'email': 'john@example.com'
});
```

### PUT Request
```dart
final apiService = ApiService();
final response = await apiService.put('/users/1', {
  'name': 'Jane Doe'
});
```

### DELETE Request
```dart
final apiService = ApiService();
final response = await apiService.delete('/users/1');
```

## 📝 Adding Your Backend Endpoints

When you're ready to add your Spring Boot endpoints:

1. **Update the API calls** in `lib/screens/home_screen.dart` or create new screens
2. **Create models** in `lib/models/` folder for your data structures
3. **Add error handling** as needed for your specific use cases

## 🛠️ Development Tips

- **Hot Reload**: Press `r` in the terminal while the app is running to hot reload
- **Hot Restart**: Press `R` in the terminal to hot restart
- **Debug Mode**: The app runs in debug mode by default. Check `lib/config/app_config.dart` to toggle debug mode

## 📦 Dependencies

- **http**: For making HTTP requests to the backend
- **provider**: For state management (ready to use when needed)
- **json_annotation**: For JSON serialization (when you add models)

## 🔒 Security Notes

- Never commit sensitive data (API keys, tokens) to version control
- Use environment variables for different configurations (dev, staging, production)
- Always validate and sanitize data from the backend

## 📚 Learning Resources

- Flutter Documentation: https://flutter.dev/docs
- Dart Language Tour: https://dart.dev/guides/language/language-tour
- HTTP Package: https://pub.dev/packages/http

## 🐛 Troubleshooting

### Connection Issues
- Make sure your Spring Boot backend is running
- Check if the backend URL is correct in `app_config.dart`
- For Android emulator, use `http://10.0.2.2:8080` instead of `localhost`
- For physical devices, ensure both devices are on the same network

### Build Issues
- Run `flutter clean` and then `flutter pub get`
- Make sure your Flutter SDK is up to date: `flutter upgrade`

## 📞 Next Steps

1. Install Flutter SDK (if not already installed)
2. Run `flutter pub get` to install dependencies
3. Update the backend URL in `lib/config/app_config.dart`
4. Provide your Spring Boot endpoints and we'll integrate them!

---

**Note**: This is a beginner-friendly setup. The code is well-documented and follows Flutter best practices.

