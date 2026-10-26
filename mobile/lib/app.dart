import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/session_gate.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class BolivarApp extends StatelessWidget {
  const BolivarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolívar Aprende y Trabaja',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: buildAppTheme(),
      home: const SessionGate(),
    );
  }
}
