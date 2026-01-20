import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock location details
  String _city = "Kolkata";
  String _state = "West Bengal";
  String _country = "India";
  String _pincode = "700001";
  bool _hideHelp = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('hideHelp')) {
      _hideHelp = args['hideHelp'] as bool;
    }
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('location_city');
      final savedState = prefs.getString('location_state');
      final savedCountry = prefs.getString('location_country');
      final savedPincode = prefs.getString('location_pincode');

      if (savedCity != null && mounted) {
        setState(() {
          _city = savedCity;
          _state = savedState ?? _state;
          _country = savedCountry ?? _country;
          _pincode = savedPincode ?? _pincode;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _saveLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location_city', _city);
      await prefs.setString('location_state', _state);
      await prefs.setString('location_country', _country);
      await prefs.setString('location_pincode', _pincode);
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  Future<bool> _handlePermissionRequest() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.locationPermissionsDenied,
              ),
            ),
          );
        }
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  Future<void> _useCurrentLocation() async {
    final hasPermission = await _handlePermissionRequest();
    if (!hasPermission) return;

    try {
      // Show loading state if needed (optional)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fetchingYourLocation),
          ),
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!kIsWeb) {
        // Use geocoding package for Mobile
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            setState(() {
              _city =
                  place.locality ??
                  place.subAdministrativeArea ??
                  AppLocalizations.of(context)!.unknown;
              _state = place.administrativeArea ?? "";
              _country = place.country ?? "";
              _pincode = place.postalCode ?? "";
            });
            await _saveLocation();
          }
        } catch (e) {
          debugPrint('Geocoding error: $e');
          // Fallback if geocoding fails
          setState(() {
            _city = "Lat: ${position.latitude.toStringAsFixed(2)}";
            _state = "Long: ${position.longitude.toStringAsFixed(2)}";
            _country = AppLocalizations.of(context)!.unknown;
            _pincode = AppLocalizations.of(context)!.notAvailable;
          });
          await _saveLocation();
        }
      } else {
        // For Web, geocoding package is not supported
        // Since we can't easily reverse geocode on web without an API key,
        // we'll show a more realistic mock or use the coordinates.
        setState(() {
          _city = "Kakhuria (Web)";
          _state = "West Bengal";
          _country = "India";
          _pincode = "721444";
        });
        await _saveLocation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _confirmLocation() async {
    await _saveLocation();
    if (mounted) {
      Navigator.pop(context, _city);
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
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
                // ignore: deprecated_member_use
                icon: MdiIcons.whatsapp,
                title: AppLocalizations.of(context)!.chatWithSupport,
                subtitle: AppLocalizations.of(context)!.whatsAppSupport,
                color: const Color(0xFF25D366), // WhatsApp Green
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
                      const SnackBar(
                        content: Text('Could not launch WhatsApp'),
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
              const Divider(height: 1, indent: 80),
              _buildHelpOption(
                icon: Icons.logout_rounded,
                title: AppLocalizations.of(context)!.logout,
                subtitle: AppLocalizations.of(context)!.signOutOfYourAccount,
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _showLogoutConfirmation();
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: title == AppLocalizations.of(context)!.logout
              ? Colors.red
              : AppColors.textPrimary,
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

    // Responsive sizing
    final horizontalPadding = (screenWidth * 0.06).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(12.0, 20.0);
    final headingFontSize = (screenWidth * 0.055).clamp(20.0, 24.0);
    final buttonHeight = (screenHeight * 0.065).clamp(56.0, 64.0);
    final buttonFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final locationIconSize = (screenWidth * 0.07).clamp(20.0, 28.0);
    final cityFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final detailsFontSize = (screenWidth * 0.035).clamp(13.0, 15.0);

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
          top: false,
          child: Column(
            children: [
              // Styled Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: screenWidth * 0.02,
                  right: screenWidth * 0.02,
                  bottom: verticalPadding,
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
                        size: (screenWidth * 0.05).clamp(18.0, 22.0),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.locationSelection,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Help button
                    if (!_hideHelp)
                      InkWell(
                        onTap: _showHelpOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.01,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: (screenWidth * 0.05).clamp(18.0, 22.0),
                                color: Colors.white,
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Text(
                                AppLocalizations.of(context)!.help,
                                style: TextStyle(
                                  fontSize: (screenWidth * 0.04).clamp(
                                    14.0,
                                    18.0,
                                  ),
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
                  padding: EdgeInsets.all(horizontalPadding.clamp(20.0, 28.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Heading
                      Text(
                        AppLocalizations.of(context)!.confirmLocationToEarn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: headingFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onTap: _handlePermissionRequest,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.searchForLocation,
                            hintStyle: TextStyle(fontSize: detailsFontSize),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: locationIconSize * 0.85,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025),

                      // Use Current Location Option
                      InkWell(
                        onTap: _useCurrentLocation,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.018,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrangeStart.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryOrangeStart.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                color: AppColors.primaryOrangeStart,
                                size: locationIconSize * 0.8,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.useCurrentLocation,
                                  style: TextStyle(
                                    color: AppColors.primaryOrangeStart,
                                    fontWeight: FontWeight.w600,
                                    fontSize: buttonFontSize,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      // Location Details Section (Redesigned Style)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Left Accent Line
                              Container(
                                width: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryOrangeStart,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          screenWidth * 0.03,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOrangeStart
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: AppColors.primaryOrangeStart,
                                          size: locationIconSize,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.04),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    _city,
                                                    style: TextStyle(
                                                      fontSize: cityFontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .successGreen
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.selected,
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .successGreen,
                                                      fontSize:
                                                          (detailsFontSize *
                                                          0.75),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '$_state, $_country, $_pincode',
                                              style: TextStyle(
                                                fontSize: detailsFontSize,
                                                color: AppColors.textSecondary,
                                                height: 1.4,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ],
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
                      SizedBox(height: screenHeight * 0.03),

                      // Why we need your location Note
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: locationIconSize * 0.65,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.whyWeNeedLocation,
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: detailsFontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.locationExplanation,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: detailsFontSize * 0.9,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      // Bottom Button
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrangeStart,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.useThisLocationForEarning,
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
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
}
