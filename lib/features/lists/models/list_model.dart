import '../../products/models/product_model.dart';

class ListModel {
  final int id;
  final int listType;
  final String title;
  final int current;
  final int total;
  List<ProductModel> products;

  ListModel({
    required this.id,
    required this.listType,
    required this.title,
    required this.current,
    required this.total,
    required this.products,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: int.tryParse(json['ListaId'].toString()) ?? 0,
      listType: json['TipoLista'] ?? 0,
      title: json['Titulo'] ?? '',
      current: json['atual'] ?? 0,
      total: json['total'] ?? 0,
      products: (json['produto'] as List<dynamic>? ?? [])
          .map((item) => ProductModel.fromJson(item))
          .toList(),
    );
  }
}
