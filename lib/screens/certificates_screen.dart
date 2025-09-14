import 'package:flutter/material.dart';
import '../services/digital_literacy_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  List<Map<String, dynamic>> _certificates = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Mock phone number - in real app this would come from authentication
  final String _phoneNumber = '+256700000000';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCertificates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Using mock data for now - replace with real API when ready
      final result = await DigitalLiteracyService.getMockCertificates();
      
      if (result['success']) {
        setState(() {
          _certificates = List<Map<String, dynamic>>.from(result['data']);
          _stats = {
            'total_certificates': result['total_certificates'],
            'earned_certificates': result['earned_certificates'],
            'total_points_earned': result['total_points_earned'],
            'completion_rate': result['completion_rate'],
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load certificates';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _earnedCertificates {
    return _certificates.where((cert) => cert['is_earned'] == true).toList();
  }

  List<Map<String, dynamic>> get _availableCertificates {
    return _certificates.where((cert) => cert['is_earned'] == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          ),
        ),
        child: _isLoading 
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty 
            ? _buildErrorState()
            : _buildCertificatesContent(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2C3E50),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Row(
        children: [
          Icon(Icons.workspace_premium, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Certificates & Badges',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadCertificates,
          tooltip: 'Refresh',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
          Tab(text: 'Earned', icon: Icon(Icons.star)),
          Tab(text: 'Available', icon: Icon(Icons.lock_outline)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Loading certificates...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCertificates,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildEarnedTab(),
        _buildAvailableTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          _buildStatsCards(),
          
          const SizedBox(height: 24),
          
          // Recent achievements
          const Text(
            'Recent Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._earnedCertificates.take(3).map((cert) => _buildCertificateCard(cert, isCompact: true)),
          
          if (_earnedCertificates.length > 3) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () => _tabController.animateTo(1),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.star),
                label: Text('View All ${_earnedCertificates.length} Certificates'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Progress section
          const Text(
            'Progress Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildEarnedTab() {
    if (_earnedCertificates.isEmpty) {
      return _buildEmptyEarnedState();
    }

    return RefreshIndicator(
      onRefresh: _loadCertificates,
      color: const Color(0xFF4CA1AF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _earnedCertificates.length,
        itemBuilder: (context, index) {
          final certificate = _earnedCertificates[index];
          return _buildCertificateCard(certificate);
        },
      ),
    );
  }

  Widget _buildAvailableTab() {
    if (_availableCertificates.isEmpty) {
      return _buildEmptyAvailableState();
    }

    return RefreshIndicator(
      onRefresh: _loadCertificates,
      color: const Color(0xFF4CA1AF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableCertificates.length,
        itemBuilder: (context, index) {
          final certificate = _availableCertificates[index];
          return _buildCertificateCard(certificate);
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Earned',
            '${_stats['earned_certificates'] ?? 0}',
            Icons.star,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Points',
            '${_stats['total_points_earned'] ?? 0}',
            Icons.stars,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completion',
            '${_stats['completion_rate'] ?? 0}%',
            Icons.trending_up,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Journey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: (_stats['completion_rate'] ?? 0) / 100,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CA1AF)),
            minHeight: 8,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${_stats['earned_certificates'] ?? 0} of ${_stats['total_certificates'] ?? 0} certificates earned',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem('Marketing', _getProgressByCategory('Marketing')),
              _buildProgressItem('Finance', _getProgressByCategory('Finance')),
              _buildProgressItem('Technology', _getProgressByCategory('Technology')),
              _buildProgressItem('Business', _getProgressByCategory('Business')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String category, double progress) {
    final categoryInfo = DigitalLiteracyService.getCategoryInfo(category);
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 6,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Color(categoryInfo['color'])),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  categoryInfo['icon'],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          category,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          '${progress.round()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(categoryInfo['color']),
          ),
        ),
      ],
    );
  }

  double _getProgressByCategory(String category) {
    final categoryBadges = _certificates.where((cert) => cert['category'] == category).toList();
    if (categoryBadges.isEmpty) return 0;
    
    final earnedCount = categoryBadges.where((cert) => cert['is_earned']).length;
    return (earnedCount / categoryBadges.length * 100);
  }

  Widget _buildCertificateCard(Map<String, dynamic> certificate, {bool isCompact = false}) {
    final skillInfo = DigitalLiteracyService.getSkillLevelInfo(certificate['skill_level'] ?? 'BEGINNER');
    final categoryInfo = DigitalLiteracyService.getCategoryInfo(certificate['category'] ?? '');
    final isEarned = certificate['is_earned'] ?? false;
    final progress = certificate['progress'] ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEarned ? Border.all(color: Color(certificate['badge_color'] ?? 0xFF4CA1AF), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: isEarned ? 12 : 8,
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
                // Badge/Icon
                Container(
                  width: isCompact ? 50 : 60,
                  height: isCompact ? 50 : 60,
                  decoration: BoxDecoration(
                    color: isEarned 
                      ? Color(certificate['badge_color'] ?? 0xFF4CA1AF)
                      : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      certificate['icon'] ?? '🏆',
                      style: TextStyle(fontSize: isCompact ? 24 : 30),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Certificate info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              certificate['title'] ?? 'Certificate',
                              style: TextStyle(
                                fontSize: isCompact ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (isEarned) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.verified, color: Colors.green, size: 20),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(categoryInfo['color']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              categoryInfo['label'],
                              style: TextStyle(
                                color: Color(categoryInfo['color']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    ],
                  ),
                ),
              ],
            ),
            
            if (!isCompact) ...[
              const SizedBox(height: 12),
              
              Text(
                certificate['description'] ?? 'Certificate description not available.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              if (isEarned) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earned: ${DigitalLiteracyService.formatDate(certificate['earned_date'] ?? '')}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            'Certificate #${certificate['certificate_number'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4CA1AF)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '+${certificate['points_earned']} pts',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${certificate['sessions_completed']}/${certificate['total_sessions']} sessions',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CA1AF)),
                            minHeight: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$progress%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CA1AF),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEarnedState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 80,
            color: Colors.white54,
          ),
          SizedBox(height: 24),
          Text(
            'No Certificates Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Complete training sessions to earn\nyour first certificate!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAvailableState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Colors.white54,
          ),
          SizedBox(height: 24),
          Text(
            'All Certificates Earned!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Congratulations! You\'ve completed all\navailable certificates.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}