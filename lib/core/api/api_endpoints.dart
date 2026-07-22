class ApiEndpoints {
  /// Base URL API dapat diganti saat build/run via `--dart-define=BASE_URL=http://...`
  /// Default untuk Android Emulator: `http://10.0.2.2:8000/api`
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  /// Base Web URL untuk mencetak Struk PDF (misal: `/sistem/pos/struk/{id}`)
  static String receiptUrl(int saleId) {
    // Ambil web root dari baseUrl dengan menghapus `/api`
    final webRoot = baseUrl.replaceAll(RegExp(r'/api/?$'), '');
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
