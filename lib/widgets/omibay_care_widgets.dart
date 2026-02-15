import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/app_colors.dart';
import '../models/partner_stats.dart';
import '../l10n/app_localizations.dart';

/// OmiBay Care Container - Main section widget for Account screen
/// Displays partner welfare benefits with eligibility tracking
class OmiBayCareContainer extends StatelessWidget {
  final PartnerStats stats;
  final VoidCallback onHealthCheckupTap;
  final VoidCallback onHealthInsuranceTap;
  final VoidCallback onEquipmentLoanTap;
  final VoidCallback onEmergencyLoanTap;

  const OmiBayCareContainer({
    super.key,
    required this.stats,
    required this.onHealthCheckupTap,
    required this.onHealthInsuranceTap,
    required this.onEquipmentLoanTap,
    required this.onEmergencyLoanTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient (dark navy like profile section)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.omiBayCare,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.healthAndFinancialSupport,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Eligibility Progress Row
                EligibilityProgressRow(stats: stats),
              ],
            ),
          ),
          // Benefits List
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                BenefitListItem(
                  icon: Icons.medical_services_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: l10n.freeHealthCheckup,
                  description: l10n.annualHealthCheckupVoucher,
                  isEligible: stats.isHealthCheckEligible(),
                  onTap: onHealthCheckupTap,
                ),
                const SizedBox(height: 8),
                BenefitListItem(
                  icon: Icons.health_and_safety_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: l10n.healthInsurance,
                  description: l10n.comprehensiveHealthCoverage,
                  isEligible: stats.isHealthInsuranceEligible(),
                  onTap: onHealthInsuranceTap,
                ),
                const SizedBox(height: 8),
                BenefitListItem(
                  icon: Icons.build_circle_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: l10n.equipmentLoan,
                  description: l10n.toolsAndEquipmentFinancing,
                  isEligible: stats.isEquipmentLoanEligible(),
                  onTap: onEquipmentLoanTap,
                ),
                const SizedBox(height: 8),
                BenefitListItem(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFEF4444),
                  title: l10n.emergencyLoan,
                  description: l10n.instantFinancialAssistance,
                  isEligible: stats.isEmergencyLoanEligible(),
                  onTap: onEmergencyLoanTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eligibility Progress Row - Shows active days and monthly jobs progress
class EligibilityProgressRow extends StatelessWidget {
  final PartnerStats stats;

  const EligibilityProgressRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildProgressItem(
              context: context,
              icon: Icons.calendar_today_rounded,
              label: l10n.activeDays,
              current: stats.activeDays,
              target: OmiBayCareConfig.equipmentLoanDays,
              progress: stats.getActiveDaysProgress(
                OmiBayCareConfig.equipmentLoanDays,
              ),
            ),
          ),
          Container(
            height: 36,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: _buildProgressItem(
              context: context,
              icon: Icons.work_rounded,
              label: l10n.monthlyJobs,
              current: stats.monthlyJobs,
              target: OmiBayCareConfig.targetMonthlyJobs,
              progress: stats.getMonthlyJobsProgress(
                OmiBayCareConfig.targetMonthlyJobs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int current,
    required int target,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(
              '$current / $target',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Benefit List Item - Individual benefit option in the container
class BenefitListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isEligible;
  final VoidCallback onTap;

  const BenefitListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isEligible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              _buildStatusBadge(context),
              const SizedBox(width: 8),
              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Feature not launched - always show Coming Soon
    if (!OmiBayCareConfig.featureLaunchEnabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.darkNavyStart.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 12,
              color: AppColors.darkNavyStart,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.soon,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavyStart,
              ),
            ),
          ],
        ),
      );
    }

    // Show eligibility status when feature is launched
    if (isEligible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 12,
              color: AppColors.successGreen,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.eligible,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
      );
    }

    // Locked state
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, size: 12, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            l10n.locked,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coming Soon Card - Large card showing feature not available yet
class ComingSoonCard extends StatelessWidget {
  final bool isEligible;
  final String eligibilityMessage;

  const ComingSoonCard({
    super.key,
    required this.isEligible,
    this.eligibilityMessage = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkNavyStart.withValues(alpha: 0.05),
            AppColors.darkNavyEnd.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkNavyStart.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkNavyStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.darkNavyStart,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.launchingSoon,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.weArePreparingThisBenefit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          if (isEligible) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    eligibilityMessage.isNotEmpty
                        ? eligibilityMessage
                        : l10n.youAreEligible,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Locked Overlay - Blur overlay for locked content
class LockedOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final String message;

  const LockedOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    this.message = 'Complete more jobs to unlock',
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) return child;

    return Stack(
      children: [
        // Blurred content
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: child,
          ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: Colors.grey.shade500,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Eligibility Requirement Row - Shows individual eligibility requirement
class EligibilityRequirementRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String requirement;
  final bool isMet;

  const EligibilityRequirementRow({
    super.key,
    required this.icon,
    required this.title,
    required this.requirement,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMet
            ? AppColors.successGreen.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMet
              ? AppColors.successGreen.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMet
                  ? AppColors.successGreen.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isMet ? AppColors.successGreen : Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  requirement,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isMet ? AppColors.successGreen : Colors.grey.shade400,
            size: 22,
          ),
        ],
      ),
    );
  }
}
