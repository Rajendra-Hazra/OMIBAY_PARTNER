/// Partner Statistics Model for OmiBay Care Eligibility
/// This model tracks partner activity and calculates eligibility for various benefits.

class PartnerStats {
  /// Number of active days the partner has worked
  final int activeDays;

  /// Number of jobs completed in the current month
  final int monthlyJobs;

  /// Whether the partner has stable weekly earnings (consistent for 4+ weeks)
  final bool weeklyEarningsStable;

  /// Whether the partner has a high job completion rate (>90%)
  final bool jobCompletionRateHigh;

  /// Total jobs completed overall
  final int totalJobsCompleted;

  /// Partner's current rating
  final double rating;

  const PartnerStats({
    this.activeDays = 0,
    this.monthlyJobs = 0,
    this.weeklyEarningsStable = false,
    this.jobCompletionRateHigh = false,
    this.totalJobsCompleted = 0,
    this.rating = 0.0,
  });

  /// Create from JSON map (for future API integration)
  factory PartnerStats.fromJson(Map<String, dynamic> json) {
    return PartnerStats(
      activeDays: json['active_days'] ?? 0,
      monthlyJobs: json['monthly_jobs'] ?? 0,
      weeklyEarningsStable: json['weekly_earnings_stable'] ?? false,
      jobCompletionRateHigh: json['job_completion_rate_high'] ?? false,
      totalJobsCompleted: json['total_jobs_completed'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'active_days': activeDays,
      'monthly_jobs': monthlyJobs,
      'weekly_earnings_stable': weeklyEarningsStable,
      'job_completion_rate_high': jobCompletionRateHigh,
      'total_jobs_completed': totalJobsCompleted,
      'rating': rating,
    };
  }

  /// Create dummy data for testing/preview
  factory PartnerStats.dummy() {
    return const PartnerStats(
      activeDays: 72,
      monthlyJobs: 15,
      weeklyEarningsStable: true,
      jobCompletionRateHigh: false,
      totalJobsCompleted: 45,
      rating: 4.5,
    );
  }

  /// Check if partner is eligible for Free Health Checkup
  /// Requirement: Active Days >= 60
  bool isHealthCheckEligible() {
    return activeDays >= OmiBayCareConfig.healthCheckDays;
  }

  /// Check if partner is eligible for Health Insurance
  /// Requirement: Active Days >= 75 AND rating >= 4.0
  bool isHealthInsuranceEligible() {
    return activeDays >= OmiBayCareConfig.healthInsuranceDays && rating >= 4.0;
  }

  /// Check if partner is eligible for Equipment Loan
  /// Requirement: Active Days >= 90 AND weekly earnings stable
  bool isEquipmentLoanEligible() {
    return activeDays >= OmiBayCareConfig.equipmentLoanDays &&
        weeklyEarningsStable;
  }

  /// Check if partner is eligible for Emergency Loan
  /// Requirement: Active Days >= 120 AND high job completion rate
  bool isEmergencyLoanEligible() {
    return activeDays >= OmiBayCareConfig.emergencyLoanDays &&
        jobCompletionRateHigh;
  }

  /// Get progress percentage for active days towards a target
  double getActiveDaysProgress(int targetDays) {
    if (targetDays <= 0) return 1.0;
    return (activeDays / targetDays).clamp(0.0, 1.0);
  }

  /// Get progress percentage for monthly jobs towards a target
  double getMonthlyJobsProgress(int targetJobs) {
    if (targetJobs <= 0) return 1.0;
    return (monthlyJobs / targetJobs).clamp(0.0, 1.0);
  }

  /// Copy with new values
  PartnerStats copyWith({
    int? activeDays,
    int? monthlyJobs,
    bool? weeklyEarningsStable,
    bool? jobCompletionRateHigh,
    int? totalJobsCompleted,
    double? rating,
  }) {
    return PartnerStats(
      activeDays: activeDays ?? this.activeDays,
      monthlyJobs: monthlyJobs ?? this.monthlyJobs,
      weeklyEarningsStable: weeklyEarningsStable ?? this.weeklyEarningsStable,
      jobCompletionRateHigh:
          jobCompletionRateHigh ?? this.jobCompletionRateHigh,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
      rating: rating ?? this.rating,
    );
  }
}

/// Configuration for OmiBay Care feature thresholds
/// These values can be updated from backend in the future
class OmiBayCareConfig {
  /// Days required for health checkup eligibility
  static const int healthCheckDays = 60;

  /// Days required for health insurance eligibility
  static const int healthInsuranceDays = 75;

  /// Days required for equipment loan eligibility
  static const int equipmentLoanDays = 90;

  /// Days required for emergency loan eligibility
  static const int emergencyLoanDays = 120;

  /// Target monthly jobs for progress display
  static const int targetMonthlyJobs = 20;

  /// Whether the feature is launched and active
  /// Currently false - all features show "Coming Soon"
  static const bool featureLaunchEnabled = false;

  /// Private constructor to prevent instantiation
  OmiBayCareConfig._();
}

/// Enum for benefit eligibility status
enum BenefitStatus {
  /// User is eligible and can use the benefit (when launched)
  eligible,

  /// User is not eligible yet - needs to meet requirements
  locked,

  /// Feature is not yet launched - show coming soon
  comingSoon,
}

/// Extension to get display properties for benefit status
extension BenefitStatusExtension on BenefitStatus {
  String get displayText {
    switch (this) {
      case BenefitStatus.eligible:
        return 'Eligible';
      case BenefitStatus.locked:
        return 'Locked';
      case BenefitStatus.comingSoon:
        return 'Coming Soon';
    }
  }

  bool get isAccessible {
    // User can always tap to see details, even if locked
    return true;
  }
}
