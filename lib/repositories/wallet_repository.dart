import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/wallet_transaction.dart';

abstract class WalletRepository {
  Future<List<WalletTransaction>> getTransactions();
  Future<Map<String, dynamic>> createRechargeOrder(double amount);
  Future<void> verifyRecharge(
    String orderId,
    String paymentId,
    String signature,
  );

  // Bank Accounts
  Future<void> addBankAccount(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getBankAccounts();
  Future<void> deleteBankAccount(String id);
  Future<Map<String, dynamic>> verifyIfsc(String code);
}

class WalletRepositoryImpl implements WalletRepository {
  final ApiClient apiClient;

  WalletRepositoryImpl({required this.apiClient});

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    final response = await apiClient.get(ApiEndpoints.walletTransactions);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((e) => WalletTransaction.fromJson(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> createRechargeOrder(double amount) async {
    final response = await apiClient.post(
      ApiEndpoints.recharge,
      data: {'amount': amount},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> verifyRecharge(
    String orderId,
    String paymentId,
    String signature,
  ) async {
    await apiClient.post(
      ApiEndpoints.verifyRecharge,
      data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      },
    );
  }

  // ============= Bank Account Implementation =============

  @override
  Future<void> addBankAccount(Map<String, dynamic> data) async {
    await apiClient.post(ApiEndpoints.bankDetails, data: data);
  }

  @override
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    final response = await apiClient.get(ApiEndpoints.bankDetails);
    final data = response.data;
    if (data['hasDetails'] == true) {
      return List<Map<String, dynamic>>.from(data['accounts']);
    }
    return [];
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    await apiClient.delete('${ApiEndpoints.bankDetails}/$id');
  }

  @override
  Future<Map<String, dynamic>> verifyIfsc(String code) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.verifyIfsc}/$code');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid IFSC Code');
    }
  }
}
