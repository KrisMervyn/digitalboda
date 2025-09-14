import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/digital_literacy_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedPeriod = 'all_time';
  
  List<Map<String, dynamic>> _leaderboardData = [];
  List<Map<String, dynamic>> _achievements = [];
  Map<String, dynamic>? _userRank;
  int _totalParticipants = 0;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockLeaderboard = [
    {
      'rank': 1,
      'rider_name': 'John Mukasa',
      'total_points': 1250,
      'completed_modules': 4,
      'attendance_rate': 95,
      'avatar': '🏆',
    },
    {
      'rank': 2,
      'rider_name': 'Sarah Nakato',
      'total_points': 1180,
      'completed_modules': 4,
      'attendance_rate': 92,
      'avatar': '🥈',
    },
    {
      'rank': 3,
      'rider_name': 'David Ssentongo',
      'total_points': 1050,
      'completed_modules': 3,
      'attendance_rate': 88,
      'avatar': '🥉',
    },
    {
      'rank': 4,
      'rider_name': 'Grace Namuli',
      'total_points': 980,
      'completed_modules': 3,
      'attendance_rate': 85,
      'avatar': '👤',
    },
    {
      'rank': 5,
      'rider_name': 'James Okello',
      'total_points': 920,
      'completed_modules': 3,
      'attendance_rate': 80,
      'avatar': '👤',
    },
    {
      'rank': 6,
      'rider_name': 'Mary Achieng',
      'total_points': 850,
      'completed_modules': 2,
      'attendance_rate': 75,
      'avatar': '👤',
    },
    {
      'rank': 7,
      'rider_name': 'Paul Wamala',
      'total_points': 780,
      'completed_modules': 2,
      'attendance_rate': 70,
      'avatar': '👤',
    },
    {
      'rank': 8,
      'rider_name': 'You (Demo)',
      'total_points': 720,
      'completed_modules': 2,
      'attendance_rate': 65,
      'avatar': '👤',
      'is_current_user': true,
    },
  ];

  final List<Map<String, dynamic>> _mockAchievements = [
    {
      'id': 1,
      'title': 'First Steps',
      'description': 'Complete your first training session',
      'icon': '👶',
      'category': 'attendance',
      'earned': true,
      'earned_date': '2024-01-15',
    },
    {
      'id': 2,
      'title': 'Module Master',
      'description': 'Complete all sessions in a module',
      'icon': '🎓',
      'category': 'completion',
      'earned': true,
      'earned_date': '2024-01-20',
    },
    {
      'id': 3,
      'title': 'Perfect Attendance',
      'description': 'Attend 10 consecutive sessions',
      'icon': '⭐',
      'category': 'attendance',
      'earned': true,
      'earned_date': '2024-02-01',
    },
    {
      'id': 4,
      'title': 'Knowledge Seeker',
      'description': 'Complete 2 training modules',
      'icon': '📚',
      'category': 'completion',
      'earned': true,
      'earned_date': '2024-02-10',
    },
    {
      'id': 5,
      'title': 'Digital Expert',
      'description': 'Complete all 4 training modules',
      'icon': '🏆',
      'category': 'completion',
      'earned': false,
    },
    {
      'id': 6,
      'title': 'Top Performer',
      'description': 'Reach the top 10 on leaderboard',
      'icon': '🌟',
      'category': 'ranking',
      'earned': false,
    },
    {
      'id': 7,
      'title': 'Community Helper',
      'description': 'Help 5 other riders with training',
      'icon': '🤝',
      'category': 'social',
      'earned': false,
    },
    {
      'id': 8,
      'title': 'Champion',
      'description': 'Reach #1 on the leaderboard',
      'icon': '👑',
      'category': 'ranking',
      'earned': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // For demo purposes, use mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _leaderboardData = _mockLeaderboard;
        _achievements = _mockAchievements;
        _totalParticipants = _mockLeaderboard.length;
        _userRank = _mockLeaderboard.firstWhere(
          (rider) => rider['is_current_user'] == true,
          orElse: () => {'rank': 0},
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load leaderboard data: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadLeaderboardData();
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: const Color(0xFF2C3E50),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: '🏆 Rankings'),
                  Tab(text: '🏅 Achievements'),
                ],
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardTab(),
                  _buildAchievementsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading rankings...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Load Rankings',
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
                onPressed: _refreshData,
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
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(),
            
            const SizedBox(height: 20),
            
            // Current user rank card
            if (_userRank != null && _userRank!['rank'] > 0)
              _buildCurrentUserRankCard(),
            
            const SizedBox(height: 20),
            
            // Top 3 podium
            if (_leaderboardData.length >= 3) _buildPodium(),
            
            const SizedBox(height: 24),
            
            // Full rankings list
            const Text(
              'Full Rankings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._leaderboardData.map((rider) => _buildRankingCard(rider)).toList(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final earnedAchievements = _achievements.where((a) => a['earned'] == true).toList();
    final availableAchievements = _achievements.where((a) => a['earned'] == false).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement stats
          _buildAchievementStats(earnedAchievements.length, _achievements.length),
          
          const SizedBox(height: 24),
          
          // Earned achievements
          if (earnedAchievements.isNotEmpty) ...[
            const Text(
              'Earned Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...earnedAchievements.map((achievement) => 
              _buildAchievementCard(achievement, true)).toList(),
            const SizedBox(height: 24),
          ],
          
          // Available achievements
          if (availableAchievements.isNotEmpty) ...[
            const Text(
              'Available Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...availableAchievements.map((achievement) => 
              _buildAchievementCard(achievement, false)).toList(),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('Weekly', 'weekly'),
          _buildPeriodButton('Monthly', 'monthly'),
          _buildPeriodButton('All Time', 'all_time'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String title, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => _changePeriod(period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentUserRankCard() {
    final userRank = _userRank!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CA1AF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '#${userRank['rank']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Current Rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${userRank['total_points']} points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'out of $_totalParticipants riders',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _leaderboardData.take(3).toList();
    
    return Container(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (top3.length > 1)
            Expanded(child: _buildPodiumPosition(top3[1], 2, 140, Colors.grey.shade400)),
          
          const SizedBox(width: 8),
          
          // 1st place  
          if (top3.isNotEmpty)
            Expanded(child: _buildPodiumPosition(top3[0], 1, 180, Colors.amber)),
          
          const SizedBox(width: 8),
          
          // 3rd place
          if (top3.length > 2)
            Expanded(child: _buildPodiumPosition(top3[2], 3, 120, Colors.orange.shade400)),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(Map<String, dynamic> rider, int position, double height, Color color) {
    String medal = '';
    switch (position) {
      case 1:
        medal = '🏆';
        break;
      case 2:
        medal = '🥈';
        break;
      case 3:
        medal = '🥉';
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          medal,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#$position',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rider['rider_name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${rider['total_points']} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> rider) {
    final isCurrentUser = rider['is_current_user'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF4CA1AF).withOpacity(0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser 
            ? Border.all(color: const Color(0xFF4CA1AF), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(rider['rank']),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '#${rider['rank']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Rider info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rider['rider_name'] ?? 'Unknown Rider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? Colors.white : const Color(0xFF2C3E50),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '(You)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip(
                      '${rider['total_points']} pts',
                      Colors.orange,
                      isCurrentUser,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      '${rider['completed_modules']}/4 modules',
                      Colors.blue,
                      isCurrentUser,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Attendance rate
          Column(
            children: [
              Text(
                '${rider['attendance_rate']}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? Colors.white : const Color(0xFF2C3E50),
                ),
              ),
              Text(
                'attendance',
                style: TextStyle(
                  fontSize: 12,
                  color: isCurrentUser ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, Color color, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Colors.white.withOpacity(0.2)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCurrentUser ? Colors.white : color,
        ),
      ),
    );
  }

  Widget _buildAchievementStats(int earned, int total) {
    final percentage = total > 0 ? (earned / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Achievement Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$earned of $total achievements earned',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, bool earned) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned 
            ? Colors.white
            : Colors.white.withOpacity(0.5),
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
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: earned 
                  ? _getCategoryColor(achievement['category'])
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                achievement['icon'] ?? '🏅',
                style: TextStyle(
                  fontSize: 24,
                  color: earned ? null : Colors.grey,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? 'Achievement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: earned 
                        ? const Color(0xFF2C3E50)
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: earned ? Colors.grey : Colors.grey.shade400,
                  ),
                ),
                if (earned && achievement['earned_date'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Earned on ${achievement['earned_date']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Status icon
          Icon(
            earned ? Icons.check_circle : Icons.radio_button_unchecked,
            color: earned ? Colors.green : Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.orange.shade400;
      default:
        return const Color(0xFF4CA1AF);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'attendance':
        return Colors.blue;
      case 'completion':
        return Colors.green;
      case 'ranking':
        return Colors.amber;
      case 'social':
        return Colors.purple;
      default:
        return const Color(0xFF4CA1AF);
    }
  }
}