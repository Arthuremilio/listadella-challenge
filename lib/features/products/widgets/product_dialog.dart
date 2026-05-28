import 'package:flutter/material.dart';
import '../models/category_model.dart';

class NewProductDialog extends StatefulWidget {
  final List<CategoryModel> categories;

  const NewProductDialog({super.key, required this.categories});

  @override
  State<NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<NewProductDialog> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  String? _selectedCategory;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _addProduct() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Informe o nome do produto.';
      });
      _nameFocusNode.requestFocus();
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _errorMessage = 'Selecione uma categoria.';
      });
      _categoryFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop({'name': name, 'category': _selectedCategory!});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.secondary,
      title: const Text(
        'Adicionar produto',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            style: const TextStyle(color: Color(0xFF263238)),
            decoration: InputDecoration(
              labelText: 'Nome do produto',
              hintText: 'Ex: arroz',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: colorScheme.surface,
              hintStyle: const TextStyle(color: Colors.black54),
              labelStyle: const TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            focusNode: _categoryFocusNode,
            dropdownColor: colorScheme.surface,
            style: const TextStyle(color: Color(0xFF263238), fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Categoria',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: colorScheme.surface,
              hintStyle: const TextStyle(color: Colors.black54),
              labelStyle: const TextStyle(color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.secondary, width: 2),
              ),
            ),
            items: widget.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.name,
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _errorMessage = null;
              });
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _addProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
