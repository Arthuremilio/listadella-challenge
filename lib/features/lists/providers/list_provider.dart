import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/list_model.dart';
import 'dart:convert';

class ListsProvider with ChangeNotifier {
  final List<ListModel> _lists = [];

  bool _isLoading = false;
  String? _error;
  List<ListModel> get lists => [..._lists];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _lists.isEmpty && !_isLoading;

  Future<void> getLists({required int userId, required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final url = Uri.parse(
      'https://listadella.azurewebsites.net/apiListadella_desafio/Listasusuario?Usuarioid=$userId',
    );

    try {
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
        final errorMessage =
            body['Messages']?[0]?['Description'] ??
            body['Description'] ??
            'Erro desconhecido';
        throw Exception(errorMessage);
      }

      final lists = body['sdtListasUsuario'] as List<dynamic>? ?? [];
      _lists.clear();
      _lists.addAll(lists.map((item) => ListModel.fromJson(item)).toList());
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ListModel? getListById(int id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addList({
    required int userId,
    required String title,
    required String token,
  }) async {
    final url = Uri.parse(
      'https://listadella.azurewebsites.net/apiListadella_desafio/NovaLista',
    );

    final requestBody = {
      'sdtNovaLista': {'UsuarioId': userId, 'ListaNome': title},
    };

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      final responseBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode != 200) {
        final errorMessage =
            responseBody['Messages']?[0]?['Description'] ??
            responseBody['Description'] ??
            'Erro desconhecido';
        throw Exception(errorMessage);
      }

      final messages = responseBody['Messages'];

      if (messages is List && messages.isNotEmpty) {
        final firstMessage = messages.first;

        if (firstMessage is Map && firstMessage['Id'] == 'Error') {
          throw Exception(
            firstMessage['Description'] ?? 'Erro ao criar lista.',
          );
        }
      }

      await getLists(userId: userId, token: token);
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
