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
          final savedUrl = await _storageService.getBaseUrl();
          if (savedUrl != null && savedUrl.isNotEmpty) {
            options.baseUrl = savedUrl;
          }

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

  void updateBaseUrl(String newUrl) {
    final cleanUrl = newUrl.trim();
    dio.options.baseUrl = cleanUrl;
    _storageService.saveBaseUrl(cleanUrl);
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
        return 'Koneksi ke server terputus/timeout (15 detik). Periksa jaringan Wi-Fi/Hotspot Anda.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server backend. Pastikan server Laravel sedang berjalan.';
      }
      return error.message ?? 'Terjadi kesalahan jaringan.';
    }
    return error.toString();
  }
}
