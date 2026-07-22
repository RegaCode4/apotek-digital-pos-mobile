import 'package:flutter/foundation.dart';

class ApiEndpoints {
  /// Base URL default berdasarkan platform:
  /// - Web: `http://localhost:8000/api`
  /// - Mobile/Emulator: `http://10.0.2.2:8000/api`
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

  static const String _definedBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    return defaultBaseUrl;
  }

  /// Base Web URL untuk mencetak Struk PDF (misal: `/sistem/pos/struk/{id}`)
  static String receiptUrl(int saleId, {String? customBaseUrl}) {
    final root = (customBaseUrl != null && customBaseUrl.isNotEmpty)
        ? customBaseUrl
        : baseUrl;
    final webRoot = root.replaceAll(RegExp(r'/api/?$'), '');
    return '$webRoot/sistem/pos/struk/$saleId';
  }

  // Endpoints Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user';

  // Endpoints Medicines
  static const String searchMedicines = '/medicines/search';
  static String medicineDetail(int id) => '/medicines/$id';

  // Endpoints Transactions
  static const String transactions = '/transactions';
  static String transactionDetail(int id) => '/transactions/$id';
}
