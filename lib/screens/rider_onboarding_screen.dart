import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';

class RiderOnboardingScreen extends StatefulWidget {
  final String phoneNumber;
  final String userName;
  final String userType;

  const RiderOnboardingScreen({
    Key? key,
    required this.phoneNumber,
    required this.userName,
    required this.userType,
  }) : super(key: key);

  @override
  State<RiderOnboardingScreen> createState() => _RiderOnboardingScreenState();
}

class _RiderOnboardingScreenState extends State<RiderOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _stageNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _stageLocationController = TextEditingController();
  
  // Form data
  String _selectedGender = 'Male';
  String _selectedIdType = 'National ID';
  bool _idPhotoFrontTaken = false;
  bool _idPhotoBackTaken = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name if available
    if (widget.userName.isNotEmpty) {
      final nameParts = widget.userName.split(' ');
      _firstNameController.text = nameParts.first;
      if (nameParts.length > 1) {
        _lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _stageNameController.dispose();
    _idNumberController.dispose();
    _stageLocationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _takePhoto(bool isFront) {
    // Simulate photo taking for now
    setState(() {
      if (isFront) {
        _idPhotoFrontTaken = true;
      } else {
        _idPhotoBackTaken = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isFront ? "Front" : "Back"} photo taken! Camera functionality will be added in next update.'),
        backgroundColor: Color(0xFF4CA1AF),
      ),
    );
  }

  void _completeOnboarding() {
    // Here you would normally send data to your backend
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0 ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: _previousPage,
        ) : null,
        title: Text(
          'Step ${_currentPage + 1} of 5',
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 5,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CA1AF)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildPersonalInfoPage(),
                _buildGenderPage(),
                _buildStageInfoPage(),
                _buildIdVerificationPage(),
                _buildLocationPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s start with your basic information',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInputField(
            label: 'First Name',
            controller: _firstNameController,
            icon: Icons.person,
            hint: 'Enter your first name',
          ),
          const SizedBox(height: 16),
          
          _buildInputField(
            label: 'Last Name',
            controller: _lastNameController,
            icon: Icons.person,
            hint: 'Enter your last name',
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _firstNameController.text.isNotEmpty && 
                         _lastNameController.text.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA1AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please select your gender',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildGenderOption('Male', Icons.male),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenderOption('Female', Icons.female),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA1AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your operating stage',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInputField(
            label: 'Stage Name',
            controller: _stageNameController,
            icon: Icons.location_on,
            hint: 'e.g., Kampala Central Stage',
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _stageNameController.text.isNotEmpty ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA1AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdVerificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ID Verification',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your identification document',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 32),
          
          // ID Type Selection
          Row(
            children: [
              Expanded(
                child: _buildIdTypeOption('National ID'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIdTypeOption('Permit'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildInputField(
            label: '${_selectedIdType} Number',
            controller: _idNumberController,
            icon: Icons.credit_card,
            hint: 'Enter your ${_selectedIdType.toLowerCase()} number',
          ),
          const SizedBox(height: 24),
          
          // Photo upload sections
          Row(
            children: [
              Expanded(child: _buildPhotoUpload('Front Side', true, _idPhotoFrontTaken)),
              const SizedBox(width: 16),
              Expanded(child: _buildPhotoUpload('Back Side', false, _idPhotoBackTaken)),
            ],
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _idNumberController.text.isNotEmpty && 
                         _idPhotoFrontTaken && _idPhotoBackTaken ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA1AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stage Location',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your stage location details',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 32),
          
          _buildInputField(
            label: 'Stage Address/Location',
            controller: _stageLocationController,
            icon: Icons.location_on,
            hint: 'e.g., Near Central Market, Kampala',
          ),
          const SizedBox(height: 24),
          
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
              children: [
                Icon(
                  Icons.info,
                  size: 48,
                  color: Color(0xFF4CA1AF),
                ),
                const SizedBox(height: 16),
                const Text(
                  'GPS Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'GPS location capture will be available in the next update. For now, please provide your stage address above.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636E72),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _stageLocationController.text.isNotEmpty ? _completeOnboarding : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA1AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Color(0xFF4CA1AF).withOpacity(0.4),
              ),
              child: const Text(
                'Complete Registration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(color: Color(0xFFB2BEC3)),
                prefixIcon: Icon(icon, color: Color(0xFF4CA1AF)),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3436),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4CA1AF).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF4CA1AF) : Color(0xFFB0BEC5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Color(0xFF4CA1AF) : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Color(0xFF4CA1AF) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdTypeOption(String idType) {
    final isSelected = _selectedIdType == idType;
    return GestureDetector(
      onTap: () => setState(() => _selectedIdType = idType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4CA1AF).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF4CA1AF) : Color(0xFFB0BEC5),
          ),
        ),
        child: Text(
          idType,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Color(0xFF4CA1AF) : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPhotoUpload(String label, bool isFront, bool photoTaken) {
    return Column(
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
        GestureDetector(
          onTap: () => _takePhoto(isFront),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFB0BEC5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: photoTaken
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 32,
                        color: Color(0xFF4CA1AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Photo Taken',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CA1AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take Photo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}