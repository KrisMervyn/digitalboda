import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'rider_onboarding_complete_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;
  final String? firstName;
  final String? lastName;
  final String? experienceLevel;
  final String? enumeratorId;
  final String? fullName; // Keep for backward compatibility

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.isRegistration = false,
    this.firstName,
    this.lastName,
    this.experienceLevel,
    this.enumeratorId,
    this.fullName, // Deprecated, use firstName + lastName
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _verificationId = '';
  int _resendToken = 0;
  int _countdown = 60;
  bool _isResendEnabled = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _sendOTP();
    _startCountdown();
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

  void _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = _getFriendlyErrorMessage(e);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken ?? 0;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken > 0 ? _resendToken : null,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to send verification code. Please try again.';
      });
    }
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

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      setState(() => _isLoading = true);

      // Step 1: Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Step 2: Get Firebase ID token
        String? firebaseToken = await userCredential.user!.getIdToken();
        
        if (firebaseToken != null) {
          // Step 3: Call Django backend
          Map<String, dynamic> result;
          
          if (widget.isRegistration) {
            // Register new rider
            result = await ApiService.registerRider(
              phoneNumber: widget.phoneNumber,
              firebaseToken: firebaseToken,
              firstName: widget.firstName,
              lastName: widget.lastName,
              experienceLevel: widget.experienceLevel,
              enumeratorId: widget.enumeratorId,
            );
          } else {
            // Get existing rider profile
            result = await ApiService.getRiderProfile(
              phoneNumber: widget.phoneNumber,
              firebaseToken: firebaseToken,
            );
          }
          
          if (result['success']) {
            // Success - navigate based on registration or login
            if (widget.isRegistration) {
              // New registration - go to onboarding
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
              // Existing user login - go to home
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            // Backend error
            setState(() {
              _isLoading = false;
              _errorMessage = result['error'] ?? 'Authentication failed';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Authentication token error. Please try again.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is FirebaseAuthException) {
          _errorMessage = _getFriendlyErrorMessage(e);
        } else {
          _errorMessage = 'Verification failed. Please try again.';
        }
      });
    }
  }

  void _verifyOTP() {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter complete OTP');
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: otp,
    );

    _signInWithCredential(credential);
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
                            // Clear error message without triggering rebuild if not necessary
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
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 24 : 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}