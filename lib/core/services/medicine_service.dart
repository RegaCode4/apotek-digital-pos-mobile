import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/medicine.dart';

class MedicineService {
  final ApiClient _apiClient;

  MedicineService(this._apiClient);

  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.searchMedicines,
        queryParameters: {'q': query},
      );

      final data = response.data;
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => Medicine.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }

  Future<Medicine> getMedicineDetail(int id) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.medicineDetail(id),
      );

      final data = response.data;
      if (data['success'] == true) {
        return Medicine.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil detail obat.');
      }
    } catch (e) {
      throw Exception(ApiClient.extractErrorMessage(e));
    }
  }
}
