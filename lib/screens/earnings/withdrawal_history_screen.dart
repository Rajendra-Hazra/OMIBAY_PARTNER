import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../core/pdf_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final prefs = await SharedPreferences.getInstance();
      final List<String> completedList =
          prefs.getStringList('completed_jobs_list') ?? [];

      final List<Map<String, dynamic>> transactionData = completedList.map((
        item,
      ) {
        final data = jsonDecode(item) as Map<String, dynamic>;
        final title = data['title']?.toString() ?? '';
        final bool isJob = title.startsWith('Job:') || title.startsWith('কাজ:');
        String timeDisplay = l10n.justNow;
        if (data['date'] != null) {
          try {
            final date = DateTime.parse(data['date']);
            final locale = Localizations.localeOf(context).toString();
            timeDisplay = LocalizationHelper.convertBengaliToEnglish(
              DateFormat('dd MMM yyyy, hh:mm a', locale).format(date),
            );
          } catch (_) {}
        }

        return {
          ...data,
          'subtitle': data['subtitle'] ?? data['customer'] ?? l10n.partner,
          'amount': LocalizationHelper.convertBengaliToEnglish(
            data['amount'] ?? '+${l10n.currencySymbol}${data['price'] ?? '0'}',
          ),
          'isCredit': data['isCredit'] ?? (data['type'] == 'Credit'),
          'time': timeDisplay,
          'status': data['isCredit'] == true ? l10n.completed : l10n.deducted,
          'isJob': isJob,
        };
      }).toList();

      setState(() {
        _transactions = transactionData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 70),
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_transactions[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.noTransactionHistoryFound,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              l10n.transactionHistory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_transactions.isNotEmpty)
            IconButton(
              onPressed: () {
                PdfHelper.generateTransactionHistoryPdf(_transactions);
              },
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: l10n.exportHistory,
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> transaction) {
    final l10n = AppLocalizations.of(context)!;
    final bool isCredit = transaction['isCredit'] ?? true;
    final bool isJob = transaction['isJob'] ?? false;
    final String status =
        transaction['status'] ?? (isCredit ? l10n.completed : l10n.deducted);
    Color statusColor = isCredit ? AppColors.successGreen : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/transaction-details',
          arguments: transaction,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCredit
                    ? Icons.check_circle_rounded
                    : Icons.remove_circle_rounded,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationHelper.getTransactionTitle(
                      context,
                      transaction,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    LocalizationHelper.getTransactionSubtitle(
                      context,
                      transaction,
                    ),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['time'] ?? 'Just now',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  LocalizationHelper.convertBengaliToEnglish(
                    transaction['amount'] ?? '${l10n.currencySymbol}0',
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCredit ? AppColors.successGreen : Colors.red,
                  ),
                ),
                if (isJob) ...[
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
