class AuthResponse {
  final UserData data;
  final String message;
  final String accessToken;
  final String refreshToken;
  final int status;

  AuthResponse({
    required this.data,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.status,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: UserData.fromJson(json['data']),
      message: json['message'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      status: json['status'] ?? 200,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'status': status,
    };
  }
}

class UserData {
  final String id;
  final String mobileNumber;
  final String? email;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final String authProvider;
  final String? providerId;
  final String userType;
  final String? fullName;
  final String? dateOfBirth;
  final bool isActive;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;
  final String referralCode;
  final double walletBalance;
  final double totalEarnedReferral;
  final double totalWithdrawn;
  final double pendingWithdrawal;
  final String? profilePictureUrl;
  final String? defaultBankAccountNumber;
  final String? defaultBankName;
  final String? defaultIfscCode;
  final String? defaultAccountHolderName;
  final bool oauthUser;
  final bool mobileOtpUser;
  final bool emailPasswordUser;
  final String name;
  final double avgRating;
  final int totalJobsDone;
  final String? partnerId;

  UserData({
    required this.id,
    required this.mobileNumber,
    this.email,
    required this.isMobileVerified,
    required this.isEmailVerified,
    required this.authProvider,
    this.providerId,
    required this.userType,
    this.fullName,
    this.dateOfBirth,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.referralCode,
    required this.walletBalance,
    required this.totalEarnedReferral,
    required this.totalWithdrawn,
    required this.pendingWithdrawal,
    this.defaultBankAccountNumber,
    this.defaultBankName,
    this.defaultIfscCode,
    this.defaultAccountHolderName,
    this.profilePictureUrl,
    required this.oauthUser,
    required this.mobileOtpUser,
    required this.emailPasswordUser,
    required this.name,
    this.avgRating = 0.0,
    this.totalJobsDone = 0,
    this.partnerId,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'],
      isMobileVerified: json['isMobileVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      authProvider: json['authProvider'] ?? 'LOCAL',
      providerId: json['providerId'],
      userType: json['userType'] ?? 'NORMAL',
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      referralCode: json['referralCode'] ?? '',
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      totalEarnedReferral: (json['totalEarnedReferral'] ?? 0).toDouble(),
      totalWithdrawn: (json['totalWithdrawn'] ?? 0).toDouble(),
      pendingWithdrawal: (json['pendingWithdrawal'] ?? 0).toDouble(),
      defaultBankAccountNumber: json['defaultBankAccountNumber'],
      defaultBankName: json['defaultBankName'],
      defaultIfscCode: json['defaultIfscCode'],
      defaultAccountHolderName: json['defaultAccountHolderName'],
      profilePictureUrl: json['profilePictureUrl'],
      oauthUser: json['oauthUser'] ?? false,
      mobileOtpUser: json['mobileOtpUser'] ?? false,
      emailPasswordUser: json['emailPasswordUser'] ?? false,
      name: json['name'] ?? '',
      avgRating: (json['avgRating'] ?? 0).toDouble(),
      totalJobsDone: json['totalJobsDone'] ?? 0,
      partnerId: json['partnerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'email': email,
      'isMobileVerified': isMobileVerified,
      'isEmailVerified': isEmailVerified,
      'authProvider': authProvider,
      'providerId': providerId,
      'userType': userType,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'referralCode': referralCode,
      'walletBalance': walletBalance,
      'totalEarnedReferral': totalEarnedReferral,
      'totalWithdrawn': totalWithdrawn,
      'pendingWithdrawal': pendingWithdrawal,
      'defaultBankAccountNumber': defaultBankAccountNumber,
      'defaultBankName': defaultBankName,
      'defaultIfscCode': defaultIfscCode,
      'defaultAccountHolderName': defaultAccountHolderName,
      'emailPasswordUser': emailPasswordUser,
      'name': name,
      'avgRating': avgRating,
      'totalJobsDone': totalJobsDone,
      'partnerId': partnerId,
    };
  }
}
