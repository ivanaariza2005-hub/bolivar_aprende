import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/offers/data/offers_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_CO');
  Intl.defaultLocale = 'es_CO';

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient();
  final authRepository = AuthRepository(
    client: apiClient,
    tokenStorage: tokenStorage,
  );
  final offersRepository = OffersRepository(client: apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<OffersRepository>.value(value: offersRepository),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final provider = AuthProvider(repository: authRepository);

            apiClient.onUnauthorized = () {
              appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
              provider.handleSessionExpired();
            };

            provider.bootstrap();
            return provider;
          },
        ),
      ],
      child: const BolivarApp(),
    ),
  );
}
