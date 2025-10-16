import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class PinLoginScreen extends StatefulWidget {
  final String phoneNumber;

  const PinLoginScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loginWithPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    if (_pinController.text.length < 4) {
      setState(() {
        _errorMessage = 'PIN must be at least 4 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await AuthService.loginWithPin(
        phoneNumber: widget.phoneNumber,
        pinCode: _pinController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'PIN login failed';
        });
        
        // Clear PIN field on error
        _pinController.clear();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login failed. Please try again.';
      });
      _pinController.clear();
    }
  }

  void _switchToPhoneLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Get masked phone number for display
  String get _maskedPhoneNumber {
    if (widget.phoneNumber.length >= 8) {
      return '${widget.phoneNumber.substring(0, 4)}****${widget.phoneNumber.substring(widget.phoneNumber.length - 3)}';
    }
    return widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // PIN Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CA1AF),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CA1AF).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome text
                    const Text(
                      'Enter Your PIN',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Enter your PIN to access your account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _maskedPhoneNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CA1AF),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // PIN Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'PIN Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '• • • • • •',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Color(0xFFB2BEC3),
                                  fontSize: 24,
                                  letterSpacing: 8,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFF2D3436),
                                letterSpacing: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              onFieldSubmitted: (_) => _loginWithPin(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Error message
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
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginWithPin,
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
                                'Access Account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Alternative login options
                    const Text(
                      'Having trouble?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF636E72),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Use phone login button
                    TextButton(
                      onPressed: _switchToPhoneLogin,
                      child: const Text(
                        'Use Phone Number Instead',
                        style: TextStyle(
                          color: Color(0xFF4CA1AF),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
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