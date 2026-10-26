import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/offer_enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../offers_provider.dart';
import 'municipality_picker.dart';

class OffersFilterBar extends StatefulWidget {
  const OffersFilterBar({super.key, required this.provider});

  final OffersProvider provider;

  @override
  State<OffersFilterBar> createState() => _OffersFilterBarState();
}

class _OffersFilterBarState extends State<OffersFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.provider.query.search,
    );
    widget.provider.addListener(_syncSearchField);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_syncSearchField);
    _searchController.dispose();
    super.dispose();
  }

  void _syncSearchField() {
    final query = widget.provider.query.search;

    if (query == _searchController.text) {
      return;
    }

    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  Future<void> _pickMunicipality() async {
    final result = await showMunicipalityPicker(
      context,
      selected: widget.provider.query.municipality,
      allowAll: true,
    );

    if (result == null) {
      return;
    }

    widget.provider.setMunicipality(result.isEmpty ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final query = provider.query;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Buscar por título, institución o descripción',
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar búsqueda',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearch('');
                      setState(() {});
                    },
                  ),
          ),
          onChanged: (value) {
            provider.setSearch(value);
            setState(() {});
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.minTouchTarget,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _FilterChip(
                label: 'Todas',
                selected: query.type == null,
                onSelected: () => provider.setType(null),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Laboral',
                icon: Icons.work_outline,
                selected: query.type == OfferType.job,
                onSelected: () => provider.setType(OfferType.job),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: 'Académica',
                icon: Icons.school_outlined,
                selected: query.type == OfferType.academic,
                onSelected: () => provider.setType(OfferType.academic),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FilterChip(
                label: query.municipality ?? 'Municipio',
                icon: Icons.place_outlined,
                selected: query.municipality != null,
                onSelected: _pickMunicipality,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textSecondary;
    final iconData = icon;

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      avatar: iconData == null ? null : Icon(iconData, size: 16, color: color),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accentSoft,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}
