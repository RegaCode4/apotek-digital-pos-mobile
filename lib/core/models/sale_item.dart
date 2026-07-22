import 'medicine.dart';

class SaleItem {
  final int id;
  final int saleId;
  final int medicineId;
  final String? prescriptionNo;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double subtotal;
  final Medicine? medicine;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.medicineId,
    this.prescriptionNo,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.subtotal,
    this.medicine,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] as int? ?? 0,
      saleId: json['sale_id'] as int? ?? 0,
      medicineId: json['medicine_id'] as int? ?? 0,
      prescriptionNo: json['prescription_no'] as String?,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0.0,
      discount: double.tryParse(json['discount'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      medicine: json['medicine'] != null ? Medicine.fromJson(json['medicine']) : null,
    );
  }
}
