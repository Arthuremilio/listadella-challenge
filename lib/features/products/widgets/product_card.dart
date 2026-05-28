import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Future<void> Function() onToggleCheck;
  final Future<void> Function() onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.onToggleCheck,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final checked = product.isChecked;

    return Dismissible(
      key: ValueKey('${product.name}-${product.category}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onToggleCheck();
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          await onRemove();
          return false;
        }

        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          checked ? Icons.close : Icons.check,
          color: Colors.white,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: checked
            ? Color(0xFF1D3607)
            : Theme.of(context).colorScheme.primary,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontSize: 22,
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
