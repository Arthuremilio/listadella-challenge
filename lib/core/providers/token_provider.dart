import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TokenProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;

  static const String _tokenUrl =
      'https://listadella.azurewebsites.net/oauth/access_token';

  String? get token => _token;

  bool get hasValidToken {
    if (_token == null || _expiryDate == null) {
      return false;
    }

    // margem de segurança: considera expirado 1 minuto antes
    return _expiryDate!.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }

  Future<String> getValidToken() async {
    debugPrint(
      'Verificando token: ${_token ?? "null"}, expira em: ${_expiryDate ?? "null"}',
    );
    if (hasValidToken) {
      return _token!;
    }

    await getToken();

    if (_token == null) {
      throw Exception('Não foi possível obter o token da API.');
    }

    return _token!;
  }

  Future<void> getToken() async {
    final response = await http
        .post(
          Uri.parse(_tokenUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'client_id': '',
            'grant_type': '',
            'scope': '',
            'username': '',
            'password': '',
          },
        )
        .timeout(const Duration(seconds: 20));

    final body = jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body['error_description'] ??
            body['Description'] ??
            'Erro ao obter token da API.',
      );
    }

    final accessToken = body['access_token'];
    debugPrint('Token recebido: $accessToken');

    if (accessToken == null) {
      throw Exception('Token não encontrado na resposta da API.');
    }

    _token = accessToken.toString();

    final expiresIn = int.tryParse(body['expires_in'].toString()) ?? 3600;

    _expiryDate = DateTime.now().add(Duration(seconds: expiresIn));

    notifyListeners();
  }

  void clearToken() {
    _token = null;
    _expiryDate = null;
    notifyListeners();
  }
}
