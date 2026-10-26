import '../../../core/constants/offer_enums.dart';

class OfferQuery {
  const OfferQuery({
    this.search = '',
    this.type,
    this.municipality,
    this.savedOnly = false,
  });

  final String search;
  final OfferType? type;
  final String? municipality;
  final bool savedOnly;

  Map<String, dynamic> toQueryParameters() {
    final parameters = <String, dynamic>{};
    final trimmedSearch = search.trim();
    final selectedType = type;
    final selectedMunicipality = municipality;

    if (trimmedSearch.isNotEmpty) {
      parameters['q'] = trimmedSearch;
    }
    if (selectedType != null) {
      parameters['type'] = selectedType.name;
    }
    if (selectedMunicipality != null) {
      parameters['municipality'] = selectedMunicipality;
    }
    if (savedOnly) {
      parameters['saved'] = 'true';
    }

    return parameters;
  }
}
