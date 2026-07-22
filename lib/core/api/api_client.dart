import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';
import '../services/storage_service.dart';

class ApiClient {
  late final Dio dio;
  final StorageService _storageService;
  VoidCallback? onUnauthenticated;

  ApiClient(this._storageService, {this.onUnauthenticated}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storageService.clearAuthData();
            if (onUnauthenticated != null) {
              onUnauthenticated!();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper untuk mengekstrak pesan error yang user-friendly dalam Bahasa Indonesia
  static String extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null && error.response?.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Koneksi ke server terputus/timeout. Periksa koneksi jaringan Anda.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server (${ApiEndpoints.baseUrl}). Pastikan backend Laravel berjalan.';
      }
      return error.message ?? 'Terjadi kesalahan jaringan.';
    }
    return error.toString();
  }
}
