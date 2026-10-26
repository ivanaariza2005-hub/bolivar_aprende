import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../navigation/app_drawer.dart';
import '../data/offer_query.dart';
import '../data/offers_repository.dart';
import 'offers_provider.dart';
import 'widgets/offers_filter_bar.dart';
import 'widgets/offers_list_body.dart';

class SavedOffersScreen extends StatelessWidget {
  const SavedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OffersProvider>(
      create: (providerContext) => OffersProvider(
        repository: providerContext.read<OffersRepository>(),
        initialQuery: const OfferQuery(savedOnly: true),
      )..load(),
      child: const _SavedOffersView(),
    );
  }
}

class _SavedOffersView extends StatelessWidget {
  const _SavedOffersView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OffersProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (headerContext) => IconButton(
            tooltip: 'Abrir menú',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(headerContext).openDrawer(),
          ),
        ),
        title: const Text('Mis ofertas guardadas'),
      ),
      drawer: const AppDrawer(section: DrawerSection.saved),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.md,
              ),
              child: OffersFilterBar(provider: provider),
            ),
            Expanded(
              child: OffersListBody(
                provider: provider,
                emptyIcon: Icons.bookmark_border,
                emptyTitle: 'Aún no has guardado ofertas',
                emptyMessage:
                    'Usa el ícono de marcador en cualquier oferta para encontrarla aquí después.',
                emptyActionLabel: 'Explorar ofertas',
                onEmptyAction: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
