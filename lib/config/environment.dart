import 'package:flutter/foundation.dart';

enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static const Environment _environment = kDebugMode 
      ? Environment.development 
      : Environment.production;

  static Environment get environment => _environment;

  // API Configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        // For local development
        return kIsWeb 
            ? 'http://localhost:8000/api'  // Web development
            : defaultTargetPlatform == TargetPlatform.android
                ? 'http://192.168.1.5:8000/api'  // Android emulator - use real IP
                : 'http://localhost:8000/api';  // iOS simulator
      case Environment.production:
        return 'https://dashboard.digitalboda.com/api';
    }
  }

  // Alternative: Use your computer's IP for real device testing
  static String get apiBaseUrlForDevice {
    switch (_environment) {
      case Environment.development:
        // Replace with your actual computer IP
        return 'http://192.168.1.100:8000/api';  // Change this to your computer's IP
      case Environment.production:
        return 'https://dashboard.digitalboda.com/api';
    }
  }

  // Environment-specific settings
  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'digitalboda-dev';  // Your dev Firebase project
      case Environment.production:
        return 'digitalboda-prod'; // Your prod Firebase project
    }
  }

  // Logging Configuration
  static bool get enableDebugLogs => isDevelopment;
  static bool get enableNetworkLogs => isDevelopment;

  // Feature Flags
  static bool get enablePinAuthentication => false;  // Disabled - using persistent login only
  static bool get enableBiometrics => isProduction;
  static bool get enableCrashReporting => isProduction;

  // Timeouts
  static Duration get apiTimeout => isDevelopment 
      ? const Duration(seconds: 30)  // Longer timeout for development
      : const Duration(seconds: 10);

  // App Information
  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'DigitalBoda (Dev)';
      case Environment.production:
        return 'DigitalBoda';
    }
  }

  // Helper method to get appropriate API URL
  static String getApiUrl({bool forRealDevice = false}) {
    if (isDevelopment && forRealDevice) {
      return apiBaseUrlForDevice;
    }
    return apiBaseUrl;
  }

  // Debug information
  static Map<String, dynamic> get debugInfo => {
    'environment': _environment.toString(),
    'apiBaseUrl': apiBaseUrl,
    'apiBaseUrlForDevice': apiBaseUrlForDevice,
    'isProduction': isProduction,
    'isDevelopment': isDevelopment,
    'platform': defaultTargetPlatform.toString(),
    'isWeb': kIsWeb,
  };

  static void printDebugInfo() {
    if (isDevelopment) {
      print('🔧 Environment Configuration:');
      debugInfo.forEach((key, value) {
        print('   $key: $value');
      });
    }
  }
}