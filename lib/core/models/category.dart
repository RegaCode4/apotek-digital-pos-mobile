class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(dynamic json) {
    if (json == null) {
      return Category(id: 0, name: '');
    }
    if (json is String) {
      return Category(id: 0, name: json);
    }
    if (json is Map) {
      return Category(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
      );
    }
    return Category(id: 0, name: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
