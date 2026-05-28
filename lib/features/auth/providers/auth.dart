import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:listadella_desafio/core/providers/token_provider.dart';

class Auth with ChangeNotifier {
  String? _email;
  int? _id;
  DateTime? _expiryDate;

  TokenProvider? _tokenProvider;

  static const String _baseUrl =
      'https://listadella.azurewebsites.net/apiListadella_desafio';

  void updateTokenProvider(TokenProvider tokenProvider) {
    _tokenProvider = tokenProvider;
  }

  bool get isAuth {
    final isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return _id != null && isValid;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  int? get id {
    return isAuth ? _id : null;
  }

  Future<Map<String, dynamic>> _authenticate(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    if (_tokenProvider == null) {
      throw Exception('TokenProvider não inicializado.');
    }
    final token = await _tokenProvider!.getValidToken();

    final response = await http
        .post(
          Uri.parse('$_baseUrl/$endpoint'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw Exception('Tempo limite excedido na requisição.');
          },
        );
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : <String, dynamic>{};
    if (response.statusCode != 200) {
      final errorMessage =
          responseBody['Messages']?['Description'] ?? 'Erro desconhecido';
      throw Exception(errorMessage);
    }
    final messages = responseBody['Messages'];

    if (messages is Map && messages['Id'] == 'Error') {
      throw Exception(messages['Description'] ?? 'Erro retornado pela API.');
    }

    return responseBody;
  }

  Future<void> signup(
    String email,
    String password,
    String name,
    String phone,
    Function(int) onUserIdReceived,
  ) async {
    final body = {
      'sdtUsuarios': {
        'UsuarioNome': name,
        'UsuarioEmail': email,
        'UsuarioSenha': password,
        'UsuarioTelefone': phone,
      },
    };

    final responseBody = await _authenticate('InsertUsuario', body);
    final userId = responseBody['UsuarioId'] ?? 0;

    if (userId == null || userId == 0) {
      throw Exception('ID do usuário não encontrado na resposta da API.');
    }
    _id = userId;

    onUserIdReceived(_id!);
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password,
    Function(int) onUserIdReceived,
  ) async {
    final body = {
      'sdtUsuarios': {'UsuarioEmail': email, 'UsuarioSenha': password},
    };

    final responseBody = await _authenticate('LogInUsuario', body);

    final usuario = responseBody['sdtUsuarios'] ?? responseBody;

    final userId = usuario['UsuarioId'] ?? 0;

    if (userId == null || userId == 0) {
      throw Exception('E-mail ou senha inválidos.');
    }

    _email = usuario['UsuarioEmail']?.toString() ?? email;
    _id = userId;
    _expiryDate = DateTime.now().add(const Duration(days: 7));

    onUserIdReceived(_id!);
    notifyListeners();
  }

  void logout() {
    _email = null;
    _id = null;
    _expiryDate = null;

    notifyListeners();
  }
}
