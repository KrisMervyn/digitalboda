import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class SimpleTrainingService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  /// Get all available training modules
  static Future<Map<String, dynamic>> getAvailableModules() async {
    try {
      print('📚 Fetching available training modules...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/training/modules/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Modules response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data['data']?.length ?? 0} training modules');
        
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get training modules';
        print('❌ Error fetching modules: $error');
        
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getAvailableModules: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  /// Express interest in a training module (simplified enrollment)
  static Future<Map<String, dynamic>> expressInterestInModule({
    required String phoneNumber,
    required int moduleId,
  }) async {
    try {
      print('📝 Expressing interest in module $moduleId for $phoneNumber...');
      
      final requestBody = {
        'phone_number': phoneNumber,
        'module_id': moduleId,
      };
      
      print('📤 Sending enrollment data: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/training/enroll/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 20));
      
      print('📡 Enrollment response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Successfully expressed interest in module');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to express interest';
        print('❌ Error expressing interest: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in expressInterestInModule: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  /// Get rider's training progress
  static Future<Map<String, dynamic>> getRiderProgress(String phoneNumber) async {
    try {
      print('📈 Fetching training progress for $phoneNumber...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/training/progress/').replace(
          queryParameters: {'phone_number': phoneNumber},
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Progress response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched training progress');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get progress';
        print('❌ Error fetching progress: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getRiderProgress: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  /// Format duration for display
  static String formatDuration(double hours) {
    if (hours < 1) {
      int minutes = (hours * 60).round();
      return '${minutes} min';
    } else if (hours % 1 == 0) {
      return '${hours.toInt()} hr';
    } else {
      int wholeHours = hours.floor();
      int minutes = ((hours - wholeHours) * 60).round();
      return '${wholeHours}hr ${minutes}min';
    }
  }
  
  /// Get skill level color and info
  static Map<String, dynamic> getSkillLevelInfo(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return {
          'color': 0xFFFF9800, // Orange
          'icon': '🌱',
          'label': 'Beginner'
        };
      case 'INTERMEDIATE':
        return {
          'color': 0xFF2196F3, // Blue
          'icon': '📈',
          'label': 'Intermediate'
        };
      case 'ADVANCED':
        return {
          'color': 0xFF4CAF50, // Green
          'icon': '⭐',
          'label': 'Advanced'
        };
      case 'EXPERT':
        return {
          'color': 0xFF9C27B0, // Purple
          'icon': '👑',
          'label': 'Expert'
        };
      default:
        return {
          'color': 0xFF757575, // Grey
          'icon': '❓',
          'label': 'Unknown'
        };
    }
  }
  
  /// Get module status info
  static Map<String, dynamic> getModuleStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return {
          'color': 0xFF2196F3, // Blue
          'label': 'Available',
          'description': 'Ready to start'
        };
      case 'IN_PROGRESS':
        return {
          'color': 0xFFFF9800, // Orange
          'label': 'In Progress',
          'description': 'Currently learning'
        };
      case 'COMPLETED':
        return {
          'color': 0xFF4CAF50, // Green
          'label': 'Completed',
          'description': 'Successfully finished'
        };
      default:
        return {
          'color': 0xFF757575, // Grey
          'label': 'Unknown',
          'description': 'Status unknown'
        };
    }
  }
  
  /// Calculate overall completion percentage
  static double calculateOverallProgress(List<dynamic> modules) {
    if (modules.isEmpty) return 0.0;
    
    int totalSessions = 0;
    int attendedSessions = 0;
    
    for (var module in modules) {
      totalSessions += (module['total_sessions'] as int? ?? 0);
      attendedSessions += (module['attended_sessions'] as int? ?? 0);
    }
    
    if (totalSessions == 0) return 0.0;
    return (attendedSessions / totalSessions) * 100;
  }
}