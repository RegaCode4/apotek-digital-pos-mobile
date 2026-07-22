import 'category.dart';

class Medicine {
  final int id;
  final String name;
  final String? genericName;
  final int? categoryId;
  final String? manufacturer;
  final String unit;
  final double price;
  final int stock;
  final int minStock;
  final String? expiryDate;
  final bool requiresPrescription;
  final String? description;
  final Category? category;

  Medicine({
    required this.id,
    required this.name,
    this.genericName,
    this.categoryId,
    this.manufacturer,
    required this.unit,
    required this.price,
    required this.stock,
    required this.minStock,
    this.expiryDate,
    required this.requiresPrescription,
    this.description,
    this.category,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      genericName: json['generic_name'] as String?,
      categoryId: json['category_id'] as int?,
      manufacturer: json['manufacturer'] as String?,
      unit: json['unit'] as String? ?? 'tablet',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      minStock: int.tryParse(json['min_stock'].toString()) ?? 10,
      expiryDate: json['expiry_date'] as String?,
      requiresPrescription: json['requires_prescription'] == true ||
          json['requires_prescription'] == 1 ||
          json['requires_prescription'] == '1',
      description: json['description'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'category_id': categoryId,
      'manufacturer': manufacturer,
      'unit': unit,
      'price': price,
      'stock': stock,
      'min_stock': minStock,
      'expiry_date': expiryDate,
      'requires_prescription': requiresPrescription,
      'description': description,
      'category': category?.toJson(),
    };
  }

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= minStock;
}
