import 'sale_item.dart';
import 'user.dart';

class Sale {
  final int id;
  final String invoiceNo;
  final String buyerName;
  final int cashierId;
  final String paymentMethod;
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double grandTotal;
  final String? bpjsClaimNo;
  final String? notes;
  final String? saleDate;
  final List<SaleItem> saleItems;
  final User? cashier;

  Sale({
    required this.id,
    required this.invoiceNo,
    required this.buyerName,
    required this.cashierId,
    required this.paymentMethod,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.grandTotal,
    this.bpjsClaimNo,
    this.notes,
    this.saleDate,
    this.saleItems = const [],
    this.cashier,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    var itemsList = <SaleItem>[];
    if (json['sale_items'] != null && json['sale_items'] is List) {
      itemsList = (json['sale_items'] as List)
          .map((i) => SaleItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return Sale(
      id: json['id'] as int,
      invoiceNo: json['invoice_no'] as String? ?? '',
      buyerName: json['buyer_name'] as String? ?? 'Umum',
      cashierId: json['cashier_id'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount'].toString()) ?? 0.0,
      grandTotal: double.tryParse(json['grand_total'].toString()) ?? 0.0,
      bpjsClaimNo: json['bpjs_claim_no'] as String?,
      notes: json['notes'] as String?,
      saleDate: json['sale_date'] as String? ?? json['created_at'] as String?,
      saleItems: itemsList,
      cashier: json['cashier'] != null ? User.fromJson(json['cashier']) : null,
    );
  }
}
