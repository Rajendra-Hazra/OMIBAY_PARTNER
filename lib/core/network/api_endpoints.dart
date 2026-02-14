class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://electric-mollusk-tops.ngrok-free.app';
  static const String baseApiUrl = baseUrl;

  // ============= Authentication =============
  static const String auth = '$baseApiUrl/auth';
  static const String login = '$auth/login';
  static const String sendOtp = '$auth/send-otp';
  static const String verifyOtp = '$auth/verify-otp';
  static const String verifyPhonePartner = '$auth/verify-phone/partner';
  static const String googleLoginPartner = '$auth/oauth/callback/login/partner';
  static const String refreshToken = '$auth/refresh';
  static const String logout = '$auth/logout';

  // ============= User =============
  static const String user = '$baseApiUrl/api/user';
  static const String userProfile = '$user/profile';
  static const String deviceToken = '$user/device-token';

  // ============= Partner Documents =============
  static const String partnerDocuments = '$baseApiUrl/api/partner/documents';
  static const String uploadDocument = '$partnerDocuments/upload';

  // ============= Partner Services =============
  static const String partnerServices = '$baseApiUrl/api/partner/services';
  static const String availableServices = '$partnerServices/available';
  static const String updatePartnerServices = partnerServices;
  static const String partnerStatus =
      '$baseApiUrl/api/partner/services/online-status';
  static const String getPartnerStatus =
      '$partnerServices/status'; // GET endpoint for status & stats

  // ============= Partner Earnings =============
  static const String partnerEarnings = '$baseApiUrl/api/partner/earnings';
  static const String partnerEarningsStats = '$partnerEarnings/stats';
  static const String partnerEarningsGraph = '$partnerEarnings/graph';
  static const String partnerEarningsHistory = '$partnerEarnings/history';

  // ============= Wallet =============
  static const String wallet = '$baseApiUrl/api/wallet';
  static const String walletTransactions = '$wallet/transactions';
  static const String recharge = '$wallet/recharge';
  static const String verifyRecharge = '$wallet/verify-recharge';

  // ============= Bank Details =============
  static const String bankDetails = '$baseApiUrl/api/user/bank-details';
  static const String verifyIfsc = '$bankDetails/ifsc';
  static const String verifyUpi = '$bankDetails/upi';
}
