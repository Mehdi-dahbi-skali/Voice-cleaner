/// Application configuration file
/// This file contains all the configuration settings for the app
/// 
/// IMPORTANT: Update the backendBaseUrl with your Spring Boot backend URL
class AppConfig {
  // 🚪 API Gateway URL (The entry point for all microservices)
  // - Web (Chrome): 'http://localhost:8080' (default Gateway port)
  // - Android Emulator: 'http://10.0.2.2:8080'
  static const String gatewayUrl = 'http://localhost:8080'; 

  // 📂 Microservice Route Prefixes (Mapped in Gateway via Eureka)
  static const String userService = '/userservice';
  static const String audioService = '/audioservice';
  
  // Full API base URL
  static String get apiBaseUrl => gatewayUrl;
  
  // Request timeout duration (in seconds)
  static const int requestTimeoutSeconds = 30;
  
  // 🧪 Mode
  static const bool useMockData = false; // Set to true to test UI without backend
  static const bool debugMode = true;
}

