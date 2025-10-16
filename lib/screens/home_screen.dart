import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../services/digital_literacy_service.dart';
import '../services/simple_training_service.dart';
import 'pending_approval_screen.dart';
import 'login_screen.dart';
import 'simple_training_modules_screen.dart';
import 'simple_training_progress_screen.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';
import 'certificates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _riderData;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _trainingModules = [];
  Map<String, dynamic>? _riderProgress;
  List<Map<String, dynamic>> _upcomingSessions = [];

  @override
  void initState() {
    super.initState();
    _checkRiderStatus();
    _loadDigitalLiteracyData();
  }

  Future<void> _checkRiderStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User not authenticated, redirect to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      String? firebaseToken = await user.getIdToken();
      if (firebaseToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication error. Please try again.';
        });
        return;
      }

      // Get rider profile to check status
      Map<String, dynamic> result = await ApiService.getRiderProfile(
        phoneNumber: user.phoneNumber ?? '',
        firebaseToken: firebaseToken,
      );

      if (result['success']) {
        Map<String, dynamic> riderData = result['data'];
        String status = riderData['status'] ?? 'REGISTERED';
        
        setState(() {
          _riderData = riderData;
          _isLoading = false;
        });

        // Check if rider is not approved yet
        if (status == 'PENDING_APPROVAL' || status == 'ONBOARDING' || status == 'REGISTERED') {
          // Redirect to pending approval screen
          String referenceNumber = riderData['reference_number'] ?? 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PendingApprovalScreen(
                firstName: riderData['first_name'] ?? riderData['firstName'] ?? 'User',
                lastName: riderData['last_name'] ?? riderData['lastName'] ?? '',
                phoneNumber: user.phoneNumber ?? '',
                referenceNumber: referenceNumber,
              ),
            ),
          );
          return;
        } else if (status == 'REJECTED') {
          // Show rejection dialog
          _showRejectionDialog(riderData['rejection_reason']);
          return;
        }
        
        // If approved, stay on home screen
        
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error. Please try again.';
      });
    }
  }

  Future<void> _loadDigitalLiteracyData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Load training modules using new simplified service
      final modulesResult = await SimpleTrainingService.getAvailableModules();
      if (modulesResult['success']) {
        setState(() {
          _trainingModules = List<Map<String, dynamic>>.from(modulesResult['data'] ?? []);
        });
      }

      // Load rider progress using new simplified service
      final progressResult = await SimpleTrainingService.getRiderProgress(user.phoneNumber ?? '');
      if (progressResult['success']) {
        setState(() {
          _riderProgress = progressResult['data'];
        });
      }

      // Keep upcoming sessions empty for now since simplified system doesn't use scheduled sessions
      setState(() {
        _upcomingSessions = [];
      });
    } catch (e) {
      print('Error loading training data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              'Application Not Approved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your application was not approved.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Login',
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error signing out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C3E50),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C3E50),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Connection Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _checkRiderStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA1AF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Home screen with bottom navigation
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: Text(
          _getPageTitle(_selectedIndex),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'refresh') {
                _checkRiderStatus();
                _loadDigitalLiteracyData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: _getSelectedPage(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_membership),
              label: 'Certificates',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF4CA1AF),
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 20,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Digital Literacy Training';
      case 1:
        return 'Leaderboard';
      case 2:
        return 'Notifications';
      case 3:
        return 'Certificates';
      default:
        return 'DigitalBoda';
    }
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return const LeaderboardScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const CertificatesScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome ${_riderData?['first_name'] ?? 'Rider'}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${_riderData?['unique_id'] ?? 'Loading...'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'APPROVED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_riderProgress != null) _buildProgressCard(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Upcoming Sessions
              if (_upcomingSessions.isNotEmpty) ...[
                const Text(
                  'Upcoming Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _upcomingSessions.length,
                    itemBuilder: (context, index) {
                      final session = _upcomingSessions[index];
                      return _buildSessionCard(session);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Training Modules Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Training Modules',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SimpleTrainingModulesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Training Modules Grid
              if (_trainingModules.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _trainingModules.take(4).length,
                  itemBuilder: (context, index) {
                    final module = _trainingModules[index];
                    return _buildModuleCard(module);
                  },
                ),
              
              if (_trainingModules.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Training modules are loading...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _riderProgress!;
    final overallStats = progress['overall_stats'] ?? {};
    final totalPoints = overallStats['total_points_earned'] ?? 0;
    final totalModules = overallStats['modules_available'] ?? 0;
    final completedModules = overallStats['modules_completed'] ?? 0;
    final progressPercentage = totalModules > 0 ? (completedModules / totalModules * 100).round() : 0;
    
    return Column(
      children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedModules of $totalModules modules',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'points earned',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progressPercentage / 100,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          '$progressPercentage% Complete',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleTrainingProgressScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Detailed Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA1AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color(0xFF4CA1AF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['session_title'] ?? 'Training Session',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DigitalLiteracyService.formatDate(session['scheduled_date'] ?? ''),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session['location_name'] ?? 'Location TBD',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.people,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${session['registered_count'] ?? 0}/${session['capacity'] ?? 20} registered',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final skillInfo = DigitalLiteracyService.getSkillLevelInfo(module['skill_level'] ?? 'BEGINNER');
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleTrainingModulesScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    module['icon'] ?? '📚',
                    style: const TextStyle(fontSize: 32),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(skillInfo['color']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skillInfo['label'],
                      style: TextStyle(
                        color: Color(skillInfo['color']),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                module['title'] ?? 'Training Module',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${module['session_count'] ?? 0} sessions',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${module['points_value'] ?? 0} points',
                style: const TextStyle(
                  color: Color(0xFF4CA1AF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}