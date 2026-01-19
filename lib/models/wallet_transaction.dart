import '../core/localization_helper.dart';

/// Wallet Transaction Model
/// Represents a single transaction in the partner's wallet
class WalletTransaction {
  final String id;
  final String jobId;
  final String type; // 'CREDIT' or 'DEBIT'
  final double amount;
  final String description;
  final DateTime createdAt;

  // Additional breakdown fields for display
  final double totalJobPrice;
  final double tipAmount;
  final double serviceAmount;
  final double platformDeduction; // 25% (5% GST + 20% OmiBay Fee)
  final double partnerNetEarning;
  final String paymentMode; // 'ONLINE' or 'COD'
  final String? customerName;
  final String? serviceName;
  final String? serviceKey;
  final bool isJob;

  WalletTransaction({
    required this.id,
    required this.jobId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    required this.totalJobPrice,
    required this.tipAmount,
    required this.serviceAmount,
    required this.platformDeduction,
    required this.partnerNetEarning,
    required this.paymentMode,
    this.customerName,
    this.serviceName,
    this.serviceKey,
    this.isJob = false,
  });

  /// Check if this is a credit transaction
  bool get isCredit => type == 'CREDIT';

  /// Get formatted amount with sign
  String get formattedAmount {
    final prefix = isCredit ? '+' : '-';
    return LocalizationHelper.convertBengaliToEnglish(
      '$prefix₹${amount.toStringAsFixed(2)}',
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'type': type,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'totalJobPrice': totalJobPrice,
      'tipAmount': tipAmount,
      'serviceAmount': serviceAmount,
      'platformDeduction': platformDeduction,
      'partnerNetEarning': partnerNetEarning,
      'paymentMode': paymentMode,
      'customerName': customerName,
      'serviceName': serviceName,
      'serviceKey': serviceKey,
      'isJob': isJob,
    };
  }

  /// Create from JSON
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      type: json['type'] ?? 'CREDIT',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalJobPrice: (json['totalJobPrice'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0.0,
      serviceAmount: (json['serviceAmount'] as num?)?.toDouble() ?? 0.0,
      platformDeduction: (json['platformDeduction'] as num?)?.toDouble() ?? 0.0,
      partnerNetEarning: (json['partnerNetEarning'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['paymentMode'] ?? 'ONLINE',
      customerName: json['customerName'],
      serviceName: json['serviceName'],
      serviceKey: json['serviceKey'],
      isJob: json['isJob'] ?? false,
    );
  }
}
