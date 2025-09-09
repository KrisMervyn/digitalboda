import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your Django server URL
  static const String baseUrl = 'http://192.168.1.19:8000/api'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // For iOS simulator
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api'; // For real device

  static Future<Map<String, dynamic>> registerRider({
    required String phoneNumber,
    required String firebaseToken,
    String? firstName,
    String? lastName,
    String? experienceLevel,
    String? enumeratorId,
    String? fullName, // Keep for backward compatibility
  }) async {
    print('🚀 Starting registration request...');
    print('📱 Phone: $phoneNumber');
    print('👤 Name: ${firstName ?? fullName} ${lastName ?? ''}');
    print('🎯 Experience: $experienceLevel');
    print('👨‍💼 Enumerator: $enumeratorId');
    print('🔑 Token length: ${firebaseToken.length}');
    print('🌐 URL: $baseUrl/register/');

    try {
      final Map<String, dynamic> requestBody = {
        'phoneNumber': phoneNumber,
      };
      
      // Use new firstName/lastName if available, fallback to fullName
      if (firstName != null && lastName != null) {
        requestBody['firstName'] = firstName;
        requestBody['lastName'] = lastName;
      } else if (fullName != null && fullName.isNotEmpty) {
        // Split fullName for backward compatibility
        final nameParts = fullName.split(' ');
        requestBody['firstName'] = nameParts.first;
        requestBody['lastName'] = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }
      
      if (experienceLevel != null) {
        requestBody['experienceLevel'] = experienceLevel;
      }
      
      if (enumeratorId != null) {
        requestBody['enumeratorId'] = enumeratorId;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> getRiderProfile({
    required String phoneNumber,
    required String firebaseToken,
  }) async {
    print('🚀 Starting profile request...');
    print('📱 Phone: $phoneNumber');
    print('🌐 URL: $baseUrl/profile/$phoneNumber/');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/$phoneNumber/'),
        headers: {
          'Authorization': 'Bearer $firebaseToken',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Profile not found',
        };
      }
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> submitOnboarding({
    required String phoneNumber,
    required String firebaseToken,
    required int age,
    required String location,
    required String nationalIdNumber,
  }) async {
    print('🚀 Starting onboarding submission...');
    print('📱 Phone: $phoneNumber');
    print('👤 Age: $age');
    print('📍 Location: $location');
    print('🆔 National ID: $nationalIdNumber');
    print('🌐 URL: $baseUrl/onboarding/submit/');

    try {
      final Map<String, dynamic> requestBody = {
        'phoneNumber': phoneNumber,
        'age': age,
        'location': location,
        'nationalIdNumber': nationalIdNumber,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/onboarding/submit/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Onboarding submission failed',
        };
      }
    } catch (e) {
      print('❌ API Error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
}