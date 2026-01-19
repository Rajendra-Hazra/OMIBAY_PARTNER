import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class SuspensionPolicyScreen extends StatelessWidget {
  const SuspensionPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.suspensionPolicyTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.lastUpdated('January 2026'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      l10n.suspensionPurposeTitle,
                      l10n.suspensionPurposeContent,
                    ),
                    _buildSection(
                      l10n.suspensionTypesTitle,
                      l10n.suspensionTypesContent,
                    ),
                    _buildSection(
                      l10n.suspensionTempReasonsTitle,
                      l10n.suspensionTempReasonsContent,
                    ),
                    _buildSection(
                      l10n.suspensionTempActionTitle,
                      l10n.suspensionTempActionContent,
                    ),
                    _buildSection(
                      l10n.suspensionPermReasonsTitle,
                      l10n.suspensionPermReasonsContent,
                    ),
                    _buildSection(
                      l10n.suspensionPermActionTitle,
                      l10n.suspensionPermActionContent,
                    ),
                    _buildSection(
                      l10n.suspensionNotifyTitle,
                      l10n.suspensionNotifyContent,
                    ),
                    _buildSection(
                      l10n.suspensionAppealTitle,
                      l10n.suspensionAppealContent,
                    ),
                    _buildSection(
                      l10n.suspensionReactivateTitle,
                      l10n.suspensionReactivateContent,
                    ),
                    _buildSection(
                      l10n.suspensionFinalNoteTitle,
                      l10n.suspensionFinalNoteContent,
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        l10n.suspensionContact,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.suspensionPolicyTitle,
              style: const TextStyle(
                fontSize: 18,
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
