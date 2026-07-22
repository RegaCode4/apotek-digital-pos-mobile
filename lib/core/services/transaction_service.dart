import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/sale.dart';
import '../models/cart_item.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<Sale> createTransaction({
    required String buyerName,
    required String paymentMethod,
    required double subtotal,
    required double discountAmount,
    required double taxAmount,
    required double grandTotal,
    String? bpjsClaimNo,
    String? notes,
    required List<CartItem> items,
  }) async {
    try {
      final payload = {
        'buyer_name': buyerName,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'grand_total': grandTotal,
        'bpjs_claim_no': bpjsClaimNo,
        'notes': notes,
        'items': items.map((item) => item.toApiJson()).toList(),
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.transactions,
        data: payload,
      );

      final data = response.data;
      if (data['success'] == true) {
        return Sale.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal memproses transaksi.');
      }
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }

  Future<List<Sale>> getTransactionHistory({String period = 'today'}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.transactions,
        queryParameters: {'period': period},
      );

      final data = response.data;
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Sale.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }

  Future<Sale> getTransactionDetail(int id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.transactionDetail(id),
      );

      final data = response.data;
      if (data['success'] == true) {
        return Sale.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil detail transaksi.');
      }
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }
}
