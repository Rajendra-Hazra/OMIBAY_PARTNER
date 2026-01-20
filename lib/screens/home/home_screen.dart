import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/incoming_job_modal.dart';
import '../../core/app_colors.dart';
import '../../services/wallet_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

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
  String _locationCity = '';
  double _todayBusiness = 0.0;
  int _todayJobsDone = 0;
  Timer? _jobSimulationTimer;
  Timer? _onlineTimer;
  int _onlineSeconds = 0;
  bool _isInitialLoad = true;
  List<Map<String, dynamic>> _activeJobs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileData();
    _loadActiveJob();
    _loadOnlineStatus();
    // Listen for global profile updates
    AppColors.profileUpdateNotifier.addListener(_loadProfileData);
    AppColors.jobUpdateNotifier.addListener(_loadActiveJob);
    AppColors.jobUpdateNotifier.addListener(_loadProfileData);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppColors.profileUpdateNotifier.removeListener(_loadProfileData);
    AppColors.jobUpdateNotifier.removeListener(_loadActiveJob);
    _jobSimulationTimer?.cancel();
    _onlineTimer?.cancel();
    _saveOnlineTime();
    // Don't stop timer or change status on dispose - keep it running
    super.dispose();
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
      // Load from new multi-job list
      final jobs = await WalletService.getActiveJobs();
      setState(() {
        _activeJobs = jobs;
      });
    } catch (e) {
      debugPrint('Error loading active jobs: $e');
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

      setState(() {
        if (savedName != null && savedName.isNotEmpty) {
          _displayName = savedName;
        }
        if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
          _photoUrl = savedPhotoPath;
        }
        if (savedRating != null && savedRating.isNotEmpty) {
          // Show only the calculated average rating (no mock level)
          _rating = savedRating;
        } else {
          _rating = '0.0';
        }
        if (savedTodayRating != null && savedTodayRating.isNotEmpty) {
          _todayRating = savedTodayRating;
        } else {
          _todayRating = '0.0';
        }
        if (savedCity != null && savedCity.isNotEmpty) {
          _locationCity = savedCity;
        }
        _todayBusiness = savedTodayBusiness;
        _todayJobsDone = savedTodayJobsDone;
        _onlineSeconds = savedOnlineSeconds;
      });
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> _loadOnlineStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIsOnline = prefs.getBool('partner_is_online') ?? false;

      if (savedIsOnline) {
        setState(() {
          _isOnline = true;
        });
        // Catch up on time if the app was killed while online
        await _catchUpOnlineTime();
        _startJobSimulation();
        _startOnlineTimer();
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

  Future<void> _saveOnlineStatus(bool isOnline) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('partner_is_online', isOnline);
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
          physics: const BouncingScrollPhysics(),
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
                    _buildChallengesAndReferralCard(
                      borderRadius,
                      bodyFontSize,
                      smallFontSize,
                    ),
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
                      child: Text(
                        _locationCity.isEmpty ? l10n.location : _locationCity,
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
            _startJobSimulation();
            _startOnlineTimer();
          } else {
            _jobSimulationTimer?.cancel();
            _stopOnlineTimer();
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 100) {
            if (!_isOnline) {
              setState(() => _isOnline = true);
              _saveOnlineStatus(true);
              _startJobSimulation();
              _startOnlineTimer();
            }
          } else if (details.primaryVelocity! < -100) {
            if (_isOnline) {
              setState(() => _isOnline = false);
              _saveOnlineStatus(false);
              _jobSimulationTimer?.cancel();
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

  void _startJobSimulation() {
    _jobSimulationTimer?.cancel();
    // Random delay between 5 to 10 seconds for dev mode
    // Updated delay to 10-15 seconds as per project specification for dev mode
    final seconds = 10 + Random().nextInt(6);
    _jobSimulationTimer = Timer(Duration(seconds: seconds), () {
      if (mounted && _isOnline) {
        _showIncomingJob();
      }
    });
  }

  void _showIncomingJob() {
    final bool isScheduled = Random().nextBool();
    final bool isOnline = Random().nextBool();
    final double tipAmount = Random().nextDouble() > 0.7 ? 50.0 : 0.0;

    // Multiple job types for testing variety
    final List<Map<String, String>> jobTemplates = [
      {
        'serviceKey': 'fullHomeCleaning',
        'customer': AppLocalizations.of(context)!.mockCustomerName,
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '1,499',
        'distance': '2.4 km',
        'paymentTypeKey': '', // Random (Online/Cash)
      },
      {
        'serviceKey': 'kitchenDeepClean',
        'customer': 'Priya Patel',
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '799',
        'distance': '1.8 km',
        'paymentTypeKey': 'prepaid', // Already paid online
      },
      {
        'serviceKey': 'bathroomSanitization',
        'customer': 'Amit Kumar',
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '599',
        'distance': '3.2 km',
        'paymentTypeKey': '', // Random (Online/Cash)
      },
      {
        'serviceKey': 'sofaAndCarpetCleaning',
        'customer': 'Sneha Reddy',
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '1,299',
        'distance': '5.1 km',
        'paymentTypeKey': 'prepaid', // Already paid online
      },
      {
        'serviceKey': 'acServiceAndRepair',
        'customer': 'Vikram Singh',
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '499',
        'distance': '2.0 km',
        'paymentTypeKey': '', // Random (Online/Cash)
      },
      {
        'serviceKey': 'pestControl',
        'customer': 'Meera Nair',
        'location': AppLocalizations.of(context)!.mockLocation,
        'price': '1,999',
        'distance': '4.5 km',
        'paymentTypeKey': '', // Random (Online/Cash)
      },
    ];

    // Randomly select a job template
    final selectedJob = jobTemplates[Random().nextInt(jobTemplates.length)];

    final int etaMins = 10 + Random().nextInt(20);
    final String scheduledDate = '${20 + Random().nextInt(10)} Jan';
    final String scheduledTime = '${9 + Random().nextInt(4)}:00 AM';

    final mockJob = {
      'serviceKey': selectedJob['serviceKey']!,
      'customer': selectedJob['customer']!,
      'location': selectedJob['location']!,
      'etaMins': etaMins.toString(),
      'isScheduled': isScheduled.toString(),
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'price': selectedJob['price']!,
      'tip': tipAmount.toStringAsFixed(0),
      'distance': selectedJob['distance']!,
      'paymentTypeKey': selectedJob['paymentTypeKey']!.isNotEmpty
          ? selectedJob['paymentTypeKey']!
          : (isOnline ? 'online' : 'cash'),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingJobModal(
        job: mockJob,
        onAccept: () async {
          // Generate unique job ID
          final String jobId = '#OK${Random().nextInt(999999)}';

          // Create job data map for multi-job storage
          final jobData = {
            'id': jobId,
            'serviceKey': mockJob['serviceKey'],
            'customer': mockJob['customer'],
            'location': mockJob['location'],
            'price': mockJob['price'],
            'tip': mockJob['tip'],
            'isScheduled': mockJob['isScheduled'],
            'scheduledDate': mockJob['scheduledDate'],
            'scheduledTime': mockJob['scheduledTime'],
            'distance': mockJob['distance'],
            'etaMins': mockJob['etaMins'],
            'paymentTypeKey': mockJob['paymentTypeKey'],
          };

          // Add to active jobs list
          await WalletService.addActiveJob(jobData);

          AppColors.jobUpdateNotifier.value++;

          if (!context.mounted) return;
          Navigator.pop(context);
          _showFeedbackPopup(true);
        },
        onDecline: () {
          if (!context.mounted) return;
          Navigator.pop(context);
          _showFeedbackPopup(false);
        },
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
    // Helper to get localized service name
    String getServiceName() {
      return LocalizationHelper.getLocalizedServiceName(
        context,
        job['serviceKey'] ?? job['service'],
      );
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
                        job['id'] ?? 'N/A',
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
                  '₹${LocalizationHelper.convertBengaliToEnglish(job['price'] ?? '0')}',
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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/job-details',
                arguments: {
                  ...job,
                  'service': getServiceName(),
                  'timeType': getTimeType(),
                  'eta': getEta(),
                  'paymentType': getPaymentType(),
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeStart,
              minimumSize: const Size(double.infinity, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.viewDetails,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: bodyFontSize,
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildChallengesAndReferralCard(
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
      child: Column(
        children: [
          // Weekly Bonus Challenge Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.orange,
                        size: bodyFontSize,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.weeklyBonusChallenge,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: bodyFontSize,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.complete15Jobs,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: smallFontSize,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.earnExtraReward,
                            style: TextStyle(
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: smallFontSize,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_todayJobsDone / 15).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          color: Colors.orange,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.jobsDoneCount(_todayJobsDone.toString()),
                          style: TextStyle(
                            fontSize: smallFontSize * 0.9,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          // Share & Earn Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: const Color(0xFF60A5FA),
                      size: bodyFontSize * 1.5,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.shareAndEarn,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.inviteYourFriends,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: smallFontSize,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/referral');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share_outlined, size: smallFontSize * 1.5),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.invite,
                        style: TextStyle(fontSize: bodyFontSize),
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
}
