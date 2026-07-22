import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/medicine.dart';

class CartState {
  final List<CartItem> items;
  final String buyerName;
  final String paymentMethod;
  final double discountAmount;
  final bool isTaxEnabled;
  final String? bpjsClaimNo;
  final String? notes;

  const CartState({
    this.items = const [],
    this.buyerName = 'Umum',
    this.paymentMethod = 'cash',
    this.discountAmount = 0.0,
    this.isTaxEnabled = false,
    this.bpjsClaimNo,
    this.notes,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  double get taxAmount {
    if (!isTaxEnabled) return 0.0;
    final taxable = subtotal - discountAmount;
    if (taxable <= 0) return 0.0;
    return taxable * 0.11; // PPN 11%
  }

  double get grandTotal {
    final total = (subtotal - discountAmount) + taxAmount;
    return total < 0 ? 0.0 : total;
  }

  bool get hasPrescriptionItem {
    return items.any((item) => item.medicine.requiresPrescription);
  }

  bool get arePrescriptionsFilled {
    for (final item in items) {
      if (item.medicine.requiresPrescription) {
        if (item.prescriptionNo == null || item.prescriptionNo!.trim().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  CartState copyWith({
    List<CartItem>? items,
    String? buyerName,
    String? paymentMethod,
    double? discountAmount,
    bool? isTaxEnabled,
    String? bpjsClaimNo,
    String? notes,
  }) {
    return CartState(
      items: items ?? this.items,
      buyerName: buyerName ?? this.buyerName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      isTaxEnabled: isTaxEnabled ?? this.isTaxEnabled,
      bpjsClaimNo: bpjsClaimNo ?? this.bpjsClaimNo,
      notes: notes ?? this.notes,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addToCart(Medicine medicine) {
    if (medicine.stock <= 0) return;

    final index = state.items.indexWhere((item) => item.medicine.id == medicine.id);
    if (index >= 0) {
      final currentItem = state.items[index];
      if (currentItem.quantity < medicine.stock) {
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[index] = currentItem.copyWith(quantity: currentItem.quantity + 1);
        state = state.copyWith(items: updatedItems);
      }
    } else {
      final newItem = CartItem(medicine: medicine, quantity: 1);
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(int medicineId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(medicineId);
      return;
    }

    final index = state.items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      final currentItem = state.items[index];
      final maxStock = currentItem.medicine.stock;
      final newQty = quantity > maxStock ? maxStock : quantity;

      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[index] = currentItem.copyWith(quantity: newQty);
      state = state.copyWith(items: updatedItems);
    }
  }

  void updatePrescriptionNo(int medicineId, String prescriptionNo) {
    final index = state.items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[index] = updatedItems[index].copyWith(prescriptionNo: prescriptionNo);
      state = state.copyWith(items: updatedItems);
    }
  }

  void removeFromCart(int medicineId) {
    final updatedItems = state.items.where((item) => item.medicine.id != medicineId).toList();
    state = state.copyWith(items: updatedItems);
  }

  void setDiscountAmount(double discount) {
    state = state.copyWith(discountAmount: discount < 0 ? 0.0 : discount);
  }

  void toggleTax(bool enable) {
    state = state.copyWith(isTaxEnabled: enable);
  }

  void setBuyerName(String name) {
    state = state.copyWith(buyerName: name.isEmpty ? 'Umum' : name);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setBpjsClaimNo(String? claimNo) {
    state = state.copyWith(bpjsClaimNo: claimNo);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  void resetCart() {
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
