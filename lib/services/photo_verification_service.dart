import 'dart:convert';
import 'package:http/http.dart' as http;

class PhotoVerificationService {
  // Use same base URL as your existing ApiService
  static const String baseUrl = 'http://192.168.1.3:8000/api';

  /// Login rider and get authentication token
  static Future<Map<String, dynamic>> loginRider({
    required String phoneNumber,
    required String password,
  }) async {
    print('🔐 Logging in rider: $phoneNumber');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/rider/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📡 Login response: ${response.statusCode}');
      print('📄 Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'token': data['token'],
          'rider_id': data['rider_id'],
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body)['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Get photo verification report for rider
  static Future<Map<String, dynamic>> getPhotoVerificationReport({
    required int riderId,
    required String token,
  }) async {
    print('📸 Getting photo verification report for rider: $riderId');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/riders/$riderId/photo-verification-report/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Report response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication required. Please login again.',
          'need_login': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get verification report',
        };
      }
    } catch (e) {
      print('❌ Report error: $e');
      return {
        'success': false,
        'error': 'Connection failed. Please check your internet.',
      };
    }
  }

  /// Verify token is still valid
  static Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-token/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token verification error: $e');
      return false;
    }
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200 ? 'Logged out successfully' : 'Logout failed',
      };
    } catch (e) {
      print('❌ Logout error: $e');
      return {
        'success': false,
        'error': 'Connection failed during logout.',
      };
    }
  }
}

/// Models for photo verification data
class PhotoVerificationReport {
  final int riderId;
  final String riderName;
  final String phoneNumber;
  final VerificationStatus status;
  final double? confidenceScore;
  final double? faceMatchScore;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final List<String> warnings;
  final Map<String, dynamic> details;

  PhotoVerificationReport({
    required this.riderId,
    required this.riderName,
    required this.phoneNumber,
    required this.status,
    this.confidenceScore,
    this.faceMatchScore,
    this.verifiedBy,
    this.verifiedAt,
    this.warnings = const [],
    this.details = const {},
  });

  factory PhotoVerificationReport.fromJson(Map<String, dynamic> json) {
    final report = json['verification_report'] ?? {};
    
    return PhotoVerificationReport(
      riderId: json['rider_id'] ?? 0,
      riderName: json['rider_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: _parseStatus(report['status'] ?? 'PENDING'),
      confidenceScore: report['confidence_score']?.toDouble(),
      faceMatchScore: report['face_match_score']?.toDouble(),
      verifiedBy: report['verified_by'],
      verifiedAt: report['verified_at'] != null 
          ? DateTime.tryParse(report['verified_at'])
          : null,
      warnings: List<String>.from(report['warnings'] ?? []),
      details: report['details'] ?? {},
    );
  }

  static VerificationStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'VERIFIED': return VerificationStatus.verified;
      case 'REJECTED': return VerificationStatus.rejected;
      case 'FLAGGED': return VerificationStatus.flagged;
      case 'PENDING': return VerificationStatus.pending;
      default: return VerificationStatus.pending;
    }
  }

  bool get isVerified => status == VerificationStatus.verified;
  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get isFlagged => status == VerificationStatus.flagged;
  
  String get statusText {
    switch (status) {
      case VerificationStatus.verified: return 'Verified ✅';
      case VerificationStatus.rejected: return 'Rejected ❌';
      case VerificationStatus.flagged: return 'Under Review 🔍';
      case VerificationStatus.pending: return 'Pending ⏳';
    }
  }

  String get statusDescription {
    switch (status) {
      case VerificationStatus.verified:
        return 'Your photos have been verified successfully!';
      case VerificationStatus.rejected:
        return 'Your photos were rejected. Please upload new photos.';
      case VerificationStatus.flagged:
        return 'Your photos are under manual review. Please wait.';
      case VerificationStatus.pending:
        return 'Your photos are waiting to be verified.';
    }
  }
}

enum VerificationStatus { pending, verified, rejected, flagged }