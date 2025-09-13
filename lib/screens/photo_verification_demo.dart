import 'package:flutter/material.dart';
import '../services/photo_verification_service.dart';
import 'photo_verification_status_screen.dart';

class PhotoVerificationDemo extends StatefulWidget {
  const PhotoVerificationDemo({Key? key}) : super(key: key);

  @override
  State<PhotoVerificationDemo> createState() => _PhotoVerificationDemoState();
}

class _PhotoVerificationDemoState extends State<PhotoVerificationDemo> {
  String? _authToken;
  int? _riderId;
  String? _riderName;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Photo Verification Demo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 Photo Verification System Demo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Test the new AI-powered photo verification features',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_authToken == null) ...[
              _buildLoginSection(),
            ] else ...[
              _buildLoggedInSection(),
            ],
            
            const SizedBox(height: 20),
            _buildQuickTestSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔐 Rider Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _loginTestRider,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Logging in...'),
                      ],
                    )
                  : const Text('Login as Test Rider'),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: +256774523416 | Password: password123',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInSection() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logged in as $_riderName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Rider ID: $_riderId',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '📸 Photo Verification Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _viewPhotoStatus,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('View Verification Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Quick Test (No Login Required)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test with pre-configured data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _quickTest,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Quick Test - View Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginTestRider() async {
    setState(() => _isLoading = true);

    try {
      final result = await PhotoVerificationService.loginRider(
        phoneNumber: '+256774523416',
        password: 'password123',
      );

      if (result['success'] == true) {
        setState(() {
          _authToken = result['token'];
          _riderId = result['rider_id'];
          _riderName = result['data']['full_name'] ?? 'Test Rider';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorDialog(result['error'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Connection error: $e');
    }
  }

  void _logout() {
    setState(() {
      _authToken = null;
      _riderId = null;
      _riderName = null;
    });
  }

  void _viewPhotoStatus() {
    if (_riderId != null && _authToken != null && _riderName != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoVerificationStatusScreen(
            riderId: _riderId!,
            token: _authToken!,
            riderName: _riderName!,
          ),
        ),
      );
    }
  }

  void _quickTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoVerificationStatusScreen(
          riderId: 12,
          token: '73e552a25b43d1bbbf2b5421b589ba59001dccaf',
          riderName: 'muto nyo',
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}