import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String referenceNumber;

  const PendingApprovalScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.referenceNumber,
  }) : super(key: key);

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  String _status = 'PENDING_APPROVAL';
  bool _isCheckingStatus = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
    _startStatusCheck();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startStatusCheck() {
    // Check status every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _checkApprovalStatus();
        _startStatusCheck();
      }
    });
  }

  Future<void> _checkApprovalStatus() async {
    if (_isCheckingStatus) return;
    
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? firebaseToken = await user.getIdToken();
        if (firebaseToken != null) {
          Map<String, dynamic> result = await ApiService.getRiderProfile(
            phoneNumber: widget.phoneNumber,
            firebaseToken: firebaseToken,
          );
          
          if (result['success'] && mounted) {
            String newStatus = result['data']['status'] ?? 'PENDING_APPROVAL';
            setState(() {
              _status = newStatus;
            });
            
            // If approved, navigate to home screen
            if (newStatus == 'APPROVED') {
              _showApprovalSuccess();
            } else if (newStatus == 'REJECTED') {
              _showRejectionDialog(result['data']['rejection_reason']);
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently for now
      debugPrint('Status check error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _showApprovalSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your application has been approved! Welcome to DigitalBoda training program.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CA1AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Training',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(String? reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Application Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your application was not approved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (reason != null && reason.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Reason:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Please contact your enumerator for more information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Animated Clock Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CA1AF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 64,
                        color: Color(0xFF4CA1AF),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Your application is under review by your assigned enumerator.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF636E72),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference Number
                    Row(
                      children: [
                        const Icon(
                          Icons.confirmation_number,
                          color: Color(0xFF4CA1AF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Reference Number',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.referenceNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Applicant Info
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Color(0xFF4CA1AF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Applicant',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.firstName} ${widget.lastName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xFF4CA1AF),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (_isCheckingStatus)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CA1AF)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39C12).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _status == 'PENDING_APPROVAL' ? 'Pending Review' : _status,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF39C12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Info message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA1AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CA1AF).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Color(0xFF4CA1AF),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You\'ll receive a notification once your application is reviewed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This usually takes 1-2 business days',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Refresh Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingStatus ? null : _checkApprovalStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA1AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF4CA1AF).withOpacity(0.4),
                  ),
                  icon: _isCheckingStatus 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    _isCheckingStatus ? 'Checking Status...' : 'Check Status',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}