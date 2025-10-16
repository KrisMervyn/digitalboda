import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/simple_training_service.dart';

class SimpleTrainingProgressScreen extends StatefulWidget {
  const SimpleTrainingProgressScreen({Key? key}) : super(key: key);

  @override
  State<SimpleTrainingProgressScreen> createState() => _SimpleTrainingProgressScreenState();
}

class _SimpleTrainingProgressScreenState extends State<SimpleTrainingProgressScreen> {
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Please login to view your progress';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await SimpleTrainingService.getRiderProgress(user.phoneNumber ?? '');
      
      if (result['success']) {
        setState(() {
          _progressData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load progress';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load progress: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: const Text(
          'Training Progress',
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
            onPressed: _loadProgress,
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
              'Loading your progress...',
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
              'Error loading progress',
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
              onPressed: _loadProgress,
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

    if (_progressData == null) {
      return const Center(
        child: Text(
          'No progress data available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRiderInfoCard(),
          const SizedBox(height: 20),
          _buildOverallStatsCard(),
          const SizedBox(height: 20),
          _buildModulesSection(),
        ],
      ),
    );
  }

  Widget _buildRiderInfoCard() {
    final riderInfo = _progressData!['rider_info'] as Map<String, dynamic>;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CA1AF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF4CA1AF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riderInfo['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${riderInfo['rider_id'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Phone', riderInfo['phone'] ?? 'N/A'),
          _buildInfoRow('Trainer', riderInfo['trainer'] ?? 'Not assigned'),
          _buildInfoRow('Status', riderInfo['status'] ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final stats = _progressData!['overall_stats'] as Map<String, dynamic>;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.school,
                  '${stats['total_sessions_attended'] ?? 0}',
                  'Sessions Attended',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.star,
                  '${stats['total_points_earned'] ?? 0}',
                  'Points Earned',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.play_circle_fill,
                  '${stats['modules_in_progress'] ?? 0}',
                  'In Progress',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.check_circle,
                  '${stats['modules_completed'] ?? 0}',
                  'Completed',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    final modules = _progressData!['modules'] as List<dynamic>;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Modules Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          if (modules.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No modules available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...modules.map((module) => _buildModuleProgressItem(module)).toList(),
        ],
      ),
    );
  }

  Widget _buildModuleProgressItem(Map<String, dynamic> module) {
    final int totalSessions = module['total_sessions'] ?? 0;
    final int attendedSessions = module['attended_sessions'] ?? 0;
    final int completionPercentage = module['completion_percentage'] ?? 0;
    final String status = module['status'] ?? 'AVAILABLE';
    final statusInfo = SimpleTrainingService.getModuleStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                module['module_icon'] ?? '📱',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['module_title'] ?? 'Unknown Module',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$attendedSessions of $totalSessions sessions attended',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(statusInfo['color']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(statusInfo['color']).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  statusInfo['label'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(statusInfo['color']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completionPercentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(statusInfo['color']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completionPercentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(statusInfo['color']),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}