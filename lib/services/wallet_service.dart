import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_transaction.dart';

/// Wallet Service
/// Handles all wallet-related operations including job completion calculations
class WalletService {
  // Fee Constants
  static const double gstPercent = 0.05; // 5%
  static const double omibayFeePercent = 0.20; // 20%
  static const double totalDeductionPercent = 0.25; // 25% (GST + OmiBay Fee)

  /// Calculate partner earnings from a job
  /// Returns a map with all calculated values
  static Map<String, double> calculateEarnings({
    required double totalJobPrice,
    required double tipAmount,
  }) {
    // Base amount is the job price excluding tip
    final double baseAmount = totalJobPrice - tipAmount;

    // Platform deduction (25% of base amount)
    final double platformDeduction = baseAmount * totalDeductionPercent;

    // GST breakdown (5% of base amount)
    final double gstAmount = baseAmount * gstPercent;

    // OmiBay fee breakdown (20% of base amount)
    final double omibayFee = baseAmount * omibayFeePercent;

    // Remaining amount after deduction
    final double remainingAmount = baseAmount - platformDeduction;

    // Partner net earning = remaining amount + 100% tip
    final double partnerNetEarning = remainingAmount + tipAmount;

    // Amount payable to platform (for COD jobs)
    final double amountPayableToPlatform = totalJobPrice - partnerNetEarning;

    return {
      'baseAmount': baseAmount,
      'platformDeduction': platformDeduction,
      'gstAmount': gstAmount,
      'omibayFee': omibayFee,
      'remainingAmount': remainingAmount,
      'partnerNetEarning': partnerNetEarning,
      'amountPayableToPlatform': amountPayableToPlatform,
    };
  }

  /// Process job completion and update wallet
  /// Returns the created WalletTransaction
  static Future<WalletTransaction> processJobCompletion({
    required String jobId,
    required double totalJobPrice,
    required double tipAmount,
    required String paymentMode, // "ONLINE" or "COD"
    String? customerName,
    String? serviceName,
    String? serviceKey,
    String? location,
    String? timeType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate all earnings
    final earnings = calculateEarnings(
      totalJobPrice: totalJobPrice,
      tipAmount: tipAmount,
    );

    final double partnerNetEarning = earnings['partnerNetEarning']!;
    final double amountPayableToPlatform = earnings['amountPayableToPlatform']!;
    final double platformDeduction = earnings['platformDeduction']!;
    final double baseAmount = earnings['baseAmount']!;

    // Get current wallet balance
    double currentBalance = prefs.getDouble('wallet_balance') ?? 0.0;

    // Create transaction based on payment mode
    WalletTransaction transaction;

    if (paymentMode == 'ONLINE') {
      // ONLINE: Credit partner net earning to wallet
      await prefs.setDouble(
        'wallet_balance',
        currentBalance + partnerNetEarning,
      );

      transaction = WalletTransaction(
        id: '#TXN${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        type: 'CREDIT',
        amount: partnerNetEarning,
        description: 'Job completed - Online payment',
        createdAt: DateTime.now(),
        totalJobPrice: totalJobPrice,
        tipAmount: tipAmount,
        serviceAmount: baseAmount,
        platformDeduction: platformDeduction,
        partnerNetEarning: partnerNetEarning,
        paymentMode: paymentMode,
        customerName: customerName,
        serviceName: serviceName,
        serviceKey: serviceKey,
        isJob: true,
      );
    } else {
      // COD: Debit platform payable amount from wallet
      // Partner already collected full cash from customer
      // So we deduct what's owed to the platform
      await prefs.setDouble(
        'wallet_balance',
        currentBalance - amountPayableToPlatform,
      );

      transaction = WalletTransaction(
        id: '#TXN${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        type: 'DEBIT',
        amount: amountPayableToPlatform,
        description: 'COD adjustment - Payable to OmiBay',
        createdAt: DateTime.now(),
        totalJobPrice: totalJobPrice,
        tipAmount: tipAmount,
        serviceAmount: baseAmount,
        platformDeduction: platformDeduction,
        partnerNetEarning: partnerNetEarning,
        paymentMode: paymentMode,
        customerName: customerName,
        serviceName: serviceName,
        serviceKey: serviceKey,
        isJob: true,
      );
    }

    // Save transaction to history
    // Pass extra job info for the jobs list
    await _saveTransaction(prefs, transaction, {
      'location': location,
      'timeType': timeType,
      if (serviceKey != null) 'serviceKey': serviceKey,
    });

    // Update today's stats (including Total Business)
    await _updateDailyStats(prefs, partnerNetEarning, tipAmount, totalJobPrice);

    // Update average rating
    await _updateAverageRating(prefs);

    return transaction;
  }

  /// Record a manual transaction (Withdrawal or Payment)
  static Future<void> recordManualTransaction({
    required String title,
    required double amount,
    required bool isCredit,
    required String subtitle,
    String? titleKey,
    String? subtitleKey,
    String? methodKey,
    String? jobId,
    String? customerName,
    String? serviceName,
    String? paymentMode,
    String? location,
    String? timeType,
    double? tipAmount,
    double? serviceAmount,
    double? platformDeduction,
    double? partnerNetEarning,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Update wallet balance
    double currentBalance = prefs.getDouble('wallet_balance') ?? 0.0;
    if (isCredit) {
      await prefs.setDouble('wallet_balance', currentBalance + amount);
    } else {
      await prefs.setDouble('wallet_balance', currentBalance - amount);
    }

    // For manual transactions, we still store them in the same format as job transactions
    // so they appear consistently in the UI
    final transaction = {
      'id': '#TXN${DateTime.now().millisecondsSinceEpoch}',
      'jobId': jobId ?? '#TXN${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      if (titleKey != null) 'titleKey': titleKey,
      if (subtitleKey != null) 'subtitleKey': subtitleKey,
      if (methodKey != null) 'methodKey': methodKey,
      'amount': '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
      'subtitle': subtitle,
      'date': DateTime.now().toIso8601String(),
      'type': isCredit ? 'Credit' : 'Debit',
      'isCredit': isCredit,
      // For manual transactions, we'll use the amount as the job price for display purposes
      'jobPrice': amount.toStringAsFixed(2),
      'tipAmount': (tipAmount ?? 0.0).toStringAsFixed(2),
      'serviceAmount': (serviceAmount ?? amount).toStringAsFixed(2),
      'feeAmount': (platformDeduction ?? 0.0).toStringAsFixed(2),
      'partnerEarning': (partnerNetEarning ?? amount).toStringAsFixed(2),
      'paymentMode': paymentMode ?? (isCredit ? 'ONLINE' : 'COD'),
      'customer': customerName ?? 'OmiBay System',
      'service': serviceName,
    };

    final List<String> transactions =
        prefs.getStringList('completed_jobs_list') ?? [];
    transactions.insert(0, jsonEncode(transaction));
    await prefs.setStringList('completed_jobs_list', transactions);
  }

  /// Save transaction to SharedPreferences
  static Future<void> _saveTransaction(
    SharedPreferences prefs,
    WalletTransaction transaction, [
    Map<String, dynamic>? extraJobInfo,
  ]) async {
    final List<String> transactions =
        prefs.getStringList('completed_jobs_list') ?? [];

    // Convert transaction to legacy format for backward compatibility
    final legacyTransaction = {
      'id': transaction.id,
      'title': 'Job: ${transaction.serviceName ?? 'Service'}',
      'customer': transaction.customerName ?? 'Customer',
      'amount': transaction.formattedAmount,
      'subtitle': transaction.isCredit
          ? 'Online Payment'
          : 'Cash (Amount Due to OmiBay)',
      'date': transaction.createdAt.toIso8601String(),
      'type': transaction.type == 'CREDIT' ? 'Credit' : 'Debit',
      'isCredit': transaction.isCredit,
      'jobPrice': transaction.totalJobPrice.toStringAsFixed(2),
      'tipAmount': transaction.tipAmount.toStringAsFixed(2),
      'serviceAmount': transaction.serviceAmount.toStringAsFixed(2),
      'feeAmount': transaction.platformDeduction.toStringAsFixed(2),
      'partnerEarning': transaction.partnerNetEarning.toStringAsFixed(2),
      'paymentMode': transaction.paymentMode,
      'jobId': transaction.jobId,
      'isJob': transaction.isJob,
      'serviceKey': transaction.serviceKey,
      'rating': (4.5 + (Random().nextDouble() * 0.5)).toStringAsFixed(1),
      // Include extra info if this is a job transaction
      if (extraJobInfo != null) ...extraJobInfo,
    };

    transactions.insert(0, jsonEncode(legacyTransaction));
    await prefs.setStringList('completed_jobs_list', transactions);
  }

  /// Update daily statistics
  static Future<void> _updateDailyStats(
    SharedPreferences prefs,
    double earnings,
    double tipAmount,
    double totalJobPrice,
  ) async {
    final double todayEarnings = prefs.getDouble('today_earnings') ?? 0.0;
    final double todayBusiness = prefs.getDouble('today_business') ?? 0.0;
    final double totalTips = prefs.getDouble('total_tips') ?? 0.0;
    final int todayJobs = prefs.getInt('today_jobs_done') ?? 0;

    await prefs.setDouble('today_earnings', todayEarnings + earnings);
    await prefs.setDouble('today_business', todayBusiness + totalJobPrice);
    await prefs.setDouble('total_tips', totalTips + tipAmount);
    await prefs.setInt('today_jobs_done', todayJobs + 1);
  }

  /// Get current wallet balance
  static Future<double> getWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('wallet_balance') ?? 0.0;
  }

  /// Get all transactions
  static Future<List<WalletTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> transactionStrings =
        prefs.getStringList('completed_jobs_list') ?? [];

    return transactionStrings.map((str) {
      final json = jsonDecode(str) as Map<String, dynamic>;
      return WalletTransaction(
        id: json['id'] ?? '',
        jobId: json['jobId'] ?? json['id'] ?? '',
        type: json['isCredit'] == true ? 'CREDIT' : 'DEBIT',
        amount:
            double.tryParse(
              json['partnerEarning']?.toString() ??
                  json['amount']?.toString().replaceAll(
                    RegExp(r'[^0-9.]'),
                    '',
                  ) ??
                  '0',
            ) ??
            0.0,
        description: json['subtitle'] ?? '',
        createdAt: json['date'] != null
            ? DateTime.tryParse(json['date']) ?? DateTime.now()
            : DateTime.now(),
        totalJobPrice:
            double.tryParse(json['jobPrice']?.toString() ?? '0') ?? 0.0,
        tipAmount: double.tryParse(json['tipAmount']?.toString() ?? '0') ?? 0.0,
        serviceAmount:
            double.tryParse(json['serviceAmount']?.toString() ?? '0') ?? 0.0,
        platformDeduction:
            double.tryParse(json['feeAmount']?.toString() ?? '0') ?? 0.0,
        partnerNetEarning:
            double.tryParse(json['partnerEarning']?.toString() ?? '0') ?? 0.0,
        paymentMode: json['paymentMode'] ?? 'ONLINE',
        customerName: json['customerName'] ?? json['customer'],
        serviceName:
            json['serviceName'] ??
            json['title']
                ?.toString()
                .replaceFirst('Job: ', '')
                .replaceFirst('কাজ: ', ''),
        serviceKey: json['serviceKey'],
        isJob:
            json['isJob'] ??
            (json['title']?.toString().startsWith('Job:') ?? false) ||
                (json['title']?.toString().startsWith('কাজ:') ?? false),
      );
    }).toList();
  }

  /// Clear active job data from SharedPreferences (legacy - single job)
  static Future<void> clearActiveJob() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_job_service');
    await prefs.remove('active_job_customer');
    await prefs.remove('active_job_location');
    await prefs.remove('active_job_price');
    await prefs.remove('active_job_tip');
    await prefs.remove('active_job_time_type');
    await prefs.remove('active_job_distance');
    await prefs.remove('active_job_eta');
    await prefs.remove('active_job_id');
    await prefs.remove('active_job_payment_type');
  }

  // ==================== MULTIPLE ACTIVE JOBS SUPPORT ====================

  /// Add a new active job to the list
  static Future<void> addActiveJob(Map<String, dynamic> job) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activeJobsList =
        prefs.getStringList('active_jobs_list') ?? [];

    // Add job with timestamp
    job['acceptedAt'] = DateTime.now().toIso8601String();
    activeJobsList.insert(0, jsonEncode(job));

    await prefs.setStringList('active_jobs_list', activeJobsList);
  }

  /// Get all active jobs
  static Future<List<Map<String, dynamic>>> getActiveJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activeJobsList =
        prefs.getStringList('active_jobs_list') ?? [];

    return activeJobsList
        .map((str) {
          try {
            return jsonDecode(str) as Map<String, dynamic>;
          } catch (e) {
            return <String, dynamic>{};
          }
        })
        .where((map) => map.isNotEmpty)
        .toList();
  }

  /// Get a specific active job by ID
  static Future<Map<String, dynamic>?> getActiveJobById(String jobId) async {
    final jobs = await getActiveJobs();
    try {
      return jobs.firstWhere((job) => job['id'] == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Remove a specific active job by ID
  static Future<void> removeActiveJob(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activeJobsList =
        prefs.getStringList('active_jobs_list') ?? [];

    activeJobsList.removeWhere((str) {
      try {
        final job = jsonDecode(str) as Map<String, dynamic>;
        return job['id'] == jobId;
      } catch (e) {
        return false;
      }
    });

    await prefs.setStringList('active_jobs_list', activeJobsList);
  }

  /// Get count of active jobs
  static Future<int> getActiveJobsCount() async {
    final jobs = await getActiveJobs();
    return jobs.length;
  }

  /// Clear all active jobs
  static Future<void> clearAllActiveJobs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_jobs_list');
  }

  /// Calculate and update average rating from all completed jobs
  static Future<void> _updateAverageRating(SharedPreferences prefs) async {
    final List<String> completedList =
        prefs.getStringList('completed_jobs_list') ?? [];

    if (completedList.isEmpty) {
      await prefs.setString('profile_rating', '4.8');
      await prefs.setString('today_rating', '0.0');
      return;
    }

    double totalRating = 0.0;
    int ratedJobs = 0;

    double todayTotalRating = 0.0;
    int todayRatedJobs = 0;
    final now = DateTime.now();

    // Add some base rating to look professional (e.g. starting with 4.8 from 20 previous jobs)
    const double baseRating = 4.8;
    const int baseCount = 20;
    totalRating += (baseRating * baseCount);
    ratedJobs += baseCount;

    for (var item in completedList) {
      try {
        final data = jsonDecode(item) as Map<String, dynamic>;
        // Only count job transactions
        final title = data['title']?.toString() ?? '';
        final bool isJob = title.startsWith('Job:') || title.startsWith('কাজ:');

        if (isJob) {
          final ratingStr = data['rating']?.toString();
          final double rating = double.tryParse(ratingStr ?? '4.8') ?? 4.8;

          // Lifetime calculation
          totalRating += rating;
          ratedJobs++;

          // Today's calculation
          if (data['date'] != null) {
            final date = DateTime.tryParse(data['date']);
            if (date != null &&
                date.year == now.year &&
                date.month == now.month &&
                date.day == now.day) {
              todayTotalRating += rating;
              todayRatedJobs++;
            }
          }
        }
      } catch (_) {}
    }

    final average = totalRating / ratedJobs;
    await prefs.setString('profile_rating', average.toStringAsFixed(1));

    if (todayRatedJobs > 0) {
      final todayAverage = todayTotalRating / todayRatedJobs;
      await prefs.setString('today_rating', todayAverage.toStringAsFixed(1));
    } else {
      await prefs.setString('today_rating', '0.0');
    }
  }

  /// Get average rating
  static Future<double> getAverageRating() async {
    final prefs = await SharedPreferences.getInstance();
    final ratingStr = prefs.getString('profile_rating') ?? '0.0';
    return double.tryParse(ratingStr) ?? 0.0;
  }
}
