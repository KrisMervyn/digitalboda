import 'dart:convert';
import 'package:http/http.dart' as http;

class EnumeratorService {
  static const String baseUrl = 'http://192.168.1.19:8000/api';
  
  // Store enumerator credentials for authentication
  static String? _enumeratorUsername;
  static String? _enumeratorPassword;

  static Future<Map<String, dynamic>> login({
    required String enumeratorId,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'enumeratorId': enumeratorId,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Store credentials for future requests
        _enumeratorUsername = responseData['data']['username'];
        _enumeratorPassword = password;
        
        return {
          'success': true,
          'data': responseData['data'],
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
    if (_enumeratorUsername == null || _enumeratorPassword == null) {
      throw Exception('Enumerator not authenticated');
    }
    
    String credentials = '$_enumeratorUsername:$_enumeratorPassword';
    String encoded = base64Encode(utf8.encode(credentials));
    
    return {
      'Authorization': 'Basic $encoded',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/dashboard/stats/'),
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

  static Future<Map<String, dynamic>> getAssignedRiders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/enumerator/assigned-riders/'),
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
          'error': jsonDecode(response.body)['error'] ?? 'Failed to get assigned riders',
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
        Uri.parse('$baseUrl/enumerator/pending-riders/'),
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

  static Future<Map<String, dynamic>> approveRider(int riderId, {String notes = ''}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enumerator/rider/$riderId/approve/'),
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
        Uri.parse('$baseUrl/enumerator/rider/$riderId/reject/'),
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
    _enumeratorUsername = null;
    _enumeratorPassword = null;
  }

  static bool get isAuthenticated {
    return _enumeratorUsername != null && _enumeratorPassword != null;
  }
}