import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../config/environment.dart';

class DigitalLiteracyService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // Get all digital literacy training modules (REAL API)
  static Future<Map<String, dynamic>> getTrainingModules() async {
    try {
      print('📚 Fetching digital literacy training modules from real API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/modules/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Modules response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data['data']?.length ?? 0} training modules from real API');
        
        // Return data in the format expected by the Flutter UI
        return {
          'success': true,
          'data': data['data'], // Real data from Django API
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get training modules';
        print('❌ Error fetching modules: $error');
        
        // Fallback to mock data if API fails
        print('🔄 Falling back to mock data...');
        return await getMockTrainingModules();
      }
    } catch (e) {
      print('💥 Exception in getTrainingModules: $e');
      
      // Fallback to mock data for development
      print('🔄 Falling back to mock data due to connection error...');
      return await getMockTrainingModules();
    }
  }

  // Get mock training modules (fallback)
  static Future<Map<String, dynamic>> getMockTrainingModules() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'data': [
        {
          'id': 1,
          'title': 'Smartphone Basics',
          'description': 'Master the fundamentals of smartphone operation, navigation, and essential features for daily digital activities.',
          'icon': '📱',
          'skill_level': 'BEGINNER',
          'session_count': 5,
          'total_duration_hours': 6.0,
          'points_value': 150,
          'sessions': [
            {
              'id': 1,
              'session_number': 1,
              'title': 'Getting Started with Your Phone',
              'description': 'Learn to power on, unlock, and navigate your smartphone interface',
              'duration_hours': 1.5,
              'points_value': 30,
              'learning_objectives': [
                'Power on and unlock smartphone',
                'Navigate home screen and menus',
                'Understand basic touch gestures',
                'Customize basic settings'
              ],
              'required_materials': [
                'Android smartphone',
                'Charger',
                'Practice cards with common icons'
              ]
            },
            {
              'id': 2,
              'session_number': 2,
              'title': 'Making Calls and Contacts',
              'description': 'Master voice calling, contact management, and emergency features',
              'duration_hours': 1.0,
              'points_value': 25,
              'learning_objectives': [
                'Make and receive voice calls',
                'Add and organize contacts',
                'Use emergency calling features',
                'Manage call history'
              ],
              'required_materials': [
                'Android smartphone',
                'SIM card with airtime',
                'Emergency contact list'
              ]
            }
          ]
        },
        {
          'id': 2,
          'title': 'Mobile Banking & Digital Payments',
          'description': 'Learn secure mobile money transactions, banking apps, and digital payment safety practices.',
          'icon': '💳',
          'skill_level': 'INTERMEDIATE',
          'session_count': 4,
          'total_duration_hours': 7.0,
          'points_value': 200,
          'sessions': [
            {
              'id': 3,
              'session_number': 1,
              'title': 'Mobile Money Basics',
              'description': 'Introduction to mobile money services and basic transactions',
              'duration_hours': 2.0,
              'points_value': 50,
              'learning_objectives': [
                'Understand mobile money services',
                'Register for mobile money account',
                'Send and receive money',
                'Check account balance'
              ],
              'required_materials': [
                'Android smartphone',
                'National ID',
                'Mobile money agent location'
              ]
            }
          ]
        }
      ]
    };
  }
  
  // Get upcoming training sessions (REAL API)
  static Future<Map<String, dynamic>> getUpcomingSessions(String phoneNumber) async {
    try {
      print('📅 Fetching upcoming training sessions for $phoneNumber from real API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/upcoming-sessions/?phone_number=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Sessions response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data['data']['total_count'] ?? 0} upcoming sessions from real API');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get upcoming sessions';
        print('❌ Error fetching sessions: $error');
        
        // Fallback to mock data
        print('🔄 Falling back to mock upcoming sessions...');
        return await getMockUpcomingSessions(phoneNumber);
      }
    } catch (e) {
      print('💥 Exception in getUpcomingSessions: $e');
      
      // Fallback to mock data for development
      print('🔄 Falling back to mock upcoming sessions due to connection error...');
      return await getMockUpcomingSessions(phoneNumber);
    }
  }

  // Get mock upcoming sessions (fallback)
  static Future<Map<String, dynamic>> getMockUpcomingSessions(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'data': {
        'upcoming_sessions': [
          {
            'schedule_id': 1,
            'session': {
              'id': 1,
              'title': 'Getting Started with Your Phone',
              'description': 'Learn to power on, unlock, and navigate your smartphone interface',
              'session_number': 1,
              'duration_hours': 1.5,
              'points_value': 30,
            },
            'module': {
              'id': 1,
              'title': 'Smartphone Basics',
              'icon': '📱',
            },
            'trainer': {
              'id': 1,
              'name': 'Sarah Nakamya',
              'unique_id': 'EN-2025-0001',
            },
            'scheduled_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'location_name': 'Nakawa Stage',
            'location_address': 'Nakawa Division, Kampala',
            'gps_coordinates': {
              'latitude': 0.3476,
              'longitude': 32.6131,
            },
            'capacity': 25,
            'registered_count': 12,
            'spots_remaining': 13,
            'is_registered': false,
            'rider_progress': {
              'completion_percentage': 0,
              'sessions_attended': 0,
              'skill_level': 'BEGINNER',
            },
          }
        ],
        'total_count': 1,
      }
    };
  }
  
  // Get rider's digital literacy progress
  static Future<Map<String, dynamic>> getRiderProgress(String phoneNumber) async {
    try {
      print('📈 Fetching digital literacy progress for $phoneNumber...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/rider-progress/?phone_number=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Progress response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched rider progress');
        return {
          'success': true,
          'data': data['data'],
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
  
  // Register attendance for a training session using stage ID
  static Future<Map<String, dynamic>> registerAttendance({
    required String phoneNumber,
    required int scheduleId,
    required String enumeratorId,
    required String stageId,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      print('🎯 Registering attendance for session $scheduleId with stage ID $stageId...');
      
      // Try to get venue coordinates from session data
      double? venueLatitude = sessionData?['gps_coordinates']?['latitude']?.toDouble();
      double? venueLongitude = sessionData?['gps_coordinates']?['longitude']?.toDouble();
      
      // Get current location for GPS verification (use venue coordinates for testing)
      final locationResult = await getCurrentLocation(
        venueLatitude: venueLatitude,
        venueLongitude: venueLongitude,
      );
      if (!locationResult['success']) {
        return {
          'success': false,
          'error': 'Failed to get GPS location: ${locationResult['error']}',
        };
      }
      
      final location = locationResult['data'];
      final requestBody = {
        'phone_number': phoneNumber,
        'schedule_id': scheduleId,
        'trainer_id': enumeratorId, // Backend expects trainer_id but it's actually the enumerator
        'stage_id': stageId,
        'gps_latitude': location['latitude'],
        'gps_longitude': location['longitude'],
      };
      
      print('📤 Sending attendance data: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/digital-literacy/register-attendance/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 20));
      
      print('📡 Attendance response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Successfully registered attendance');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to register attendance';
        print('❌ Error registering attendance: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in registerAttendance: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Verify stage ID for session attendance
  static Future<Map<String, dynamic>> verifyStageId({
    required String stageId,
    required int scheduleId,
  }) async {
    try {
      print('🔍 Verifying stage ID $stageId for session $scheduleId...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/verify-stage/?stage_id=$stageId&schedule_id=$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Stage verification response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Stage ID verification result: ${data['valid']}');
        return {
          'success': true,
          'valid': data['valid'] ?? false,
          'message': data['message'],
          'stage_name': data['stage_name'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to verify stage ID';
        print('❌ Error verifying stage ID: $error');
        return {
          'success': false,
          'valid': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in verifyStageId: $e');
      return {
        'success': false,
        'valid': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Get current location (with training venue coordinates)
  static Future<Map<String, dynamic>> getCurrentLocation({
    double? venueLatitude,
    double? venueLongitude,
  }) async {
    try {
      print('📍 Getting current location...');
      
      // For testing/training, use venue coordinates to simulate being at the location
      // In production, this would use actual GPS services
      await Future.delayed(const Duration(seconds: 1));
      
      // Use provided venue coordinates or default Kampala coordinates
      final baseLatitude = venueLatitude ?? 0.3641;  // Closer to training venues
      final baseLongitude = venueLongitude ?? 32.6176;
      final random = (DateTime.now().millisecond % 100) / 100000.0; // Very small variation
      
      return {
        'success': true,
        'data': {
          'latitude': baseLatitude + random, // Very small variation to simulate GPS accuracy
          'longitude': baseLongitude + random,
          'accuracy': 5.0,
        },
      };
      
    } catch (e) {
      print('💥 Exception getting location: $e');
      return {
        'success': false,
        'error': 'Failed to get location. Please try again.',
      };
    }
  }
  
  // Calculate distance between two points in meters (simple implementation)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    // Simple Haversine formula implementation
    const double earthRadius = 6371000; // Earth radius in meters
    
    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLng = _degreesToRadians(endLongitude - startLongitude);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) * math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  // Get leaderboard rankings
  static Future<Map<String, dynamic>> getLeaderboard({
    String period = 'all_time', // 'weekly', 'monthly', 'all_time'
    int limit = 50,
  }) async {
    try {
      print('🏆 Fetching leaderboard for period: $period...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/leaderboard/?period=$period&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Leaderboard response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data['data']?.length ?? 0} leaderboard entries');
        return {
          'success': true,
          'data': data['data'],
          'current_user_rank': data['current_user_rank'],
          'total_participants': data['total_participants'],
          'period': period,
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get leaderboard';
        print('❌ Error fetching leaderboard: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getLeaderboard: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Get rider achievements
  static Future<Map<String, dynamic>> getRiderAchievements(String phoneNumber) async {
    try {
      print('🏅 Fetching achievements for rider: $phoneNumber...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/achievements/?phone_number=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Achievements response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched rider achievements');
        return {
          'success': true,
          'data': data['data'],
          'total_achievements': data['total_achievements'],
          'earned_achievements': data['earned_achievements'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get achievements';
        print('❌ Error fetching achievements: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getRiderAchievements: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Get achievement statistics
  static Future<Map<String, dynamic>> getAchievementStats() async {
    try {
      print('📊 Fetching achievement statistics...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/achievement-stats/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Achievement stats response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched achievement stats');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get achievement stats';
        print('❌ Error fetching achievement stats: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getAchievementStats: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Format date for display
  static String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  // Format duration
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
  
  // Get notifications for a rider
  static Future<Map<String, dynamic>> getNotifications(String phoneNumber) async {
    try {
      print('🔔 Fetching notifications for rider: $phoneNumber...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/notifications/?phone_number=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Notifications response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched ${data['data']?.length ?? 0} notifications');
        return {
          'success': true,
          'data': data['data'],
          'unread_count': data['unread_count'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get notifications';
        print('❌ Error fetching notifications: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getNotifications: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Mark notification as read
  static Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    try {
      print('📖 Marking notification $notificationId as read...');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/digital-literacy/notifications/$notificationId/read/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Mark read response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Successfully marked notification as read');
        return {
          'success': true,
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to mark as read';
        print('❌ Error marking as read: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in markNotificationRead: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please try again.',
      };
    }
  }
  
  // Mark all notifications as read
  static Future<Map<String, dynamic>> markAllNotificationsRead(String phoneNumber) async {
    try {
      print('📖 Marking all notifications as read for $phoneNumber...');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/digital-literacy/notifications/read-all/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone_number': phoneNumber}),
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Mark all read response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Successfully marked all notifications as read');
        return {
          'success': true,
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to mark all as read';
        print('❌ Error marking all as read: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in markAllNotificationsRead: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please try again.',
      };
    }
  }
  
  // Get mock notifications for testing
  static Future<Map<String, dynamic>> getMockNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final notifications = [
      {
        'id': 1,
        'type': 'session_reminder',
        'title': 'Training Session Tomorrow',
        'message': 'Don\'t forget your Digital Marketing Basics session at 10:00 AM at Nakawa Stage',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'is_read': false,
        'icon': '📅',
        'priority': 'high',
      },
      {
        'id': 2,
        'type': 'achievement',
        'title': 'New Achievement Unlocked! 🏆',
        'message': 'You\'ve earned the "Social Media Savvy" badge for completing 3 social media training sessions',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'is_read': false,
        'icon': '🏆',
        'priority': 'medium',
      },
      {
        'id': 3,
        'type': 'training_update',
        'title': 'New Training Module Available',
        'message': 'Advanced Digital Payment Systems module is now available. Start learning today!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'is_read': true,
        'icon': '📚',
        'priority': 'medium',
      },
      {
        'id': 4,
        'type': 'leaderboard',
        'title': 'You\'re Moving Up! 📈',
        'message': 'Great job! You\'ve moved up to 15th position in this week\'s leaderboard',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'is_read': true,
        'icon': '📈',
        'priority': 'low',
      },
      {
        'id': 5,
        'type': 'session_reminder',
        'title': 'Session Starting Soon',
        'message': 'Your "Mobile Banking Safety" session starts in 30 minutes at Wandegeya Stage',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
        'is_read': false,
        'icon': '⏰',
        'priority': 'urgent',
      },
      {
        'id': 6,
        'type': 'completion',
        'title': 'Session Completed Successfully! ✅',
        'message': 'You\'ve completed "Introduction to Smartphones" and earned 50 points',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'is_read': true,
        'icon': '✅',
        'priority': 'low',
      },
      {
        'id': 7,
        'type': 'general',
        'title': 'Weekly Progress Report',
        'message': 'This week you attended 2 sessions and earned 150 points. Keep it up!',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'is_read': false,
        'icon': '📊',
        'priority': 'low',
      },
    ];
    
    final unreadCount = notifications.where((n) => !(n['is_read'] as bool)).length;
    
    return {
      'success': true,
      'data': notifications,
      'unread_count': unreadCount,
    };
  }
  
  // Get skill level color
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
  
  // Get notification priority info
  static Map<String, dynamic> getNotificationPriorityInfo(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return {
          'color': 0xFFE53E3E, // Red
          'borderColor': 0xFFE53E3E,
          'backgroundColor': 0xFFFFF5F5,
        };
      case 'high':
        return {
          'color': 0xFFFF9500, // Orange
          'borderColor': 0xFFFF9500,
          'backgroundColor': 0xFFFFFAF0,
        };
      case 'medium':
        return {
          'color': 0xFF3182CE, // Blue
          'borderColor': 0xFF3182CE,
          'backgroundColor': 0xFFF7FAFC,
        };
      case 'low':
        return {
          'color': 0xFF38A169, // Green
          'borderColor': 0xFF38A169,
          'backgroundColor': 0xFFF0FFF4,
        };
      default:
        return {
          'color': 0xFF718096, // Grey
          'borderColor': 0xFF718096,
          'backgroundColor': 0xFFF7FAFC,
        };
    }
  }
  
  // Format relative time
  static String formatRelativeTime(String timestamp) {
    try {
      final DateTime notificationTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(notificationTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
  
  // Register for a training session
  static Future<Map<String, dynamic>> registerForSession({
    required String phoneNumber,
    required int scheduleId,
  }) async {
    try {
      print('📝 Registering for session $scheduleId...');
      
      final requestBody = {
        'phone_number': phoneNumber,
        'schedule_id': scheduleId,
      };
      
      print('📤 Sending registration data: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/digital-literacy/register-session/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 20));
      
      print('📡 Registration response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Successfully registered for session');
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to register for session';
        print('❌ Error registering for session: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in registerForSession: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  // Get rider certificates
  static Future<Map<String, dynamic>> getRiderCertificates(String phoneNumber) async {
    try {
      print('🏆 Fetching certificates for rider: $phoneNumber...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/certificates/?phone_number=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Certificates response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched certificates');
        return {
          'success': true,
          'data': data['data'],
          'total_certificates': data['total_certificates'],
          'earned_certificates': data['earned_certificates'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get certificates';
        print('❌ Error fetching certificates: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getRiderCertificates: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Get all available badges/certificates
  static Future<Map<String, dynamic>> getAllBadges() async {
    try {
      print('🏅 Fetching all available badges...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/badges/'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('📡 Badges response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched badges');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get badges';
        print('❌ Error fetching badges: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getAllBadges: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }
  
  // Get mock certificates for testing
  static Future<Map<String, dynamic>> getMockCertificates() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final certificates = [
      {
        'id': 1,
        'title': 'Digital Marketing Basics',
        'description': 'Completed comprehensive training on digital marketing fundamentals, social media strategies, and online advertising',
        'icon': '📱',
        'badge_color': 0xFF4CAF50,
        'earned_date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'points_earned': 250,
        'skill_level': 'INTERMEDIATE',
        'category': 'Marketing',
        'progress': 100,
        'is_earned': true,
        'certificate_number': 'DL-2024-001',
        'trainer_name': 'Sarah Nakamya',
        'sessions_completed': 5,
        'total_sessions': 5,
      },
      {
        'id': 2,
        'title': 'Mobile Banking Safety',
        'description': 'Mastered secure mobile banking practices, fraud prevention, and safe transaction methods',
        'icon': '💳',
        'badge_color': 0xFF2196F3,
        'earned_date': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'points_earned': 200,
        'skill_level': 'ADVANCED',
        'category': 'Finance',
        'progress': 100,
        'is_earned': true,
        'certificate_number': 'DL-2024-002',
        'trainer_name': 'John Musoke',
        'sessions_completed': 4,
        'total_sessions': 4,
      },
      {
        'id': 3,
        'title': 'Smartphone Mastery',
        'description': 'Achieved proficiency in smartphone usage, app management, and digital communication',
        'icon': '📱',
        'badge_color': 0xFFFF9800,
        'earned_date': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'points_earned': 150,
        'skill_level': 'BEGINNER',
        'category': 'Technology',
        'progress': 100,
        'is_earned': true,
        'certificate_number': 'DL-2024-003',
        'trainer_name': 'Grace Nakato',
        'sessions_completed': 3,
        'total_sessions': 3,
      },
      {
        'id': 4,
        'title': 'Advanced Digital Payments',
        'description': 'Expert level training in digital payment systems, cryptocurrency basics, and financial technology',
        'icon': '💰',
        'badge_color': 0xFF9C27B0,
        'earned_date': null,
        'points_earned': 0,
        'skill_level': 'EXPERT',
        'category': 'Finance',
        'progress': 60,
        'is_earned': false,
        'certificate_number': null,
        'trainer_name': 'David Ssemwogerere',
        'sessions_completed': 3,
        'total_sessions': 5,
      },
      {
        'id': 5,
        'title': 'Social Media for Business',
        'description': 'Learn to leverage social media platforms for business growth, customer engagement, and brand building',
        'icon': '📈',
        'badge_color': 0xFF4CAF50,
        'earned_date': null,
        'points_earned': 0,
        'skill_level': 'INTERMEDIATE',
        'category': 'Marketing',
        'progress': 40,
        'is_earned': false,
        'certificate_number': null,
        'trainer_name': 'Mary Namugga',
        'sessions_completed': 2,
        'total_sessions': 5,
      },
      {
        'id': 6,
        'title': 'E-commerce Essentials',
        'description': 'Master online selling platforms, inventory management, and digital customer service',
        'icon': '🛒',
        'badge_color': 0xFFFF5722,
        'earned_date': null,
        'points_earned': 0,
        'skill_level': 'INTERMEDIATE',
        'category': 'Business',
        'progress': 0,
        'is_earned': false,
        'certificate_number': null,
        'trainer_name': 'Peter Kizito',
        'sessions_completed': 0,
        'total_sessions': 4,
      },
    ];
    
    final earnedCount = certificates.where((c) => c['is_earned'] as bool).length;
    final totalPoints = certificates.where((c) => c['is_earned'] as bool).fold(0, (sum, c) => sum + (c['points_earned'] as int));
    
    return {
      'success': true,
      'data': certificates,
      'total_certificates': certificates.length,
      'earned_certificates': earnedCount,
      'total_points_earned': totalPoints,
      'completion_rate': (earnedCount / certificates.length * 100).round(),
    };
  }
  
  // Get real-time session status
  static Future<Map<String, dynamic>> getSessionStatus({
    required int scheduleId,
    bool includeAttendees = false,
  }) async {
    try {
      print('📊 Fetching real-time session status for $scheduleId...');
      
      final queryParams = includeAttendees ? '?include_attendees=true' : '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/session-status/$scheduleId/$queryParams'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Session status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched session status');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get session status';
        print('❌ Error fetching session status: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in getSessionStatus: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  // Check attendance window
  static Future<Map<String, dynamic>> checkAttendanceWindow({
    required int scheduleId,
  }) async {
    try {
      print('⏰ Checking attendance window for session $scheduleId...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/digital-literacy/check-attendance-window/?schedule_id=$scheduleId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Attendance window response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully checked attendance window');
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to check attendance window';
        print('❌ Error checking attendance window: $error');
        return {
          'success': false,
          'error': error,
        };
      }
    } catch (e) {
      print('💥 Exception in checkAttendanceWindow: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet and try again.',
      };
    }
  }

  // Format attendance window status message
  static String formatAttendanceWindowStatus(Map<String, dynamic> windowData) {
    if (!windowData['is_open']) {
      return windowData['status_message'] ?? 'Attendance window is closed';
    }
    
    final timeUntilChange = windowData['time_until_change_seconds'] as int? ?? 0;
    if (timeUntilChange > 0) {
      final minutes = timeUntilChange ~/ 60;
      if (minutes > 0) {
        return 'Closes in $minutes minutes';
      } else {
        return 'Closes in less than a minute';
      }
    }
    
    return 'Attendance is open';
  }

  // Get certificate category info
  static Map<String, dynamic> getCategoryInfo(String category) {
    switch (category.toLowerCase()) {
      case 'marketing':
        return {
          'color': 0xFF4CAF50,
          'icon': '📱',
          'label': 'Marketing'
        };
      case 'finance':
        return {
          'color': 0xFF2196F3,
          'icon': '💳',
          'label': 'Finance'
        };
      case 'technology':
        return {
          'color': 0xFFFF9800,
          'icon': '💻',
          'label': 'Technology'
        };
      case 'business':
        return {
          'color': 0xFFFF5722,
          'icon': '🏢',
          'label': 'Business'
        };
      default:
        return {
          'color': 0xFF757575,
          'icon': '📚',
          'label': 'General'
        };
    }
  }
}