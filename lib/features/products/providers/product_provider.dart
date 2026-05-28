import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductProvider with ChangeNotifier {
  final List<ProductModel> _products = [];

  bool _isLoading = false;
  String? _error;

  final List<CategoryModel> _categories = [];

  static const String _baseUrl =
      'https://listadella.azurewebsites.net/apiListadella_desafio';

  List<ProductModel> get products => [..._products];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _products.isEmpty && !isLoading;

  List<CategoryModel> get categories => [..._categories];

  bool get categoriesLoaded => _categories.isNotEmpty;

  void loadProducts(List<ProductModel> products) {
    _products.clear();
    _products.addAll(products);
    notifyListeners();
  }

  Future<void> selectProductCategory({required String token}) async {
    if (_categories.isNotEmpty) {
      return;
    }

    final url = Uri.parse('$_baseUrl/SelecionarCategoriaProdutos');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar categorias.');
    }

    final categories = body['ValorProdutoCategoria']?.toString();
    if (categories == null || categories.isEmpty) {
      throw Exception('Categorias não encontradas.');
    }
    final decoded = jsonDecode(categories) as Map<String, dynamic>;

    _categories.clear();

    _categories.addAll(
      decoded.entries.map((entry) {
        return CategoryModel.fromEntry(entry);
      }).toList(),
    );
    notifyListeners();
  }

  int getCategoryId(String category) {
    final categoryIds = {
      'Açougue': 1,
      'Bebidas': 2,
      'Congelados': 3,
      'Frios e Laticínios': 4,
      'Higiene': 5,
      'Hortifruti': 6,
      'Limpeza': 7,
      'Matinais': 8,
      'Mercearia': 9,
      'Padaria': 10,
      'Pet Shop': 11,
      'Utilidades Domésticas': 12,
    };
    return categoryIds[category] ?? 0;
  }

  Future<void> addProduct({
    required int listId,
    required String name,
    required String category,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/AdicionaProdutoLista');

    final categoryId = getCategoryId(category);

    final body = {
      'sdtNovoProdutoLista': {
        'UsuarioListaId': listId,
        'UsuarioListaProdutosNome': name,
        'CategoriaProdutoId': categoryId,
      },
    };

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar produto.');
    }

    final messages = responseBody['Messages'];

    if (messages is List && messages.isNotEmpty) {
      final first = messages.first;

      if (first is Map && first['Id'] == 'Error') {
        throw Exception(first['Description'] ?? 'Erro ao adicionar produto.');
      }
    }

    _products.insert(0, ProductModel(name: name, category: category, check: 0));

    notifyListeners();
  }

  Future<void> changeProductStatus({
    required int listId,
    required ProductModel product,
    required String token,
  }) async {
    final newCheck = product.isChecked ? 2 : 1;

    final url = Uri.parse('$_baseUrl/AlterarEstadoProduto');

    final body = {
      'sdtReceberEstadoProdutoLista': {
        'UsuarioListaId': listId,
        'UsuarioListaProdutosNome': product.name,
        'UsuarioListaProdutoCheck': newCheck,
      },
    };

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Erro ao alterar estado do produto.');
    }

    final index = _products.indexWhere(
      (item) => item.name == product.name && item.category == product.category,
    );

    if (index >= 0) {
      _products[index] = _products[index].copyWith(check: newCheck);
      notifyListeners();
    }
  }

  Future<void> removeProduct({
    required int listId,
    required ProductModel product,
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/RemoveProdutoLista');

    final body = {
      'UsuarioListaId': listId,
      'UsuarioListaProdutosNome': product.name,
    };

    final response = await http
        .post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover produto.');
    }

    _products.removeWhere(
      (item) => item.name == product.name && item.category == product.category,
    );

    notifyListeners();
  }

  void clear() {
    _products.clear();
    notifyListeners();
  }
}
