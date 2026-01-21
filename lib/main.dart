import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart' as intl_symbols;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'l10n/app_localizations.dart';
import 'core/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/document_verification_screen.dart';
import 'screens/auth/location_selection_screen.dart';
import 'screens/auth/aadhar_verification_screen.dart';
import 'screens/auth/pan_verification_screen.dart';
import 'screens/auth/dl_verification_screen.dart';
import 'screens/auth/work_verification_screen.dart';
import 'screens/jobs/job_details_screen.dart';
import 'screens/jobs/active_job_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/account/support_screen.dart';
import 'screens/account/payment_setup_screen.dart';
import 'screens/account/edit_services_screen.dart';
import 'screens/account/edit_profile_screen.dart';
import 'screens/account/documents_list_screen.dart';
import 'screens/account/permissions_screen.dart';
import 'screens/account/terms_of_service_screen.dart';
import 'screens/account/privacy_policy_screen.dart';
import 'screens/account/suspension_policy_screen.dart';
import 'screens/account/language_selection_screen.dart';
import 'screens/account/account_faq_screen.dart';
import 'screens/account/live_chat_screen.dart';
import 'screens/account/deactivate_account_screen.dart';
import 'screens/account/delete_account_screen.dart';
import 'screens/account/settings_screen.dart';
import 'screens/earnings/transaction_details_screen.dart';
import 'screens/earnings/referral_screen.dart';
import 'screens/earnings/withdrawal_history_screen.dart';
import 'screens/home/opportunity_map_screen.dart';
import 'widgets/main_nav_wrapper.dart';

// Global navigator key for notification handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global locale notifier for language switching
class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier();

  static final LocaleNotifier instance = LocaleNotifier();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'en';
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /* Temporarily disabled for UI testing without google-services.json
  // Initialize Firebase (skip on web until FirebaseOptions are configured)
  if (!kIsWeb) {
    await Firebase.initializeApp();

    // Set up FCM background message handler (mobile only)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize notification service (mobile only)
    await NotificationService.instance.initialize(navKey: navigatorKey);
  }
  */

  // Force English digits globally for Bengali locale to ensure numeric numbers
  // always stay in English as per user preference.
  if (intl_symbols.numberFormatSymbols.containsKey('bn')) {
    final bnSymbols = intl_symbols.numberFormatSymbols['bn'] as NumberSymbols;
    intl_symbols.numberFormatSymbols['bn'] = NumberSymbols(
      NAME: bnSymbols.NAME,
      DECIMAL_SEP: bnSymbols.DECIMAL_SEP,
      GROUP_SEP: bnSymbols.GROUP_SEP,
      PERCENT: bnSymbols.PERCENT,
      ZERO_DIGIT: '0', // Force English digits (0-9)
      PLUS_SIGN: bnSymbols.PLUS_SIGN,
      MINUS_SIGN: bnSymbols.MINUS_SIGN,
      EXP_SYMBOL: bnSymbols.EXP_SYMBOL,
      PERMILL: bnSymbols.PERMILL,
      INFINITY: bnSymbols.INFINITY,
      NAN: bnSymbols.NAN,
      DECIMAL_PATTERN: bnSymbols.DECIMAL_PATTERN,
      SCIENTIFIC_PATTERN: bnSymbols.SCIENTIFIC_PATTERN,
      PERCENT_PATTERN: bnSymbols.PERCENT_PATTERN,
      CURRENCY_PATTERN: bnSymbols.CURRENCY_PATTERN,
      DEF_CURRENCY_CODE: bnSymbols.DEF_CURRENCY_CODE,
    );
  }

  await LocaleNotifier.instance.loadSavedLocale();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    LocaleNotifier.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleNotifier.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmiBay Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Global navigator key for notification handling
      navigatorKey: navigatorKey,
      // Localization configuration
      locale: LocaleNotifier.instance.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('bn'), // Bengali
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/verification': (context) => const DocumentVerificationScreen(),
        '/location-selection': (context) => const LocationSelectionScreen(),
        '/aadhar-verification': (context) => const AadharVerificationScreen(),
        '/pan-verification': (context) => const PanVerificationScreen(),
        '/dl-verification': (context) => const DlVerificationScreen(),
        '/work-verification': (context) => const WorkVerificationScreen(),
        '/home': (context) => const MainNavigationWrapper(initialIndex: 0),
        '/jobs': (context) => const MainNavigationWrapper(initialIndex: 1),
        '/earnings': (context) => const MainNavigationWrapper(initialIndex: 2),
        '/account': (context) => const MainNavigationWrapper(initialIndex: 3),
        '/job-details': (context) => const JobDetailsScreen(),
        '/active-job': (context) => const ActiveJobScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/support': (context) => const SupportScreen(),
        '/payment-setup': (context) => const PaymentSetupScreen(),
        '/edit-services': (context) => const EditServicesScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/documents': (context) => const DocumentsListScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/terms': (context) => const TermsOfServiceScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
        '/suspension-policy': (context) => const SuspensionPolicyScreen(),
        '/language': (context) => const LanguageSelectionScreen(),
        '/transaction-details': (context) => const TransactionDetailsScreen(),
        '/referral': (context) => const ReferralScreen(),
        '/withdrawal-history': (context) => const WithdrawalHistoryScreen(),
        '/opportunity-map': (context) => const OpportunityMapScreen(),
        '/account-faq': (context) => const AccountFaqScreen(),
        '/live-chat': (context) => const LiveChatScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/deactivate-account': (context) => const DeactivateAccountScreen(),
        '/delete-account': (context) => const DeleteAccountScreen(),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
