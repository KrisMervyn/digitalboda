import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class ApiService {
  // Dynamic base URL based on environment
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

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
    int? age,
    String? ageBracket,
    required String association,
    String? profilePhotoPath,
    String? nationalIdPhotoPath,
  }) async {
    print('🚀 Starting onboarding submission...');
    print('📱 Phone: $phoneNumber');
    print('👤 Age: $age');
    print('🏢 Association: $association');
    print('📸 Profile photo: ${profilePhotoPath != null ? "✓" : "✗"}');
    print('🆔 ID photo: ${nationalIdPhotoPath != null ? "✓" : "✗"}');
    print('🌐 URL: $baseUrl/onboarding/submit/');

    try {
      // Create multipart request if photos are provided
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/onboarding/submit/'));
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $firebaseToken',
      });
      
      // Add form fields
      request.fields.addAll({
        'phoneNumber': phoneNumber,
        'association': association,
      });
      
      if (age != null) {
        request.fields['age'] = age.toString();
      }
      
      if (ageBracket != null) {
        request.fields['ageBracket'] = ageBracket;
      }
      
      // Add photo files if they exist
      if (profilePhotoPath != null) {
        final profileFile = await http.MultipartFile.fromPath('profile_photo', profilePhotoPath);
        request.files.add(profileFile);
        print('📸 Added profile photo to request');
      }
      
      if (nationalIdPhotoPath != null) {
        final idFile = await http.MultipartFile.fromPath('national_id_photo', nationalIdPhotoPath);
        request.files.add(idFile);
        print('🆔 Added ID photo to request');
      }
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

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

  /// Update FCM token for push notifications
  static Future<Map<String, dynamic>> getAssociations() async {
    try {
      print('🏢 Fetching associations from API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/associations/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Associations response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print('✅ Successfully fetched ${data['count']} associations');
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to fetch associations',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch associations from server',
        };
      }
    } catch (e) {
      print('❌ Error fetching associations: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> updateFCMToken({
    required String fcmToken,
    required String phoneNumber,
    required String firebaseToken,
  }) async {
    try {
      print('📡 Updating FCM token for: $phoneNumber');
      
      final response = await http.put(
        Uri.parse('$baseUrl/fcm/update-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'phone_number': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 FCM Response status: ${response.statusCode}');
      print('📄 FCM Response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'FCM token updated successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update FCM token',
        };
      }
    } catch (e) {
      print('❌ FCM Token Update Error: $e');
      return {
        'success': false,
        'error': 'Connection failed while updating FCM token.',
      };
    }
  }

  /// Get Firebase authentication token
  static Future<String?> _getFirebaseToken() async {
    try {
      // This would get the Firebase ID token for authentication
      // You might need to import firebase_auth and implement this properly
      return null; // Placeholder for now
    } catch (e) {
      print('❌ Error getting Firebase token: $e');
      return null;
    }
  }
}