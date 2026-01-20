import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<Map<String, String>> get _languages => [
    {
      'name': AppLocalizations.of(context)!.english,
      'code': 'en',
      'native': 'English',
    },
    {
      'name': AppLocalizations.of(context)!.bengali,
      'code': 'bn',
      'native': 'বাংলা',
    },
  ];

  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'en';
    setState(() {
      _selectedLanguage = savedLanguage;
    });
  }

  Future<void> _updateLanguage() async {
    await LocaleNotifier.instance.setLocale(_selectedLanguage);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.languageUpdated),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final headingFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.04).clamp(15.0, 18.0);
    final smallFontSize = (screenWidth * 0.035).clamp(12.0, 14.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);
    final buttonHeight = (screenHeight * 0.06).clamp(56.0, 64.0);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, headingFontSize, iconSize),
            Expanded(
              child: ListView.separated(
                itemCount: _languages.length,
                padding: EdgeInsets.symmetric(vertical: 8),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = _selectedLanguage == lang['code'];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 8,
                    ),
                    title: Text(
                      lang['native']!,
                      style: TextStyle(
                        fontSize: bodyFontSize,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primaryOrangeStart,
                            size: iconSize,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['code']!;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _updateLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrangeStart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.updateLanguage,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headingFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 16,
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
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.7),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.appLanguage,
              style: TextStyle(
                fontSize: headingFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
