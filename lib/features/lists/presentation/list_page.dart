import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/list_card.dart';
import '../providers/list_provider.dart';
import 'package:listadella_desafio/core/providers/user_provider.dart';
import 'package:listadella_desafio/core/providers/token_provider.dart';
import '../widgets/list_dialog.dart';
import 'package:listadella_desafio/features/auth/providers/auth.dart';
import 'package:listadella_desafio/core/routes/app_routes.dart';
import 'package:listadella_desafio/core/widgets/error_dialog.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLists();
    });
  }

  Future<void> _loadLists() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);

      final userId = userProvider.userId;

      if (userId == null) {
        return;
      }

      final token = await tokenProvider.getValidToken();

      await Provider.of<ListsProvider>(
        context,
        listen: false,
      ).getLists(userId: userId, token: token);
    } catch (error) {
      if (!mounted) return;

      _showErrorDialog(error.toString());
    }
  }

  Future<void> _showNewListDialog() async {
    try {
      final title = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return const NewListDialog();
        },
      );

      if (title == null || title.isEmpty) {
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final listsProvider = Provider.of<ListsProvider>(context, listen: false);

      final userId = userProvider.userId;

      if (userId == null) {
        _showErrorDialog('Usuário não encontrado.');
        return;
      }

      final token = await tokenProvider.getValidToken();

      await listsProvider.addList(userId: userId, title: title, token: token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Lista criada com sucesso!',
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Minhas listas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: () {
              try {
                Provider.of<Auth>(context, listen: false).logout();
                Provider.of<UserProvider>(context, listen: false).clearUser();

                Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
              } catch (error) {
                _showErrorDialog(error.toString());
              }
            },
          ),
        ],
      ),
      body: Consumer<ListsProvider>(
        builder: (context, listsProvider, child) {
          final lists = listsProvider.lists;

          return Column(
            children: [
              Expanded(
                child: listsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : listsProvider.hasError
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            listsProvider.error ?? 'Erro ao carregar listas.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : listsProvider.isEmpty
                    ? const Center(child: Text('Nenhuma lista encontrada.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          final list = lists[index];

                          return ListCard(list: list);
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
                        onPressed: listsProvider.isLoading
                            ? null
                            : () => _showNewListDialog(),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.add, color: Colors.white),
                      ),

                      Card(
                        color: Theme.of(context).colorScheme.secondary,
                        child: Text(
                          '${lists.length} Lista(s)',
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
