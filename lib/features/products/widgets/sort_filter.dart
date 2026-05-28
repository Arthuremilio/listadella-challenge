import 'package:flutter/material.dart';

class SortFilter extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSelectedSort;

  const SortFilter({
    super.key,
    required this.selectedSort,
    required this.onSelectedSort,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    PopupMenuItem<String> sortItem({
      required String value,
      required String title,
      required IconData icon,
    }) {
      final selected = selectedSort == value;

      return PopupMenuItem<String>(
        value: value,
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                if (selected)
                  Icon(Icons.check, color: colorScheme.primary, size: 20),
              ],
            ),
            Divider(
              color: selected ? colorScheme.primary : colorScheme.secondary,
            ),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort, color: Colors.white),
      color: colorScheme.surface,
      tooltip: 'Ordenar produtos',
      position: PopupMenuPosition.under,
      onSelected: (sort) {
        onSelectedSort(sort);
      },
      itemBuilder: (context) {
        return [
          sortItem(
            value: 'pending',
            title: 'Pendentes primeiro',
            icon: Icons.radio_button_unchecked,
          ),
          sortItem(
            value: 'checked',
            title: 'Comprados primeiro',
            icon: Icons.check_circle_outline,
          ),
          sortItem(
            value: 'name_az',
            title: 'Nome A-Z',
            icon: Icons.arrow_downward,
          ),
          sortItem(
            value: 'name_za',
            title: 'Nome Z-A',
            icon: Icons.arrow_upward,
          ),
          sortItem(
            value: 'none',
            title: 'Remover ordenação',
            icon: Icons.clear,
          ),
        ];
      },
    );
  }
}
