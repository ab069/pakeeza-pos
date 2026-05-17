import 'package:flutter/material.dart';
import 'package:pakeeza_pos/core/constants/app_constants.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/data/repositories/auth_repository.dart';
import 'package:pakeeza_pos/features/auth/auth_screen.dart';
import 'package:pakeeza_pos/features/shell/main_shell.dart';
import 'package:pakeeza_pos/providers/auth_provider.dart';
import 'package:pakeeza_pos/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class PakeezaPosApp extends StatelessWidget {
  const PakeezaPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository())..init(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _RootGate(),
      ),
    );
  }
}

class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn) {
      return const AuthScreen();
    }

    return const MainShell();
  }
}
