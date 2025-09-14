import 'package:flutter/material.dart';
import '../services/digital_literacy_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'all';
  
  // Mock phone number - in real app this would come from authentication
  final String _phoneNumber = '+256700000000';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Using mock data for now - replace with real API when ready
      final result = await DigitalLiteracyService.getMockNotifications();
      
      if (result['success']) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(result['data']);
          _unreadCount = result['unread_count'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load notifications';
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

  Future<void> _markAsRead(int notificationId) async {
    // Find and update the notification locally
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1 && !_notifications[index]['is_read']) {
        _notifications[index]['is_read'] = true;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
    });

    // In real app, call API to mark as read
    // await DigitalLiteracyService.markNotificationRead(notificationId);
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['is_read'] = true;
      }
      _unreadCount = 0;
    });

    // In real app, call API to mark all as read
    // await DigitalLiteracyService.markAllNotificationsRead(_phoneNumber);
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return _notifications;
    } else if (_selectedFilter == 'unread') {
      return _notifications.where((n) => !n['is_read']).toList();
    } else {
      return _notifications.where((n) => n['type'] == _selectedFilter).toList();
    }
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
            : _buildNotificationsList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2C3E50),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_unreadCount > 0)
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadNotifications,
          tooltip: 'Refresh',
        ),
      ],
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
            'Loading notifications...',
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
            onPressed: _loadNotifications,
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

  Widget _buildNotificationsList() {
    final filteredNotifications = _filteredNotifications;

    return Column(
      children: [
        // Filter tabs
        _buildFilterTabs(),
        
        // Notifications list
        Expanded(
          child: filteredNotifications.isEmpty 
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: const Color(0xFF4CA1AF),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = filteredNotifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All', 'count': _notifications.length},
      {'key': 'unread', 'label': 'Unread', 'count': _unreadCount},
      {'key': 'session_reminder', 'label': 'Reminders', 'count': _notifications.where((n) => n['type'] == 'session_reminder').length},
      {'key': 'achievement', 'label': 'Achievements', 'count': _notifications.where((n) => n['type'] == 'achievement').length},
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter['key'].toString();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter['label'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (filter['count'] != 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        filter['count'].toString(),
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF2C3E50) : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'unread' 
              ? Icons.mark_email_read_outlined
              : Icons.notifications_none,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'unread' 
              ? 'All caught up!' 
              : 'No notifications yet',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'unread' 
              ? 'You\'ve read all your notifications.' 
              : 'Notifications will appear here when you have them.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final priorityInfo = DigitalLiteracyService.getNotificationPriorityInfo(notification['priority'] ?? 'low');
    final isRead = notification['is_read'] ?? false;
    final relativeTime = DigitalLiteracyService.formatRelativeTime(notification['timestamp'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead 
          ? Colors.white.withOpacity(0.95)
          : Color(priorityInfo['backgroundColor']),
        borderRadius: BorderRadius.circular(12),
        border: isRead 
          ? null
          : Border.all(
              color: Color(priorityInfo['borderColor']).withOpacity(0.3),
              width: 1,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _markAsRead(notification['id']),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isRead 
                          ? const Color(0xFF4CA1AF)
                          : Color(priorityInfo['color']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          notification['icon'] ?? '📱',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Notification content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isRead ? Colors.black : Color(priorityInfo['color']),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Color(priorityInfo['color']),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            notification['message'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Footer with type and time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRead 
                          ? const Color(0xFF4CA1AF).withOpacity(0.1)
                          : Color(priorityInfo['color']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getNotificationTypeLabel(notification['type'] ?? ''),
                        style: TextStyle(
                          color: isRead ? const Color(0xFF4CA1AF) : Color(priorityInfo['color']),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    Text(
                      relativeTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNotificationTypeLabel(String type) {
    switch (type) {
      case 'session_reminder':
        return 'Session Reminder';
      case 'achievement':
        return 'Achievement';
      case 'training_update':
        return 'Training Update';
      case 'leaderboard':
        return 'Leaderboard';
      case 'completion':
        return 'Completion';
      case 'general':
        return 'General';
      default:
        return 'Notification';
    }
  }
}