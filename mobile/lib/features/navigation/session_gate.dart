import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/auth_provider.dart';
import '../auth/presentation/login_screen.dart';
import '../offers/data/offers_repository.dart';
import '../offers/presentation/home_screen.dart';
import '../offers/presentation/offers_provider.dart';
import 'splash_screen.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return switch (auth.status) {
      AuthStatus.unknown => const SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => ChangeNotifierProvider<OffersProvider>(
          create: (providerContext) => OffersProvider(
              repository: providerContext.read<OffersRepository>())
            ..load(),
          child: const HomeScreen(),
        ),
    };
  }
}
