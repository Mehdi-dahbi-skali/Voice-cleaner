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

  /// 📡 Generic GET (Prepended with Gateway URL)
  Future<Map<String, dynamic>> get(String endpoint) async {
    if (AppConfig.useMockData) return _getMockData(endpoint);
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      if (AppConfig.debugMode) print('GET Request: $url');
      final response = await http
          .get(url, headers: _headers)
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 📡 Generic POST
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    if (AppConfig.useMockData) return {'status': 'mock_success'};
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      if (AppConfig.debugMode) print('POST Request: $url');
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(data))
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- 🎤 Specific Microservice Helpers ---

  /// Fetch all audios from /audioservice/audios
  Future<List<dynamic>> fetchAudios() async {
    final response = await get('${AppConfig.audioService}/audios');
    if (response is List) return response;
    if (response.containsKey('content')) return response['content']; // Mapping for Spring Pageable
    return [];
  }

  /// 🎤 UPLOAD AUDIO to /audioservice/audios
  Future<Map<String, dynamic>> uploadAudio(File audioFile) async {
    if (AppConfig.useMockData) return {'id': 'mock_123', 'status': 'processed'};
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.audioService}/audios');
      if (AppConfig.debugMode) print('UPLOAD Audio → $uri');
      
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

      final streamedResponse = await request.send()
          .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- 🔒 Private Handlers ---

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (AppConfig.debugMode) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw Exception('Gateway Error (${response.statusCode}): ${response.body}');
    }
  }

  dynamic _getMockData(String endpoint) {
    if (endpoint.contains('/audios')) {
      return [
        {'id': '1', 'title': 'Mock Recording 1', 'duration': '00:45', 'date': 'Today', 'type': 'original'},
        {'id': '2', 'title': 'Mock Recording 2', 'duration': '01:12', 'date': 'Yesterday', 'type': 'cleaned'},
      ];
    }
    return {};
  }

  String _handleError(dynamic error) {
    if (AppConfig.debugMode) print('Error Details: $error');
    if (error is SocketException) return 'Microservice unreachable. Gateway check failed.';
    return error.toString();
  }
}
