import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/token_provider.dart';
import 'features/auth/providers/auth.dart';
import 'features/auth/presentation/auth_page.dart';
import 'features/lists/providers/list_provider.dart';
import 'features/lists/presentation/list_page.dart';
import 'features/products/presentation/product_page.dart';
import 'features/products/providers/product_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TokenProvider()),
        ChangeNotifierProxyProvider<TokenProvider, Auth>(
          create: (_) => Auth(),
          update: (_, tokenProvider, auth) {
            final authInstance = auth ?? Auth();
            authInstance.updateTokenProvider(tokenProvider);
            return authInstance;
          },
        ),
        ChangeNotifierProvider(create: (_) => ListsProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Listadella',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            brightness: Brightness.light,
            primary: Color(0xffC02D23),
            secondary: Color(0xFF17171A),
            surface: Color(0xFFF7F8FA),
            error: Color(0xFFC62828),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
            bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
            bodySmall: TextStyle(color: Colors.white, fontSize: 14),
            labelLarge: TextStyle(color: Colors.white, fontSize: 18),
          ),
          scaffoldBackgroundColor: Color(0xFF0C0C0D),
        ),
        initialRoute: AppRoutes.auth,
        routes: {
          AppRoutes.auth: (ctx) => const AuthPage(),
          AppRoutes.lists: (ctx) => const ListsPage(),
          AppRoutes.listProducts: (ctx) => const ProductPage(),
        },
      ),
    );
  }
}
