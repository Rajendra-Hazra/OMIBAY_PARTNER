class EarningsStats {
  final double totalEarnings;
  final double walletBalance;
  final double totalTips;
  final double todayEarnings;
  final int todayJobs;
  final int totalJobs;
  final WeeklyBonus? weeklyBonus;
  final ReferralOffer? referralOffer;

  EarningsStats({
    required this.totalEarnings,
    required this.walletBalance,
    required this.totalTips,
    required this.todayEarnings,
    required this.todayJobs,
    required this.totalJobs,
    this.weeklyBonus,
    this.referralOffer,
  });

  factory EarningsStats.fromJson(Map<String, dynamic> json) {
    return EarningsStats(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      totalTips: (json['totalTips'] as num?)?.toDouble() ?? 0.0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      todayJobs: (json['todayJobs'] as num?)?.toInt() ?? 0,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      weeklyBonus: json['weeklyBonus'] != null
          ? WeeklyBonus.fromJson(json['weeklyBonus'])
          : null,
      referralOffer: json['referralOffer'] != null
          ? ReferralOffer.fromJson(json['referralOffer'])
          : null,
    );
  }
}

class ReferralOffer {
  final String title;
  final String subtitle;
  final double amount;
  final String actionText;

  ReferralOffer({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.actionText,
  });

  factory ReferralOffer.fromJson(Map<String, dynamic> json) {
    return ReferralOffer(
      title: json['title'] as String? ?? 'Refer & earn',
      subtitle: json['subtitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      actionText: json['actionText'] as String? ?? 'Invite',
    );
  }
}

class WeeklyBonus {
  final String title;
  final String subtitle;
  final int targetJobs;
  final int completedJobs;
  final double rewardAmount;
  final bool isCompleted;
  final String endsIn;

  WeeklyBonus({
    required this.title,
    required this.subtitle,
    required this.targetJobs,
    required this.completedJobs,
    required this.rewardAmount,
    required this.isCompleted,
    required this.endsIn,
  });

  factory WeeklyBonus.fromJson(Map<String, dynamic> json) {
    return WeeklyBonus(
      title: json['title'] as String? ?? 'Weekly Bonus',
      subtitle: json['subtitle'] as String? ?? '',
      targetJobs: (json['targetJobs'] as num?)?.toInt() ?? 0,
      completedJobs: (json['completedJobs'] as num?)?.toInt() ?? 0,
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      endsIn: json['endsIn'] as String? ?? '',
    );
  }
}
