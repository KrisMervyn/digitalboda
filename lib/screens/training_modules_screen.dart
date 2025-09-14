import 'package:flutter/material.dart';
import '../services/digital_literacy_service.dart';
import 'session_detail_screen.dart';

class TrainingModulesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> modules;
  final Map<String, dynamic>? riderProgress;
  final int? selectedModuleId;

  const TrainingModulesScreen({
    Key? key,
    required this.modules,
    this.riderProgress,
    this.selectedModuleId,
  }) : super(key: key);

  @override
  State<TrainingModulesScreen> createState() => _TrainingModulesScreenState();
}

class _TrainingModulesScreenState extends State<TrainingModulesScreen> {
  late PageController _pageController;
  int _currentModuleIndex = 0;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // If a specific module was selected, scroll to it
    if (widget.selectedModuleId != null) {
      final index = widget.modules.indexWhere(
        (module) => module['id'] == widget.selectedModuleId
      );
      if (index != -1) {
        _currentModuleIndex = index;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentModuleIndex = index;
    });
  }

  void _navigateToSessionDetail(Map<String, dynamic> session, Map<String, dynamic> module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          session: session,
          schedule: null, // TODO: Add schedule data from upcoming sessions
          moduleTitle: module['title'] ?? 'Training Module',
          moduleIcon: module['icon'] ?? '📚',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.modules.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ),
        ),
        child: Column(
          children: [
            // Module indicator dots
            _buildModuleIndicator(),
            
            // Module content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.modules.length,
                itemBuilder: (context, index) {
                  final module = widget.modules[index];
                  return _buildModuleContent(module);
                },
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 24),
            Text(
              'No Training Modules Available',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Training modules will be available soon.\nCheck back later!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.modules.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: index == _currentModuleIndex ? 24 : 8,
            decoration: BoxDecoration(
              color: index == _currentModuleIndex 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleContent(Map<String, dynamic> module) {
    final skillInfo = DigitalLiteracyService.getSkillLevelInfo(module['skill_level'] ?? 'BEGINNER');
    final sessions = List<Map<String, dynamic>>.from(module['sessions'] ?? []);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module header card
          Container(
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
                      module['icon'] ?? '📚',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module['title'] ?? 'Training Module',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(skillInfo['color']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skillInfo['label'],
                              style: TextStyle(
                                color: Color(skillInfo['color']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  module['description'] ?? 'Module description not available.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.schedule,
                      '${module['total_duration_hours'] ?? 0}hrs',
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.book,
                      '${sessions.length} sessions',
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.star,
                      '${module['points_value'] ?? 0} pts',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sessions section
          const Text(
            'Training Sessions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...sessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;
            return _buildSessionCard(session, index + 1, module);
          }).toList(),
          
          const SizedBox(height: 32),
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

  Widget _buildSessionCard(Map<String, dynamic> session, int sessionNumber, Map<String, dynamic> module) {
    final objectives = List<String>.from(session['learning_objectives'] ?? []);
    final materials = List<String>.from(session['required_materials'] ?? []);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4CA1AF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$sessionNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          session['title'] ?? 'Session $sessionNumber',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              session['description'] ?? 'Session description not available.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  Icons.access_time,
                  '${session['duration_hours'] ?? 0}h',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.star_outline,
                  '${session['points_value'] ?? 0} pts',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (objectives.isNotEmpty) ...[
                  const Text(
                    'Learning Objectives:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...objectives.map((objective) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFF4CA1AF))),
                        Expanded(
                          child: Text(
                            objective,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 16),
                ],
                
                if (materials.isNotEmpty) ...[
                  const Text(
                    'Required Materials:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...materials.map((material) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, 
                               size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            material,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                  const SizedBox(height: 16),
                ],
                
                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToSessionDetail(session, module),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CA1AF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details & Register'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: _currentModuleIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          
          // Module counter
          Text(
            '${_currentModuleIndex + 1} of ${widget.modules.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: _currentModuleIndex < widget.modules.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}