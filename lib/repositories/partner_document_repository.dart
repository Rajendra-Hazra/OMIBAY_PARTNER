import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

abstract class PartnerDocumentRepository {
  Future<void> uploadDocument({
    required String documentType,
    required String filePath,
    String side = 'NONE',
  });
}

class PartnerDocumentRepositoryImpl implements PartnerDocumentRepository {
  final ApiClient _apiClient;

  PartnerDocumentRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<void> uploadDocument({
    required String documentType,
    required String filePath,
    String side = 'NONE',
  }) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'documentType': documentType,
      'side': side,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    await _apiClient.post(
      ApiEndpoints.uploadDocument,
      data: formData,
      options: Options(
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }
}
