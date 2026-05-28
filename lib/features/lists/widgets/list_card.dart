import 'package:flutter/material.dart';
import '../models/list_model.dart';
import 'package:listadella_desafio/core/routes/app_routes.dart';

class ListCard extends StatelessWidget {
  final ListModel list;

  const ListCard({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.primary,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.listProducts, arguments: list);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            list.title,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
