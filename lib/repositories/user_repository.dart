import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auth_response.dart';

abstract class UserRepository {
  Future<UserData> getUserProfile();
  Future<UserData> updateProfile({
    String? fullName,
    String? dateOfBirth,
    File? profilePicture,
  });
  Future<UserData> updateEmail(String newEmail, String currentPassword);
  Future<UserData> updateMobile(String mobileNumber);
}

class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<UserData> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userProfile);
      return UserData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserData> updateProfile({
    String? fullName,
    String? dateOfBirth,
    File? profilePicture,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {};
      if (fullName != null) formDataMap['fullName'] = fullName;
      if (dateOfBirth != null) formDataMap['dateOfBirth'] = dateOfBirth;
      if (profilePicture != null) {
        formDataMap['file'] = await MultipartFile.fromFile(
          profilePicture.path,
          filename: profilePicture.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await _apiClient.dio.put(
        ApiEndpoints.userProfile,
        data: formData,
      );

      return UserData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserData> updateEmail(String newEmail, String currentPassword) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.user}/email',
        data: {'newEmail': newEmail, 'currentPassword': currentPassword},
      );
      return UserData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserData> updateMobile(String mobileNumber) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiEndpoints.user}/mobile',
        data: {'mobileNumber': mobileNumber},
      );
      return UserData.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
