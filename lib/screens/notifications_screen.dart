import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      _initNotifications();
      _isLoaded = true;
    }
  }

  void _initNotifications() {
    final l10n = AppLocalizations.of(context)!;

    _notifications = [
      {
        'type': 'job',
        'title': l10n.notificationJobTitle,
        'body': l10n
            .notificationJobBody, // This is a bit tricky as the ARB contains the full text
        'time': l10n.time2MinsAgo,
        'isRead': false,
      },
      {
        'type': 'payment',
        'title': l10n.notificationPaymentTitle,
        'body': l10n.notificationPaymentBody,
        'time': l10n.time1HourAgo,
        'isRead': false,
      },
      {
        'type': 'system',
        'title': l10n.notificationSystemTitle,
        'body': l10n.notificationSystemBody,
        'time': l10n.timeYesterday,
        'isRead': true,
      },
      {
        'type': 'promo',
        'title': l10n.notificationPromoTitle,
        'body': l10n.notificationPromoBody,
        'time': l10n.time2DaysAgo,
        'isRead': true,
      },
      {
        'type': 'job',
        'title': l10n.notificationCancelledTitle,
        'body': l10n.notificationCancelledBody,
        'time': l10n.time3DaysAgo,
        'isRead': true,
      },
    ];
    _updateUnreadCount();
  }

  @override
  void initState() {
    super.initState();
  }

  void _updateUnreadCount() {
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    AppColors.unreadNotificationsNotifier.value = unreadCount;
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
    _updateUnreadCount();
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    _updateUnreadCount();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    _updateUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotifications,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 15,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.notifications,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                AppLocalizations.of(context)!.markAllAsRead,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(int index) {
    final notification = _notifications[index];
    final type = notification['type'];
    final isRead = notification['isRead'];

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'job':
        icon = Icons.work_outline;
        iconColor = AppColors.primaryOrangeStart;
        break;
      case 'payment':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = AppColors.successGreen;
        break;
      case 'system':
        icon = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      default:
        icon = Icons.local_offer_outlined;
        iconColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: isRead
          ? Colors.white
          : Colors.orange.shade50.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        if (value == 'read') {
                          _markAsRead(index);
                        } else if (value == 'delete') {
                          _deleteNotification(index);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (!isRead)
                          PopupMenuItem<String>(
                            value: 'read',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.markAllAsRead,
                                ),
                              ],
                            ),
                          ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.delete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['body'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
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
