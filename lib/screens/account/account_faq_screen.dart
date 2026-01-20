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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final horizontalPadding = (screenWidth * 0.04).clamp(16.0, 24.0);
    final verticalPadding = (screenHeight * 0.015).clamp(12.0, 20.0);
    final headingFontSize = (screenWidth * 0.05).clamp(18.0, 22.0);
    final bodyFontSize = (screenWidth * 0.038).clamp(14.0, 16.0);
    final smallFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);
    final iconSize = (screenWidth * 0.06).clamp(24.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context, headingFontSize, iconSize),
            // Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding * 0.5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: bodyFontSize),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHelp,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: iconSize * 0.8,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: iconSize * 0.7),
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
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding * 0.5,
              ),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: smallFontSize + 1,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primaryOrangeStart
                              : AppColors.textPrimary,
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  padding: EdgeInsets.all(horizontalPadding * 0.6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: iconSize * 0.7,
                      ),
                      SizedBox(width: horizontalPadding * 0.6),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.docVerificationPrompt,
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: smallFontSize + 1,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: verticalPadding),

            // FAQ List
            Expanded(
              child: _filteredFaq.isEmpty
                  ? _buildEmptyState(iconSize, bodyFontSize)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      itemCount: _filteredFaq.length + 1,
                      itemBuilder: (context, index) {
                        // Show FAQ items
                        if (index < _filteredFaq.length) {
                          final item = _filteredFaq[index];
                          return _buildFaqItem(
                            item,
                            bodyFontSize,
                            smallFontSize,
                          );
                        }
                        // Show help section at the end
                        return _buildStillNeedHelpSection(
                          bodyFontSize,
                          smallFontSize,
                          iconSize,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double headingFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 16,
        bottom: 16,
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
            icon: Icon(Icons.arrow_back_ios_new, size: iconSize * 0.7),
            onPressed: () => Navigator.pop(context),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.accountIssueAndFaq,
              style: TextStyle(
                fontSize: headingFontSize,
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

  Widget _buildFaqItem(
    Map<String, String> item,
    double bodyFontSize,
    double smallFontSize,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            item['question']!,
            style: TextStyle(
              fontSize: bodyFontSize,
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
                fontSize: smallFontSize + 1,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryOrangeStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['category']!,
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrangeStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double iconSize, double bodyFontSize) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: iconSize * 2.5,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppLocalizations.of(context)!.noResultsFoundFor(_searchQuery),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: bodyFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryDifferentKeywords,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: bodyFontSize * 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStillNeedHelpSection(
    double bodyFontSize,
    double smallFontSize,
    double iconSize,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeStart.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
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
                size: iconSize * 0.8,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.stillNeedHelp,
                  style: TextStyle(
                    fontSize: bodyFontSize,
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
              fontSize: smallFontSize + 1,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
