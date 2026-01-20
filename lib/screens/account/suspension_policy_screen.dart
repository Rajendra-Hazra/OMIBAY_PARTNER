import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class SuspensionPolicyScreen extends StatelessWidget {
  const SuspensionPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 24.0 * paddingScale;
    final vPadding = 24.0 * paddingScale;
    final headerTitleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final mainTitleFontSize = (screenWidth * 0.065).clamp(20.0, 28.0);
    final sectionTitleFontSize = (screenWidth * 0.048).clamp(16.0, 20.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.055).clamp(18.0, 24.0);

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, headerTitleFontSize, iconSize),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: hPadding,
                  vertical: vPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suspensionPolicyTitle,
                      style: TextStyle(
                        fontSize: mainTitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16 * paddingScale),
                    Text(
                      l10n.lastUpdated('January 2026'),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: bodyFontSize,
                      ),
                    ),
                    SizedBox(height: 32 * paddingScale),
                    _buildSection(
                      l10n.suspensionPurposeTitle,
                      l10n.suspensionPurposeContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionTypesTitle,
                      l10n.suspensionTypesContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionTempReasonsTitle,
                      l10n.suspensionTempReasonsContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionTempActionTitle,
                      l10n.suspensionTempActionContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionPermReasonsTitle,
                      l10n.suspensionPermReasonsContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionPermActionTitle,
                      l10n.suspensionPermActionContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionNotifyTitle,
                      l10n.suspensionNotifyContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionAppealTitle,
                      l10n.suspensionAppealContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionReactivateTitle,
                      l10n.suspensionReactivateContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    _buildSection(
                      l10n.suspensionFinalNoteTitle,
                      l10n.suspensionFinalNoteContent,
                      sectionTitleFontSize,
                      bodyFontSize,
                      paddingScale,
                    ),
                    SizedBox(height: 40 * paddingScale),
                    Center(
                      child: Text(
                        l10n.suspensionContact,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: smallFontSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24 * paddingScale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double iconSize,
  ) {
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
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.9),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.suspensionPolicyTitle,
              style: TextStyle(
                fontSize: titleFontSize,
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

  Widget _buildSection(
    String title,
    String content,
    double titleFontSize,
    double contentFontSize,
    double paddingScale,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0 * paddingScale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12 * paddingScale),
          Text(
            content,
            style: TextStyle(
              fontSize: contentFontSize,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
