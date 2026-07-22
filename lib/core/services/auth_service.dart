import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user = User.fromJson(data['data']['user']);

        await _storageService.saveToken(token);
        await _storageService.saveUser(user);

        return user;
      } else {
        throw Exception(data['message'] ?? 'Login gagal.');
      }
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network failure during logout
    } finally {
      await _storageService.clearAuthData();
    }
  }

  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
