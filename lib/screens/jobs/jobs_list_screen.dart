import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../services/wallet_service.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    await _loadActiveJob();
    await _loadCompletedJobs();
  }

  Future<void> _loadCompletedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> completedList =
          prefs.getStringList('completed_jobs_list') ?? [];
      setState(() {
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
    } catch (e) {
      debugPrint('Error loading completed jobs: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsList(isAccepted: true),
                  _buildJobsList(isAccepted: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 15,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.manageServiceRequests,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(
                  context,
                )!.searchByBookingIdOrService,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.grey,
                          size: 18,
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryOrangeStart,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryOrangeStart,
        indicatorWeight: 3,
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

  Widget _buildJobsList({required bool isAccepted}) {
    final jobs = isAccepted ? _activeJobs : _completedJobs;

    final filteredJobs = jobs.where((job) {
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final id = (job['id'] ?? job['jobId'] ?? '').toString().toLowerCase();
      final serviceKey = (job['serviceKey'] ?? '').toString();
      final service = (job['service'] ?? '').toString();

      // Get localized service name for searching
      final localizedService = LocalizationHelper.getLocalizedServiceName(
        context,
        serviceKey.isNotEmpty ? serviceKey : service,
      ).toLowerCase();

      return id.contains(query) ||
          service.toLowerCase().contains(query) ||
          serviceKey.toLowerCase().contains(query) ||
          localizedService.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(
          data: filteredJobs[index],
          isCompleted: !isAccepted,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search,
              size: 64,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noJobsFound,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.whenYouAcceptJob,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard({Map<String, dynamic>? data, bool isCompleted = false}) {
    if (data == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    // Helper to get localized service name
    String getServiceName() {
      return LocalizationHelper.getLocalizedServiceName(
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

    // Map legacy/transaction format to standard job format if needed
    final Map<String, dynamic> jobData = {
      'service': getServiceName(),
      'id': LocalizationHelper.convertBengaliToEnglish(
        data['id'] ?? data['jobId'] ?? '#JOB',
      ),
      'price': data['price'] ?? data['jobPrice'] ?? '0',
      'customer': LocalizationHelper.getLocalizedCustomerName(
        context,
        data['customer'],
      ),
      'location': LocalizationHelper.getLocalizedLocation(
        context,
        data['location'],
      ),
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobData['service'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.bookingId(jobData['id']),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted
                        ? AppLocalizations.of(context)!.completed
                        : '₹${LocalizationHelper.convertBengaliToEnglish(jobData['price'])}',
                    style: TextStyle(
                      color: isCompleted ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${LocalizationHelper.convertBengaliToEnglish(jobData['price'])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context)!.paymentReceived,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                if (jobData['customer'] != null &&
                    jobData['customer'] != 'null')
                  Expanded(
                    child: _buildInfoItem(Icons.person, jobData['customer']),
                  ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.event_available,
                    jobData['timeType'] ?? l10n.instant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    jobData['location'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/job-details', arguments: data);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryOrangeStart,
                side: const BorderSide(color: AppColors.primaryOrangeStart),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.viewDetails),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
