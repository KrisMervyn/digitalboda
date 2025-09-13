import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'pending_approval_screen.dart';

class RiderOnboardingCompleteScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String experienceLevel;

  const RiderOnboardingCompleteScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.experienceLevel,
  }) : super(key: key);

  @override
  State<RiderOnboardingCompleteScreen> createState() => _RiderOnboardingCompleteScreenState();
}

class _RiderOnboardingCompleteScreenState extends State<RiderOnboardingCompleteScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Form controllers
  final _nationalIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Image files
  File? _profilePhoto;
  File? _nationalIdPhoto;
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _nationalIdController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfilePhoto) async {
    // Show dialog to choose camera or gallery
    final ImageSource? source = await _showImageSourceDialog(isProfilePhoto);
    if (source == null) return;
    
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        if (isProfilePhoto) {
          _profilePhoto = File(image.path);
        } else {
          _nationalIdPhoto = File(image.path);
        }
        _errorMessage = '';
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog(bool isProfilePhoto) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isProfilePhoto ? 'Profile Photo' : 'ID Document Photo'),
          content: Text(isProfilePhoto 
            ? 'Take a clear selfie or choose from gallery'
            : 'Take a photo of your ID document or choose from gallery'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Camera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Validate required fields
    if (_profilePhoto == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Profile photo is required';
      });
      return;
    }

    if (_nationalIdPhoto == null || _nationalIdController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'National ID photo and number are required';
      });
      return;
    }

    if (_ageController.text.isEmpty || _locationController.text.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Age and location are required';
      });
      return;
    }

    try {
      // Get Firebase token
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication error. Please try again.';
        });
        return;
      }
      
      String? firebaseToken = await user.getIdToken();
      if (firebaseToken == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication token error. Please try again.';
        });
        return;
      }
      
      // Submit onboarding data with photos
      Map<String, dynamic> result = await ApiService.submitOnboarding(
        phoneNumber: widget.phoneNumber,
        firebaseToken: firebaseToken,
        age: int.parse(_ageController.text),
        location: _locationController.text.trim(),
        nationalIdNumber: _nationalIdController.text.trim(),
        profilePhotoPath: _profilePhoto?.path,
        nationalIdPhotoPath: _nationalIdPhoto?.path,
      );
      
      if (result['success']) {
        // Success - navigate to pending approval screen
        String referenceNumber = result['data']['reference_number'] ?? 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        bool photoVerificationTriggered = result['data']['photo_verification_triggered'] ?? false;
        
        // Show photo verification feedback
        if (photoVerificationTriggered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Photos submitted and verification started!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PendingApprovalScreen(
              firstName: widget.firstName,
              lastName: widget.lastName,
              phoneNumber: widget.phoneNumber,
              referenceNumber: referenceNumber,
            ),
          ),
          (route) => false,
        );
      } else {
        String errorMessage = result['error'] ?? 'Submission failed. Please try again.';
        String? validationType = result['validation_error'];
        
        // Handle ID number mismatch specifically
        if (validationType == 'id_number_mismatch') {
          errorMessage = 'ID Number Mismatch!\n\n$errorMessage\n\nPlease check your ID document photo and the entered ID number.';
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Submission failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0 
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
              onPressed: _previousPage,
            )
          : null,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentPage 
                          ? Color(0xFF4CA1AF) 
                          : Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildProfilePhotoPage(),
                _buildDocumentPage(),
                _buildPersonalInfoPage(),
              ],
            ),
          ),
          
          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
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
          
          // Bottom Navigation
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_currentPage == 2 ? _submitOnboarding : _nextPage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CA1AF),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentPage == 2 ? 'Submit Application' : 'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.account_circle,
            size: 80,
            color: Color(0xFF4CA1AF),
          ),
          SizedBox(height: 24),
          Text(
            'Add Profile Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'This helps us identify you during the verification process',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          SizedBox(height: 40),
          
          // Profile Photo Preview/Upload
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(75),
                border: Border.all(
                  color: _profilePhoto != null ? Color(0xFF4CA1AF) : Color(0xFFE0E0E0),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _profilePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(72),
                    child: Image.file(
                      _profilePhoto!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Color(0xFF636E72),
                  ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            _profilePhoto != null ? 'Tap to change photo' : 'Tap to add photo',
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.credit_card,
            size: 80,
            color: Color(0xFF4CA1AF),
          ),
          SizedBox(height: 24),
          Text(
            'National ID Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'We need to verify your identity for security purposes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          SizedBox(height: 40),
          
          // National ID Number Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: TextFormField(
                controller: _nationalIdController,
                decoration: InputDecoration(
                  labelText: 'National ID Number',
                  hintText: 'Enter your national ID number',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.badge, color: Color(0xFF4CA1AF), size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // National ID Photo Upload
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _nationalIdPhoto != null ? Color(0xFF4CA1AF) : Color(0xFFE0E0E0),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _nationalIdPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _nationalIdPhoto!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Color(0xFF636E72),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Take photo of National ID',
                        style: TextStyle(
                          color: Color(0xFF636E72),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 40),
          Icon(
            Icons.person_pin_circle,
            size: 80,
            color: Color(0xFF4CA1AF),
          ),
          SizedBox(height: 24),
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Help us know you better with some basic information',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF636E72),
            ),
          ),
          SizedBox(height: 40),
          
          // Age Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter your age',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF4CA1AF), size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Location Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter your location/area',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on, color: Color(0xFF4CA1AF), size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF2D3436)),
              ),
            ),
          ),
          SizedBox(height: 40),
          
          // Summary Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4CA1AF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF4CA1AF).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                SizedBox(height: 12),
                Text('Name: ${widget.firstName} ${widget.lastName}'),
                Text('Phone: ${widget.phoneNumber}'),
                Text('Experience: ${widget.experienceLevel}'),
                SizedBox(height: 8),
                Text(
                  'After submitting, your application will be reviewed by our team. You\'ll receive a notification once approved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF636E72),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}