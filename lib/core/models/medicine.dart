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
    Category? cat;
    if (json['category'] != null) {
      cat = Category.fromJson(json['category']);
    } else if (json['category_name'] != null) {
      cat = Category(
        id: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
        name: json['category_name'].toString(),
      );
    }

    return Medicine(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      genericName: json['generic_name']?.toString(),
      categoryId: int.tryParse(json['category_id']?.toString() ?? ''),
      manufacturer: json['manufacturer']?.toString(),
      unit: json['unit']?.toString() ?? 'tablet',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      minStock: int.tryParse(json['min_stock']?.toString() ?? '10') ?? 10,
      expiryDate: json['expiry_date']?.toString(),
      requiresPrescription: json['requires_prescription'] == true ||
          json['requires_prescription'] == 1 ||
          json['requires_prescription'] == '1' ||
          json['requires_prescription'] == 'true',
      description: json['description']?.toString(),
      category: cat,
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
