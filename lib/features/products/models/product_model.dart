class ProductModel {
  final String name;
  final String category;
  final int check;

  ProductModel({
    required this.name,
    required this.category,
    required this.check,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['nome']?.toString() ?? '',
      category: json['categoria']?.toString() ?? '',
      check: int.tryParse(json['check']?.toString() ?? '') ?? 0,
    );
  }

  bool get isChecked => check == 1;

  ProductModel copyWith({String? name, String? category, int? check}) {
    return ProductModel(
      name: name ?? this.name,
      category: category ?? this.category,
      check: check ?? this.check,
    );
  }
}
