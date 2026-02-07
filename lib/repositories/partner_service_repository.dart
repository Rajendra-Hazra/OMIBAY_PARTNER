import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class PartnerServiceDetail {
  final String serviceTypeId;
  final String? experience;
  final String? specialSkills;
  final String? videoUrl;

  PartnerServiceDetail({
    required this.serviceTypeId,
    this.experience,
    this.specialSkills,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceTypeId': serviceTypeId,
      'experience': experience,
      'specialSkills': specialSkills,
      'videoUrl': videoUrl,
    };
  }
}

class PartnerServiceSelectionResponse {
  final String partnerId;
  final List<String> selectedServices;

  PartnerServiceSelectionResponse({
    required this.partnerId,
    required this.selectedServices,
  });

  factory PartnerServiceSelectionResponse.fromJson(Map<String, dynamic> json) {
    return PartnerServiceSelectionResponse(
      partnerId: json['partnerId'] ?? '',
      selectedServices:
          (json['selectedServices'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class PartnerStatus {
  final bool isOnline;
  final bool isAvailable;
  final bool isBusy;
  final int weeklyOrderCount;
  final int weeklyIncentiveTarget;
  final double weeklyIncentiveAmount;
  final double rating;
  final double todayEarnings;
  final int todayJobs;

  PartnerStatus({
    required this.isOnline,
    required this.isAvailable,
    required this.isBusy,
    this.weeklyOrderCount = 0,
    this.weeklyIncentiveTarget = 0,
    this.weeklyIncentiveAmount = 0.0,
    this.rating = 0.0,
    this.todayEarnings = 0.0,
    this.todayJobs = 0,
  });

  factory PartnerStatus.fromJson(Map<String, dynamic> json) {
    return PartnerStatus(
      isOnline: json['isOnline'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      isBusy: json['isBusy'] ?? false,
      weeklyOrderCount: json['weeklyOrderCount'] ?? 0,
      weeklyIncentiveTarget: json['weeklyIncentiveTarget'] ?? 0,
      weeklyIncentiveAmount: (json['weeklyIncentiveAmount'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      todayEarnings: (json['todayEarnings'] ?? 0.0).toDouble(),
      todayJobs: json['todayJobs'] ?? 0,
    );
  }
}

abstract class PartnerServiceRepository {
  Future<List<ServiceType>> getAvailableServiceTypes();
  Future<void> updatePartnerServices(List<PartnerServiceDetail> details);
  Future<void> updateOnlineStatus(
    bool isOnline, {
    double? latitude,
    double? longitude,
  });
  Future<PartnerStatus?> getPartnerStatus();
  Future<List<String>> getPartnerSelectedServices();
}

class ServiceType {
  final String id;
  final String name;
  final String? icon;

  ServiceType({required this.id, required this.name, this.icon});

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'].toString(),
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class PartnerServiceRepositoryImpl implements PartnerServiceRepository {
  final ApiClient _apiClient;

  PartnerServiceRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ServiceType>> getAvailableServiceTypes() async {
    final response = await _apiClient.get(ApiEndpoints.availableServices);
    if (response.data is List) {
      return (response.data as List)
          .map((json) => ServiceType.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<void> updatePartnerServices(List<PartnerServiceDetail> details) async {
    await _apiClient.post(
      ApiEndpoints.updatePartnerServices,
      data: {'services': details.map((d) => d.toJson()).toList()},
    );
  }

  @override
  Future<void> updateOnlineStatus(
    bool isOnline, {
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, dynamic>{'isOnline': isOnline};

    if (latitude != null && longitude != null) {
      queryParams['latitude'] = latitude;
      queryParams['longitude'] = longitude;
    }

    await _apiClient.post(
      ApiEndpoints.partnerStatus,
      queryParameters: queryParams,
    );
  }

  @override
  Future<PartnerStatus?> getPartnerStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getPartnerStatus);
      if (response.data != null) {
        return PartnerStatus.fromJson(response.data);
      }
    } catch (e) {
      // Handle error gracefully or rethrow
      print('Error fetching partner status: $e');
    }
    return null;
  }

  @override
  Future<List<String>> getPartnerSelectedServices() async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.partnerServices}/selected',
      );
      if (response.data != null) {
        final selection = PartnerServiceSelectionResponse.fromJson(
          response.data,
        );
        return selection.selectedServices;
      }
    } catch (e) {
      print('Error fetching selected services: $e');
    }
    return [];
  }
}
