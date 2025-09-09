import 'package:flutter/material.dart';

class AdminAccessWidget extends StatefulWidget {
  final Widget child;
  
  const AdminAccessWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AdminAccessWidget> createState() => _AdminAccessWidgetState();
}

class _AdminAccessWidgetState extends State<AdminAccessWidget> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    
    // Reset tap count if more than 2 seconds have passed
    if (_lastTapTime != null && now.difference(_lastTapTime!).inSeconds > 2) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTapTime = now;
    
    // If user taps 5 times in 2 seconds, show admin access
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showAdminAccess();
    }
  }

  void _showAdminAccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFF2C3E50)),
              SizedBox(width: 8),
              Text(
                'Admin Access',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text('Do you want to access the admin dashboard?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/admin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
              ),
              child: const Text(
                'Admin Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}