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
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.03).clamp(11.0, 14.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, paddingScale, titleFontSize, smallFontSize),
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState(paddingScale, bodyFontSize)
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.shade100,
                        indent: 70 * paddingScale,
                      ),
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(
                          index,
                          paddingScale,
                          bodyFontSize,
                          smallFontSize,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double paddingScale, double bodyFontSize) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 100 * paddingScale),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * paddingScale),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: (64 * paddingScale).clamp(48.0, 80.0),
                color: Colors.grey[300],
              ),
            ),
            SizedBox(height: 24 * paddingScale),
            Text(
              AppLocalizations.of(context)!.noNotifications,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: bodyFontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double paddingScale,
    double titleFontSize,
    double smallFontSize,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (10 * paddingScale),
        left: 10 * paddingScale,
        right: 16 * paddingScale,
        bottom: 15 * paddingScale,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: (20 * paddingScale).clamp(18.0, 24.0),
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.notifications,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12 * paddingScale),
              ),
              child: Text(
                AppLocalizations.of(context)!.markAllAsRead,
                style: TextStyle(color: Colors.white, fontSize: smallFontSize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    int index,
    double paddingScale,
    double bodyFontSize,
    double smallFontSize,
  ) {
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

    return InkWell(
      onTap: () => _markAsRead(index),
      child: Container(
        padding: EdgeInsets.all(16 * paddingScale),
        color: isRead
            ? Colors.white
            : Colors.orange.shade50.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10 * paddingScale),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: (20 * paddingScale).clamp(18.0, 24.0),
              ),
            ),
            SizedBox(width: 16 * paddingScale),
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
                            fontSize: bodyFontSize,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: smallFontSize - 1,
                        ),
                      ),
                      SizedBox(width: 4 * paddingScale),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: (18 * paddingScale).clamp(16.0, 22.0),
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
                                  Icon(
                                    Icons.mark_email_read_outlined,
                                    size: (18 * paddingScale).clamp(16.0, 22.0),
                                  ),
                                  SizedBox(width: 8 * paddingScale),
                                  Text(
                                    AppLocalizations.of(context)!.markAllAsRead,
                                    style: TextStyle(fontSize: smallFontSize),
                                  ),
                                ],
                              ),
                            ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: (18 * paddingScale).clamp(16.0, 22.0),
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8 * paddingScale),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: smallFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4 * paddingScale),
                  Text(
                    notification['body'],
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: bodyFontSize - 1,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
