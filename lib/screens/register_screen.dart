// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+256';
  String _selectedUserType = 'New Rider';

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
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join our training program and start earning rewards',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // First Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter your first name',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFB2BEC3)),
                          labelStyle: TextStyle(color: Color(0xFF2D3436), fontSize: 14),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF4CA1AF), size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Last Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          hintText: 'Enter your last name',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Color(0xFFB2BEC3)),
                          labelStyle: TextStyle(color: Color(0xFF2D3436), fontSize: 14),
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF4CA1AF), size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone Number Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '+256',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
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
                                labelText: 'Phone Number',
                                hintText: '7XX XXX XXX',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Color(0xFFB2BEC3)),
                                labelStyle: TextStyle(color: Color(0xFF2D3436), fontSize: 14),
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                  ),
                  const SizedBox(height: 12),

                  // User Type Selection
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Experience Level',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // New Rider Option
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedUserType = 'New Rider'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedUserType == 'New Rider'
                                          ? Color(0xFF4CA1AF).withOpacity(0.1)
                                          : Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedUserType == 'New Rider'
                                            ? Color(0xFF4CA1AF)
                                            : Color(0xFFB0BEC5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: _selectedUserType == 'New Rider'
                                              ? Color(0xFF4CA1AF)
                                              : Colors.grey[600],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'New Rider',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUserType == 'New Rider'
                                                ? Color(0xFF4CA1AF)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Experienced Rider Option
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedUserType = 'Experienced Rider'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedUserType == 'Experienced Rider'
                                          ? Color(0xFF2C3E50).withOpacity(0.1)
                                          : Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _selectedUserType == 'Experienced Rider'
                                            ? Color(0xFF2C3E50)
                                            : Color(0xFFB0BEC5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.motorcycle,
                                          color: _selectedUserType == 'Experienced Rider'
                                              ? Color(0xFF2C3E50)
                                              : Colors.grey[600],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Experienced',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedUserType == 'Experienced Rider'
                                                ? Color(0xFF2C3E50)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_firstNameController.text.isNotEmpty && 
                            _lastNameController.text.isNotEmpty && 
                            _phoneController.text.isNotEmpty) {
                          String fullPhoneNumber = '+256${_phoneController.text.trim()}';
                          
                          // Remove any spaces or dashes
                          fullPhoneNumber = fullPhoneNumber.replaceAll(RegExp(r'[\s-]'), '');
                          
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OTPVerificationScreen(
                                phoneNumber: fullPhoneNumber,
                                isRegistration: true,
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                experienceLevel: _selectedUserType,
                              ),
                            ),
                          );
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
                      child: const Text(
                        'Join Training Program',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Redirect
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Color(0xFF636E72)),
                          children: [
                            TextSpan(
                              text: 'Login',
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