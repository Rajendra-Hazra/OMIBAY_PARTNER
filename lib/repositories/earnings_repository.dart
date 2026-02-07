import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/earnings_stats.dart';

class EarningsRepository {
  final ApiClient _apiClient;

  EarningsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<EarningsStats> getEarningsStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.partnerEarningsStats);
      return EarningsStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEarningsGraph({
    int? month,
    int? year,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.partnerEarningsGraph,
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );

      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getEarningsHistory() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.partnerEarningsHistory,
      );
      // Return raw list, UI will map it.
      return (response.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
