import 'package:bolivar_aprende/core/constants/offer_enums.dart';
import 'package:bolivar_aprende/core/theme/app_theme.dart';
import 'package:bolivar_aprende/features/offers/data/offer.dart';
import 'package:bolivar_aprende/features/offers/presentation/widgets/offer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Offer buildOffer({bool isSaved = false}) => Offer(
      id: 'a0000000-0000-4000-8000-000000000001',
      title: 'Operario de producción en planta de alimentos',
      description:
          'Se requiere operario para la línea de empaque de una planta de alimentos.',
      type: OfferType.job,
      institution: 'Agrosur del Bolívar',
      municipality: 'El Carmen de Bolívar',
      modality: OfferModality.onsite,
      isSaved: isSaved,
      createdAt: DateTime(2026, 10, 20),
      updatedAt: DateTime(2026, 10, 20),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_CO');
  });

  testWidgets('muestra título, institución, municipio y tipo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: OfferCard(
            offer: buildOffer(),
            onTap: () {},
            onToggleSaved: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('Operario de producción en planta de alimentos'),
      findsOneWidget,
    );
    expect(find.text('Agrosur del Bolívar'), findsOneWidget);
    expect(find.text('El Carmen de Bolívar'), findsOneWidget);
    expect(find.text('Laboral'), findsOneWidget);
  });

  testWidgets('notifica el guardado al tocar el marcador', (tester) async {
    var toggleCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: OfferCard(
            offer: buildOffer(),
            onTap: () {},
            onToggleSaved: () => toggleCalls += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Guardar oferta'));
    await tester.pump();

    expect(toggleCalls, 1);
  });

  testWidgets('abre el detalle al tocar la tarjeta', (tester) async {
    var tapCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: OfferCard(
            offer: buildOffer(isSaved: true),
            onTap: () => tapCalls += 1,
            onToggleSaved: () {},
          ),
        ),
      ),
    );

    await tester.tap(
      find.text('Operario de producción en planta de alimentos'),
    );
    await tester.pump();

    expect(tapCalls, 1);
    expect(find.byTooltip('Quitar de guardadas'), findsOneWidget);
  });
}
