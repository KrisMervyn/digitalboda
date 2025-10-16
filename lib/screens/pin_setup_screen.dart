import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isChangingPin;
  final VoidCallback? onSuccess;

  const PinSetupScreen({
    Key? key,
    this.isChangingPin = false,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setupOrChangePin() async {
    if (_newPinController.text.isEmpty || _confirmPinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter and confirm your PIN';
      });
      return;
    }

    if (_newPinController.text.length < 4 || _newPinController.text.length > 6) {
      setState(() {
        _errorMessage = 'PIN must be 4-6 digits';
      });
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      setState(() {
        _errorMessage = 'PIN codes do not match';
      });
      return;
    }

    if (widget.isChangingPin && _currentPinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your current PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Map<String, dynamic> result;

    if (widget.isChangingPin) {
      result = await AuthService.changePin(
        currentPin: _currentPinController.text,
        newPin: _newPinController.text,
        confirmPin: _confirmPinController.text,
      );
    } else {
      result = await AuthService.setupPin(
        pinCode: _newPinController.text,
        confirmPin: _confirmPinController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'PIN setup successful'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Call success callback and navigate back
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'PIN setup failed';
      });
    }
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF4CA1AF)),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF636E72),
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3436),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
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
        title: Text(
          widget.isChangingPin ? 'Change PIN' : 'Setup PIN',
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    widget.isChangingPin ? 'Change Your PIN' : 'Setup Your PIN',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isChangingPin
                        ? 'Enter your current PIN and create a new one'
                        : 'Create a 4-6 digit PIN for quick and secure access to your account',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Current PIN field (only for changing PIN)
                  if (widget.isChangingPin)
                    _buildPinField(
                      controller: _currentPinController,
                      label: 'Current PIN',
                      hint: 'Enter current PIN',
                      obscureText: _obscureCurrentPin,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureCurrentPin = !_obscureCurrentPin;
                        });
                      },
                    ),

                  // New PIN field
                  _buildPinField(
                    controller: _newPinController,
                    label: widget.isChangingPin ? 'New PIN' : 'Create PIN',
                    hint: 'Enter 4-6 digits',
                    obscureText: _obscureNewPin,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPin = !_obscureNewPin;
                      });
                    },
                  ),

                  // Confirm PIN field
                  _buildPinField(
                    controller: _confirmPinController,
                    label: 'Confirm PIN',
                    hint: 'Re-enter PIN',
                    obscureText: _obscureConfirmPin,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPin = !_obscureConfirmPin;
                      });
                    },
                  ),

                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
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

                  const SizedBox(height: 16),

                  // Setup/Change PIN Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _setupOrChangePin,
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
                          : Text(
                              widget.isChangingPin ? 'Change PIN' : 'Setup PIN',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Security tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            Text(
                              'Security Tips',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Use a PIN that\'s easy for you to remember but hard for others to guess\n'
                          '• Don\'t use obvious patterns like 1234 or 0000\n'
                          '• Keep your PIN confidential and don\'t share it with anyone\n'
                          '• Your PIN will be locked for 30 minutes after 5 failed attempts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}