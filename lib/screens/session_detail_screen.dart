import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/digital_literacy_service.dart';

class SessionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final Map<String, dynamic>? schedule;
  final String moduleTitle;
  final String moduleIcon;

  const SessionDetailScreen({
    Key? key,
    required this.session,
    this.schedule,
    required this.moduleTitle,
    required this.moduleIcon,
  }) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final TextEditingController _stageIdController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isRegistered = false;
  String _errorMessage = '';
  String _successMessage = '';
  Map<String, dynamic>? _verificationResult;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  @override
  void dispose() {
    _stageIdController.dispose();
    super.dispose();
  }

  void _checkRegistrationStatus() {
    // Mock check - in real implementation, check if user is already registered
    // This would call an API to check registration status
    setState(() {
      _isRegistered = false; // For demo purposes
    });
  }

  Future<void> _verifyStageId() async {
    if (_stageIdController.text.trim().isEmpty) {
      _showSnackBar('Please enter your stage ID', Colors.orange);
      return;
    }

    final stageId = _stageIdController.text.trim().toUpperCase();
    final scheduleId = widget.schedule?['id'] ?? 1;

    setState(() {
      _isVerifying = true;
      _errorMessage = '';
      _verificationResult = null;
    });

    try {
      final result = await DigitalLiteracyService.verifyStageId(
        stageId: stageId,
        scheduleId: scheduleId,
      );

      setState(() {
        _verificationResult = result;
        _isVerifying = false;
      });

      if (result['success'] && result['valid']) {
        _showSnackBar(
          'Stage verified: ${result['stage_name'] ?? stageId}', 
          Colors.green
        );
      } else {
        _showSnackBar(
          result['error'] ?? 'Invalid stage ID for this session location',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Failed to verify stage ID: $e';
      });
      _showSnackBar('Verification failed. Please try again.', Colors.red);
    }
  }

  Future<void> _registerAttendance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please login to register attendance', Colors.red);
      return;
    }

    if (_stageIdController.text.trim().isEmpty) {
      _showSnackBar('Please enter and verify your stage ID first', Colors.orange);
      return;
    }

    if (_verificationResult == null || !(_verificationResult!['valid'] ?? false)) {
      _showSnackBar('Please verify your stage ID first', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final result = await DigitalLiteracyService.registerAttendance(
        phoneNumber: user.phoneNumber ?? '',
        scheduleId: widget.schedule?['id'] ?? 1,
        trainerId: widget.schedule?['trainer_id'] ?? 'trainer_001',
        stageId: _stageIdController.text.trim().toUpperCase(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        setState(() {
          _isRegistered = true;
          _successMessage = result['message'] ?? 'Successfully registered for session!';
        });
        _showSnackBar('Successfully registered for session!', Colors.green);
      } else {
        _showSnackBar(
          result['error'] ?? 'Failed to register attendance',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Registration failed: $e';
      });
      _showSnackBar('Registration failed. Please try again.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
          'Session Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Header Card
                _buildSessionHeader(),
                
                const SizedBox(height: 24),
                
                // Session Details
                _buildSessionDetails(),
                
                const SizedBox(height: 24),
                
                // Learning Objectives
                _buildLearningObjectives(),
                
                const SizedBox(height: 24),
                
                // Required Materials
                _buildRequiredMaterials(),
                
                const SizedBox(height: 24),
                
                // Schedule Information (if available)
                if (widget.schedule != null) _buildScheduleInfo(),
                
                const SizedBox(height: 24),
                
                // Stage ID Verification and Attendance
                _buildAttendanceSection(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
              Text(
                widget.moduleIcon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session['title'] ?? 'Training Session',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.moduleTitle,
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
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time,
                '${widget.session['duration_hours'] ?? 0}h',
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.star,
                '${widget.session['points_value'] ?? 0} points',
                Colors.orange,
              ),
              const SizedBox(width: 12),
              if (_isRegistered)
                _buildInfoChip(
                  Icons.check_circle,
                  'Registered',
                  Colors.green,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails() {
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.session['description'] ?? 'No description available.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningObjectives() {
    final objectives = List<String>.from(widget.session['learning_objectives'] ?? []);
    
    if (objectives.isEmpty) return const SizedBox.shrink();

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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Objectives',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...objectives.map((objective) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Color(0xFF4CA1AF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    objective,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRequiredMaterials() {
    final materials = List<String>.from(widget.session['required_materials'] ?? []);
    
    if (materials.isEmpty) return const SizedBox.shrink();

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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Required Materials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          ...materials.map((material) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    material,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo() {
    final schedule = widget.schedule!;
    
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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Schedule Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(
            Icons.access_time,
            'Date & Time',
            DigitalLiteracyService.formatDate(schedule['scheduled_date'] ?? ''),
          ),
          _buildScheduleItem(
            Icons.location_on,
            'Location',
            schedule['location_name'] ?? 'Location TBD',
          ),
          _buildScheduleItem(
            Icons.home,
            'Address',
            schedule['location_address'] ?? 'Address not specified',
          ),
          _buildScheduleItem(
            Icons.people,
            'Capacity',
            '${schedule['registered_count'] ?? 0}/${schedule['capacity'] ?? 20} registered',
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4CA1AF)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    if (_isRegistered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Attendance Registered',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            if (_successMessage.isNotEmpty)
              Text(
                _successMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      );
    }

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
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Register Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter your stage ID to verify your location and register attendance for this session.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          
          // Stage ID input
          TextFormField(
            controller: _stageIdController,
            decoration: InputDecoration(
              labelText: 'Stage ID',
              hintText: 'Enter your stage ID (e.g., STG001)',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) {
              setState(() {
                _errorMessage = '';
                _verificationResult = null;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Verification result
          if (_verificationResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (_verificationResult!['valid'] ?? false)
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    (_verificationResult!['valid'] ?? false)
                        ? Icons.check_circle
                        : Icons.error,
                    color: (_verificationResult!['valid'] ?? false)
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      (_verificationResult!['valid'] ?? false)
                          ? 'Stage verified: ${_verificationResult!['stage_name'] ?? _stageIdController.text}'
                          : _verificationResult!['error'] ?? 'Invalid stage ID',
                      style: TextStyle(
                        color: (_verificationResult!['valid'] ?? false)
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _verifyStageId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CA1AF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.verified_user),
                  label: Text(_isVerifying ? 'Verifying...' : 'Verify Stage'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_verificationResult?['valid'] == true && !_isLoading)
                      ? _registerAttendance
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.how_to_reg),
                  label: Text(_isLoading ? 'Registering...' : 'Register'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}