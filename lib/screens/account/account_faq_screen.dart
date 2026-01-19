import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';

class AccountFaqScreen extends StatefulWidget {
  const AccountFaqScreen({super.key});

  @override
  State<AccountFaqScreen> createState() => _AccountFaqScreenState();
}

class _AccountFaqScreenState extends State<AccountFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory =
      ''; // Initialize empty, will set in didChangeDependencies

  List<String> get _categories => [
    AppLocalizations.of(context)!.all,
    AppLocalizations.of(context)!.categoryAccount,
    AppLocalizations.of(context)!.categoryNotification,
    AppLocalizations.of(context)!.categoryService,
    AppLocalizations.of(context)!.categoryJobs,
    AppLocalizations.of(context)!.categoryPayments,
    AppLocalizations.of(context)!.categoryDocuments,
    AppLocalizations.of(context)!.categoryAppFeature,
  ];

  List<Map<String, String>> get _faqData => [
    {
      'question': AppLocalizations.of(context)!.faqQuestion1,
      'answer': AppLocalizations.of(context)!.faqAnswer1,
      'category': AppLocalizations.of(context)!.categoryDocuments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion2,
      'answer': AppLocalizations.of(context)!.faqAnswer2,
      'category': AppLocalizations.of(context)!.categoryDocuments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion3,
      'answer': AppLocalizations.of(context)!.faqAnswer3,
      'category': AppLocalizations.of(context)!.categoryDocuments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion4,
      'answer': AppLocalizations.of(context)!.faqAnswer4,
      'category': AppLocalizations.of(context)!.categoryAccount,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion5,
      'answer': AppLocalizations.of(context)!.faqAnswer5,
      'category': AppLocalizations.of(context)!.categoryAccount,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion6,
      'answer': AppLocalizations.of(context)!.faqAnswer6,
      'category': AppLocalizations.of(context)!.categoryPayments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion7,
      'answer': AppLocalizations.of(context)!.faqAnswer7,
      'category': AppLocalizations.of(context)!.categoryPayments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion8,
      'answer': AppLocalizations.of(context)!.faqAnswer8,
      'category': AppLocalizations.of(context)!.categoryNotification,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion9,
      'answer': AppLocalizations.of(context)!.faqAnswer9,
      'category': AppLocalizations.of(context)!.categoryService,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion10,
      'answer': AppLocalizations.of(context)!.faqAnswer10,
      'category': AppLocalizations.of(context)!.categoryJobs,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion11,
      'answer': AppLocalizations.of(context)!.faqAnswer11,
      'category': AppLocalizations.of(context)!.categoryAppFeature,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion12,
      'answer': AppLocalizations.of(context)!.faqAnswer12,
      'category': AppLocalizations.of(context)!.categoryDocuments,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion13,
      'answer': AppLocalizations.of(context)!.faqAnswer13,
      'category': AppLocalizations.of(context)!.categoryAccount,
    },
    {
      'question': AppLocalizations.of(context)!.faqQuestion14,
      'answer': AppLocalizations.of(context)!.faqAnswer14,
      'category': AppLocalizations.of(context)!.categoryJobs,
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategory.isEmpty) {
      _selectedCategory = AppLocalizations.of(context)!.all;
    }
  }

  List<Map<String, String>> get _filteredFaq {
    return _faqData.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item['question']!.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == AppLocalizations.of(context)!.all ||
          item['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHelp,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Categories Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primaryOrangeStart.withValues(
                        alpha: 0.1,
                      ),
                      checkmarkColor: AppColors.primaryOrangeStart,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primaryOrangeStart
                            : AppColors.textPrimary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryOrangeStart
                              : Colors.transparent,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Document Prompt Style Information
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.docVerificationPrompt,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // FAQ List
            Expanded(
              child: _filteredFaq.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredFaq.length + 1,
                      itemBuilder: (context, index) {
                        // Show FAQ items
                        if (index < _filteredFaq.length) {
                          final item = _filteredFaq[index];
                          return _buildFaqItem(item);
                        }
                        // Show help section at the end
                        return _buildStillNeedHelpSection();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.accountIssueAndFaq,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          item['question']!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            item['answer']!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item['category']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrangeStart,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noResultsFoundFor(_searchQuery),
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tryDifferentKeywords,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStillNeedHelpSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeStart.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryOrangeStart.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                color: AppColors.primaryOrangeStart,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.stillNeedHelp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.stillNeedHelpContent,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
