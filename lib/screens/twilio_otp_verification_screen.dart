import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/twilio_service.dart';
import 'home_screen.dart';
import 'rider_onboarding_complete_screen.dart';
import 'package:flutter/foundation.dart';

class TwilioOTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;
  final String? firstName;
  final String? lastName;
  final String? experienceLevel;
  final String? enumeratorId;
  final String? fullName;

  const TwilioOTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isRegistration = false,
    this.firstName,
    this.lastName,
    this.experienceLevel,
    this.enumeratorId,
    this.fullName,
  });

  @override
  State<TwilioOTPVerificationScreen> createState() => _TwilioOTPVerificationScreenState();
}

class _TwilioOTPVerificationScreenState extends State<TwilioOTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 60;
  bool _isResendEnabled = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _useTwilio = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: Twilio OTP Screen initialized with phone number: ${widget.phoneNumber}');
    print('DEBUG: Is registration: ${widget.isRegistration}');
    
    // Check if Twilio is configured
    _useTwilio = TwilioService.isConfigured();
    print('DEBUG: Using Twilio: $_useTwilio');
    
    _sendOTP();
    _startCountdown();
  }

  void _sendOTP() async {
    print('DEBUG: Starting OTP verification for: ${widget.phoneNumber}');
    print('DEBUG: Using provider: ${_useTwilio ? 'Twilio' : 'Firebase'}');
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool success = false;
      
      if (_useTwilio) {
        // Use Twilio SMS
        success = await TwilioService.sendOTP(
          phoneNumber: widget.phoneNumber,
          customMessage: 'Your DigitalBoda verification code is: {OTP}. Valid for 5 minutes.',
        );
        
        if (success) {
          print('DEBUG: Twilio OTP sent successfully');
          setState(() {
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to send SMS via Twilio');
        }
      } else {
        // Fallback to Firebase (your existing implementation)
        await _sendFirebaseOTP();
      }
    } catch (e) {
      print('DEBUG: Exception during OTP send: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send verification code. Please try again.';
      });
    }
  }

  Future<void> _sendFirebaseOTP() async {
    // Enhanced phone number validation
    if (!widget.phoneNumber.startsWith('+')) {
      throw Exception('Phone number must start with country code (+)');
    }
    
    if (widget.phoneNumber.length < 10) {
      throw Exception('Phone number is too short');
    }

    print('DEBUG: Attempting Firebase phone verification...');
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('DEBUG: Auto-verification completed');
        await _signInWithFirebaseCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('DEBUG: Firebase verification failed - Code: ${e.code}, Message: ${e.message}');
        String errorMsg = _getFriendlyErrorMessage(e);
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print('DEBUG: Firebase code sent successfully');
        setState(() {
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('DEBUG: Firebase code auto-retrieval timeout');
      },
      timeout: const Duration(seconds: 60),
    );
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'billing-not-enabled':
        return 'Service temporarily unavailable. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Verification failed. Please try again.';
    }
  }

  void _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_useTwilio) {
        // Verify with Twilio
        bool isValid = TwilioService.verifyOTP(
          phoneNumber: widget.phoneNumber,
          otp: otp,
        );
        
        if (isValid) {
          print('DEBUG: Twilio OTP verified successfully');
          await _handleSuccessfulVerification();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid or expired verification code';
          });
        }
      } else {
        // Handle Firebase verification (implement based on your Firebase flow)
        setState(() {
          _isLoading = false;
          _errorMessage = 'Firebase verification not implemented in this screen';
        });
      }
    } catch (e) {
      print('DEBUG: Error verifying OTP: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification failed. Please try again.';
      });
    }
  }

  Future<void> _handleSuccessfulVerification() async {
    try {
      // Here you would typically authenticate the user with your backend
      // For now, we'll simulate a successful authentication
      
      if (widget.isRegistration) {
        // Register new rider
        Map<String, dynamic> result = await ApiService.registerRider(
          phoneNumber: widget.phoneNumber,
          firebaseToken: 'twilio_verified', // Use a special token for Twilio
          firstName: widget.firstName,
          lastName: widget.lastName,
          experienceLevel: widget.experienceLevel,
          enumeratorId: widget.enumeratorId,
        );
        
        if (result['success']) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RiderOnboardingCompleteScreen(
                firstName: widget.firstName ?? '',
                lastName: widget.lastName ?? '',
                phoneNumber: widget.phoneNumber,
                experienceLevel: widget.experienceLevel ?? 'New Rider',
              ),
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['error'] ?? 'Registration failed';
          });
        }
      } else {
        // Login existing user
        Map<String, dynamic> result = await ApiService.getRiderProfile(
          phoneNumber: widget.phoneNumber,
          firebaseToken: 'twilio_verified',
        );
        
        if (result['success']) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = result['error'] ?? 'Login failed';
          });
        }
      }
    } catch (e) {
      print('DEBUG: Error handling successful verification: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication failed. Please try again.';
      });
    }
  }

  Future<void> _signInWithFirebaseCredential(PhoneAuthCredential credential) async {
    // Your existing Firebase credential handling
    // This is for Firebase fallback only
  }

  void _startCountdown() {
    _countdown = 60;
    _isResendEnabled = false;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
          if (_countdown == 0) {
            _isResendEnabled = true;
          }
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Verify Phone Number',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF636E72),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Powered by ${_useTwilio ? 'Twilio' : 'Firebase'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _useTwilio ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Fields
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Verification Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF4CA1AF), width: 2),
                                ),
                                contentPadding: const EdgeInsets.all(0),
                              ),
                              onChanged: (value) {
                                if (_errorMessage.isNotEmpty) {
                                  setState(() => _errorMessage = '');
                                }
                                
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                }
                                if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }

                                // Auto-verify when all digits entered
                                if (index == 5 && value.isNotEmpty) {
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    _verifyOTP();
                                  });
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 30),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CA1AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF4CA1AF).withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: _isResendEnabled && !_isLoading ? () {
                      _sendOTP();
                      _startCountdown();
                    } : null,
                    child: Text(
                      _isResendEnabled
                          ? 'Resend Code'
                          : 'Resend code in ${_countdown}s',
                      style: TextStyle(
                        color: _isResendEnabled ? const Color(0xFF4CA1AF) : const Color(0xFF636E72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Service Info
                if (_useTwilio)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Using Twilio SMS service for reliable delivery to Uganda numbers',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 24 : 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}