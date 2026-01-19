import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

// Service status enum
enum ServiceStatus { verified, pending }

// Service model class with status
class PartnerService {
  final String id;
  final String name;
  final IconData icon;
  final String experience;
  final String? videoPath;
  final ServiceStatus status;

  const PartnerService({
    required this.id,
    required this.name,
    required this.icon,
    required this.experience,
    this.videoPath,
    required this.status,
  });

  bool get isVerified => status == ServiceStatus.verified;
  bool get isPending => status == ServiceStatus.pending;
}

// Service definition model
class ServiceDefinition {
  final String id;
  final String name;
  final IconData icon;

  const ServiceDefinition({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class EditServicesScreen extends StatefulWidget {
  const EditServicesScreen({super.key});

  @override
  State<EditServicesScreen> createState() => _EditServicesScreenState();
}

class _EditServicesScreenState extends State<EditServicesScreen> {
  // Services from work verification (verified + pending)
  List<PartnerService> _services = [];
  List<PartnerService> _appliances = [];
  bool _isLoading = true;
  bool _hideHelp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('hideHelp')) {
      _hideHelp = args['hideHelp'] as bool;
    }
  }

  void _showHelpOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.helpAndSupport,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Options
              _buildHelpOption(
                icon: Icons.chat_bubble_outline_rounded,
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
                color: const Color(0xFF25D366), // WhatsApp Green
                onTap: () async {
                  Navigator.pop(context);
                  final l10n = AppLocalizations.of(context)!;
                  final String phoneNumber = l10n.whatsappSupportNumber;
                  final Uri whatsappUri = Uri.parse(
                    "https://wa.me/$phoneNumber",
                  );
                  if (!await launchUrl(
                    whatsappUri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.couldNotLaunchWhatsApp,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildHelpOption(
                icon: Icons.help_outline_rounded,
                title: AppLocalizations.of(context)!.accountIssueAndFaq,
                subtitle: AppLocalizations.of(
                  context,
                )!.commonQuestionsAndAccountHelp,
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/account-faq');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      onTap: onTap,
    );
  }

  // Computed properties
  List<PartnerService> get _verifiedServices =>
      _services.where((s) => s.isVerified).toList();
  List<PartnerService> get _pendingServices =>
      _services.where((s) => s.isPending).toList();
  List<PartnerService> get _verifiedAppliances =>
      _appliances.where((a) => a.isVerified).toList();
  List<PartnerService> get _pendingAppliances =>
      _appliances.where((a) => a.isPending).toList();

  int get _totalVerifiedCount =>
      _verifiedServices.length + _verifiedAppliances.length;
  int get _totalPendingCount =>
      _pendingServices.length + _pendingAppliances.length;

  // Service definitions for icon mapping
  static const Map<String, ServiceDefinition> _serviceDefinitions = {
    'plumber': ServiceDefinition(
      id: 'plumber',
      name: 'plumber',
      icon: Icons.plumbing,
    ),
    'electrician': ServiceDefinition(
      id: 'electrician',
      name: 'electrician',
      icon: Icons.electrical_services,
    ),
    'carpenter': ServiceDefinition(
      id: 'carpenter',
      name: 'carpenter',
      icon: Icons.carpenter,
    ),
    'gardening': ServiceDefinition(
      id: 'gardening',
      name: 'gardening',
      icon: Icons.grass,
    ),
    'cleaning': ServiceDefinition(
      id: 'cleaning',
      name: 'cleaning',
      icon: Icons.cleaning_services,
    ),
    'men_salon': ServiceDefinition(
      id: 'men_salon',
      name: 'menSalon',
      icon: Icons.face,
    ),
    'women_salon': ServiceDefinition(
      id: 'women_salon',
      name: 'womenSalon',
      icon: Icons.face_3,
    ),
    'makeup_beauty': ServiceDefinition(
      id: 'makeup_beauty',
      name: 'makeupAndBeauty',
      icon: Icons.brush,
    ),
    'quick_transport': ServiceDefinition(
      id: 'quick_transport',
      name: 'quickTransport',
      icon: Icons.local_shipping,
    ),
    'appliances_repair': ServiceDefinition(
      id: 'appliances_repair',
      name: 'appliancesRepair',
      icon: Icons.home_repair_service,
    ),
  };

  // Appliance definitions
  static const Map<String, ServiceDefinition> _applianceDefinitions = {
    'ac': ServiceDefinition(id: 'ac', name: 'ac', icon: Icons.ac_unit),
    'air_cooler': ServiceDefinition(
      id: 'air_cooler',
      name: 'airCooler',
      icon: Icons.air,
    ),
    'chimney': ServiceDefinition(
      id: 'chimney',
      name: 'chimney',
      icon: Icons.kitchen,
    ),
    'geyser': ServiceDefinition(
      id: 'geyser',
      name: 'geyser',
      icon: Icons.water_drop,
    ),
    'laptop': ServiceDefinition(
      id: 'laptop',
      name: 'laptop',
      icon: Icons.laptop,
    ),
    'refrigerator': ServiceDefinition(
      id: 'refrigerator',
      name: 'refrigerator',
      icon: Icons.kitchen,
    ),
    'washing_machine': ServiceDefinition(
      id: 'washing_machine',
      name: 'washingMachine',
      icon: Icons.local_laundry_service,
    ),
    'microwave': ServiceDefinition(
      id: 'microwave',
      name: 'microwave',
      icon: Icons.microwave,
    ),
    'television': ServiceDefinition(
      id: 'television',
      name: 'television',
      icon: Icons.tv,
    ),
    'water_purifier': ServiceDefinition(
      id: 'water_purifier',
      name: 'waterPurifier',
      icon: Icons.water,
    ),
  };

  String _getLocalizedServiceName(String nameKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (nameKey) {
      case 'plumber':
        return l10n.plumber;
      case 'electrician':
        return l10n.electrician;
      case 'carpenter':
        return l10n.carpenter;
      case 'gardening':
        return l10n.gardening;
      case 'cleaning':
        return l10n.cleaning;
      case 'menSalon':
        return l10n.menSalon;
      case 'womenSalon':
        return l10n.womenSalon;
      case 'makeupAndBeauty':
        return l10n.makeupAndBeauty;
      case 'quickTransport':
        return l10n.quickTransport;
      case 'appliancesRepair':
        return l10n.appliancesRepair;
      case 'ac':
        return l10n.ac;
      case 'airCooler':
        return l10n.airCooler;
      case 'chimney':
        return l10n.chimney;
      case 'geyser':
        return l10n.geyser;
      case 'laptop':
        return l10n.laptop;
      case 'refrigerator':
        return l10n.refrigerator;
      case 'washingMachine':
        return l10n.washingMachine;
      case 'microwave':
        return l10n.microwave;
      case 'television':
        return l10n.television;
      case 'waterPurifier':
        return l10n.waterPurifier;
      default:
        return nameKey;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadVerifiedServices();
  }

  Future<void> _loadVerifiedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved services that have been verified in work verification
      final savedServices = prefs.getStringList('profile_services') ?? [];
      final savedAppliances = prefs.getStringList('profile_appliances') ?? [];

      List<PartnerService> servicesList = [];
      List<PartnerService> appliancesList = [];

      // Load services with complete data
      for (String serviceId in savedServices) {
        if (serviceId == 'appliances_repair') continue; // Handle separately

        final experience = prefs.getString('exp_$serviceId') ?? '';
        final videoPath = prefs.getString('video_$serviceId');
        // Check if service is verified or pending
        final statusStr = prefs.getString('status_$serviceId') ?? 'pending';
        final status = statusStr == 'verified'
            ? ServiceStatus.verified
            : ServiceStatus.pending;

        // Only add if has experience AND video (submitted for verification)
        if (experience.isNotEmpty && videoPath != null) {
          final definition = _serviceDefinitions[serviceId];
          if (definition != null) {
            servicesList.add(
              PartnerService(
                id: serviceId,
                name: definition.name,
                icon: definition.icon,
                experience: experience,
                videoPath: videoPath,
                status: status,
              ),
            );
          }
        }
      }

      // Load appliances with complete data
      for (String applianceId in savedAppliances) {
        final experience = prefs.getString('exp_$applianceId') ?? '';
        final videoPath = prefs.getString('video_$applianceId');
        // Check if appliance is verified or pending
        final statusStr = prefs.getString('status_$applianceId') ?? 'pending';
        final status = statusStr == 'verified'
            ? ServiceStatus.verified
            : ServiceStatus.pending;

        // Only add if has experience AND video (submitted for verification)
        if (experience.isNotEmpty && videoPath != null) {
          final definition = _applianceDefinitions[applianceId];
          if (definition != null) {
            appliancesList.add(
              PartnerService(
                id: applianceId,
                name: definition.name,
                icon: definition.icon,
                experience: experience,
                videoPath: videoPath,
                status: status,
              ),
            );
          }
        }
      }

      setState(() {
        _services = servicesList;
        _appliances = appliancesList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading services: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(PartnerService service, bool isAppliance) async {
    // Cannot delete pending services
    if (service.isPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotDeletePending),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculate total VERIFIED services count (exclude pending)
    final totalVerified = _totalVerifiedCount;

    // Check if this is the last VERIFIED service - cannot delete
    if (totalVerified <= 1) {
      await _showLastServiceWarning(service.name);
      return;
    }

    final confirmed = await _showDeleteConfirmation(
      _getLocalizedServiceName(service.name),
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      if (isAppliance) {
        // Remove from appliances list
        final savedAppliances = prefs.getStringList('profile_appliances') ?? [];
        savedAppliances.remove(service.id);
        await prefs.setStringList('profile_appliances', savedAppliances);

        // Remove verification data and status
        await prefs.remove('exp_${service.id}');
        await prefs.remove('video_${service.id}');
        await prefs.remove('status_${service.id}');

        // If no appliances left, remove appliances_repair from services
        if (savedAppliances.isEmpty) {
          final savedServices = prefs.getStringList('profile_services') ?? [];
          savedServices.remove('appliances_repair');
          await prefs.setStringList('profile_services', savedServices);
        }
      } else {
        // Remove from services list
        final savedServices = prefs.getStringList('profile_services') ?? [];
        savedServices.remove(service.id);
        await prefs.setStringList('profile_services', savedServices);

        // Remove verification data and status
        await prefs.remove('exp_${service.id}');
        await prefs.remove('video_${service.id}');
        await prefs.remove('status_${service.id}');
      }

      // Reload services
      await _loadVerifiedServices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.serviceRemovedSuccess(_getLocalizedServiceName(service.name)),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorRemovingService(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Show warning when trying to delete last service
  Future<void> _showLastServiceWarning(String serviceName) async {
    final shouldVerifyNew = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primaryOrangeStart,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.cannotRemove,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.mustHaveOneService,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    color: AppColors.primaryOrangeStart,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.toSwitchServices(serviceName),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(AppLocalizations.of(context)!.verifyNewService),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrangeStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    // If user wants to verify new service, navigate to verification
    if (shouldVerifyNew == true) {
      await _navigateToVerification();
    }
  }

  Future<bool?> _showDeleteConfirmation(String serviceName) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.remove,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.removeServiceConfirm(serviceName),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.remove,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToVerification() async {
    // Pass argument to indicate we're adding a new service (start with empty selection)
    final result = await Navigator.pushNamed(
      context,
      '/work-verification',
      arguments: {'addNewService': true},
    );
    if (result == true) {
      await _loadVerifiedServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final hasVerifiedServices =
        _verifiedServices.isNotEmpty || _verifiedAppliances.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: hasVerifiedServices
                    ? _buildVerifiedServicesList()
                    : _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(child: _buildBottomBar()),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.work_off_outlined,
                size: 64,
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noVerifiedServices,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.verifyAtLeastOneService,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToVerification,
              icon: const Icon(Icons.verified_outlined),
              label: Text(AppLocalizations.of(context)!.verifyYourServices),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedServicesList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: AppColors.successGreen, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.myServices,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppLocalizations.of(context)!.verifiedCount(_totalVerifiedCount)}, ${AppLocalizations.of(context)!.pendingCount(_totalPendingCount)}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Verified Services List
          if (_verifiedServices.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.activeServices,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._verifiedServices.map(
              (service) => _buildServiceCard(service, false),
            ),
          ],

          // Verified Appliances List
          if (_verifiedAppliances.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.activeApplianceServices,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._verifiedAppliances.map(
              (appliance) => _buildServiceCard(appliance, true),
            ),
          ],

          // Pending Services Section
          if (_pendingServices.isNotEmpty || _pendingAppliances.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.verificationPendingNotify,
                      style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_pendingServices.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)!.pendingVerification,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingServices.map(
                (service) => _buildServiceCard(service, false),
              ),
            ],

            if (_pendingAppliances.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.pendingApplianceServices,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingAppliances.map(
                (appliance) => _buildServiceCard(appliance, true),
              ),
            ],
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildServiceCard(PartnerService service, bool isAppliance) {
    final isPending = service.isPending;
    final statusColor = isPending ? Colors.orange : AppColors.successGreen;
    final statusText = isPending
        ? AppLocalizations.of(context)!.pending
        : AppLocalizations.of(context)!.verified;
    final statusIcon = isPending ? Icons.hourglass_empty : Icons.check_circle;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPending
            ? Border.all(color: Colors.orange.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Service Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (isPending ? Colors.orange : AppColors.primaryOrangeStart)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                color: isPending ? Colors.orange : AppColors.primaryOrangeStart,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getLocalizedServiceName(service.name),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.work_history_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.experience,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (service.videoPath != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.videoUploaded,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Delete Button (disabled for pending services)
            if (service.isVerified)
              IconButton(
                onPressed: () => _deleteService(service, isAppliance),
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                tooltip: AppLocalizations.of(context)!.remove,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              Tooltip(
                message: AppLocalizations.of(context)!.cannotDeleteWhilePending,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.delete_outline, color: Colors.grey[300]),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
        left: 10,
        right: 20,
        bottom: 20,
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.editServices,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!_hideHelp)
            Flexible(
              child: InkWell(
                onTap: _showHelpOptions,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.help,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasVerifiedServices =
        _verifiedServices.isNotEmpty || _verifiedAppliances.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _navigateToVerification,
          icon: const Icon(Icons.add_circle_outline),
          label: Text(
            hasVerifiedServices
                ? AppLocalizations.of(context)!.addMoreServices
                : AppLocalizations.of(context)!.verifyFirstService,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrangeStart,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey[300],
          ),
        ),
      ),
    );
  }
}
