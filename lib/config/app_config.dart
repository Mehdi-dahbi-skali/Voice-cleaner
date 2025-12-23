/// Application configuration file
/// This file contains all the configuration settings for the app
/// 
/// IMPORTANT: Update the backendBaseUrl with your Spring Boot backend URL
class AppConfig {
  // Backend API base URL
  // Change this to your Spring Boot backend URL
  // 
  // IMPORTANT: For different platforms, use:
  // - Web (Chrome): 'http://localhost:8085' (requires CORS on backend)
  // - Android Emulator: 'http://10.0.2.2:8085' (no CORS needed) ← USE THIS FOR ANDROID
  // - iOS Simulator: 'http://localhost:8085' (no CORS needed)
  // - Physical Device: 'http://YOUR_COMPUTER_IP:8085' (no CORS needed)
  // - Production: 'https://your-backend-domain.com'
  static const String backendBaseUrl = 'http://localhost:8085'; // For web testing (CORS now configured)
  
  // API endpoints prefix (empty for Eureka services)
  static const String apiPrefix = '';
  
  // Full API base URL
  static String get apiBaseUrl => '$backendBaseUrl$apiPrefix';
  
  // Request timeout duration (in seconds)
  static const int requestTimeoutSeconds = 30;
  
  // Enable debug mode (set to false in production)
  static const bool debugMode = true;
}

