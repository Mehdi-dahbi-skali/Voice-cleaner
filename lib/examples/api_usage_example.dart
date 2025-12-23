/// Example file showing how to use the API Service
/// 
/// This file demonstrates how to make API calls to your Spring Boot backend
/// Copy and modify these examples for your actual endpoints

import '../services/api_service.dart';

class ApiUsageExample {
  final ApiService _apiService = ApiService();

  /// Example: GET request to fetch all users
  /// Replace '/users' with your actual endpoint
  Future<void> fetchUsers() async {
    try {
      final response = await _apiService.get('/users');
      print('Users: $response');
      // Process the response data here
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  /// Example: GET request to fetch a single user by ID
  /// Replace '/users' with your actual endpoint
  Future<void> fetchUserById(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      print('User: $response');
      // Process the response data here
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  /// Example: POST request to create a new user
  /// Replace '/users' with your actual endpoint
  Future<void> createUser() async {
    try {
      final response = await _apiService.post('/users', {
        'name': 'John Doe',
        'email': 'john@example.com',
        'age': 30,
      });
      print('Created user: $response');
      // Process the response data here
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  /// Example: PUT request to update a user
  /// Replace '/users' with your actual endpoint
  Future<void> updateUser(int userId) async {
    try {
      final response = await _apiService.put('/users/$userId', {
        'name': 'Jane Doe',
        'email': 'jane@example.com',
      });
      print('Updated user: $response');
      // Process the response data here
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  /// Example: DELETE request to delete a user
  /// Replace '/users' with your actual endpoint
  Future<void> deleteUser(int userId) async {
    try {
      final response = await _apiService.delete('/users/$userId');
      print('Deleted user: $response');
      // Process the response data here
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  /// Example: Using in a Flutter widget (StatefulWidget)
  /// 
  /// In your widget's State class:
  /// 
  /// bool _isLoading = false;
  /// List<dynamic> _users = [];
  /// 
  /// Future<void> _loadUsers() async {
  ///   setState(() => _isLoading = true);
  ///   try {
  ///     final response = await _apiService.get('/users');
  ///     setState(() {
  ///       _users = response['data'] ?? [];
  ///       _isLoading = false;
  ///     });
  ///   } catch (e) {
  ///     setState(() => _isLoading = false);
  ///     // Show error message to user
  ///     ScaffoldMessenger.of(context).showSnackBar(
  ///       SnackBar(content: Text('Error: $e')),
  ///     );
  ///   }
  /// }
}

