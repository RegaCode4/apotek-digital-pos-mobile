import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/medicine.dart';
import '../../../core/providers/core_providers.dart';

class MedicineSearchState {
  final bool isLoading;
  final String query;
  final List<Medicine> medicines;
  final String? errorMessage;

  const MedicineSearchState({
    this.isLoading = false,
    this.query = '',
    this.medicines = const [],
    this.errorMessage,
  });

  MedicineSearchState copyWith({
    bool? isLoading,
    String? query,
    List<Medicine>? medicines,
    String? errorMessage,
  }) {
    return MedicineSearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      medicines: medicines ?? this.medicines,
      errorMessage: errorMessage,
    );
  }
}

class MedicineSearchNotifier extends StateNotifier<MedicineSearchState> {
  final Ref ref;

  MedicineSearchNotifier(this.ref) : super(const MedicineSearchState()) {
    searchMedicines('');
  }

  Future<void> searchMedicines(String query) async {
    state = state.copyWith(isLoading: true, query: query, errorMessage: null);
    try {
      final medicineService = ref.read(medicineServiceProvider);
      final list = await medicineService.searchMedicines(query);
      state = state.copyWith(
        isLoading: false,
        medicines: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void refresh() {
    searchMedicines(state.query);
  }
}

final medicineSearchProvider =
    StateNotifierProvider<MedicineSearchNotifier, MedicineSearchState>((ref) {
  return MedicineSearchNotifier(ref);
});
