import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class AuthService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _pinEnabledKey = 'pin_enabled';

  // Persistent login management
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_pinEnabledKey);
  }

  // PIN Authentication
  static Future<Map<String, dynamic>> loginWithPin({
    required String phoneNumber,
    required String pinCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/rider/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'pin_code': pinCode,
          'login_type': 'pin',
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save login data for persistent login
        await saveLoginData(
          token: responseData['token'],
          userData: responseData,
        );

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'PIN login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> loginWithPhone({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/rider/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'login_type': 'phone',
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save login data for persistent login
        await saveLoginData(
          token: responseData['token'],
          userData: responseData,
        );

        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Phone login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  // PIN Management
  static Future<Map<String, dynamic>> setupPin({
    required String pinCode,
    required String confirmPin,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'Not authenticated',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/pin/setup/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'pin_code': pinCode,
          'confirm_pin': confirmPin,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mark PIN as enabled
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_pinEnabledKey, true);

        return {
          'success': true,
          'message': responseData['message'] ?? 'PIN setup successful',
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'PIN setup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> changePin({
    required String currentPin,
    required String newPin,
    required String confirmPin,
  }) async {
    final token = await getAuthToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'Not authenticated',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/pin/change/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'current_pin': currentPin,
          'new_pin': newPin,
          'confirm_pin': confirmPin,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'PIN changed successfully',
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'PIN change failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getPinStatus() async {
    final token = await getAuthToken();
    if (token == null) {
      return {
        'success': false,
        'error': 'Not authenticated',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/pin/status/'),
        headers: {
          'Authorization': 'Token $token',
        },
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to get PIN status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  // Token verification (for Firebase tokens)
  static Future<bool> verifyToken() async {
    final token = await getAuthToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-token/'),
        headers: {
          'Authorization': 'Bearer $token',  // Use Bearer for Firebase tokens
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}