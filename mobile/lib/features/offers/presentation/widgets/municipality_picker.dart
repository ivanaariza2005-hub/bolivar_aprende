import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/municipalities.dart';
import '../../../../core/theme/app_colors.dart';

Future<String?> showMunicipalityPicker(
  BuildContext context, {
  String? selected,
  bool allowAll = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final entries = <String>[if (allowAll) '', ...bolivarMunicipalities];

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Municipio',
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (itemContext, index) {
                    final municipality = entries[index];
                    final label = municipality.isEmpty
                        ? 'Todos los municipios'
                        : municipality;
                    final isSelected = municipality == (selected ?? '');

                    return ListTile(
                      title: Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.accent,
                              size: 20,
                            )
                          : null,
                      onTap: () => Navigator.of(itemContext).pop(municipality),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
