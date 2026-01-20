import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';

class PaymentSetupScreen extends StatefulWidget {
  const PaymentSetupScreen({super.key});

  @override
  State<PaymentSetupScreen> createState() => _PaymentSetupScreenState();
}

class _PaymentSetupScreenState extends State<PaymentSetupScreen> {
  // Bank Form Controllers
  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();

  // UPI Form Controller
  final _upiIdController = TextEditingController();
  final _confirmUpiIdController = TextEditingController();

  bool _isLoading = true;

  List<Map<String, dynamic>> _bankAccounts = [];
  List<String> _upiIds = [];
  String _defaultBankId = ''; // Store the unique ID for bank
  String _defaultUpiId = ''; // Store the unique ID for upi

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      final String bankJson = prefs.getString('saved_bank_accounts') ?? '[]';
      final String upiJson = prefs.getString('saved_upi_ids') ?? '[]';

      _bankAccounts = List<Map<String, dynamic>>.from(jsonDecode(bankJson));
      _upiIds = List<String>.from(jsonDecode(upiJson));
      _defaultBankId = prefs.getString('default_bank_id') ?? '';
      _defaultUpiId = prefs.getString('default_upi_id') ?? '';

      // Auto-set defaults if only one exists and none is set
      if (_defaultBankId.isEmpty && _bankAccounts.length == 1) {
        _defaultBankId = _bankAccounts[0]['bank_account_number'];
        prefs.setString('default_bank_id', _defaultBankId);
      }
      if (_defaultUpiId.isEmpty && _upiIds.length == 1) {
        _defaultUpiId = _upiIds[0];
        prefs.setString('default_upi_id', _defaultUpiId);
      }

      _isLoading = false;
    });
  }

  Future<void> _setDefaultMethod(String id, String type) async {
    final prefs = await SharedPreferences.getInstance();
    if (type == 'bank') {
      await prefs.setString('default_bank_id', id);
      setState(() => _defaultBankId = id);
    } else {
      await prefs.setString('default_upi_id', id);
      setState(() => _defaultUpiId = id);
    }
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.setDefaultPayoutMethod(
              type == 'bank' ? l10n.bankAccount : l10n.upiId,
            ),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deletePaymentMethod(String id, String type) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(l10n.deletePaymentMethodTitle),
              content: Text(
                l10n.deletePaymentMethodConfirm(
                  type == 'bank' ? l10n.bankAccount.toLowerCase() : l10n.upiId,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirm) return;

    final prefs = await SharedPreferences.getInstance();
    if (type == 'bank') {
      _bankAccounts.removeWhere((item) => item['bank_account_number'] == id);
      await prefs.setString('saved_bank_accounts', jsonEncode(_bankAccounts));
      if (_defaultBankId == id) {
        await prefs.remove('default_bank_id');
        _defaultBankId = '';
      }
    } else {
      _upiIds.removeWhere((item) => item == id);
      await prefs.setString('saved_upi_ids', jsonEncode(_upiIds));
      if (_defaultUpiId == id) {
        await prefs.remove('default_upi_id');
        _defaultUpiId = '';
      }
    }

    _fetchPaymentDetails();
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiIdController.dispose();
    _confirmUpiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingScale = (screenWidth / 375).clamp(0.8, 1.2);
    final hPadding = 20.0 * paddingScale;
    final vPadding = 20.0 * paddingScale;
    final titleFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.035).clamp(13.0, 16.0);
    final smallFontSize = (screenWidth * 0.03).clamp(11.0, 13.0);
    final labelFontSize = (screenWidth * 0.028).clamp(10.0, 12.0);
    final iconSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final buttonHeight = (screenHeight * 0.06).clamp(50.0, 60.0);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrangeStart),
        ),
      );
    }
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, titleFontSize, iconSize),
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
                      l10n.savedOptions,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 12 * paddingScale),
                    if (_bankAccounts.isEmpty && _upiIds.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24 * paddingScale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.payment_outlined,
                              color: Colors.grey[300],
                              size: 40 * paddingScale,
                            ),
                            SizedBox(height: 12 * paddingScale),
                            Text(
                              l10n.noPaymentMethodSaved,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: bodyFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    if (_bankAccounts.isNotEmpty || _upiIds.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bank Accounts Section
                            if (_bankAccounts.isNotEmpty) ...[
                              _buildSectionLabel(
                                l10n.bankAccountsLabel,
                                labelFontSize,
                              ),
                              ..._bankAccounts.asMap().entries.map((entry) {
                                final int idx = entry.key;
                                final bank = entry.value;
                                final String accNo =
                                    bank['bank_account_number'];
                                return Column(
                                  children: [
                                    _buildSavedItem(
                                      icon: Icons.account_balance,
                                      title:
                                          bank['bank_name'] ?? l10n.bankAccount,
                                      subtitle: l10n.accountNumberLabel(
                                        LocalizationHelper.convertBengaliToEnglish(
                                          _maskAccountNumber(context, accNo),
                                        ),
                                      ),
                                      isDefault: _defaultBankId == accNo,
                                      onDelete: () =>
                                          _deletePaymentMethod(accNo, 'bank'),
                                      onSetDefault: () =>
                                          _setDefaultMethod(accNo, 'bank'),
                                      bodyFontSize: bodyFontSize,
                                      smallFontSize: smallFontSize,
                                      iconSize: iconSize,
                                    ),
                                    if (idx < _bankAccounts.length - 1)
                                      const Divider(
                                        height: 1,
                                        indent: 60,
                                        endIndent: 16,
                                      ),
                                  ],
                                );
                              }),
                            ],

                            // Differentiation line between Bank and UPI
                            if (_bankAccounts.isNotEmpty && _upiIds.isNotEmpty)
                              Container(
                                height: 12 * paddingScale,
                                width: double.infinity,
                                color: Colors.grey[50],
                                child: Center(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.border.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),

                            // UPI IDs Section
                            if (_upiIds.isNotEmpty) ...[
                              _buildSectionLabel(
                                l10n.upiIdsLabel,
                                labelFontSize,
                              ),
                              ..._upiIds.asMap().entries.map((entry) {
                                final int idx = entry.key;
                                final upiId = entry.value;
                                return Column(
                                  children: [
                                    _buildSavedItem(
                                      icon: Icons.qr_code,
                                      title: l10n.upiId,
                                      subtitle:
                                          LocalizationHelper.convertBengaliToEnglish(
                                            upiId,
                                          ),
                                      isDefault: _defaultUpiId == upiId,
                                      onDelete: () =>
                                          _deletePaymentMethod(upiId, 'upi'),
                                      onSetDefault: () =>
                                          _setDefaultMethod(upiId, 'upi'),
                                      bodyFontSize: bodyFontSize,
                                      smallFontSize: smallFontSize,
                                      iconSize: iconSize,
                                    ),
                                    if (idx < _upiIds.length - 1)
                                      const Divider(
                                        height: 1,
                                        indent: 60,
                                        endIndent: 16,
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    SizedBox(height: 32 * paddingScale),
                    Text(
                      l10n.addNewOption,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 12 * paddingScale),
                    _buildAddOptionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: l10n.addBankAccount,
                      subtitle: l10n.directTransferToBank,
                      onTap: () => _showBankDialog(
                        context,
                        bodyFontSize,
                        smallFontSize,
                        iconSize,
                        buttonHeight,
                        paddingScale,
                      ),
                      titleFontSize: bodyFontSize + 1,
                      subtitleFontSize: smallFontSize,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8 * paddingScale),
                      child: const Divider(height: 1, color: AppColors.border),
                    ),
                    _buildAddOptionTile(
                      icon: Icons.send_to_mobile_outlined,
                      title: l10n.addUpiId,
                      subtitle: l10n.upiAppsSubtitle,
                      onTap: () => _showUpiDialog(
                        context,
                        bodyFontSize,
                        smallFontSize,
                        iconSize,
                        buttonHeight,
                        paddingScale,
                      ),
                      titleFontSize: bodyFontSize + 1,
                      subtitleFontSize: smallFontSize,
                    ),
                    SizedBox(height: 40 * paddingScale),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.green[600],
                                size: iconSize * 0.8,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  l10n.secureSslEncryption,
                                  style: TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.paymentSecurityNote,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: smallFontSize,
                            ),
                          ),
                        ],
                      ),
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

  String _maskAccountNumber(BuildContext context, String acc) {
    if (acc.length < 4) return acc;
    return AppLocalizations.of(
      context,
    )!.accountNumberMask(acc.substring(acc.length - 4));
  }

  Widget _buildSectionLabel(String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSavedItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
    required VoidCallback onDelete,
    required VoidCallback onSetDefault,
    required double bodyFontSize,
    required double smallFontSize,
    required double iconSize,
  }) {
    return InkWell(
      onTap: isDefault ? null : onSetDefault,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDefault
              ? AppColors.primaryOrangeStart.withValues(alpha: 0.04)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Left: Status Indicator (Radio style)
            Container(
              height: iconSize,
              width: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDefault
                      ? AppColors.primaryOrangeStart
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isDefault
                  ? Center(
                      child: Container(
                        height: iconSize * 0.5,
                        width: iconSize * 0.5,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrangeStart,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Middle: Payment Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDefault
                    ? AppColors.primaryOrangeStart.withValues(alpha: 0.12)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDefault
                    ? AppColors.primaryOrangeStart
                    : Colors.grey[600],
                size: iconSize,
              ),
            ),
            const SizedBox(width: 16),
            // Middle: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isDefault
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: bodyFontSize,
                            color: isDefault ? Colors.black : Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          size: iconSize * 0.7,
                          color: AppColors.primaryOrangeStart,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDefault ? Colors.grey[700] : Colors.grey[500],
                      fontSize: smallFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Right: Delete Action
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[300],
                size: iconSize * 0.9,
              ),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryOrangeStart,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showBankDialog(
    BuildContext context,
    double bodyFontSize,
    double smallFontSize,
    double iconSize,
    double buttonHeight,
    double paddingScale,
  ) {
    // Clear controllers before opening for fresh entry
    _holderNameController.clear();
    _accountNumberController.clear();
    _confirmAccountNumberController.clear();
    _ifscController.clear();
    _bankNameController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isMatching =
                _accountNumberController.text ==
                    _confirmAccountNumberController.text &&
                _accountNumberController.text.isNotEmpty;
            bool isDirty = _confirmAccountNumberController.text.isNotEmpty;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20 * paddingScale,
                vertical: 24 * paddingScale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeStart.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: AppColors.primaryOrangeStart,
                        size: iconSize * 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.bankAccountDetails,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize + 4,
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        l10n.accountHolderName,
                        _holderNameController,
                        hint: l10n.holderNameHint,
                        icon: Icons.person_outline,
                        onChanged: (val) => setDialogState(() {}),
                        bodyFontSize: bodyFontSize,
                        smallFontSize: smallFontSize,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        l10n.bankName,
                        _bankNameController,
                        hint: l10n.bankNameHint,
                        icon: Icons.business_outlined,
                        onChanged: (val) => setDialogState(() {}),
                        bodyFontSize: bodyFontSize,
                        smallFontSize: smallFontSize,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        l10n.accountNumber,
                        _accountNumberController,
                        hint: l10n.enterAccountNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [EnglishDigitFormatter()],
                        icon: Icons.numbers_outlined,
                        obscureText: true,
                        onChanged: (val) => setDialogState(() {}),
                        bodyFontSize: bodyFontSize,
                        smallFontSize: smallFontSize,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        l10n.reEnterAccountNumber,
                        _confirmAccountNumberController,
                        hint: l10n.confirmAccountNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [EnglishDigitFormatter()],
                        icon: Icons.verified_user_outlined,
                        errorText: isDirty && !isMatching
                            ? l10n.accountNumbersDoNotMatch
                            : null,
                        onChanged: (val) => setDialogState(() {}),
                        bodyFontSize: bodyFontSize,
                        smallFontSize: smallFontSize,
                      ),
                      const SizedBox(height: 16),
                      _buildDialogTextField(
                        l10n.ifscCode,
                        _ifscController,
                        hint: l10n.ifscHint,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [EnglishDigitFormatter()],
                        icon: Icons.code_outlined,
                        onChanged: (val) => setDialogState(() {}),
                        bodyFontSize: bodyFontSize,
                        smallFontSize: smallFontSize,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.correctDetailsWarning,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: smallFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: bodyFontSize,
                    ),
                  ),
                ),
                SizedBox(
                  height: buttonHeight * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_holderNameController.text.isEmpty ||
                          _accountNumberController.text.isEmpty ||
                          _ifscController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseFillAllFields)),
                        );
                        return;
                      }
                      if (!isMatching) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.accountNumbersDoNotMatch),
                          ),
                        );
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();

                      // Add to list
                      final newBank = {
                        'bank_holder_name': _holderNameController.text,
                        'bank_account_number': _accountNumberController.text,
                        'bank_ifsc': _ifscController.text,
                        'bank_name': _bankNameController.text,
                      };

                      _bankAccounts.add(newBank);
                      await prefs.setString(
                        'saved_bank_accounts',
                        jsonEncode(_bankAccounts),
                      );

                      // Clear fields
                      _holderNameController.clear();
                      _accountNumberController.clear();
                      _confirmAccountNumberController.clear();
                      _ifscController.clear();
                      _bankNameController.clear();

                      if (context.mounted) Navigator.pop(context);
                      _fetchPaymentDetails();
                    },
                    child: Text(
                      l10n.saveBankDetails,
                      style: TextStyle(fontSize: bodyFontSize),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpiDialog(
    BuildContext context,
    double bodyFontSize,
    double smallFontSize,
    double iconSize,
    double buttonHeight,
    double paddingScale,
  ) {
    // Clear controllers before opening for fresh entry
    _upiIdController.clear();
    _confirmUpiIdController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isMatching =
                _upiIdController.text == _confirmUpiIdController.text &&
                _upiIdController.text.isNotEmpty;
            bool isDirty = _confirmUpiIdController.text.isNotEmpty;

            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20 * paddingScale,
                vertical: 24 * paddingScale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrangeStart.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.qr_code,
                        color: AppColors.primaryOrangeStart,
                        size: iconSize * 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.addUpiId,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: bodyFontSize + 4,
                      ),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogTextField(
                      l10n.upiId,
                      _upiIdController,
                      hint: l10n.upiIdHint,
                      inputFormatters: [EnglishDigitFormatter()],
                      icon: Icons.alternate_email_outlined,
                      obscureText: true,
                      onChanged: (val) => setDialogState(() {}),
                      bodyFontSize: bodyFontSize,
                      smallFontSize: smallFontSize,
                    ),
                    const SizedBox(height: 16),
                    _buildDialogTextField(
                      l10n.reEnterUpiId,
                      _confirmUpiIdController,
                      hint: l10n.confirmUpiId,
                      inputFormatters: [EnglishDigitFormatter()],
                      icon: Icons.verified_user_outlined,
                      errorText: isDirty && !isMatching
                          ? l10n.upiIdsDoNotMatch
                          : null,
                      onChanged: (val) => setDialogState(() {}),
                      bodyFontSize: bodyFontSize,
                      smallFontSize: smallFontSize,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.upiInstantCreditNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: smallFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: bodyFontSize,
                    ),
                  ),
                ),
                SizedBox(
                  height: buttonHeight * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_upiIdController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.pleaseEnterUpiId)),
                        );
                        return;
                      }
                      if (!isMatching) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.upiIdsDoNotMatch)),
                        );
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();

                      // Add to list
                      _upiIds.add(_upiIdController.text);
                      await prefs.setString(
                        'saved_upi_ids',
                        jsonEncode(_upiIds),
                      );

                      // Clear fields
                      _upiIdController.clear();
                      _confirmUpiIdController.clear();

                      if (context.mounted) Navigator.pop(context);
                      _fetchPaymentDetails();
                    },
                    child: Text(
                      l10n.saveUpi,
                      style: TextStyle(fontSize: bodyFontSize),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    IconData? icon,
    bool obscureText = false,
    String? errorText,
    ValueChanged<String>? onChanged,
    required double bodyFontSize,
    required double smallFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: bodyFontSize),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(fontSize: bodyFontSize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: smallFontSize, color: Colors.grey),
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppColors.textSecondary)
                : null,
            errorText: errorText,
            errorStyle: TextStyle(fontSize: smallFontSize * 0.9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryOrangeStart,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double titleFontSize,
    double iconSize,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33FF7A00),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.paymentSetup,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
