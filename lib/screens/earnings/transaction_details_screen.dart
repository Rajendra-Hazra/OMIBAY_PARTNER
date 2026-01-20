import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/localization_helper.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 14.0);
    final borderRadius = (screenWidth * 0.06).clamp(16.0, 24.0);

    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Extract all data from arguments
    final String transactionId =
        args?['id'] ??
        '${l10n.transactionIdPrefix}${DateTime.now().millisecondsSinceEpoch}';
    final String jobId = args?['jobId'] ?? transactionId;
    final String amount = LocalizationHelper.convertBengaliToEnglish(
      args?['amount'] ?? '${l10n.currencySymbol}0.00',
    );
    final String date = args?['time'] ?? l10n.justNow;
    final bool isCredit = args?['isCredit'] ?? true;

    // Use LocalizationHelper to get localized title and subtitle
    final String title = LocalizationHelper.getTransactionTitle(
      context,
      args ?? {},
    );
    final String subtitle = LocalizationHelper.getTransactionSubtitle(
      context,
      args ?? {},
    );

    // Extract breakdown data - these come from the actual job data
    final double jobPrice =
        double.tryParse(args?['jobPrice']?.toString() ?? '0') ?? 0.0;
    final double tipAmount =
        double.tryParse(args?['tipAmount']?.toString() ?? '0') ?? 0.0;
    final double serviceAmount =
        double.tryParse(args?['serviceAmount']?.toString() ?? '0') ?? 0.0;
    final double feeAmount =
        double.tryParse(args?['feeAmount']?.toString() ?? '0') ?? 0.0;
    final double partnerEarning =
        double.tryParse(args?['partnerEarning']?.toString() ?? '0') ?? 0.0;

    // Get payment mode
    final String paymentMode = args?['paymentMode']?.toString() ?? 'ONLINE';
    final bool isOnlinePayment =
        paymentMode == 'ONLINE' ||
        paymentMode == 'Online' ||
        paymentMode == l10n.online;

    // Determine payment method label
    final String paymentMethod = isOnlinePayment
        ? l10n.onlinePayment
        : l10n.cashPayAfterService;

    // Check if this is a manual transaction (withdrawal or payment)
    final bool isManualTransaction =
        args?['titleKey'] != null ||
        (args?['title']?.toString() ?? '').contains(l10n.withdrawal) ||
        (args?['title']?.toString() ?? '').contains('Due Amount') ||
        (args?['title']?.toString() ?? '').contains(l10n.dueAmountPaid);

    // Determine status text for the big header
    String statusText = isCredit ? l10n.paymentCredited : l10n.feeDeducted;
    if (isManualTransaction) {
      statusText = title;
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, titleFontSize, borderRadius, hPadding),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(hPadding * 1.2),
                child: Column(
                  children: [
                    _buildStatusCard(
                      isCredit,
                      amount,
                      statusText,
                      borderRadius,
                      bodyFontSize,
                    ),
                    SizedBox(height: 24 * paddingScale),
                    _buildTransactionInfo(
                      context,
                      transactionId,
                      jobId,
                      date,
                      paymentMethod,
                      isManualTransaction,
                      bodyFontSize,
                    ),
                    SizedBox(height: 24 * paddingScale),
                    if (isManualTransaction)
                      _buildSimpleTransactionInfo(
                        context,
                        args,
                        title,
                        subtitle,
                        borderRadius,
                        bodyFontSize,
                        smallFontSize,
                      )
                    else
                      _buildEarningsBreakdown(
                        context,
                        jobPrice,
                        tipAmount,
                        serviceAmount,
                        feeAmount,
                        partnerEarning,
                        isCredit,
                        isOnlinePayment,
                        borderRadius,
                        bodyFontSize,
                        smallFontSize,
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
    double horizontalPadding,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: horizontalPadding * 0.5,
        right: horizontalPadding,
        bottom: 20,
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              l10n.transactionDetails,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    bool isCredit,
    String amount,
    String statusText,
    double borderRadius,
    double fontSize,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isCredit ? Colors.green.shade100 : Colors.red.shade100,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCredit ? Icons.check_circle_rounded : Icons.remove_rounded,
            color: isCredit ? AppColors.successGreen : Colors.red,
            size: fontSize * 3,
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.successGreen : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              LocalizationHelper.convertBengaliToEnglish(amount),
              style: TextStyle(
                fontSize: fontSize * 1.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(
    BuildContext context,
    String transactionId,
    String jobId,
    String date,
    String paymentMethod,
    bool isManualTransaction,
    double fontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildInfoRow(
          l10n.transactionId,
          LocalizationHelper.convertBengaliToEnglish(transactionId),
          fontSize,
        ),
        _buildInfoRow(l10n.dateTime, date, fontSize),
        if (!isManualTransaction) ...[
          _buildInfoRow(
            l10n.jobReference,
            LocalizationHelper.convertBengaliToEnglish(jobId),
            fontSize,
          ),
          _buildInfoRow(l10n.paymentMethod, paymentMethod, fontSize),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: fontSize * 0.9,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize * 0.9,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTransactionInfo(
    BuildContext context,
    Map<String, dynamic>? args,
    String title,
    String subtitle,
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgStart,
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transactionDetails,
            style: TextStyle(
              fontSize: smallFontSize * 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(l10n.transactionType, title, bodyFontSize),
          _buildInfoRow(l10n.description, subtitle, bodyFontSize),
          _buildInfoRow(
            l10n.amountLabel,
            LocalizationHelper.convertBengaliToEnglish(
              args?['amount']?.toString() ?? '${l10n.currencySymbol}0.00',
            ),
            bodyFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(
    BuildContext context,
    double jobPrice,
    double tipAmount,
    double serviceAmount,
    double feeAmount,
    double partnerEarning,
    bool isCredit,
    bool isOnlinePayment,
    double borderRadius,
    double bodyFontSize,
    double smallFontSize,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Calculate platform payable amount for COD
    final double platformPayable = jobPrice - partnerEarning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgStart,
        borderRadius: BorderRadius.circular(borderRadius * 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.earningsBreakdown,
            style: TextStyle(
              fontSize: smallFontSize * 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow(
            l10n.totalJobPrice,
            LocalizationHelper.convertBengaliToEnglish(
              '${l10n.currencySymbol}${jobPrice.toStringAsFixed(2)}',
            ),
            bodyFontSize,
          ),
          if (tipAmount > 0)
            _buildBreakdownRow(
              l10n.tipAmount,
              LocalizationHelper.convertBengaliToEnglish(
                '${l10n.currencySymbol}${tipAmount.toStringAsFixed(2)}',
              ),
              bodyFontSize,
              valueColor: Colors.orange,
            ),
          _buildBreakdownRow(
            l10n.serviceAmountExclTip,
            LocalizationHelper.convertBengaliToEnglish(
              '${l10n.currencySymbol}${serviceAmount.toStringAsFixed(2)}',
            ),
            bodyFontSize,
          ),
          _buildBreakdownRow(
            l10n.gst,
            LocalizationHelper.convertBengaliToEnglish(
              '-${l10n.currencySymbol}${(serviceAmount * 0.05).toStringAsFixed(2)}',
            ),
            bodyFontSize,
            valueColor: Colors.red,
          ),
          _buildBreakdownRow(
            l10n.platformFee,
            LocalizationHelper.convertBengaliToEnglish(
              '-${l10n.currencySymbol}${(serviceAmount * 0.20).toStringAsFixed(2)}',
            ),
            bodyFontSize,
            valueColor: Colors.red,
          ),
          if (tipAmount > 0)
            _buildBreakdownRow(
              l10n.tipToPartner,
              LocalizationHelper.convertBengaliToEnglish(
                '+${l10n.currencySymbol}${tipAmount.toStringAsFixed(2)}',
              ),
              bodyFontSize,
              valueColor: Colors.green,
            ),
          const Divider(height: 32),
          _buildBreakdownRow(
            l10n.yourNetEarning,
            LocalizationHelper.convertBengaliToEnglish(
              '${l10n.currencySymbol}${partnerEarning.toStringAsFixed(2)}',
            ),
            bodyFontSize,
            isTotal: true,
            isCredit: true,
          ),
          if (!isOnlinePayment) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: bodyFontSize,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.cashPaymentNote,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                            fontSize: smallFontSize * 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationHelper.convertBengaliToEnglish(
                      l10n.collectedCashFromCustomer(
                        jobPrice.toStringAsFixed(2),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: smallFontSize * 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocalizationHelper.convertBengaliToEnglish(
                      l10n.amountDueToOmiBay(
                        platformPayable.toStringAsFixed(2),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontSize: smallFontSize * 0.9,
                      fontWeight: FontWeight.w600,
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

  Widget _buildBreakdownRow(
    String label,
    String value,
    double fontSize, {
    bool isTotal = false,
    bool isCredit = true,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? fontSize * 1.1 : fontSize * 0.9,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? fontSize * 1.1 : fontSize * 0.9,
              color:
                  valueColor ??
                  (isTotal
                      ? (isCredit ? AppColors.successGreen : Colors.red)
                      : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
