import 'medicine.dart';

class CartItem {
  final Medicine medicine;
  int quantity;
  double discount;
  String? prescriptionNo;

  CartItem({
    required this.medicine,
    this.quantity = 1,
    this.discount = 0.0,
    this.prescriptionNo,
  });

  double get unitPrice => medicine.price;
  double get subtotal => (unitPrice * quantity) - discount;

  Map<String, dynamic> toApiJson() {
    return {
      'medicine_id': medicine.id,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount': discount,
      'prescription_no': prescriptionNo,
    };
  }

  CartItem copyWith({
    Medicine? medicine,
    int? quantity,
    double? discount,
    String? prescriptionNo,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      prescriptionNo: prescriptionNo ?? this.prescriptionNo,
    );
  }
}
