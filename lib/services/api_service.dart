import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// API Service class
/// Handles all HTTP requests to the Spring Boot backend
class ApiService {

  // Base headers for JSON requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET request
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

  /// POST request (JSON)
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
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

  /// PUT request (JSON)
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
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

  /// 🎤 UPLOAD AUDIO (multipart/form-data)
  /// POST /audioservice/audios
  /// form-data → key = "file"
  Future<Map<String, dynamic>> uploadAudio(File audioFile) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/audioservice/audios',
      );

      if (AppConfig.debugMode) {
        print('UPLOAD Audio → $uri');
        print('Audio path: ${audioFile.path}');
      }

      final request = http.MultipartRequest('POST', uri);

      // Attach audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // MUST MATCH BACKEND
          audioFile.path,
        ),
      );

      final streamedResponse = await request.send()
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));

      final response = await http.Response.fromStream(streamedResponse);

      if (AppConfig.debugMode) {
        print('Upload Status: ${response.statusCode}');
        print('Upload Response: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Upload failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (AppConfig.debugMode) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (_) {
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
  String _handleError(dynamic error) {
    if (AppConfig.debugMode) {
      print('Error: $error');
    }

    final errorString = error.toString();

    if (errorString.contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else if (errorString.contains('SocketException') ||
        errorString.contains('Failed host lookup')) {
      return 'Cannot connect to server. Is backend running?';
    } else if (errorString.contains('CORS') ||
        errorString.contains('ClientException')) {
      return 'CORS error: check Spring Boot configuration.';
    } else {
      return errorString;
    }
  }
}
