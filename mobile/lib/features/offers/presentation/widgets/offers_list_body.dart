import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/state_view.dart';
import '../../data/offer.dart';
import '../offer_detail_screen.dart';
import '../offers_provider.dart';
import 'offer_card.dart';

class OffersListBody extends StatelessWidget {
  const OffersListBody({
    super.key,
    required this.provider,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyActionLabel,
    this.onEmptyAction,
  });

  final OffersProvider provider;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  Future<void> _openDetail(BuildContext context, Offer offer) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => OfferDetailScreen(offer: offer, provider: provider),
      ),
    );
  }

  Future<void> _toggleSaved(BuildContext context, Offer offer) async {
    final saved = await provider.toggleSaved(offer);

    if (!context.mounted) {
      return;
    }

    if (saved == null) {
      showAppSnackBar(
        context,
        provider.errorMessage ?? 'No fue posible actualizar la oferta.',
      );
      return;
    }

    showAppSnackBar(
      context,
      saved ? 'Oferta guardada.' : 'Oferta eliminada de guardadas.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (provider.status) {
      OffersStatus.loading => StateView.loading(message: 'Cargando ofertas'),
      OffersStatus.error => StateView.error(
          message:
              provider.errorMessage ?? 'No fue posible cargar las ofertas.',
          onRetry: provider.load,
        ),
      OffersStatus.empty => StateView.empty(
          icon: emptyIcon,
          title: emptyTitle,
          message: emptyMessage,
          actionLabel: emptyActionLabel,
          onAction: onEmptyAction,
        ),
      OffersStatus.success => RefreshIndicator(
          onRefresh: provider.refresh,
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceElevated,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              96,
            ),
            itemCount: provider.offers.length,
            separatorBuilder: (_, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (itemContext, index) {
              final offer = provider.offers[index];

              return OfferCard(
                offer: offer,
                onTap: () => _openDetail(itemContext, offer),
                onToggleSaved: () => _toggleSaved(itemContext, offer),
              );
            },
          ),
        ),
    };
  }
}
