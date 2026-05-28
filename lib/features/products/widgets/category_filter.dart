import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategory;
  final Function(String?) onSelectedCategory;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_alt, color: Colors.white),
      color: colorScheme.surface,
      tooltip: 'Filtrar categorias',
      position: PopupMenuPosition.under,
      onSelected: (category) {
        onSelectedCategory(category);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: 'all',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Todas as categorias',
                      style: TextStyle(color: Colors.black),
                    ),
                    if (selectedCategory == null || selectedCategory == 'all')
                      Icon(Icons.check, color: colorScheme.primary, size: 20),
                  ],
                ),
                Divider(
                  color: selectedCategory == null || selectedCategory == 'all'
                      ? colorScheme.primary
                      : colorScheme.secondary,
                ),
              ],
            ),
          ),
          ...categories.map((category) {
            final selected = selectedCategory == category.name;

            return PopupMenuItem<String>(
              value: category.name,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (selected)
                        Icon(Icons.check, color: colorScheme.primary, size: 20),
                    ],
                  ),
                  Divider(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                ],
              ),
            );
          }),
        ];
      },
    );
  }
}
