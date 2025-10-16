import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/simple_training_service.dart';

class SimpleTrainingModulesScreen extends StatefulWidget {
  const SimpleTrainingModulesScreen({Key? key}) : super(key: key);

  @override
  State<SimpleTrainingModulesScreen> createState() => _SimpleTrainingModulesScreenState();
}

class _SimpleTrainingModulesScreenState extends State<SimpleTrainingModulesScreen> {
  List<dynamic> _modules = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await SimpleTrainingService.getAvailableModules();
      
      if (result['success']) {
        setState(() {
          _modules = result['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load training modules';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load training modules: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _expressInterest(int moduleId, String moduleTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please login to express interest in training', Colors.red);
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Express Interest'),
        content: Text(
          'Are you interested in learning $moduleTitle?\n\n'
          'Your trainer will contact you to schedule the training sessions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CA1AF),
            ),
            child: Text('Yes, I\'m Interested', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Expressing interest...')),
          ],
        ),
      ),
    );

    try {
      final result = await SimpleTrainingService.expressInterestInModule(
        phoneNumber: user.phoneNumber ?? '',
        moduleId: moduleId,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (result['success']) {
        _showSnackBar(
          result['message'] ?? 'Interest expressed successfully!',
          Colors.green,
        );
        
        // Show success details
        _showSuccessDialog(result['data']);
      } else {
        _showSnackBar(
          result['error'] ?? 'Failed to express interest',
          Colors.red,
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      _showSnackBar('Failed to express interest: $e', Colors.red);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Interest Registered!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Module: ${data['module_title']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Trainer: ${data['trainer_name']}'),
            SizedBox(height: 8),
            Text('Total Sessions: ${data['total_sessions']}'),
            SizedBox(height: 8),
            Text('Points to Earn: ${data['total_points']}'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data['next_steps'] ?? 'Your trainer will contact you soon.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CA1AF),
            ),
            child: Text('Got it!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: const Text(
          'Training Modules',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadModules,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading training modules...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              'Error loading modules',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadModules,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C3E50),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_modules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'No training modules available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please check back later',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Choose Training Modules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Express interest in training modules. Your trainer will contact you to schedule sessions.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Modules List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final module = _modules[index];
              return _buildModuleCard(module);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final int sessionCount = module['session_count'] ?? 0;
    final int pointsValue = module['points_value'] ?? 0;
    final double totalHours = (module['total_duration_hours'] ?? 0.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  module['icon'] ?? '📱',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module['title'] ?? 'Training Module',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module['description'] ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Flexible(
                  child: _buildStatChip(
                    Icons.access_time,
                    SimpleTrainingService.formatDuration(totalHours),
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildStatChip(
                    Icons.play_lesson,
                    '$sessionCount sessions',
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildStatChip(
                    Icons.star,
                    '$pointsValue points',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _expressInterest(
                  module['id'],
                  module['title'] ?? 'Training Module',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CA1AF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Express Interest',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}