import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';
import '../../repositories/partner_service_repository.dart';
import '../../repositories/partner_document_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

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
  String? _compressionStatus;
  bool _addNewServiceMode =
      false; // Flag to indicate adding new service from Edit Services
  final PartnerServiceRepository _serviceRepository =
      PartnerServiceRepositoryImpl(
        apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
      );
  final PartnerDocumentRepository _documentRepository =
      PartnerDocumentRepositoryImpl(
        apiClient: ApiClient(baseUrl: ApiEndpoints.baseUrl),
      );
  List<ServiceType> _availableServiceTypes = [];

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'carpenter':
        return Icons.carpenter;
      case 'grass':
        return Icons.grass;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'face':
        return Icons.face;
      case 'face_3':
        return Icons.face_3;
      case 'brush':
        return Icons.brush;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'home_repair_service':
        return Icons.home_repair_service;
      default:
        return Icons.work_outline;
    }
  }

  // Already verified services (non-clickable in addNewService mode)
  Set<String> _alreadyVerifiedServices = {};

  // Service selection state
  final Set<String> _selectedServices = {};

  // Available services (removed hardcoded list)
  // Appliance sub-options (removed hardcoded list)
  final Map<String, TextEditingController> _serviceExperienceControllers = {};
  final Map<String, TextEditingController> _serviceSkillsControllers = {};
  final Map<String, String?> _serviceVideoPaths = {};
  final Map<String, VideoPlayerController?> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    // Delay to get route arguments after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableServices();
      _checkArguments();
    });
  }

  Future<void> _fetchAvailableServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceRepository.getAvailableServiceTypes();
      setState(() {
        _availableServiceTypes = services;
      });
    } catch (e) {
      debugPrint('Error fetching available services: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

      Set<String> verifiedServices = {};

      // Check which services are fully verified (have experience + video)
      for (String serviceId in savedServices) {
        final hasExperience =
            prefs.getString('exp_$serviceId')?.isNotEmpty ?? false;
        final hasVideo = prefs.getString('video_$serviceId') != null;
        if (hasExperience && hasVideo) {
          verifiedServices.add(serviceId);
        }
      }

      setState(() {
        _alreadyVerifiedServices = verifiedServices;
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
        }
      });
    } catch (e) {
      debugPrint('Error loading work verification data: $e');
    }
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();

      List<PartnerServiceDetail> serviceDetails = [];

      // 1. Process each selected service
      for (String serviceId in _selectedServices) {
        String? videoUrl;

        // Compress and Upload video if exists
        String? videoPath = _serviceVideoPaths[serviceId];
        if (videoPath != null && !videoPath.startsWith('http')) {
          // Compressing video before upload
          if (!kIsWeb) {
            setState(() => _compressionStatus = 'Compressing Skill Video...');
            final compressedVideo = await _compressVideo(videoPath);
            if (compressedVideo != null) {
              videoPath = compressedVideo;
            }
            setState(() => _compressionStatus = null);
          }

          // It's a local path, needs upload
          await _documentRepository.uploadDocument(
            documentType: 'SKILL_VIDEO',
            filePath: videoPath,
          );
        }

        serviceDetails.add(
          PartnerServiceDetail(
            serviceTypeId: serviceId,
            experience: _serviceExperienceControllers[serviceId]?.text,
            specialSkills: _serviceSkillsControllers[serviceId]?.text,
            videoUrl:
                videoUrl, // This might be null or the path if backend doesn't return URL
          ),
        );

        // Save locally too for offline/state persistence
        if (_serviceExperienceControllers[serviceId]?.text.isNotEmpty ??
            false) {
          await prefs.setString(
            'exp_$serviceId',
            _serviceExperienceControllers[serviceId]!.text,
          );
        }
        if (_serviceSkillsControllers[serviceId]?.text.isNotEmpty ?? false) {
          await prefs.setString(
            'skills_$serviceId',
            _serviceSkillsControllers[serviceId]!.text,
          );
        }
        if (videoPath != null) {
          await prefs.setString('video_$serviceId', videoPath);
        }
      }

      // 2. Update partner services on backend
      await _serviceRepository.updatePartnerServices(serviceDetails);

      // 3. Mark as verified in local prefs
      await prefs.setBool('skill_verified', true);
      await prefs.setStringList('profile_services', _selectedServices.toList());

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _compressVideo(String videoPath) async {
    try {
      // Show compression progress or message if possible
      debugPrint('Starting video compression for: $videoPath');

      final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false, // Keep original just in case
        includeAudio: true,
      );

      if (mediaInfo != null && mediaInfo.path != null) {
        debugPrint('Compression finished: ${mediaInfo.path}');
        return mediaInfo.path;
      }
    } catch (e) {
      debugPrint('Video compression error: $e');
    }
    return null;
  }

  bool get _isFormValid {
    if (_selectedServices.isEmpty) {
      return false;
    }

    for (String serviceId in _selectedServices) {
      if (_getExperienceController(serviceId).text.isEmpty) return false;
      if (_serviceVideoPaths[serviceId] == null) return false;
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
                      ..._selectedServices.map((serviceId) {
                        final service = _availableServiceTypes.firstWhere(
                          (s) => s.id == serviceId,
                          orElse: () =>
                              ServiceType(id: serviceId, name: serviceId),
                        );
                        return _buildServiceSpecificSection(
                          context: context,
                          id: service.id,
                          name: service.name,
                          icon: _getIconData(service.icon),
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
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: iconSize,
                                        width: iconSize,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      if (_compressionStatus != null) ...[
                                        SizedBox(width: spacing * 0.5),
                                        Text(
                                          _compressionStatus!,
                                          style: TextStyle(
                                            fontSize: bodyFontSize * 0.9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
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
    if (source == ImageSource.camera) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.requestingCameraAccess),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        var status = await Permission.camera.status;
        if (!status.isGranted) {
          status = await Permission.camera.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.cameraPermissionRequired,
                  ),
                ),
              );
            }
            return;
          }
        }
      }
    } else if (source == ImageSource.gallery) {
      if (!kIsWeb) {
        PermissionStatus status;
        if (Platform.isAndroid) {
          if (await Permission.photos.isGranted ||
              await Permission.storage.isGranted) {
            status = PermissionStatus.granted;
          } else {
            status = await Permission.photos.request();
            if (status.isDenied || status.isPermanentlyDenied) {
              status = await Permission.storage.request();
            }
          }
        } else {
          status = await Permission.photos.request();
        }

        if (!status.isGranted && !status.isLimited) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.galleryPermissionRequired,
                ),
              ),
            );
          }
          return;
        }
      }
    }

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
          // final durationSec = controller.value.duration.inSeconds;

          // if (durationSec < 30 || durationSec > 60) {
          //   await controller.dispose();
          //   if (mounted) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text(
          //           AppLocalizations.of(context)!.videoMustBeBetween,
          //         ),
          //         backgroundColor: Colors.red,
          //       ),
          //     );
          //   }
          //   return;
          // }

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
            children: _availableServiceTypes.map((service) {
              final isSelected = _selectedServices.contains(service.id);
              final isAlreadyVerified =
                  _addNewServiceMode &&
                  _alreadyVerifiedServices.contains(service.id);
              return _buildServiceChip(
                id: service.id,
                name: service.name,
                icon: _getIconData(service.icon),
                isSelected: isSelected,
                isAlreadyVerified: isAlreadyVerified,
              );
            }).toList(),
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
