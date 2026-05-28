import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:listadella_desafio/core/routes/app_routes.dart';
import 'package:listadella_desafio/features/auth/providers/auth.dart';
import 'package:listadella_desafio/core/providers/user_provider.dart';
import 'package:listadella_desafio/core/widgets/error_dialog.dart';

enum AuthMode { signup, login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.login;
  bool _isLogin() => _authMode == AuthMode.login;
  bool _isSignup() => _authMode == AuthMode.signup;

  final Map<String, String> _authData = {
    'name': '',
    'phone': '',
    'email': '',
    'password': '',
  };

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.signup;
      } else {
        _authMode = AuthMode.login;
      }
    });
  }

  void _showErrorDialog(String message) {
    final cleanMessage = message.replaceFirst('Exception: ', '');
    showDialog(
      context: context,
      builder: (ctx) => ErrorDialog(message: cleanMessage),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      if (_isLogin()) {
        await auth.login(_authData['email']!, _authData['password']!, (userId) {
          userProvider.setUserId(userId);
        });
      } else {
        await auth.signup(
          _authData['email']!,
          _authData['password']!,
          _authData['name']!,
          _authData['phone']!,
          (userId) {
            userProvider.setUserId(userId);
          },
        );
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.lists);
      return;
    } on Exception catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      debugPrint(error.toString());
      _showErrorDialog('Ocorreu um erro inesperado!');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.secondary,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: deviceSize.width * 0.80,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isSignup()) ...[
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('name_field'),
                  decoration: InputDecoration(
                    hintText: 'Nome',
                    labelText: 'Nome',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black54),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onSaved: (name) => _authData['name'] = name ?? '',
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('phone_field'),
                  decoration: InputDecoration(
                    hintText: 'Telefone',
                    labelText: 'Telefone',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black54),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onSaved: (phone) => _authData['phone'] = phone ?? '',
                ),
              ],
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('email_field'),
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  labelText: 'E-mail',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  hintStyle: const TextStyle(color: Colors.black54),
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (email) {
                  final _email = email ?? '';
                  if (_email.trim().isEmpty || !_email.contains('@')) {
                    return 'Informe um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('password_field'),
                decoration: InputDecoration(
                  hintText: 'Senha',
                  labelText: 'Senha',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  hintStyle: const TextStyle(color: Colors.black54),
                  labelStyle: const TextStyle(color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (password) {
                  final _password = password ?? '';
                  if (_password.isEmpty || _password.length < 5) {
                    return 'Informe uma senha válida';
                  }
                  return null;
                },
              ),
              if (_isSignup()) ...[
                const SizedBox(height: 8),
                TextFormField(
                  key: const ValueKey('confirm_password_field'),
                  decoration: InputDecoration(
                    hintText: 'Confirmar Senha',
                    labelText: 'Confirmar Senha',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black54),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _passwordController.text) {
                      return 'Senhas não conferem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: deviceSize.width * 0.80,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      _authMode == AuthMode.login ? 'Entrar' : 'Registrar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).textTheme.labelLarge!.color,
                ),
                child: Text(
                  _isLogin() ? 'Deseja se registrar?' : 'Já possui uma conta?',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
