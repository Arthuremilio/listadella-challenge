import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../../lists/models/list_model.dart';
import '../models/product_model.dart';
import 'package:listadella_desafio/core/providers/token_provider.dart';
import '../widgets/product_dialog.dart';
import '../widgets/category_filter.dart';
import '../widgets/sort_filter.dart';
import 'package:listadella_desafio/core/widgets/error_dialog.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool _dataLoaded = false;
  String? _categoryFilter;
  String _sort = 'pending';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_dataLoaded) {
      final list = ModalRoute.of(context)!.settings.arguments as ListModel;

      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      productProvider.loadProducts(list.products);

      _loadCategories();

      _dataLoaded = true;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final token = await tokenProvider.getValidToken();

      await productProvider.selectProductCategory(token: token);
    } catch (error) {
      if (!mounted) return;

      _showErrorDialog(error.toString());
    }
  }

  List<ProductModel> _applyFilterAndSort(List<ProductModel> products) {
    var list = [...products];

    if (_categoryFilter != null && _categoryFilter != 'all') {
      list = list.where((product) {
        return product.category == _categoryFilter;
      }).toList();
    }

    switch (_sort) {
      case 'name_az':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;

      case 'name_za':
        list.sort((a, b) => b.name.compareTo(a.name));
        break;

      case 'pending':
        list.sort((a, b) => b.check.compareTo(a.check));
        break;

      case 'checked':
        list.sort((a, b) => a.check.compareTo(b.check));
        break;

      case 'none':
      default:
        break;
    }

    return list;
  }

  Future<void> _showNewProductDialog(ListModel list) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final token = await tokenProvider.getValidToken();

      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (ctx) {
          return NewProductDialog(categories: productProvider.categories);
        },
      );

      if (result == null) {
        return;
      }

      await productProvider.addProduct(
        listId: list.id,
        name: result['name']!,
        category: result['category']!,
        token: token,
      );

      list.products.insert(
        0,
        ProductModel(
          name: result['name']!,
          category: result['category']!,
          check: 0,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Produto adicionado com sucesso!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showErrorDialog(error.toString());
    }
  }

  Future<void> _toggleProduct(ListModel list, ProductModel product) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final token = await tokenProvider.getValidToken();

      await productProvider.changeProductStatus(
        listId: list.id,
        product: product,
        token: token,
      );

      final index = list.products.indexWhere(
        (item) =>
            item.name == product.name && item.category == product.category,
      );

      if (index >= 0) {
        final currentProduct = list.products[index];

        list.products[index] = ProductModel(
          name: currentProduct.name,
          category: currentProduct.category,
          check: currentProduct.check == 1 ? 2 : 1,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: product.isChecked
              ? Theme.of(context).colorScheme.primary
              : Color(0xFF1D3607),
          content: Center(
            child: Text(
              product.isChecked
                  ? 'Produto marcado como pendente!'
                  : 'Produto marcado como comprado!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showErrorDialog(error.toString());
    }
  }

  Future<void> _removeProduct(ListModel list, ProductModel product) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final token = await tokenProvider.getValidToken();

      await productProvider.removeProduct(
        listId: list.id,
        product: product,
        token: token,
      );

      list.products.removeWhere(
        (item) =>
            item.name == product.name && item.category == product.category,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Center(
            child: Text(
              'Produto removido com sucesso!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showErrorDialog(error.toString());
    }
  }

  void _showErrorDialog(String message) {
    final cleanMessage = message.replaceFirst('Exception: ', '');
    showDialog(
      context: context,
      builder: (ctx) {
        return ErrorDialog(message: cleanMessage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ModalRoute.of(context)!.settings.arguments as ListModel;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          list.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return Row(
                children: [
                  CategoryFilter(
                    categories: productProvider.categories,
                    selectedCategory: _categoryFilter,
                    onSelectedCategory: (category) {
                      setState(() {
                        _categoryFilter = category;
                      });
                    },
                  ),
                  SortFilter(
                    selectedSort: _sort,
                    onSelectedSort: (sort) {
                      setState(() {
                        _sort = sort;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final products = _applyFilterAndSort(productProvider.products);

          return Column(
            children: [
              Expanded(
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : productProvider.hasError
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            productProvider.error ??
                                'Erro ao carregar produtos.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : products.isEmpty
                    ? const Center(child: Text('Nenhum produto encontrado.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return ProductCard(
                            product: product,
                            onToggleCheck: () => _toggleProduct(list, product),
                            onRemove: () => _removeProduct(list, product),
                          );
                        },
                      ),
              ),
              Container(
                color: Theme.of(context).colorScheme.secondary,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        onPressed: productProvider.isLoading
                            ? null
                            : () => _showNewProductDialog(list),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      Card(
                        color: Theme.of(context).colorScheme.secondary,
                        elevation: 0,
                        child: Text(
                          '${products.length} Produto(s)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
