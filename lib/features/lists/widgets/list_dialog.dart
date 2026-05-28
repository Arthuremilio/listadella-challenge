import 'package:flutter/material.dart';

class NewListDialog extends StatefulWidget {
  const NewListDialog({super.key});

  @override
  State<NewListDialog> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _create() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Informe o nome da lista.';
      });

      _titleFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(title);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.secondary,
      title: const Text(
        'Nova lista',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            style: const TextStyle(color: Color(0xFF263238)),
            decoration: InputDecoration(
              labelText: 'Nome da lista',
              hintText: 'Ex: Compras do mês',
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
          onPressed: _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Criar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
