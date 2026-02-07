import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../services/wallet_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';
import '../../repositories/order_repository.dart';
import '../../core/network/api_endpoints.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _completedJobs = [];
  late OrderRepository _orderRepository;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _orderRepository = OrderRepositoryImpl(baseUrl: ApiEndpoints.baseUrl);
    _loadJobs();
    AppColors.jobUpdateNotifier.addListener(_loadJobs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadJobs();
  }

  @override
  void dispose() {
    AppColors.jobUpdateNotifier.removeListener(_loadJobs);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all partner orders from backend
      // Fetch all partner orders from backend (including completed)
      final allOrders = await _orderRepository.getAllPartnerOrders();

      debugPrint('📋 Fetched ${allOrders.length} total orders for Jobs page');

      if (mounted) {
        setState(() {
          // Active jobs: ALLOCATED, PARTNER_ON_WAY, PARTNER_ARRIVED, IN_PROGRESS, PAUSED
          _activeJobs = allOrders.where((order) {
            final status = order['status']?.toString() ?? '';
            return status == 'ALLOCATED' ||
                status == 'PARTNER_ON_WAY' ||
                status == 'PARTNER_ARRIVED' ||
                status == 'IN_PROGRESS' ||
                status == 'PAUSED';
          }).toList();

          // Completed jobs: COMPLETED
          _completedJobs = allOrders.where((order) {
            final status = order['status']?.toString() ?? '';
            return status == 'COMPLETED';
          }).toList();

          _isLoading = false;
        });

        debugPrint(
          '✅ Active jobs: ${_activeJobs.length}, Completed: ${_completedJobs.length}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading jobs: $e');
      // Fallback to local storage if API fails
      await _loadFromLocalStorage();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Fallback method to load from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      final jobs = await WalletService.getActiveJobs();
      final prefs = await SharedPreferences.getInstance();
      final List<String> completedList =
          prefs.getStringList('completed_jobs_list') ?? [];

      if (mounted) {
        setState(() {
          _activeJobs = jobs;
          _completedJobs = completedList
              .map((item) => jsonDecode(item) as Map<String, dynamic>)
              .where((data) {
                final title = data['title']?.toString() ?? '';
                return data['isJob'] == true ||
                    title.startsWith('Job:') ||
                    title.startsWith('কাজ:');
              })
              .toList();
        });
        debugPrint(
          '⚠️ Loaded from local storage (fallback): Active=${_activeJobs.length}, Completed=${_completedJobs.length}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading from local storage: $e');
    }
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
            _buildHeader(
              context,
              screenWidth,
              titleFontSize,
              bodyFontSize,
              smallFontSize,
              paddingScale,
            ),
            _buildTabs(paddingScale, bodyFontSize),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsList(
                    isAccepted: true,
                    screenWidth: screenWidth,
                    paddingScale: paddingScale,
                    bodyFontSize: bodyFontSize,
                    smallFontSize: smallFontSize,
                  ),
                  _buildJobsList(
                    isAccepted: false,
                    screenWidth: screenWidth,
                    paddingScale: paddingScale,
                    bodyFontSize: bodyFontSize,
                    smallFontSize: smallFontSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double screenWidth,
    double titleFontSize,
    double bodyFontSize,
    double smallFontSize,
    double paddingScale,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + (15 * paddingScale),
        left: 20 * paddingScale,
        right: 20 * paddingScale,
        bottom: 20 * paddingScale,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.jobs,
            style: TextStyle(
              color: Colors.white,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.manageServiceRequests,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: smallFontSize,
            ),
          ),
          SizedBox(height: 15 * paddingScale),
          Container(
            height: (48 * paddingScale).clamp(45.0, 56.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(fontSize: bodyFontSize),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.searchByBookingIdOrService,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: bodyFontSize,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: (22 * paddingScale).clamp(20.0, 24.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: (18 * paddingScale).clamp(16.0, 20.0),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(double paddingScale, double bodyFontSize) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryOrangeStart,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryOrangeStart,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: bodyFontSize,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(fontSize: bodyFontSize),
        tabs: [
          Tab(
            text:
                '${AppLocalizations.of(context)!.accepted} (${LocalizationHelper.convertBengaliToEnglish(_activeJobs.length)})',
          ),
          Tab(
            text:
                '${AppLocalizations.of(context)!.completed} (${LocalizationHelper.convertBengaliToEnglish(_completedJobs.length)})',
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList({
    required bool isAccepted,
    required double screenWidth,
    required double paddingScale,
    required double bodyFontSize,
    required double smallFontSize,
  }) {
    final jobs = isAccepted ? _activeJobs : _completedJobs;

    final filteredJobs = jobs.where((job) {
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      // Support both API fields and legacy fields
      final id =
          (job['displayId'] ??
                  job['orderId'] ??
                  job['id'] ??
                  job['jobId'] ??
                  '')
              .toString()
              .toLowerCase();
      final serviceName = (job['serviceName'] ?? '').toString().toLowerCase();
      final serviceKey = (job['serviceKey'] ?? '').toString();
      final service = (job['service'] ?? '').toString();

      // Get localized service name for searching (fallback for legacy data)
      final localizedService = serviceKey.isNotEmpty || service.isNotEmpty
          ? LocalizationHelper.getLocalizedServiceName(
              context,
              serviceKey.isNotEmpty ? serviceKey : service,
            ).toLowerCase()
          : '';

      return id.contains(query) ||
          serviceName.contains(query) ||
          service.toLowerCase().contains(query) ||
          serviceKey.toLowerCase().contains(query) ||
          localizedService.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return _buildEmptyState(paddingScale, bodyFontSize);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16 * paddingScale),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(
          data: filteredJobs[index],
          isCompleted: !isAccepted,
          screenWidth: screenWidth,
          paddingScale: paddingScale,
          bodyFontSize: bodyFontSize,
          smallFontSize: smallFontSize,
        );
      },
    );
  }

  Widget _buildEmptyState(double paddingScale, double bodyFontSize) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 60 * paddingScale,
          horizontal: 40 * paddingScale,
        ),
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
                Icons.search,
                size: (64 * paddingScale).clamp(48.0, 80.0),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24 * paddingScale),
            Text(
              AppLocalizations.of(context)!.noJobsFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: bodyFontSize + 2,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * paddingScale),
            Text(
              AppLocalizations.of(context)!.whenYouAcceptJob,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: bodyFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    Map<String, dynamic>? data,
    bool isCompleted = false,
    required double screenWidth,
    required double paddingScale,
    required double bodyFontSize,
    required double smallFontSize,
  }) {
    if (data == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    // Helper to get service name from API response
    String getServiceName() {
      // Use serviceName directly from API response if available
      return data['serviceName']?.toString() ??
          LocalizationHelper.getLocalizedServiceName(
            context,
            data['serviceKey'] ?? data['service'],
          );
    }

    // Helper to get localized time type
    String getTimeType() {
      return LocalizationHelper.getLocalizedTimeType(context, data);
    }

    // Helper to get localized ETA
    String getEta() {
      return LocalizationHelper.getLocalizedEta(context, data);
    }

    // Map API response format to job card format
    final Map<String, dynamic> jobData = {
      'service': getServiceName(),
      'id': data['displayId'] ?? data['orderId'] ?? data['id'] ?? '#JOB',
      'price': data['totalPrice'] ?? data['price'] ?? data['jobPrice'] ?? '0',
      'customer':
          data['customerName'] ??
          LocalizationHelper.getLocalizedCustomerName(
            context,
            data['customer'],
          ),
      'location':
          data['customerAddress'] ??
          LocalizationHelper.getLocalizedLocation(context, data['location']),
      'timeType': getTimeType(),
      'distance':
          (data['distance'] != null &&
              data['distance'] != 'null' &&
              data['distance'].toString().isNotEmpty)
          ? LocalizationHelper.convertBengaliToEnglish(data['distance'])
          : l10n.notAvailable,
      'eta': getEta(),
    };

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 16 * paddingScale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0 * paddingScale),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobData['service'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: bodyFontSize + 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AppLocalizations.of(context)!.bookingId(jobData['id']),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: smallFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * paddingScale,
                    vertical: 4 * paddingScale,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isCompleted
                          ? AppLocalizations.of(context)!.completed
                          : '₹${LocalizationHelper.convertBengaliToEnglish(jobData['price'])}',
                      style: TextStyle(
                        color: isCompleted ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: smallFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              SizedBox(height: 8 * paddingScale),
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: (16 * paddingScale).clamp(14.0, 18.0),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '₹${LocalizationHelper.convertBengaliToEnglish(jobData['price'])}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: bodyFontSize,
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.paymentReceived,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: smallFontSize - 1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            Divider(height: 24 * paddingScale),
            Row(
              children: [
                if (jobData['customer'] != null &&
                    jobData['customer'] != 'null')
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person,
                      jobData['customer'],
                      smallFontSize,
                      paddingScale,
                    ),
                  ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.event_available,
                    jobData['timeType'] ?? l10n.instant,
                    smallFontSize,
                    paddingScale,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * paddingScale),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: (16 * paddingScale).clamp(14.0, 18.0),
                  color: Colors.redAccent,
                ),
                SizedBox(width: 8 * paddingScale),
                Expanded(
                  child: Text(
                    jobData['location'],
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * paddingScale),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/job-details', arguments: data);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(
                  double.infinity,
                  (44 * paddingScale).clamp(40.0, 50.0),
                ),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryOrangeStart,
                elevation: 0,
                side: const BorderSide(color: AppColors.primaryOrangeStart),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.viewDetails,
                style: TextStyle(
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String text,
    double fontSize,
    double paddingScale,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (16 * paddingScale).clamp(14.0, 18.0),
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 8 * paddingScale),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
