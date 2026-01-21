import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final String phoneNumber = l10n.whatsappSupportNumber;
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri emailUri = Uri.parse("mailto:${l10n.supportEmail}");
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch Email');
    }
  }

  void _showCallPicker(
    BuildContext context,
    double borderRadius,
    double fontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, String>> phoneNumbers = [
      {'label': l10n.supportLine1, 'number': l10n.supportNumber1},
      {'label': l10n.supportLine2, 'number': l10n.supportNumber2},
      {'label': l10n.supportLine3, 'number': l10n.supportNumber3},
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectNumberToCall,
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...phoneNumbers.map((phone) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone,
                      color: Colors.blue,
                      size: fontSize * 1.2,
                    ),
                  ),
                  title: Text(
                    phone['label']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                  subtitle: Text(
                    phone['number']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: fontSize * 0.85,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri phoneUri = Uri.parse(
                      "tel:${phone['number']!.replaceAll(' ', '')}",
                    );
                    if (!await launchUrl(phoneUri)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.couldNotLaunchDialer)),
                        );
                      }
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.02).clamp(16.0, 24.0);
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final subFontSize = (screenWidth * 0.032).clamp(12.0, 14.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);
    final borderRadius = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, titleFontSize, borderRadius),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildContactOptions(
                      context,
                      horizontalPadding,
                      verticalPadding,
                      titleFontSize,
                      bodyFontSize,
                      borderRadius,
                    ),
                    Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.frequentlyAskedQuestions,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: subFontSize,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FaqItem(
                            question: l10n.supportFaqQuestion1,
                            answer: l10n.supportFaqAnswer1,
                            fontSize: bodyFontSize,
                            borderRadius: borderRadius,
                            iconSize: iconSize * 0.8,
                          ),
                          _FaqItem(
                            question: l10n.supportFaqQuestion2,
                            answer: l10n.supportFaqAnswer2,
                            fontSize: bodyFontSize,
                            borderRadius: borderRadius,
                            iconSize: iconSize * 0.8,
                          ),
                          _FaqItem(
                            question: l10n.supportFaqQuestion3,
                            answer: l10n.supportFaqAnswer3,
                            fontSize: bodyFontSize,
                            borderRadius: borderRadius,
                            iconSize: iconSize * 0.8,
                          ),
                          _FaqItem(
                            question: l10n.supportFaqQuestion4,
                            answer: l10n.supportFaqAnswer4,
                            fontSize: bodyFontSize,
                            borderRadius: borderRadius,
                            iconSize: iconSize * 0.8,
                          ),
                          _FaqItem(
                            question: l10n.supportFaqQuestion5,
                            answer: l10n.supportFaqAnswer5,
                            fontSize: bodyFontSize,
                            borderRadius: borderRadius,
                            iconSize: iconSize * 0.8,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/account-faq');
                              },
                              icon: Text(
                                l10n.viewAllFaqs,
                                style: TextStyle(
                                  color: AppColors.primaryOrangeStart,
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize,
                                ),
                              ),
                              label: Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.primaryOrangeStart,
                                size: iconSize * 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSupportContactSection(
                      context,
                      horizontalPadding,
                      borderRadius,
                      subFontSize,
                      bodyFontSize,
                    ),
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
    double fontSize,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 16,
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: fontSize * 0.9,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.helpAndSupport,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions(
    BuildContext context,
    double horizontalPadding,
    double verticalPadding,
    double titleFontSize,
    double bodyFontSize,
    double borderRadius,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(verticalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.howCanWeHelp,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: verticalPadding),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio:
                (MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height * 0.3))
                    .clamp(1.3, 1.8),
            children: [
              _ContactCard(
                icon: Icons.chat_bubble_outline_rounded,
                title: l10n.liveChat,
                subtitle: l10n.chatWithSupport,
                color: AppColors.primaryOrangeStart,
                onTap: () {
                  Navigator.pushNamed(context, '/live-chat');
                },
                fontSize: bodyFontSize,
                borderRadius: borderRadius,
              ),
              _ContactCard(
                icon: Icons.phone,
                title: l10n.callUs,
                subtitle: l10n.support247,
                color: Colors.blue,
                onTap: () =>
                    _showCallPicker(context, borderRadius, bodyFontSize),
                fontSize: bodyFontSize,
                borderRadius: borderRadius,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchWhatsApp(context),
            borderRadius: BorderRadius.circular(borderRadius * 0.8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(borderRadius * 0.8),
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      // ignore: deprecated_member_use
                      MdiIcons.whatsapp,
                      color: const Color(0xFF25D366),
                      size: bodyFontSize * 1.8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.whatsAppChat,
                          style: TextStyle(
                            color: const Color(0xFF075E54),
                            fontWeight: FontWeight.bold,
                            fontSize: bodyFontSize * 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.connectQuickSupport,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: bodyFontSize * 0.85,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.whatsappResponseTime,
                          style: TextStyle(
                            color: const Color(0xFF25D366),
                            fontSize: bodyFontSize * 0.7,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF25D366)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportContactSection(
    BuildContext context,
    double horizontalPadding,
    double borderRadius,
    double subFontSize,
    double bodyFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 40,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.darkNavyStart,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.contactInformation,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: subFontSize,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildContactInfoItem(
              icon: Icons.phone_in_talk_rounded,
              title: l10n.callUs,
              value: l10n.supportNumbers('+91 8016867006'),
              onTap: () => _showCallPicker(context, borderRadius, bodyFontSize),
              fontSize: bodyFontSize,
            ),
            const Divider(
              height: 1,
              indent: 60,
              endIndent: 16,
              color: Colors.white10,
            ),
            _buildContactInfoItem(
              icon: Icons.email_rounded,
              title: l10n.emailUs,
              value: l10n.supportEmail,
              onTap: () => _launchEmail(context),
              fontSize: bodyFontSize,
            ),
            const Divider(
              height: 1,
              indent: 60,
              endIndent: 16,
              color: Colors.white10,
            ),
            _buildContactInfoItem(
              icon: Icons.access_time_filled_rounded,
              title: l10n.workingHours,
              value: l10n.workingHoursTime,
              fontSize: bodyFontSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required double fontSize,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: fontSize * 1.3),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: fontSize * 0.75,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.95,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: fontSize * 0.8,
                color: Colors.white38,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;
  final double borderRadius;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.fontSize,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive padding and sizing
    final cardPadding = (screenWidth * 0.04).clamp(12.0, 20.0);
    final iconSize = (screenWidth * 0.12).clamp(32.0, 48.0);
    final titleFontSize = (screenWidth * 0.038).clamp(14.0, 17.0);
    final subtitleFontSize = (screenWidth * 0.03).clamp(11.0, 13.0);
    final spacing = (screenHeight * 0.01).clamp(6.0, 10.0);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(borderRadius * 0.8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: spacing),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: spacing * 0.5),
            Flexible(
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: subtitleFontSize,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final double fontSize;
  final double borderRadius;
  final double iconSize;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.fontSize,
    required this.borderRadius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius * 0.8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryOrangeStart,
              size: iconSize,
            ),
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: fontSize * 1.05,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.primaryOrangeStart,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: iconSize * 3,
                right: 16,
                bottom: 20,
              ),
              child: Text(
                answer,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: fontSize * 0.95,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
