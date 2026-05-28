class CategoryModel {
  final String name;
  final List<String> products;

  CategoryModel({required this.name, required this.products});

  factory CategoryModel.fromEntry(MapEntry<String, dynamic> entry) {
    return CategoryModel(
      name: entry.key,
      products: entry.value is List ? List<String>.from(entry.value) : [],
    );
  }
}
