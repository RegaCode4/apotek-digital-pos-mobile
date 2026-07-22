import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/sale.dart';
import '../../../core/providers/core_providers.dart';
import '../../pos/providers/cart_provider.dart';

class TransactionState {
  final bool isProcessing;
  final bool isLoadingHistory;
  final List<Sale> history;
  final String periodFilter;
  final String? errorMessage;
  final Sale? lastCreatedSale;

  const TransactionState({
    this.isProcessing = false,
    this.isLoadingHistory = false,
    this.history = const [],
    this.periodFilter = 'today',
    this.errorMessage,
    this.lastCreatedSale,
  });

  TransactionState copyWith({
    bool? isProcessing,
    bool? isLoadingHistory,
    List<Sale>? history,
    String? periodFilter,
    String? errorMessage,
    Sale? lastCreatedSale,
  }) {
    return TransactionState(
      isProcessing: isProcessing ?? this.isProcessing,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      history: history ?? this.history,
      periodFilter: periodFilter ?? this.periodFilter,
      errorMessage: errorMessage,
      lastCreatedSale: lastCreatedSale ?? this.lastCreatedSale,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(const TransactionState());

  Future<Sale?> submitTransaction() async {
    final cartState = ref.read(cartProvider);

    if (cartState.items.isEmpty) {
      state = state.copyWith(errorMessage: 'Keranjang belanja masih kosong.');
      return null;
    }

    if (!cartState.arePrescriptionsFilled) {
      state = state.copyWith(
        errorMessage: 'Ada obat resep yang belum diisi nomor resepnya.',
      );
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final sale = await transactionService.createTransaction(
        buyerName: cartState.buyerName,
        paymentMethod: cartState.paymentMethod,
        subtotal: cartState.subtotal,
        discountAmount: cartState.discountAmount,
        taxAmount: cartState.taxAmount,
        grandTotal: cartState.grandTotal,
        bpjsClaimNo: cartState.bpjsClaimNo,
        notes: cartState.notes,
        items: cartState.items,
      );

      state = state.copyWith(
        isProcessing: false,
        lastCreatedSale: sale,
      );

      // Clear cart on successful checkout
      ref.read(cartProvider.notifier).resetCart();
      return sale;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> fetchHistory({String? period}) async {
    final filter = period ?? state.periodFilter;
    state = state.copyWith(
      isLoadingHistory: true,
      periodFilter: filter,
      errorMessage: null,
    );

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final list = await transactionService.getTransactionHistory(period: filter);
      state = state.copyWith(
        isLoadingHistory: false,
        history: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  return TransactionNotifier(ref);
});
