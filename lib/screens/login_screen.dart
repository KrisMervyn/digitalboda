import 'package:digitalboda_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';
import 'pin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+256';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your phone number to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F2F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: const Text(
                                    '+256',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: const InputDecoration(
                                    hintText: '7XX XXX XXX',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Color(0xFFB2BEC3)),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        if (_phoneController.text.isNotEmpty && !_isLoading) {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            String fullPhoneNumber = '+256${_phoneController.text.trim()}';
                            
                            // Remove any spaces or dashes
                            fullPhoneNumber = fullPhoneNumber.replaceAll(RegExp(r'[\s-]'), '');
                            
                            // Directly use OTP verification (PIN authentication disabled)
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OTPVerificationScreen(
                                  phoneNumber: fullPhoneNumber,
                                  isRegistration: false,
                                ),
                              ),
                            );
                          } finally {
                            // Reset loading state after navigation
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CA1AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF636E72)),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF4CA1AF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}