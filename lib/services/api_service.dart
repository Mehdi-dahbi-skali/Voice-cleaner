import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// API Service class
/// This class handles all HTTP requests to the Spring Boot backend
/// 
/// Usage example:
///   final apiService = ApiService();
///   final data = await apiService.get('/users');
class ApiService {
  // Base headers for all requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET request
  /// [endpoint] - API endpoint (e.g., '/users' or '/users/1')
  /// Returns the response data as Map<String, dynamic>
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      
      if (AppConfig.debugMode) {
        print('GET Request: $url');
      }

      final response = await http
          .get(url, headers: _headers)
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  /// [endpoint] - API endpoint (e.g., '/users')
  /// [data] - Request body data as Map
  /// Returns the response data as Map<String, dynamic>
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      
      if (AppConfig.debugMode) {
        print('POST Request: $url');
        print('Request Body: ${jsonEncode(data)}');
      }

      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  /// [endpoint] - API endpoint (e.g., '/users/1')
  /// [data] - Request body data as Map
  /// Returns the response data as Map<String, dynamic>
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      
      if (AppConfig.debugMode) {
        print('PUT Request: $url');
        print('Request Body: ${jsonEncode(data)}');
      }

      final response = await http
          .put(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  /// [endpoint] - API endpoint (e.g., '/users/1')
  /// Returns the response data as Map<String, dynamic>
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      
      if (AppConfig.debugMode) {
        print('DELETE Request: $url');
      }

      final response = await http
          .delete(url, headers: _headers)
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle HTTP response
  /// Checks status code and returns parsed JSON or throws error
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (AppConfig.debugMode) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // If response body is empty, return empty map
      if (response.body.isEmpty) {
        return {};
      }
      
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If response is not JSON, return as string in a map
        return {'message': response.body};
      }
    } else {
      throw Exception(
        'Request failed with status: ${response.statusCode}\n'
        'Response: ${response.body}',
      );
    }
  }

  /// Handle errors
  /// Formats error messages for better debugging
  String _handleError(dynamic error) {
    if (AppConfig.debugMode) {
      print('Error: $error');
    }
    
    final errorString = error.toString();
    
    if (errorString.contains('TimeoutException')) {
      return 'Request timeout. Please check your internet connection.';
    } else if (errorString.contains('SocketException') || 
               errorString.contains('Failed host lookup')) {
      return 'Cannot connect to server. Please check if the backend is running.';
    } else if (errorString.contains('Failed to fetch') || 
               errorString.contains('CORS') ||
               errorString.contains('ClientException')) {
      return 'CORS error: Your Spring Boot backend needs CORS configuration. '
          'See CORS_CONFIG_EXAMPLE.java file for setup instructions. '
          'Alternatively, test on Android/iOS instead of web.';
    } else {
      return error.toString();
    }
  }
}

