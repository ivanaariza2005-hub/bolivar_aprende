import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../navigation/app_drawer.dart';
import '../data/offer.dart';
import 'offer_detail_screen.dart';
import 'offer_form_screen.dart';
import 'offers_provider.dart';
import 'widgets/offers_filter_bar.dart';
import 'widgets/offers_list_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openCreateForm(
    BuildContext context,
    OffersProvider provider,
  ) async {
    final created = await Navigator.of(context).push<Offer>(
      MaterialPageRoute<Offer>(
        builder: (_) => OfferFormScreen(provider: provider),
      ),
    );

    if (created == null || !context.mounted) {
      return;
    }

    showAppSnackBar(context, 'Oferta publicada.');
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OfferDetailScreen(offer: created, provider: provider),
      ),
    );
  }

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
        title: const Text('Ofertas'),
      ),
      drawer: const AppDrawer(section: DrawerSection.home),
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
                emptyIcon: Icons.search_off,
                emptyTitle: 'No hay ofertas con estos filtros',
                emptyMessage:
                    'Prueba con otro término de búsqueda o cambia el tipo y el municipio.',
                emptyActionLabel: 'Limpiar filtros',
                onEmptyAction: provider.clearFilters,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateForm(context, provider),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text('Publicar oferta'),
      ),
    );
  }
}
