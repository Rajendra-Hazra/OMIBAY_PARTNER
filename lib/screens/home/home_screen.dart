import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../widgets/incoming_job_modal.dart';
import '../../widgets/order_otp_dialog.dart';
import '../../widgets/pause_order_dialog.dart';
import '../../widgets/complete_order_dialog.dart';
import '../../core/app_colors.dart';
import '../../services/wallet_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../repositories/partner_service_repository.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/earnings_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../models/earnings_stats.dart';
// import '../../services/notification_service.dart';
import '../../services/location_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isOnline = false;
  String _displayName = '';
  String _photoUrl = 'https://via.placeholder.com/150';
  String _rating = '0.0';
  String _todayRating = '0.0';
  double _todayBusiness = 0.0;
  int _todayJobsDone = 0;
  Timer? _onlineTimer;
  int _onlineSeconds = 0;
  bool _isInitialLoad = true;
  List<Map<String, dynamic>> _activeJobs = [];
  // Weekly Bonus State (same as earnings screen)
  WeeklyBonus? _weeklyBonus;

  late final PartnerServiceRepository _partnerRepository;
  late final OrderRepository _orderRepository;
  late final EarningsRepository _earningsRepository;
  late final NotificationRepository _notificationRepository;
  // StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  // Location tracking
  String _currentLocation = 'Detecting location...';
  Position? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _partnerRepository = PartnerServiceRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _orderRepository = OrderRepositoryImpl(baseUrl: ApiEndpoints.baseUrl);
    _earningsRepository = EarningsRepository(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    _notificationRepository = NotificationRepository(
      ApiClient(baseUrl: ApiEndpoints.baseUrl),
    );
    WidgetsBinding.instance.addObserver(this);
    _loadProfileData();
    _loadActiveJob();
    _loadOnlineStatus();
    _loadWeeklyBonus(); // Load weekly bonus from earnings API
    _loadUnreadNotificationsCount(); // Load unread notifications count
    // Listen for global profile updates
    AppColors.profileUpdateNotifier.addListener(_loadProfileData);
    AppColors.jobUpdateNotifier.addListener(_loadActiveJob);
    AppColors.jobUpdateNotifier.addListener(_loadProfileData);
    // Listen for incoming order notifications - MOVED TO MainNavigationWrapper
    // _setupNotificationListener();
    // Request location permission and get current location
    _initializeLocation();
  }

  // Refactored to fetch status & stats from backend
  Future<void> _loadOnlineStatus() async {
    try {
      final status = await _partnerRepository.getPartnerStatus();

      if (status != null) {
        if (mounted) {
          setState(() {
            _isOnline = status.isOnline;
            _rating = status.rating.toStringAsFixed(1);
            _todayBusiness = status.todayEarnings;
            _todayJobsDone = status.todayJobs;
          });
        }

        if (status.isOnline) {
          // Catch up on time if the app was killed while online
          await _catchUpOnlineTime();
          _startOnlineTimer();
        }
      } else {
        // Fallback to local storage if API fails
        final prefs = await SharedPreferences.getInstance();
        final savedIsOnline = prefs.getBool('partner_is_online') ?? false;

        if (mounted) {
          setState(() {
            _isOnline = savedIsOnline;
          });
        }

        if (savedIsOnline) {
          await _catchUpOnlineTime();
          _startOnlineTimer();
        }
      }

      // After loading, wait for one frame then enable animations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialLoad = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error loading online status: $e');
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    }
  }

  // ... (Keep existing _saveOnlineStatus, timers, etc.)

  // Load weekly bonus from earnings API (same as earnings screen)
  Future<void> _loadWeeklyBonus() async {
    try {
      final stats = await _earningsRepository.getEarningsStats();
      if (mounted) {
        setState(() {
          _weeklyBonus = stats.weeklyBonus; // Can be null if no data
        });
      }
    } catch (e) {
      debugPrint('Error loading weekly bonus: $e');
      // Set to null on error to hide the card
      if (mounted) {
        setState(() {
          _weeklyBonus = null;
        });
      }
    }
  }

  // Load unread notifications count
  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      AppColors.unreadNotificationsNotifier.value = unreadCount;
    } catch (e) {
      debugPrint('Error loading unread notifications count: $e');
      // Set to 0 on error
      AppColors.unreadNotificationsNotifier.value = 0;
    }
  }

  // Weekly Bonus Card - Same as earnings screen
  Widget _buildBonusCard(double borderRadius, double fontSize) {
    final l10n = AppLocalizations.of(context)!;

    // Always show card, use default values if API returns null
    final bonus =
        _weeklyBonus ??
        WeeklyBonus(
          title: 'Weekly Bonus',
          subtitle: 'Complete jobs to earn bonus',
          targetJobs: 15,
          completedJobs: 0,
          rewardAmount: 200.0,
          isCompleted: false,
          endsIn: 'This week',
        );

    double progress = (bonus.completedJobs / bonus.targetJobs).clamp(0.0, 1.0);
    bool isComplete = bonus.isCompleted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E293B), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background elements
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars,
              size: 120,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeStart.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryOrangeStart.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryOrangeStart,
                        size: fontSize * 1.5,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bonus.title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: fontSize,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            bonus.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: fontSize * 0.75,
                            ),
                          ),
                          Text(
                            bonus.endsIn.isNotEmpty
                                ? 'Ends in ${bonus.endsIn}'
                                : '',
                            style: TextStyle(
                              color: AppColors.primaryOrangeStart,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 0.75,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: fontSize * 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.jobsDoneWithProgress(
                        LocalizationHelper.convertBengaliToEnglish(
                          bonus.completedJobs,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 0.85,
                      ),
                    ),
                    Text(
                      'Goal: ${LocalizationHelper.convertBengaliToEnglish(bonus.targetJobs)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: fontSize * 0.75,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            height: 12,
                            width: constraints.maxWidth * progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryOrangeStart,
                                  Color(0xFFFFB800),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryOrangeStart
                                      .withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.redeem,
                        color: Colors.greenAccent,
                        size: fontSize * 1.25,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n
                            .potentialEarnings('')
                            .replaceAll(l10n.currencySymbol, '')
                            .trim(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: fontSize * 0.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${l10n.currencySymbol}${LocalizationHelper.convertBengaliToEnglish(bonus.rewardAmount.toInt().toString())}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Notification listeners and handlers moved to MainNavigationWrapper to prevent duplicates

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppColors.profileUpdateNotifier.removeListener(_loadProfileData);
    AppColors.jobUpdateNotifier.removeListener(_loadActiveJob);
    _onlineTimer?.cancel();
    _saveOnlineTime();
    super.dispose();
  }

  /// Show toast message
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Initialize location service
  Future<void> _initializeLocation() async {
    try {
      // Try to get saved location first
      final savedAddress = await LocationService.instance.getSavedAddress();
      if (savedAddress != null) {
        setState(() {
          _currentLocation = savedAddress;
          _isLoadingLocation = false;
        });
      }

      // Request permission
      bool hasPermission = await LocationService.instance.requestPermission();
      if (!hasPermission) {
        setState(() {
          _currentLocation = 'Location permission denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current location
      Position? position = await LocationService.instance.getCurrentLocation();
      if (position != null) {
        _currentPosition = position;

        // Get address from coordinates
        String? address = await LocationService.instance
            .getAddressFromCoordinates(position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            _currentLocation = address ?? 'Location detected';
            _isLoadingLocation = false;
          });
        }
      } else {
        setState(() {
          _currentLocation = 'Unable to detect location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing location: $e');
      setState(() {
        _currentLocation = 'Location error';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      _catchUpOnlineTime();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App went to background
      _saveLastActiveTime();
    }
  }

  Future<void> _saveLastActiveTime() async {
    if (_isOnline) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_online_tick',
        DateTime.now().millisecondsSinceEpoch,
      );
      await _saveOnlineTime();
    }
  }

  Future<void> _catchUpOnlineTime() async {
    if (_isOnline) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastTick = prefs.getInt('last_online_tick');
        if (lastTick != null) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final diffSeconds = ((now - lastTick) / 1000).floor();
          if (diffSeconds > 0) {
            setState(() {
              _onlineSeconds += diffSeconds;
            });
            await _saveOnlineTime();
          }
          // Clear the last tick so we don't double count
          await prefs.remove('last_online_tick');
        }
      } catch (e) {
        debugPrint('Error catching up online time: $e');
      }
      // Restart timer if needed
      _startOnlineTimer();
    }
  }

  Future<void> _loadActiveJob() async {
    try {
      // Load active jobs from backend API instead of local storage
      final jobs = await _orderRepository.getActiveOrders();
      setState(() {
        _activeJobs = jobs;
      });
      debugPrint('✅ Loaded ${jobs.length} active jobs from backend');
    } catch (e) {
      debugPrint('Error loading active jobs from backend: $e');
      // Fallback: try to load from local storage if backend fails
      try {
        final localJobs = await WalletService.getActiveJobs();
        setState(() {
          _activeJobs = localJobs;
        });
        debugPrint(
          '⚠️ Loaded ${localJobs.length} jobs from local storage (fallback)',
        );
      } catch (e2) {
        debugPrint('Error loading from local storage: $e2');
      }
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final savedName = prefs.getString('profile_name');
      final savedPhotoPath =
          prefs.getString('profile_photo_path') ??
          prefs.getString('profile_local_photo');
      final savedRating = prefs.getString('profile_rating');
      final savedTodayRating = prefs.getString('today_rating');
      final savedCity = prefs.getString('location_city');
      final savedTodayBusiness = prefs.getDouble('today_business') ?? 0.0;
      final savedTodayJobsDone = prefs.getInt('today_jobs_done') ?? 0;
      final savedOnlineSeconds = prefs.getInt('today_online_seconds') ?? 0;

      debugPrint('Loading profile - savedName: $savedName');

      setState(() {
        if (savedName != null && savedName.isNotEmpty) {
          // Check if the name is actually a phone number
          final cleanedName = savedName.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
          final isPhoneNumber = RegExp(r'^(91)?\d{10}$').hasMatch(cleanedName);

          debugPrint(
            'Phone check - cleaned: $cleanedName, isPhone: $isPhoneNumber',
          );

          if (isPhoneNumber) {
            // Show "Partner" instead of phone number
            _displayName = 'Partner';
            debugPrint('Showing Partner (phone detected)');
          } else {
            // Show only first name - DON'T use LocalizationHelper, extract directly
            _displayName = savedName.trim().split(' ').first;
            debugPrint('Showing name: $_displayName');
          }
        } else {
          // If no name saved, show Partner
          _displayName = 'Partner';
          debugPrint('No name saved, showing Partner');
        }
        if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
          _photoUrl = savedPhotoPath;
        }
        if (savedRating != null && savedRating.isNotEmpty) {
          _rating = savedRating;
        } else {
          _rating = '0.0';
        }
        if (savedTodayRating != null && savedTodayRating.isNotEmpty) {
          _todayRating = savedTodayRating;
        } else {
          _todayRating = '0.0';
        }
        // Note: Removed _locationCity as it's replaced by _currentLocation from LocationService
        _todayBusiness = savedTodayBusiness;
        _todayJobsDone = savedTodayJobsDone;
        _onlineSeconds = savedOnlineSeconds;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _saveOnlineStatus(bool isOnline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('partner_is_online', isOnline);

      // Get fresh location if going online
      double? latitude;
      double? longitude;

      if (isOnline) {
        Position? position = await LocationService.instance
            .getCurrentLocation();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          _currentPosition = position;

          debugPrint('📍 Going online with location: $latitude, $longitude');
        }
      }

      // Sync with backend
      await _partnerRepository.updateOnlineStatus(
        isOnline,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      debugPrint('Error saving online status: $e');
    }
  }

  void _startOnlineTimer() {
    _onlineTimer?.cancel();
    _onlineTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _onlineSeconds++;
      });
      // Save every 30 seconds
      if (_onlineSeconds % 30 == 0) {
        _saveOnlineTime();
      }
    });
  }

  void _stopOnlineTimer() {
    _onlineTimer?.cancel();
    _saveOnlineTime();
  }

  Future<void> _saveOnlineTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('today_online_seconds', _onlineSeconds);
      final hours = _onlineSeconds / 3600;
      await prefs.setDouble('today_online_hrs', hours);
    } catch (e) {
      debugPrint('Error saving online time: $e');
    }
  }

  String _formatOnlineTime() {
    final hours = _onlineSeconds ~/ 3600;
    final minutes = (_onlineSeconds % 3600) ~/ 60;
    String time;
    if (hours > 0) {
      time = '${hours}h ${minutes}m';
    } else {
      time = '${minutes}m';
    }
    return LocalizationHelper.convertBengaliToEnglish(time);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
    final borderRadius = (screenWidth * 0.06).clamp(16.0, 24.0);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context, titleFontSize, borderRadius, hPadding),
              SizedBox(height: 12 * paddingScale),
              _buildStatusToggle(paddingScale, bodyFontSize, screenWidth),
              SizedBox(height: 10 * paddingScale),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * paddingScale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isOnline) ...[
                      _buildOfflinePrompt(smallFontSize),
                      SizedBox(height: 12 * paddingScale),
                    ],
                    _buildSectionTitle(
                      AppLocalizations.of(context)!.activeJobs,
                      titleFontSize,
                    ),
                    _activeJobs.isEmpty
                        ? _buildNoJobsCard(
                            borderRadius,
                            bodyFontSize,
                            smallFontSize,
                          )
                        : _buildActiveJobsList(
                            borderRadius,
                            bodyFontSize,
                            smallFontSize,
                          ),
                    SizedBox(height: 24 * paddingScale),
                    _buildPerformanceCard(
                      borderRadius,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    SizedBox(height: 24 * paddingScale),
                    _buildBonusCard(borderRadius, bodyFontSize),
                    SizedBox(height: 24 * paddingScale),
                    _buildProTipsCard(
                      borderRadius,
                      bodyFontSize,
                      smallFontSize,
                    ),
                    SizedBox(height: 24 * paddingScale),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double fontSize,
    double borderRadius,
    double horizontalPadding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            child: CircleAvatar(
              radius: fontSize * 1.2,
              backgroundColor: Colors.white24,
              backgroundImage: _photoUrl.startsWith('http')
                  ? NetworkImage(_photoUrl)
                  : FileImage(File(_photoUrl)) as ImageProvider,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.hello(
                      _displayName.isEmpty
                          ? l10n.partner
                          : LocalizationHelper.getLocalizedCustomerName(
                              context,
                              _displayName,
                            ).split(' ').first,
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _rating,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: Colors.white24),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                color: Colors.white70,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentLocation,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
            icon: ValueListenableBuilder<int>(
              valueListenable: AppColors.unreadNotificationsNotifier,
              builder: (context, count, child) {
                return Badge(
                  label: Text(count.toString()),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.notifications, color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    double paddingScale,
    double fontSize,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * paddingScale),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isOnline = !_isOnline;
          });
          _saveOnlineStatus(_isOnline);
          if (_isOnline) {
            _startOnlineTimer();
          } else {
            _stopOnlineTimer();
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 100) {
            if (!_isOnline) {
              setState(() => _isOnline = true);
              _saveOnlineStatus(true);
              _startOnlineTimer();
            }
          } else if (details.primaryVelocity! < -100) {
            if (_isOnline) {
              setState(() => _isOnline = false);
              _saveOnlineStatus(false);
              _stopOnlineTimer();
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (_isOnline ? AppColors.successGreen : Colors.red)
                    .withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: (_isOnline ? AppColors.successGreen : Colors.red)
                  .withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: !_isOnline
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.red.shade700, Colors.red.shade500],
                          )
                        : null,
                    color: _isOnline
                        ? Colors.grey.withValues(alpha: 0.05)
                        : null,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (!_isOnline)
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: !_isOnline
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.offline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: !_isOnline ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: (screenWidth * 0.25).clamp(80.0, 100.0),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? AppColors.successGreen.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedAlign(
                      duration: _isInitialLoad
                          ? Duration.zero
                          : const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: _isOnline
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isOnline
                                ? [
                                    AppColors.successGreen,
                                    const Color(0xFF059669),
                                  ]
                                : [Colors.red, Colors.red.shade700],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isOnline ? Colors.green : Colors.red)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: _isOnline
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.successGreen, Color(0xFF059669)],
                          )
                        : null,
                    color: !_isOnline
                        ? Colors.grey.withValues(alpha: 0.05)
                        : null,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (_isOnline)
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                    border: Border.all(
                      color: _isOnline
                          ? AppColors.successGreen.withValues(alpha: 0.15)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.online,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isOnline ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackPopup(bool accepted) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        // Auto-dismiss after 2.5 seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });

        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: Center(
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A192F),
                        const Color(0xFF112240),
                        accepted
                            ? AppColors.successGreen.withValues(alpha: 0.1)
                            : AppColors.errorRed.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color:
                          (accepted
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                              .withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (accepted
                                    ? AppColors.successGreen
                                    : AppColors.errorRed)
                                .withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative background circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                (accepted
                                        ? AppColors.successGreen
                                        : AppColors.errorRed)
                                    .withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  (accepted
                                          ? AppColors.successGreen
                                          : AppColors.errorRed)
                                      .withValues(alpha: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (accepted
                                              ? AppColors.successGreen
                                              : AppColors.errorRed)
                                          .withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              accepted ? '🌟' : '💔',
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            accepted
                                ? AppLocalizations.of(context)!.awesome
                                : AppLocalizations.of(context)!.noProblem,
                            style: TextStyle(
                              color: accepted
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            accepted
                                ? AppLocalizations.of(context)!.jobAccepted
                                : AppLocalizations.of(context)!.jobDeclined,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 2,
                            width: 40,
                            decoration: BoxDecoration(
                              color:
                                  (accepted
                                          ? AppColors.successGreen
                                          : AppColors.errorRed)
                                      .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            accepted
                                ? AppLocalizations.of(
                                    context,
                                  )!.goodLuckWithNewMission
                                : AppLocalizations.of(context)!.takeABreak,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveJobsList(
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Column(
      children: _activeJobs
          .map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActiveJobCard(
                job,
                borderRadius,
                bodyFontSize,
                smallFontSize,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActiveJobCard(
    Map<String, dynamic> job,
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    // Helper to get service name from API response
    String getServiceName() {
      // Use serviceName directly from API response
      return job['serviceName']?.toString() ?? 'Service';
    }

    // Helper to get localized time type
    String getTimeType() {
      return LocalizationHelper.getLocalizedTimeType(context, job);
    }

    // Helper to get localized ETA
    String getEta() {
      return LocalizationHelper.getLocalizedEta(context, job);
    }

    // Helper to get localized payment type
    String getPaymentType() {
      return LocalizationHelper.getLocalizedPaymentType(
        context,
        job['paymentTypeKey'] ?? job['paymentType'],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A192F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryOrangeStart.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getServiceName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.bookingId(
                      LocalizationHelper.convertBengaliToEnglish(
                        job['displayId'] ?? job['orderId'] ?? 'N/A',
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: smallFontSize * 0.9,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.ongoing,
                  style: TextStyle(
                    color: AppColors.primaryOrangeStart,
                    fontWeight: FontWeight.bold,
                    fontSize: smallFontSize * 0.9,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.white10),
          Row(
            children: [
              Expanded(
                child: _buildActiveJobInfo(
                  Icons.person_outline,
                  LocalizationHelper.getLocalizedCustomerName(
                    context,
                    job['customer'],
                  ),
                  smallFontSize,
                ),
              ),
              Expanded(
                child: _buildActiveJobInfo(
                  Icons.payments_outlined,
                  '₹${LocalizationHelper.convertBengaliToEnglish(job['totalPrice']?.toString() ?? '0')}',
                  smallFontSize,
                  color: AppColors.primaryOrangeStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildActiveJobInfo(
                  Icons.event_available,
                  getTimeType(),
                  smallFontSize,
                ),
              ),
              Expanded(
                child: _buildActiveJobInfo(
                  Icons.directions_car_outlined,
                  LocalizationHelper.convertBengaliToEnglish(
                    job['distance'] ??
                        '${LocalizationHelper.convertBengaliToEnglish('2.4')} km',
                  ),
                  smallFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildActiveJobInfo(
            Icons.location_on_outlined,
            LocalizationHelper.getLocalizedLocation(context, job['location']),
            smallFontSize,
            isExpanded: true,
          ),
          const SizedBox(height: 8),
          _buildActiveJobInfo(Icons.timer_outlined, getEta(), smallFontSize),

          // Customer Details Section (show when order is beyond PENDING/FINDING_PARTNER)
          if (job['status'] != null &&
              job['status'] != 'PENDING' &&
              job['status'] != 'FINDING_PARTNER' &&
              job['status'] != 'PARTNER_NOT_FOUND' &&
              job['status'] != 'CANCELLED') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: smallFontSize,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: smallFontSize * 0.9,
                              ),
                            ),
                            Text(
                              job['customerName'] ?? 'Customer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: smallFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phone',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: smallFontSize * 0.9,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final phone = job['customerPhone'];
                                if (phone != null) {
                                  final uri = Uri.parse('tel:$phone');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                }
                              },
                              child: Text(
                                job['customerPhone'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: smallFontSize,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      if (job['customerLatitude'] != null &&
                          job['customerLongitude'] != null) {
                        final uri = Uri.parse(
                          'https://www.google.com/maps/dir/?api=1&destination='
                          '${job['customerLatitude']},${job['customerLongitude']}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions,
                          size: smallFontSize,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Get Directions ↗',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: smallFontSize * 0.9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Payment Method Indicator
          const SizedBox(height: 8),
          if (job['paymentMethod'] == 'COD')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.money, color: Colors.orange, size: smallFontSize),
                  const SizedBox(width: 4),
                  Text(
                    'Collect Cash',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: smallFontSize * 0.9,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.green,
                    size: smallFontSize,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Paid Online',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: smallFontSize * 0.9,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Status-based Action Buttons
          _buildOrderActionButtons(job, bodyFontSize),
        ],
      ),
    );
  }

  /// Build action buttons based on order status
  Widget _buildOrderActionButtons(Map<String, dynamic> job, double fontSize) {
    final status = job['status']?.toString() ?? '';
    final orderId = job['orderId'] ?? job['id'];

    if (orderId == null) return const SizedBox.shrink();

    // ALLOCATED: Start Trip
    if (status == 'ALLOCATED') {
      return _ActionButton(
        label: "Start Trip",
        color: Colors.blue,
        icon: Icons.directions_car,
        onPressed: () => _handleMarkOnWay(orderId),
      );
    }

    // PARTNER_ON_WAY: I've Arrived
    if (status == 'PARTNER_ON_WAY') {
      return _ActionButton(
        label: "I've Arrived",
        color: Colors.orange,
        icon: Icons.location_on,
        onPressed: () => _handleMarkArrived(orderId),
      );
    }

    // PARTNER_ARRIVED: Enter Arrival OTP
    if (status == 'PARTNER_ARRIVED') {
      return _ActionButton(
        label: "Enter Arrival OTP",
        color: Colors.green,
        icon: Icons.verified_user,
        onPressed: () => _handleVerifyArrival(orderId),
      );
    }

    // IN_PROGRESS: Pause and Complete buttons
    if (status == 'IN_PROGRESS') {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: "Pause",
              color: Colors.grey[700]!,
              icon: Icons.pause,
              onPressed: () => _handlePauseOrder(orderId),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: "Complete Job",
              color: Colors.green,
              icon: Icons.check_circle,
              onPressed: () => _handleCompleteOrder(orderId),
            ),
          ),
        ],
      );
    }

    // PAUSED: Resume button
    if (status == 'PAUSED') {
      return _ActionButton(
        label: "Resume (Enter OTP)",
        color: Colors.blue,
        icon: Icons.play_arrow,
        onPressed: () => _handleResumeOrder(orderId),
      );
    }

    // Default: View Details
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/job-details', arguments: job);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrangeStart,
        minimumSize: const Size(double.infinity, 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        AppLocalizations.of(context)!.viewDetails,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  // Order Action Handlers
  Future<void> _handleMarkOnWay(String orderId) async {
    final success = await _orderRepository.markOnWay(orderId);
    if (success) {
      _showToast('Status updated: On Way');
      _loadActiveJob(); // Refresh jobs
    } else {
      _showToast('Failed to update status', isError: true);
    }
  }

  Future<void> _handleMarkArrived(String orderId) async {
    final success = await _orderRepository.markArrived(orderId);
    if (success) {
      _showToast('Status updated: Arrived. Ask customer for OTP.');
      _loadActiveJob();
    } else {
      _showToast('Failed to update status', isError: true);
    }
  }

  Future<void> _handleVerifyArrival(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderOtpDialog(
        orderId: orderId,
        purpose: 'ARRIVAL',
        onVerify: _orderRepository.verifyArrival,
      ),
    );

    if (result == true) {
      _showToast('OTP Verified! Job Started.');
      _loadActiveJob();
    }
  }

  Future<void> _handlePauseOrder(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PauseOrderDialog(
        orderId: orderId,
        onPause: _orderRepository.pauseOrder,
      ),
    );

    if (result == true) {
      _showToast('Job Paused');
      _loadActiveJob();
    }
  }

  Future<void> _handleResumeOrder(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderOtpDialog(
        orderId: orderId,
        purpose: 'RESUME',
        onVerify: _orderRepository.verifyResume,
      ),
    );

    if (result == true) {
      _showToast('OTP Verified! Job Resumed.');
      _loadActiveJob();
    }
  }

  Future<void> _handleCompleteOrder(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompleteOrderDialog(
        orderId: orderId,
        onUploadProof: _orderRepository.uploadOrderProof,
        onComplete: _orderRepository.completeOrder,
      ),
    );

    if (result == true) {
      _showToast('Job completed successfully!');
      _loadActiveJob(); // Refresh to remove completed job
    }
  }

  Widget _buildActiveJobInfo(
    IconData icon,
    String text,
    double fontSize, {
    Color? color,
    bool isExpanded = false,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white70, size: fontSize * 1.25),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color ?? Colors.white, fontSize: fontSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return isExpanded ? Row(children: [Expanded(child: content)]) : content;
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0A192F),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildOfflinePrompt(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orange.shade900,
            size: fontSize * 1.5,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.goOnlineToStart,
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoJobsCard(
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_outline_rounded,
              size: bodyFontSize * 3,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noActiveJobs,
            style: TextStyle(
              fontSize: bodyFontSize * 1.2,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.goOnlineToReceiveJobs,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: smallFontSize,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Card(
      elevation: 0,
      color: const Color(0xFF0A192F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primaryOrangeStart,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.todaysPerformance,
                  style: TextStyle(
                    fontSize: bodyFontSize * 1.1,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatSubContainer(
                    _buildStatItem(
                      AppLocalizations.of(context)!.business,
                      '₹${LocalizationHelper.convertBengaliToEnglish(_todayBusiness.toStringAsFixed(0))}',
                      Icons.account_balance_wallet_rounded,
                      const Color(0xFF34D399),
                      bodyFontSize,
                      smallFontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatSubContainer(
                    _buildStatItem(
                      AppLocalizations.of(context)!.jobsDone,
                      LocalizationHelper.convertBengaliToEnglish(
                        _todayJobsDone,
                      ),
                      Icons.check_circle_rounded,
                      const Color(0xFF60A5FA),
                      bodyFontSize,
                      smallFontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatSubContainer(
                    _buildStatItem(
                      AppLocalizations.of(context)!.onlineTime,
                      _formatOnlineTime(),
                      Icons.timer_rounded,
                      const Color(0xFFFB923C),
                      bodyFontSize,
                      smallFontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatSubContainer(
                    _buildStatItem(
                      AppLocalizations.of(context)!.rating,
                      LocalizationHelper.convertBengaliToEnglish(
                        _todayRating.split(' ')[0],
                      ),
                      Icons.star_rounded,
                      const Color(0xFFC084FC),
                      bodyFontSize,
                      smallFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSubContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.01),
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: bodyFontSize * 1.5),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: bodyFontSize * 1.1,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: smallFontSize, color: Colors.white60),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProTipsCard(
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
        side: BorderSide(color: Colors.orange.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange.shade800,
                      size: bodyFontSize * 1.5,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.proTips,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showAllProTips(bodyFontSize, smallFontSize),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: smallFontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              1,
              AppLocalizations.of(context)!.proTip1,
              smallFontSize,
            ),
            _buildTipItem(
              2,
              AppLocalizations.of(context)!.proTip2,
              smallFontSize,
            ),
            _buildTipItem(
              3,
              AppLocalizations.of(context)!.proTip3,
              smallFontSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(int num, String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              num.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
                fontSize: fontSize * 0.9,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.orange.shade900.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllProTips(double bodyFontSize, double smallFontSize) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      color: Colors.orange.shade800,
                      size: bodyFontSize * 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.allProTips,
                    style: TextStyle(
                      fontSize: bodyFontSize * 1.25,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildTipItem(
                    1,
                    AppLocalizations.of(context)!.proTip1,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    2,
                    AppLocalizations.of(context)!.proTip2,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    3,
                    AppLocalizations.of(context)!.proTip3,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    4,
                    AppLocalizations.of(context)!.proTip4,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    5,
                    AppLocalizations.of(context)!.proTip5,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    6,
                    AppLocalizations.of(context)!.proTip6,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    7,
                    AppLocalizations.of(context)!.proTip7,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    8,
                    AppLocalizations.of(context)!.proTip8,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    9,
                    AppLocalizations.of(context)!.proTip9,
                    smallFontSize,
                  ),
                  _buildTipItem(
                    10,
                    AppLocalizations.of(context)!.proTip10,
                    smallFontSize,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for order details

  /// Get color for order status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ALLOCATED':
        return Colors.blue;
      case 'PARTNER_ON_WAY':
        return Colors.orange;
      case 'PARTNER_ARRIVED':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.green;
      case 'PAUSED':
        return Colors.amber;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppColors.primaryOrangeStart;
    }
  }

  /// Get user-friendly label for order status
  String _getStatusLabel(String? status) {
    switch (status) {
      case 'ALLOCATED':
        return 'Assigned';
      case 'PARTNER_ON_WAY':
        return 'On Way';
      case 'PARTNER_ARRIVED':
        return 'Arrived';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'PAUSED':
        return 'Paused';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status ?? 'Unknown';
    }
  }

  /// Get user-friendly label for payment status
  String _getPaymentStatusLabel(String? paymentStatus) {
    switch (paymentStatus) {
      case 'PENDING':
        return 'Payment Pending';
      case 'PAID':
        return 'Paid Online';
      case 'FAILED':
        return 'Payment Failed';
      case 'REFUNDED':
        return 'Refunded';
      default:
        return 'Paid Online';
    }
  }

  /// Format DateTime to readable string
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      DateTime dt;
      if (dateTime is String) {
        dt = DateTime.parse(dateTime);
      } else if (dateTime is DateTime) {
        dt = dateTime;
      } else {
        return 'N/A';
      }

      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        // Format as "Jan 5, 10:30 AM"
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final hour = dt.hour > 12
            ? dt.hour - 12
            : (dt.hour == 0 ? 12 : dt.hour);
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';
        return '${months[dt.month - 1]} ${dt.day}, $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
      }
    } catch (e) {
      debugPrint('Error formatting datetime: $e');
      return 'N/A';
    }
  }
}

/// Reusable action button widget for order actions
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
