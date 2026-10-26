import 'package:bolivar_aprende/core/theme/app_theme.dart';
import 'package:bolivar_aprende/core/widgets/state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el estado vacío muestra título, mensaje y acción', (
    tester,
  ) async {
    var actionCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: StateView.empty(
            title: 'No hay ofertas con estos filtros',
            message: 'Prueba con otro término de búsqueda.',
            actionLabel: 'Limpiar filtros',
            onAction: () => actionCalls += 1,
          ),
        ),
      ),
    );

    expect(find.text('No hay ofertas con estos filtros'), findsOneWidget);
    expect(find.text('Prueba con otro término de búsqueda.'), findsOneWidget);

    await tester.tap(find.text('Limpiar filtros'));
    await tester.pump();

    expect(actionCalls, 1);
  });

  testWidgets('el estado de error permite reintentar', (tester) async {
    var retryCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: StateView.error(
            message: 'Sin conexión. Revisa tu red e intenta de nuevo.',
            onRetry: () => retryCalls += 1,
          ),
        ),
      ),
    );

    expect(find.text('No fue posible cargar la información'), findsOneWidget);
    expect(
      find.text('Sin conexión. Revisa tu red e intenta de nuevo.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(retryCalls, 1);
  });

  testWidgets('el estado de carga muestra un indicador', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: StateView.loading(message: 'Cargando ofertas')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando ofertas'), findsOneWidget);
  });
}
