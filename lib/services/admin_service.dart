import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const String baseUrl = 'https://dashboard.digitalboda.com/api';
  
  // Store admin token for authentication
  static String? _authToken;

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _authToken = responseData['token'];
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Map<String, String> _getAuthHeaders() {
    if (_authToken == null) {
      throw Exception('Admin not authenticated');
    }
    
    return {
      'Authorization': 'Token $_authToken',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard/stats/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get stats',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getPendingRiders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-riders/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get pending riders',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getRiderDetails(int riderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/rider/$riderId/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get rider details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> approveRider(int riderId, {String notes = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/rider/$riderId/approve/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to approve rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> rejectRider(int riderId, String reason) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/rider/$riderId/reject/'),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Failed to reject rider',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static void logout() {
    _authToken = null;
  }

  static bool get isAuthenticated {
    return _authToken != null;
  }
}