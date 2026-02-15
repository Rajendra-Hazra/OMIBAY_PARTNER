import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auth_response.dart';

abstract class AuthRepository {
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  });

  Future<AuthResponse> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  });

  Future<bool> isAuthenticated();
  Future<AuthResponse?> refreshToken();
  Future<void> logout();
  Future<AuthResponse> signInWithGoogle();
  Future<void> updateFcmToken(String token);
}

class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth? _firebaseAuth;
  FirebaseMessaging? _firebaseMessaging;
  final ApiClient _apiClient;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseMessaging? firebaseMessaging,
    required ApiClient apiClient,
  }) : _apiClient = apiClient {
    if (firebaseAuth != null) {
      _firebaseAuth = firebaseAuth;
    } else {
      try {
        _firebaseAuth = FirebaseAuth.instance;
      } catch (e) {
        debugPrint(
          'FirebaseAuth instance not available (likely on Web without config): $e',
        );
      }
    }

    if (firebaseMessaging != null) {
      _firebaseMessaging = firebaseMessaging;
    } else {
      try {
        _firebaseMessaging = FirebaseMessaging.instance;
      } catch (e) {
        debugPrint('FirebaseMessaging instance not available: $e');
      }
    }
  }

  @override
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    if (_firebaseAuth == null) {
      throw Exception('Firebase Auth not initialized');
    }

    String formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber
        : '+91$phoneNumber';

    await _firebaseAuth!.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    try {
      if (_firebaseAuth == null) {
        throw Exception('Firebase Auth not initialized');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth!.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase authentication failed: User is null');
      }

      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Safe get token
      final fcmToken = _firebaseMessaging != null
          ? await _firebaseMessaging!.getToken()
          : null;

      final response = await _apiClient.post(
        ApiEndpoints.verifyPhonePartner,
        data: {
          'phoneNumber': phoneNumber,
          'fcmToken': fcmToken,
          'deviceType': 'ANDROID',
        },
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);
      await prefs.setString('profile_phone', authResponse.data.mobileNumber);
      await prefs.setBool('phone_verified', true);
      await prefs.setBool('is_verified', authResponse.data.isVerified);

      // Save Partner Profile Data
      await prefs.setString('profile_id', authResponse.data.id);
      await prefs.setString(
        'profile_referral_code',
        authResponse.data.referralCode,
      );
      await prefs.setString(
        'profile_rating',
        authResponse.data.avgRating.toString(),
      );
      await prefs.setString('partner_access_date', authResponse.data.createdAt);

      // Save user details for chat and profile
      if (authResponse.data.name.isNotEmpty) {
        await prefs.setString('profile_name', authResponse.data.name);
      }
      if (authResponse.data.email != null &&
          authResponse.data.email!.isNotEmpty) {
        await prefs.setString('profile_email', authResponse.data.email!);
      }
      if (authResponse.data.partnerId != null &&
          authResponse.data.partnerId!.isNotEmpty) {
        await prefs.setString('partner_id', authResponse.data.partnerId!);
      }

      if (authResponse.data.totalJobsDone > 0) {
        List<String> dummyJobs = List.filled(
          authResponse.data.totalJobsDone,
          "job_id",
        );
        await prefs.setStringList('completed_jobs_list', dummyJobs);
      }

      return authResponse;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Firebase Auth Error');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthResponse?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Update saved tokens
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);

      // Update Profile Data on Refresh
      await prefs.setString('profile_id', authResponse.data.id);
      await prefs.setString(
        'profile_referral_code',
        authResponse.data.referralCode,
      );
      await prefs.setString('profile_phone', authResponse.data.mobileNumber);
      await prefs.setString(
        'profile_rating',
        authResponse.data.avgRating.toString(),
      );

      // Update user details for chat and profile
      if (authResponse.data.name.isNotEmpty) {
        await prefs.setString('profile_name', authResponse.data.name);
      }
      if (authResponse.data.email != null &&
          authResponse.data.email!.isNotEmpty) {
        await prefs.setString('profile_email', authResponse.data.email!);
      }
      if (authResponse.data.partnerId != null &&
          authResponse.data.partnerId!.isNotEmpty) {
        await prefs.setString('partner_id', authResponse.data.partnerId!);
      }

      // Update jobs count
      if (authResponse.data.totalJobsDone > 0) {
        List<String> dummyJobs = List.filled(
          authResponse.data.totalJobsDone,
          "job_id",
        );
        await prefs.setStringList('completed_jobs_list', dummyJobs);
      }

      // Update access date if available
      if (authResponse.data.createdAt.isNotEmpty) {
        await prefs.setString(
          'partner_access_date',
          authResponse.data.createdAt,
        );
      }

      // Notify listeners to update UI
      AppColors.profileUpdateNotifier.value++;

      return authResponse;
    } catch (e) {
      debugPrint('Refresh token failed: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      debugPrint('Backend logout failed: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await _firebaseAuth?.signOut();
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '696877816068-js08nml9tcggpk595nf5mv9gr6i77pvv.apps.googleusercontent.com',
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In cancelled by user');
      }

      final serverAuthCode = googleUser.serverAuthCode;
      if (serverAuthCode == null) {
        throw Exception('Failed to get Google server auth code');
      }

      final response = await _apiClient.post(
        ApiEndpoints.googleLoginPartner,
        data: {
          'code': serverAuthCode,
          'redirectUri': 'http://localhost:3000/auth/callback',
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);
      await prefs.setString('profile_phone', authResponse.data.mobileNumber);
      await prefs.setBool('is_verified', authResponse.data.isVerified);

      // Save Partner Profile Data
      await prefs.setString('profile_id', authResponse.data.id);
      await prefs.setString(
        'profile_referral_code',
        authResponse.data.referralCode,
      );
      await prefs.setString(
        'profile_rating',
        authResponse.data.avgRating.toString(),
      );
      await prefs.setString('partner_access_date', authResponse.data.createdAt);

      // Save user details for chat and profile
      if (authResponse.data.name.isNotEmpty) {
        await prefs.setString('profile_name', authResponse.data.name);
      }
      if (authResponse.data.email != null &&
          authResponse.data.email!.isNotEmpty) {
        await prefs.setString('profile_email', authResponse.data.email!);
      }
      if (authResponse.data.partnerId != null &&
          authResponse.data.partnerId!.isNotEmpty) {
        await prefs.setString('partner_id', authResponse.data.partnerId!);
      }

      if (authResponse.data.totalJobsDone > 0) {
        List<String> dummyJobs = List.filled(
          authResponse.data.totalJobsDone,
          "job_id",
        );
        await prefs.setStringList('completed_jobs_list', dummyJobs);
      }

      // Sync FCM Token after Google Login (as server callback doesn't handle it)
      try {
        if (_firebaseMessaging != null) {
          final fcmToken = await _firebaseMessaging!.getToken();
          if (fcmToken != null) {
            await updateFcmToken(fcmToken);
          }
        }
      } catch (e) {
        debugPrint('Failed to sync FCM token after Google Login: $e');
      }

      return authResponse;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) return;

      await _apiClient.post(
        ApiEndpoints.deviceToken,
        data: {
          'token': token,
          'deviceType': 'ANDROID', // Assuming Android for now, could be dynamic
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      debugPrint('FCM Token updated on server successfully');
    } catch (e) {
      debugPrint('Failed to update FCM token on server: $e');
      // Don't rethrow, this is a background background operation
    }
  }
}
