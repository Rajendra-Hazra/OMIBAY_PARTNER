import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_endpoints.dart';

/// Repository for order-related API operations
/// Handles complete order lifecycle management for partners
abstract class OrderRepository {
  Future<bool> acceptOrder(String orderId);
  Future<bool> rejectOrder(String orderId, {String? reason});
  Future<List<Map<String, dynamic>>> getActiveOrders();
  Future<List<Map<String, dynamic>>> getAllPartnerOrders();
  Future<bool> markOnWay(String orderId);
  Future<bool> markArrived(String orderId);
  Future<bool> verifyArrival(String orderId, String otp);
  Future<bool> pauseOrder(String orderId, String reason);
  Future<bool> verifyResume(String orderId, String otp);
  Future<String?> uploadOrderProof(String orderId, String filePath);
  Future<bool> completeOrder(String orderId);
  Future<bool> partnerCancelOrder(String orderId, String reason);
}

class OrderRepositoryImpl implements OrderRepository {
  final String baseUrl;

  OrderRepositoryImpl({required this.baseUrl});

  /// Get authentication headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        debugPrint('⚠️ No auth token found');
        return {'Content-Type': 'application/json'};
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      debugPrint('Error getting headers: $e');
      return {'Content-Type': 'application/json'};
    }
  }

  @override
  Future<bool> acceptOrder(String orderId) async {
    try {
      debugPrint('🔄 Accepting order: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/accept',
      );

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId accepted successfully');
        return true;
      } else {
        debugPrint(
          '❌ Failed to accept order: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error accepting order: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    try {
      debugPrint('🔄 Rejecting order: $orderId, Reason: $reason');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/reject',
      );

      final body = json.encode({'reason': reason ?? 'Partner declined'});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId rejected successfully');
        return true;
      } else {
        debugPrint(
          '❌ Failed to reject order: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error rejecting order: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActiveOrders() async {
    try {
      debugPrint('🔄 Fetching active orders from backend');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/partner-orders',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('📦 RAW API RESPONSE:');
        debugPrint('url: ${url.toString()}');

        debugPrint(response.body);

        final List<dynamic> orders = json.decode(response.body);

        debugPrint('📊 Total orders from API: ${orders.length}');

        // Log first order details if available
        if (orders.isNotEmpty) {
          debugPrint('🔍 SAMPLE ORDER DATA (first order):');
          debugPrint('  Keys: ${orders[0].keys.toList()}');
          debugPrint('  Full data: ${json.encode(orders[0])}');
        }

        // Filter for active orders only
        // Active statuses: ALLOCATED, PARTNER_ON_WAY, PARTNER_ARRIVED, IN_PROGRESS, PAUSED
        final activeOrders = orders
            .where((order) {
              final status = order['status']?.toString() ?? '';
              return status == 'ALLOCATED' ||
                  status == 'PARTNER_ON_WAY' ||
                  status == 'PARTNER_ARRIVED' ||
                  status == 'IN_PROGRESS' ||
                  status == 'PAUSED';
            })
            .map((order) => order as Map<String, dynamic>)
            .toList();

        debugPrint(
          '✅ Fetched ${activeOrders.length} active orders from backend',
        );

        // Log each active order's key fields
        for (var i = 0; i < activeOrders.length; i++) {
          final order = activeOrders[i];
          debugPrint('  Order $i:');
          debugPrint('    - orderId: ${order['orderId']}');
          debugPrint('    - displayId: ${order['displayId']}');
          debugPrint('    - status: ${order['status']}');
          debugPrint('    - serviceName: ${order['serviceName']}');
          debugPrint('    - totalPrice: ${order['totalPrice']}');
          debugPrint('    - paymentMethod: ${order['paymentMethod']}');
          debugPrint('    - paymentStatus: ${order['paymentStatus']}');
          debugPrint('    - customerName: ${order['customerName']}');
          debugPrint('    - createdAt: ${order['createdAt']}');
          debugPrint('    - isScheduled: ${order['isScheduled']}');
          debugPrint('    - scheduledDateTime: ${order['scheduledDateTime']}');
          debugPrint('    - items: ${order['items']}');
        }

        return activeOrders;
      } else {
        debugPrint(
          '❌ Failed to fetch orders: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching active orders: $e');
      return [];
    }
  }

  @override
  Future<bool> markOnWay(String orderId) async {
    try {
      debugPrint('🔄 Marking order as on way: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/on-way',
      );

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId marked as on way');
        return true;
      } else {
        debugPrint(
          '❌ Failed to mark on way: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error marking on way: $e');
      return false;
    }
  }

  @override
  Future<bool> markArrived(String orderId) async {
    try {
      debugPrint('🔄 Marking order as arrived: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/arrived',
      );

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId marked as arrived');
        return true;
      } else {
        debugPrint(
          '❌ Failed to mark arrived: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error marking arrived: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyArrival(String orderId, String otp) async {
    try {
      debugPrint('🔄 Verifying arrival OTP for order: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/verify-arrival',
      );

      final body = json.encode({'otp': otp});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Arrival OTP verified for order $orderId');
        return true;
      } else {
        debugPrint(
          '❌ Failed to verify arrival: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error verifying arrival: $e');
      return false;
    }
  }

  @override
  Future<bool> pauseOrder(String orderId, String reason) async {
    try {
      debugPrint('🔄 Pausing order: $orderId, Reason: $reason');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/pause',
      );

      final body = json.encode({'reason': reason});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId paused successfully');
        return true;
      } else {
        debugPrint(
          '❌ Failed to pause order: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error pausing order: $e');
      return false;
    }
  }

  @override
  Future<bool> verifyResume(String orderId, String otp) async {
    try {
      debugPrint('🔄 Verifying resume OTP for order: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/resume',
      );

      final body = json.encode({'otp': otp});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Resume OTP verified for order $orderId');
        return true;
      } else {
        debugPrint(
          '❌ Failed to verify resume: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error verifying resume: $e');
      return false;
    }
  }

  @override
  Future<String?> uploadOrderProof(String orderId, String filePath) async {
    try {
      debugPrint('🔄 Uploading proof for order: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/proof',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Add file
      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint('✅ Proof uploaded successfully for order $orderId');
        return response.body; // Returns the uploaded file URL
      } else {
        debugPrint(
          '❌ Failed to upload proof: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error uploading proof: $e');
      return null;
    }
  }

  @override
  Future<bool> completeOrder(String orderId) async {
    try {
      debugPrint('🔄 Completing order: $orderId');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/complete',
      );

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId completed successfully');
        return true;
      } else {
        debugPrint(
          '❌ Failed to complete order: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error completing order: $e');
      return false;
    }
  }

  @override
  Future<bool> partnerCancelOrder(String orderId, String reason) async {
    try {
      debugPrint('🔄 Partner cancelling order: $orderId, Reason: $reason');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/$orderId/partner-cancel',
      );

      final body = json.encode({'reason': reason});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        debugPrint('✅ Order $orderId cancelled by partner');
        return true;
      } else {
        debugPrint(
          '❌ Failed to cancel order: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPartnerOrders() async {
    try {
      debugPrint('🔄 Fetching ALL partner orders from backend');

      final headers = await _getHeaders();
      final url = Uri.parse(
        '${ApiEndpoints.baseApiUrl}/api/orders/partner-orders',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> orders = json.decode(response.body);
        debugPrint('📊 Total orders from API: ${orders.length}');

        // Return ALL orders without status filtering
        final allOrders = orders
            .map((order) => order as Map<String, dynamic>)
            .toList();

        debugPrint('✅ Fetched ${allOrders.length} orders (active + completed)');
        return allOrders;
      } else {
        debugPrint(
          '❌ Failed to fetch all orders: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching all orders: $e');
      return [];
    }
  }
}
