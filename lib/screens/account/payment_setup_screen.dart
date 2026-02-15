import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/localization_helper.dart';
import '../../repositories/wallet_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

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
  String? _selectedBank;

  static const List<String> _indianBanks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'Bank of India',
    'IndusInd Bank',
    'Kotak Mahindra Bank',
    'Yes Bank',
    'IDBI Bank',
    'Central Bank of India',
    'Indian Bank',
    'UCO Bank',
    'Indian Overseas Bank',
    'Punjab & Sind Bank',
    'Bank of Maharashtra',
    'IDFC First Bank',
    'Federal Bank',
    'South Indian Bank',
    'Karur Vysya Bank',
    'Tamilnad Mercantile Bank',
    'City Union Bank',
    'Dhanlaxmi Bank',
    'Jammu & Kashmir Bank',
    'Karnataka Bank',
    'RBL Bank',
    'Bandhan Bank',
    'Other',
  ];

  late final WalletRepository _walletRepository;

  // UPI Form Controller
  final _upiIdController = TextEditingController();
  final _confirmUpiIdController = TextEditingController();

  bool _isLoading = true;

  List<Map<String, dynamic>> _bankAccounts = [];
  List<Map<String, dynamic>> _upiIds = [];
  String _defaultBankId = ''; // Store the unique ID for bank
  String _defaultUpiId = ''; // Store the unique ID for upi

  @override
  void initState() {
    super.initState();
    _walletRepository = WalletRepositoryImpl(
      apiClient: ApiClient(baseUrl: ApiEndpoints.baseApiUrl),
    );
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final allAccounts = await _walletRepository.getBankAccounts();
      final mappedBankAccounts = <Map<String, dynamic>>[];
      final mappedUpiAccounts = <Map<String, dynamic>>[];

      for (var e in allAccounts) {
        if (e['bankName'] == 'UPI' ||
            (e['upiId'] != null && e['upiId'].toString().isNotEmpty)) {
          mappedUpiAccounts.add({
            'id': e['id'],
            'upiId': e['upiId'] ?? e['bankName'], // Fallback
            'name': e['accountHolderName'],
            'isDefault': e['isDefault'] ?? false,
          });
        } else {
          mappedBankAccounts.add({
            'id': e['id'],
            'bank_account_number': e['accountNumber'],
            'bank_name': e['bankName'],
            'bank_ifsc': e['ifscCode'],
            'bank_holder_name': e['accountHolderName'],
            'isDefault': e['isDefault'] ?? false,
          });
        }
      }

      if (mounted) {
        setState(() {
          _bankAccounts = mappedBankAccounts;
          _upiIds = mappedUpiAccounts;

          // Set defaults
          final defaultBank = _bankAccounts.firstWhere(
            (element) => element['isDefault'] == true,
            orElse: () => {},
          );
          _defaultBankId = defaultBank.isNotEmpty
              ? defaultBank['bank_account_number']
              : (prefs.getString('default_bank_id') ?? '');

          final defaultUpi = _upiIds.firstWhere(
            (element) => element['isDefault'] == true,
            orElse: () => {},
          );
          _defaultUpiId = defaultUpi.isNotEmpty
              ? defaultUpi['upiId']
              : (prefs.getString('default_upi_id') ?? '');

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bank accounts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

    try {
      await _walletRepository.deleteBankAccount(id);

      // Update usage of defaults if needed
      if (type == 'bank') {
        // id here is the database ID, but _defaultBankId stores account number.
        // This mismatch might be an issue if we don't know the account number of the deleted ID.
        // But we re-fetch details immediately after, so _defaultBankId will be updated in _fetchPaymentDetails.
        // So we don't strictly need to update local state here if we await fetch.
      } else {
        // Same for UPI
      }

      // Refresh list
      await _fetchPaymentDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
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
                                final String bankName =
                                    bank['bank_name'] ?? l10n.bankAccount;
                                final String ifscCode = bank['bank_ifsc'] ?? '';
                                final String holderName =
                                    bank['bank_holder_name'] ?? '';

                                return Column(
                                  children: [
                                    _buildSavedItem(
                                      icon: Icons.account_balance,
                                      title: bankName,
                                      subtitle:
                                          '$holderName\nIFSC: $ifscCode\n${l10n.accountNumberLabel(LocalizationHelper.convertBengaliToEnglish(_maskAccountNumber(context, accNo)))}',
                                      isDefault: _defaultBankId == accNo,
                                      onDelete: () => _deletePaymentMethod(
                                        bank['id'],
                                        'bank',
                                      ),
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
                                final item = entry.value;
                                final upiId = item['upiId'];
                                final dbId = item['id'];
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
                                          _deletePaymentMethod(dbId, 'upi'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDefault
            ? AppColors.primaryOrangeStart.withValues(alpha: 0.04)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          // Left: Payment Icon
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
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isDefault ? FontWeight.bold : FontWeight.w600,
                    fontSize: bodyFontSize,
                    color: isDefault ? Colors.black : Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
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
          // Right: Primary Badge (if default)
          if (isDefault) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrangeStart.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: iconSize * 0.7,
                    color: AppColors.primaryOrangeStart,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Primary',
                    style: TextStyle(
                      fontSize: smallFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrangeStart,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Right: 3-dot Menu
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[600],
              size: iconSize * 0.9,
            ),
            splashRadius: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'set_primary') {
                onSetDefault();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              if (!isDefault)
                PopupMenuItem<String>(
                  value: 'set_primary',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryOrangeStart,
                        size: iconSize * 0.8,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Set as Primary',
                        style: TextStyle(fontSize: smallFontSize),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: iconSize * 0.8,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.red[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
    _selectedBank = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isMatching =
                _accountNumberController.text ==
                    _confirmAccountNumberController.text &&
                _accountNumberController.text.isNotEmpty;
            bool isDirty = _confirmAccountNumberController.text.isNotEmpty;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            Expanded(
                              child: Text(
                                l10n.bankAccountDetails,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize + 4,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bank Name Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.bankName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showBankSearchDialog(
                                  context,
                                  setDialogState,
                                  bodyFontSize,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.business_outlined,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedBank ?? l10n.bankNameHint,
                                          style: TextStyle(
                                            color: _selectedBank == null
                                                ? Colors.grey
                                                : Colors.black,
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedBank == 'Other') ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _bankNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter bank name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  onChanged: (val) => setDialogState(() {}),
                                ),
                              ],
                            ],
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
                            l10n.accountHolderName,
                            _holderNameController,
                            hint: l10n.holderNameHint,
                            icon: Icons.person_outline,
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
                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: bodyFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: buttonHeight * 0.8,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrangeStart,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                if (_holderNameController.text.isEmpty ||
                                    _accountNumberController.text.isEmpty ||
                                    _ifscController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.pleaseFillAllFields),
                                    ),
                                  );
                                  return;
                                }
                                if (!isMatching) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.accountNumbersDoNotMatch,
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await _walletRepository.addBankAccount({
                                    'accountNumber':
                                        _accountNumberController.text,
                                    'ifscCode': _ifscController.text,
                                    'accountHolderName':
                                        _holderNameController.text,
                                    'bankName': _bankNameController.text,
                                    'isDefault': _bankAccounts
                                        .isEmpty, // First one is default
                                  });

                                  // Clear fields
                                  _holderNameController.clear();
                                  _accountNumberController.clear();
                                  _confirmAccountNumberController.clear();
                                  _ifscController.clear();
                                  _bankNameController.clear();
                                  _selectedBank = null;

                                  if (context.mounted) Navigator.pop(context);
                                  _fetchPaymentDetails();
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                l10n.saveBankDetails,
                                style: TextStyle(fontSize: bodyFontSize),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBankSearchDialog(
    BuildContext context,
    StateSetter setDialogState,
    double bodyFontSize,
  ) {
    final searchController = TextEditingController();
    List<String> filteredBanks = List.from(_indianBanks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSearchState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: Text(
                            'Select Bank',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: bodyFontSize + 2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search bank name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) {
                        setSearchState(() {
                          if (value.isEmpty) {
                            filteredBanks = List.from(_indianBanks);
                          } else {
                            filteredBanks = _indianBanks
                                .where(
                                  (bank) => bank.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ),
                                )
                                .toList();
                          }
                        });
                      },
                    ),
                  ),
                  // Bank List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = filteredBanks[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.account_balance,
                            color: Colors.grey,
                          ),
                          title: Text(bank),
                          onTap: () {
                            setDialogState(() {
                              _selectedBank = bank;
                              if (bank != 'Other') {
                                _bankNameController.text = bank;
                              } else {
                                _bankNameController.clear();
                              }
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        bool _isVerifying = false;
        bool _isVerified = false;
        String? _verifiedName;
        String? _errorMessage;
        bool _isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 40),
                            Expanded(
                              child: Text(
                                l10n.addUpiId,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: bodyFontSize + 4,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDialogTextField(
                            l10n.upiId,
                            _upiIdController,
                            hint: l10n.upiIdHint,
                            inputFormatters: [],
                            icon: Icons.alternate_email_outlined,
                            obscureText: false,
                            onChanged: (val) async {
                              setDialogState(() {
                                _isVerified = false;
                                _verifiedName = null;
                                _errorMessage = null;
                              });

                              // Auto-verify when UPI ID has valid format
                              if (val.isNotEmpty && val.contains('@')) {
                                setDialogState(() {
                                  _isVerifying = true;
                                });

                                // Add a small delay to avoid too many API calls while typing
                                await Future.delayed(
                                  const Duration(milliseconds: 800),
                                );

                                // Check if the value is still the same (user stopped typing)
                                if (_upiIdController.text == val) {
                                  try {
                                    final res = await _walletRepository
                                        .verifyUpi(val.trim());
                                    setDialogState(() {
                                      _isVerifying = false;
                                      _isVerified = true;
                                      _verifiedName =
                                          res['validatedAccountName'] ??
                                          'Verified User';
                                    });
                                  } catch (e) {
                                    setDialogState(() {
                                      _isVerifying = false;
                                      _errorMessage =
                                          'Verification failed. Please check the UPI ID.';
                                    });
                                  }
                                }
                              }
                            },
                            bodyFontSize: bodyFontSize,
                            smallFontSize: smallFontSize,
                          ),
                          const SizedBox(height: 16),
                          if (_isVerifying)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryOrangeStart
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryOrangeStart,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Verifying UPI ID...',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontSize: smallFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: smallFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isVerified && _verifiedName != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Verified: $_verifiedName',
                                      style: TextStyle(
                                        color: Colors.green.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: smallFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
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
                                    l10n.upiInstantCreditNote,
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
                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: bodyFontSize,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: buttonHeight * 0.8,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isVerified
                                    ? AppColors.primaryOrangeStart
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isVerified && !_isSaving
                                  ? () async {
                                      setDialogState(() => _isSaving = true);
                                      try {
                                        await _walletRepository.addBankAccount({
                                          'upiId': _upiIdController.text.trim(),
                                          'bankName': 'UPI',
                                          'accountHolderName': _verifiedName,
                                          'accountNumber': '',
                                          'ifscCode': '',
                                        });

                                        // Clear fields
                                        _upiIdController.clear();
                                        _confirmUpiIdController.clear();

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        _fetchPaymentDetails();
                                      } catch (e) {
                                        setDialogState(() {
                                          _isSaving = false;
                                          _errorMessage = 'Failed to save: $e';
                                        });
                                      }
                                    }
                                  : null,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      l10n.saveUpi,
                                      style: TextStyle(fontSize: bodyFontSize),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
