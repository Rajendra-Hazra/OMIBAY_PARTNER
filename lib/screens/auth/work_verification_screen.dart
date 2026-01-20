import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';

// Service option model class for type safety
class ServiceOption {
  final String id;
  final String name;
  final IconData icon;

  const ServiceOption({
    required this.id,
    required this.name,
    required this.icon,
  });
}

// Appliance sub-option model class
class ApplianceOption {
  final String id;
  final String name;

  const ApplianceOption({required this.id, required this.name});
}

class WorkVerificationScreen extends StatefulWidget {
  const WorkVerificationScreen({super.key});

  @override
  State<WorkVerificationScreen> createState() => _WorkVerificationScreenState();
}

class _WorkVerificationScreenState extends State<WorkVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _addNewServiceMode =
      false; // Flag to indicate adding new service from Edit Services

  String _getLocalizedName(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> nameMap = {
      'plumber': l10n.plumber,
      'electrician': l10n.electrician,
      'carpenter': l10n.carpenter,
      'gardening': l10n.gardening,
      'cleaning': l10n.cleaning,
      'men_salon': l10n.menSalon,
      'women_salon': l10n.womenSalon,
      'makeup_beauty': l10n.makeupAndBeauty,
      'quick_transport': l10n.quickTransport,
      'appliances_repair': l10n.appliancesRepair,
      'ac': l10n.ac,
      'air_cooler': l10n.airCooler,
      'chimney': l10n.chimney,
      'geyser': l10n.geyser,
      'laptop': l10n.laptop,
      'refrigerator': l10n.refrigerator,
      'washing_machine': l10n.washingMachine,
      'microwave': l10n.microwave,
      'television': l10n.television,
      'water_purifier': l10n.waterPurifier,
    };
    return nameMap[id] ?? id;
  }

  // Already verified services (non-clickable in addNewService mode)
  Set<String> _alreadyVerifiedServices = {};
  Set<String> _alreadyVerifiedAppliances = {};

  // Service selection state
  final Set<String> _selectedServices = {};
  final Set<String> _selectedApplianceSubOptions = {};
  bool _isAppliancesExpanded = false;

  // Available services
  static const List<ServiceOption> _services = [
    ServiceOption(id: 'plumber', name: 'Plumber', icon: Icons.plumbing),
    ServiceOption(
      id: 'electrician',
      name: 'Electrician',
      icon: Icons.electrical_services,
    ),
    ServiceOption(id: 'carpenter', name: 'Carpenter', icon: Icons.carpenter),
    ServiceOption(id: 'gardening', name: 'Gardening', icon: Icons.grass),
    ServiceOption(
      id: 'cleaning',
      name: 'Cleaning',
      icon: Icons.cleaning_services,
    ),
    ServiceOption(id: 'men_salon', name: 'Men Salon', icon: Icons.face),
    ServiceOption(id: 'women_salon', name: 'Women Salon', icon: Icons.face_3),
    ServiceOption(
      id: 'makeup_beauty',
      name: 'Makeup & Beauty',
      icon: Icons.brush,
    ),
    ServiceOption(
      id: 'quick_transport',
      name: 'Quick Transport',
      icon: Icons.local_shipping,
    ),
    ServiceOption(
      id: 'appliances_repair',
      name: 'Appliances Repair & Replacement',
      icon: Icons.home_repair_service,
    ),
  ];

  // Appliance sub-options
  static const List<ApplianceOption> _applianceSubOptions = [
    ApplianceOption(id: 'ac', name: 'AC'),
    ApplianceOption(id: 'air_cooler', name: 'Air Cooler'),
    ApplianceOption(id: 'chimney', name: 'Chimney'),
    ApplianceOption(id: 'geyser', name: 'Geyser'),
    ApplianceOption(id: 'laptop', name: 'Laptop'),
    ApplianceOption(id: 'refrigerator', name: 'Refrigerator'),
    ApplianceOption(id: 'washing_machine', name: 'Washing Machine'),
    ApplianceOption(id: 'microwave', name: 'Microwave'),
    ApplianceOption(id: 'television', name: 'Television'),
    ApplianceOption(id: 'water_purifier', name: 'Water Purifier'),
  ];

  // Dynamic data for each service
  final Map<String, TextEditingController> _serviceExperienceControllers = {};
  final Map<String, TextEditingController> _serviceSkillsControllers = {};
  final Map<String, String?> _serviceVideoPaths = {};
  final Map<String, VideoPlayerController?> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    // Delay to get route arguments after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkArguments();
    });
  }

  void _checkArguments() async {
    // Check if we're coming from Edit Services to add new service
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['addNewService'] == true) {
      // Load already verified services to show as disabled
      await _loadAlreadyVerifiedServices();

      setState(() {
        _addNewServiceMode = true;
        _selectedServices.clear();
        _selectedApplianceSubOptions.clear();
      });
    } else {
      // Normal flow - load saved data
      _loadSavedData();
    }
  }

  // Load services that are already verified (for addNewService mode)
  Future<void> _loadAlreadyVerifiedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedServices = prefs.getStringList('profile_services') ?? [];
      final savedAppliances = prefs.getStringList('profile_appliances') ?? [];

      Set<String> verifiedServices = {};
      Set<String> verifiedAppliances = {};

      // Check which services are fully verified (have experience + video)
      for (String serviceId in savedServices) {
        if (serviceId == 'appliances_repair') continue;
        final hasExperience =
            prefs.getString('exp_$serviceId')?.isNotEmpty ?? false;
        final hasVideo = prefs.getString('video_$serviceId') != null;
        if (hasExperience && hasVideo) {
          verifiedServices.add(serviceId);
        }
      }

      // Check which appliances are fully verified
      for (String applianceId in savedAppliances) {
        final hasExperience =
            prefs.getString('exp_$applianceId')?.isNotEmpty ?? false;
        final hasVideo = prefs.getString('video_$applianceId') != null;
        if (hasExperience && hasVideo) {
          verifiedAppliances.add(applianceId);
        }
      }

      setState(() {
        _alreadyVerifiedServices = verifiedServices;
        _alreadyVerifiedAppliances = verifiedAppliances;
      });
    } catch (e) {
      debugPrint('Error loading verified services: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _serviceExperienceControllers.values) {
      controller.dispose();
    }
    for (var controller in _serviceSkillsControllers.values) {
      controller.dispose();
    }
    for (var controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  TextEditingController _getExperienceController(String serviceId) {
    return _serviceExperienceControllers.putIfAbsent(
      serviceId,
      () => TextEditingController(),
    );
  }

  TextEditingController _getSkillsController(String serviceId) {
    return _serviceSkillsControllers.putIfAbsent(
      serviceId,
      () => TextEditingController(),
    );
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load selected services
      final savedServices = prefs.getStringList('profile_services');
      final savedAppliances = prefs.getStringList('profile_appliances');

      setState(() {
        if (savedServices != null) {
          _selectedServices.clear();
          _selectedServices.addAll(savedServices);

          for (String serviceId in savedServices) {
            _getExperienceController(serviceId).text =
                prefs.getString('exp_$serviceId') ?? '';
            _getSkillsController(serviceId).text =
                prefs.getString('skills_$serviceId') ?? '';
            _serviceVideoPaths[serviceId] = prefs.getString('video_$serviceId');
          }

          if (_selectedServices.contains('appliances_repair')) {
            _isAppliancesExpanded = true;
          }
        }

        if (savedAppliances != null) {
          _selectedApplianceSubOptions.clear();
          _selectedApplianceSubOptions.addAll(savedAppliances);

          for (String applianceId in savedAppliances) {
            _getExperienceController(applianceId).text =
                prefs.getString('exp_$applianceId') ?? '';
            _getSkillsController(applianceId).text =
                prefs.getString('skills_$applianceId') ?? '';
            _serviceVideoPaths[applianceId] = prefs.getString(
              'video_$applianceId',
            );
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading work verification data: $e');
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedApplianceSubOptions.isEmpty) {
        _selectedServices.remove('appliances_repair');
      }

      final prefs = await SharedPreferences.getInstance();

      // If in addNewService mode, merge with existing services
      if (_addNewServiceMode) {
        // Get existing services
        final existingServices = prefs.getStringList('profile_services') ?? [];
        final existingAppliances =
            prefs.getStringList('profile_appliances') ?? [];

        // Merge new services with existing ones (avoid duplicates)
        final mergedServices = {
          ...existingServices,
          ..._selectedServices,
        }.toList();
        final mergedAppliances = {
          ...existingAppliances,
          ..._selectedApplianceSubOptions,
        }.toList();

        await prefs.setStringList('profile_services', mergedServices);
        await prefs.setStringList('profile_appliances', mergedAppliances);
      } else {
        // Normal mode - replace all
        await prefs.setStringList(
          'profile_services',
          _selectedServices.toList(),
        );
        await prefs.setStringList(
          'profile_appliances',
          _selectedApplianceSubOptions.toList(),
        );
      }

      for (String serviceId in _selectedServices) {
        // Skip general category if specific appliances are selected
        if (serviceId == 'appliances_repair' &&
            _selectedApplianceSubOptions.isNotEmpty) {
          continue;
        }

        await prefs.setString(
          'exp_$serviceId',
          _serviceExperienceControllers[serviceId]?.text ?? '',
        );
        await prefs.setString(
          'skills_$serviceId',
          _serviceSkillsControllers[serviceId]?.text ?? '',
        );
        if (_serviceVideoPaths[serviceId] != null) {
          await prefs.setString(
            'video_$serviceId',
            _serviceVideoPaths[serviceId]!,
          );
        }
        // Set status as 'pending' for new services (will be changed to 'verified' by admin)
        // Only set to pending if not already verified
        final currentStatus = prefs.getString('status_$serviceId');
        if (currentStatus != 'verified') {
          await prefs.setString('status_$serviceId', 'pending');
        }
      }

      for (String applianceId in _selectedApplianceSubOptions) {
        await prefs.setString(
          'exp_$applianceId',
          _serviceExperienceControllers[applianceId]?.text ?? '',
        );
        await prefs.setString(
          'skills_$applianceId',
          _serviceSkillsControllers[applianceId]?.text ?? '',
        );
        if (_serviceVideoPaths[applianceId] != null) {
          await prefs.setString(
            'video_$applianceId',
            _serviceVideoPaths[applianceId]!,
          );
        }
        // Set status as 'pending' for new appliances (will be changed to 'verified' by admin)
        // Only set to pending if not already verified
        final currentStatus = prefs.getString('status_$applianceId');
        if (currentStatus != 'verified') {
          await prefs.setString('status_$applianceId', 'pending');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _addNewServiceMode
                  ? AppLocalizations.of(
                      context,
                    )!.serviceSubmittedForVerification
                  : AppLocalizations.of(context)!.workVerificationSaved,
            ),
            backgroundColor: _addNewServiceMode ? Colors.orange : Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.errorSavingData} $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool get _isFormValid {
    if (_selectedServices.isEmpty && _selectedApplianceSubOptions.isEmpty) {
      return false;
    }

    for (String serviceId in _selectedServices) {
      // Skip general category if specific appliances are selected
      if (serviceId == 'appliances_repair' &&
          _selectedApplianceSubOptions.isNotEmpty) {
        continue;
      }

      if (_getExperienceController(serviceId).text.isEmpty) return false;
      if (_serviceVideoPaths[serviceId] == null) return false;
    }

    for (String applianceId in _selectedApplianceSubOptions) {
      if (_getExperienceController(applianceId).text.isEmpty) return false;
      if (_serviceVideoPaths[applianceId] == null) return false;
    }

    return true;
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
              _buildHelpOption(
                // ignore: deprecated_member_use
                icon: MdiIcons.whatsapp,
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
                color: const Color(0xFF25D366),
                onTap: () async {
                  Navigator.pop(context);
                  const String phoneNumber = "918016867006";
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(12.0, 20.0);
    final titleFontSize = (screenWidth * 0.05).clamp(16.0, 20.0);
    final bodyFontSize = (screenWidth * 0.04).clamp(13.0, 16.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final borderRadius = (screenWidth * 0.04).clamp(12.0, 16.0);
    final cardPadding = (screenWidth * 0.05).clamp(16.0, 20.0);
    final spacing = (screenWidth * 0.05).clamp(16.0, 20.0);
    final buttonHeight = (screenHeight * 0.06).clamp(56.0, 64.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding * 0.5,
                  vertical: verticalPadding,
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
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: iconSize * 0.9,
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.workVerification,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!_addNewServiceMode)
                      InkWell(
                        onTap: _showHelpOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding * 0.6,
                            vertical: verticalPadding * 0.5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: iconSize,
                                color: Colors.white,
                              ),
                              SizedBox(width: spacing * 0.3),
                              Text(
                                AppLocalizations.of(context)!.help,
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceSelectionSection(
                        context,
                        cardPadding,
                        spacing,
                        titleFontSize,
                        bodyFontSize,
                        iconSize,
                        borderRadius,
                      ),
                      ..._selectedServices
                          .where(
                            (id) =>
                                id != 'appliances_repair' ||
                                _selectedApplianceSubOptions.isEmpty,
                          )
                          .map((serviceId) {
                            final service = _services.firstWhere(
                              (s) => s.id == serviceId,
                              orElse: () => _services[0],
                            );
                            return _buildServiceSpecificSection(
                              context: context,
                              id: service.id,
                              name: _getLocalizedName(context, service.id),
                              icon: service.icon,
                              cardPadding: cardPadding,
                              spacing: spacing,
                              titleFontSize: titleFontSize,
                              bodyFontSize: bodyFontSize,
                              iconSize: iconSize,
                              borderRadius: borderRadius,
                            );
                          }),
                      ..._selectedApplianceSubOptions.map((applianceId) {
                        final appliance = _applianceSubOptions.firstWhere(
                          (a) => a.id == applianceId,
                        );
                        return _buildServiceSpecificSection(
                          context: context,
                          id: appliance.id,
                          name: _getLocalizedName(context, appliance.id),
                          icon: Icons.settings_suggest_outlined,
                          cardPadding: cardPadding,
                          spacing: spacing,
                          titleFontSize: titleFontSize,
                          bodyFontSize: bodyFontSize,
                          iconSize: iconSize,
                          borderRadius: borderRadius,
                        );
                      }),
                      SizedBox(height: spacing * 1.2),
                      Padding(
                        padding: EdgeInsets.only(bottom: verticalPadding),
                        child: SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isFormValid && !_isLoading
                                ? _saveData
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrangeStart,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius * 0.75,
                                ),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey[300],
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: iconSize,
                                    width: iconSize,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.saveAndContinue,
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo(String serviceId) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.selectVideoSource,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: AppLocalizations.of(context)!.camera,
                  onTap: () {
                    Navigator.pop(context);
                    _handleVideoPicking(serviceId, ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.video_library_outlined,
                  label: AppLocalizations.of(context)!.files,
                  onTap: () {
                    Navigator.pop(context);
                    _handleVideoPicking(serviceId, ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryOrangeStart, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPreview(String serviceId) {
    final controller = _videoControllers[serviceId];
    if (controller == null || !controller.value.isInitialized) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.videoPreview,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          controller.pause();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(controller),
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              controller.value.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: Colors.white.withValues(
                                alpha: controller.value.isPlaying ? 0 : 0.8,
                              ),
                              size: 60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primaryOrangeStart,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleVideoPicking(String serviceId, ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 1),
      );

      if (video != null) {
        setState(() {
          _isLoading = true;
          // Clear previous video for this service while "uploading"
          _serviceVideoPaths.remove(serviceId);
          _videoControllers[serviceId]?.dispose();
          _videoControllers.remove(serviceId);
        });

        // Mock upload progress for 2 seconds to make it feel like an upload
        await Future.delayed(const Duration(seconds: 2));

        VideoPlayerController controller;
        if (kIsWeb) {
          controller = VideoPlayerController.networkUrl(Uri.parse(video.path));
        } else {
          controller = VideoPlayerController.file(File(video.path));
        }

        try {
          await controller.initialize();
          final durationSec = controller.value.duration.inSeconds;

          if (durationSec < 5 || durationSec > 60) {
            await controller.dispose();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.videoMustBeBetween,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            _serviceVideoPaths[serviceId] = video.path;
            _videoControllers[serviceId] = controller;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.videoUploadedSuccessfully,
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } catch (e) {
          await controller.dispose();
          debugPrint('Video initialization error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppLocalizations.of(context)!.somethingWentWrong} $e',
                ),
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorPickingImage} $e',
            ),
          ),
        );
      }
    }
  }

  Widget _buildServiceSpecificSection({
    required BuildContext context,
    required String id,
    required String name,
    required IconData icon,
    required double cardPadding,
    required double spacing,
    required double titleFontSize,
    required double bodyFontSize,
    required double iconSize,
    required double borderRadius,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: spacing),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryOrangeStart,
                size: iconSize * 1.2,
              ),
              SizedBox(width: spacing * 0.6),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.serviceDetails(name),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          _buildTextField(
            context: context,
            label: AppLocalizations.of(context)!.totalExperience,
            hint: 'e.g., 5',
            controller: _getExperienceController(id),
            keyboardType: TextInputType.number,
            inputFormatters: [
              EnglishDigitFormatter(),
              FilteringTextInputFormatter.digitsOnly,
            ],
            prefixIcon: Icons.history,
            bodyFontSize: bodyFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
          SizedBox(height: spacing * 0.8),
          _buildTextField(
            context: context,
            label: AppLocalizations.of(context)!.specialSkills,
            hint: 'e.g., Industrial Wiring',
            controller: _getSkillsController(id),
            prefixIcon: Icons.stars_outlined,
            bodyFontSize: bodyFontSize,
            iconSize: iconSize,
            borderRadius: borderRadius,
            spacing: spacing,
          ),
          SizedBox(height: spacing),
          Text(
            AppLocalizations.of(context)!.workVideo,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: bodyFontSize,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: spacing * 0.6),
          _buildVideoUploadCard(
            id,
            context,
            borderRadius,
            iconSize,
            bodyFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoUploadCard(
    String serviceId,
    BuildContext context,
    double borderRadius,
    double iconSize,
    double bodyFontSize,
  ) {
    final videoPath = _serviceVideoPaths[serviceId];
    final controller = _videoControllers[serviceId];

    return GestureDetector(
      onTap: () => _pickVideo(serviceId),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: videoPath != null
                ? AppColors.successGreen
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: videoPath != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  if (controller != null && controller.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  Container(
                    color: Colors.black26,
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () => _showVideoPreview(serviceId),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showVideoPreview(serviceId),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              size: 16,
                              color: AppColors.primaryOrangeStart,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _pickVideo(serviceId),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: AppColors.primaryOrangeStart,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_call_outlined,
                    color: AppColors.primaryOrangeStart,
                    size: iconSize * 1.6,
                  ),
                  SizedBox(height: iconSize * 0.4),
                  Text(
                    AppLocalizations.of(context)!.uploadServiceVideo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: bodyFontSize,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.minMaxVideoDuration,
                    style: TextStyle(
                      fontSize: bodyFontSize * 0.86,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildServiceSelectionSection(
    BuildContext context,
    double cardPadding,
    double spacing,
    double titleFontSize,
    double bodyFontSize,
    double iconSize,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(cardPadding * 0.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(cardPadding * 0.5),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: AppColors.primaryOrangeStart,
                  size: iconSize * 1.1,
                ),
              ),
              SizedBox(width: spacing * 0.6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.workSelection,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: spacing * 0.1),
                    Text(
                      AppLocalizations.of(context)!.selectServicesProvide,
                      style: TextStyle(
                        fontSize: bodyFontSize * 0.93,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          // Service Selection Section
          Text(
            AppLocalizations.of(context)!.selectServices,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: bodyFontSize,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: spacing * 0.6),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _services.where((s) => s.id != 'appliances_repair').map((
              service,
            ) {
              final isSelected = _selectedServices.contains(service.id);
              final isAlreadyVerified =
                  _addNewServiceMode &&
                  _alreadyVerifiedServices.contains(service.id);
              return _buildServiceChip(
                id: service.id,
                name: _getLocalizedName(context, service.id),
                icon: service.icon,
                isSelected: isSelected,
                isAlreadyVerified: isAlreadyVerified,
              );
            }).toList(),
          ),
          SizedBox(height: spacing * 0.8),
          _buildAppliancesSection(
            context,
            iconSize,
            bodyFontSize,
            borderRadius,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip({
    required String id,
    required String name,
    required IconData icon,
    required bool isSelected,
    bool isAlreadyVerified = false,
  }) {
    // Already verified services are non-clickable and show verified state
    if (isAlreadyVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.successGreen, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.successGreen),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.check_circle, size: 16, color: AppColors.successGreen),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedServices.remove(id);
            // Also clean up controllers and video paths if deselected
            _serviceExperienceControllers[id]?.dispose();
            _serviceExperienceControllers.remove(id);
            _serviceSkillsControllers[id]?.dispose();
            _serviceSkillsControllers.remove(id);
            _videoControllers[id]?.dispose();
            _videoControllers.remove(id);
            _serviceVideoPaths.remove(id);
          } else {
            _selectedServices.add(id);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrangeStart : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrangeStart
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliancesSection(
    BuildContext context,
    double iconSize,
    double bodyFontSize,
    double borderRadius,
  ) {
    final isSelected = _selectedServices.contains('appliances_repair');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryOrangeStart : Colors.grey[300]!,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedServices.remove('appliances_repair');

                  // Cleanup general category data
                  _serviceExperienceControllers['appliances_repair']?.dispose();
                  _serviceExperienceControllers.remove('appliances_repair');
                  _serviceSkillsControllers['appliances_repair']?.dispose();
                  _serviceSkillsControllers.remove('appliances_repair');
                  _videoControllers['appliances_repair']?.dispose();
                  _videoControllers.remove('appliances_repair');
                  _serviceVideoPaths.remove('appliances_repair');

                  // Also cleanup all sub-options data
                  for (var optionId in _selectedApplianceSubOptions) {
                    _serviceExperienceControllers[optionId]?.dispose();
                    _serviceExperienceControllers.remove(optionId);
                    _serviceSkillsControllers[optionId]?.dispose();
                    _serviceSkillsControllers.remove(optionId);
                    _videoControllers[optionId]?.dispose();
                    _videoControllers.remove(optionId);
                    _serviceVideoPaths.remove(optionId);
                  }
                  _selectedApplianceSubOptions.clear();
                  _isAppliancesExpanded = false;
                } else {
                  _selectedServices.add('appliances_repair');
                  _isAppliancesExpanded = true;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOrangeStart.withValues(alpha: 0.15)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_repair_service,
                      size: iconSize,
                      color: isSelected
                          ? AppColors.primaryOrangeStart
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.appliancesRepair,
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryOrangeStart
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedApplianceSubOptions.isNotEmpty)
                          Text(
                            AppLocalizations.of(context)!.countSelected(
                              _selectedApplianceSubOptions.length,
                            ),
                            style: TextStyle(
                              fontSize: bodyFontSize * 0.86,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOrangeStart
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryOrangeStart
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isAppliancesExpanded = !_isAppliancesExpanded;
                        });
                      },
                      child: Icon(
                        _isAppliancesExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Sub-options (expandable)
          if (isSelected && _isAppliancesExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectAppliancesRepair,
                    style: TextStyle(
                      fontSize: bodyFontSize * 0.93,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _applianceSubOptions.map((option) {
                      final isSubSelected = _selectedApplianceSubOptions
                          .contains(option.id);
                      final isAlreadyVerified =
                          _addNewServiceMode &&
                          _alreadyVerifiedAppliances.contains(option.id);

                      // Already verified appliance - show with green tick, non-clickable
                      if (isAlreadyVerified) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.successGreen,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getLocalizedName(context, option.id),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.successGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppColors.successGreen,
                              ),
                            ],
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSubSelected) {
                              _selectedApplianceSubOptions.remove(option.id);
                              // Cleanup
                              _serviceExperienceControllers[option.id]
                                  ?.dispose();
                              _serviceExperienceControllers.remove(option.id);
                              _serviceSkillsControllers[option.id]?.dispose();
                              _serviceSkillsControllers.remove(option.id);
                              _videoControllers[option.id]?.dispose();
                              _videoControllers.remove(option.id);
                              _serviceVideoPaths.remove(option.id);
                            } else {
                              _selectedApplianceSubOptions.add(option.id);
                              // Ensure main category is selected
                              _selectedServices.add('appliances_repair');
                            }

                            // If no sub-options are selected, uncheck the main category
                            if (_selectedApplianceSubOptions.isEmpty) {
                              _selectedServices.remove('appliances_repair');
                              _isAppliancesExpanded = false;
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSubSelected
                                ? AppColors.primaryOrangeStart.withValues(
                                    alpha: 0.15,
                                  )
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSubSelected
                                  ? AppColors.primaryOrangeStart
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSubSelected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: AppColors.primaryOrangeStart,
                                  ),
                                ),
                              Text(
                                _getLocalizedName(context, option.id),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSubSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSubSelected
                                      ? AppColors.primaryOrangeStart
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required double bodyFontSize,
    required double iconSize,
    required double borderRadius,
    required double spacing,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: bodyFontSize,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: spacing * 0.4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (_) => setState(() {}),
          style: TextStyle(fontSize: bodyFontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: bodyFontSize * 0.93,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[500], size: iconSize)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: spacing * 0.8,
              vertical: spacing * 0.7,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.75),
              borderSide: const BorderSide(
                color: AppColors.primaryOrangeStart,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
