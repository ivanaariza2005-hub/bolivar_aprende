import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/constants/offer_enums.dart';
import '../../../core/network/api_exception.dart';
import '../data/offer.dart';
import '../data/offer_draft.dart';
import '../data/offer_query.dart';
import '../data/offers_repository.dart';

enum OffersStatus { loading, success, empty, error }

class OffersProvider extends ChangeNotifier {
  OffersProvider({
    required OffersRepository repository,
    OfferQuery initialQuery = const OfferQuery(),
  })  : _repository = repository,
        _query = initialQuery;

  final OffersRepository _repository;

  OfferQuery _query;
  List<Offer> _offers = <Offer>[];
  OffersStatus _status = OffersStatus.loading;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isDisposed = false;
  int _requestId = 0;
  Timer? _searchDebounce;

  OfferQuery get query => _query;
  List<Offer> get offers => _offers;
  OffersStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _status = OffersStatus.loading;
      _notify();
    }

    final requestId = ++_requestId;

    try {
      final offers = await _repository.list(_query);

      if (requestId != _requestId) {
        return;
      }

      _offers = offers;
      _errorMessage = null;
      _status = offers.isEmpty ? OffersStatus.empty : OffersStatus.success;
    } on ApiException catch (error) {
      if (requestId != _requestId) {
        return;
      }

      _errorMessage = error.message;
      _status = OffersStatus.error;
    }

    _notify();
  }

  Future<void> refresh() => load(showLoading: false);

  void setSearch(String value) {
    if (_query.search == value) {
      return;
    }

    _query = OfferQuery(
      search: value,
      type: _query.type,
      municipality: _query.municipality,
      savedOnly: _query.savedOnly,
    );

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), load);
  }

  void setType(OfferType? type) {
    if (_query.type == type) {
      return;
    }

    _query = OfferQuery(
      search: _query.search,
      type: type,
      municipality: _query.municipality,
      savedOnly: _query.savedOnly,
    );

    _notify();
    load();
  }

  void setMunicipality(String? municipality) {
    if (_query.municipality == municipality) {
      return;
    }

    _query = OfferQuery(
      search: _query.search,
      type: _query.type,
      municipality: municipality,
      savedOnly: _query.savedOnly,
    );

    _notify();
    load();
  }

  void clearFilters() {
    _query = OfferQuery(savedOnly: _query.savedOnly);
    _notify();
    load();
  }

  Future<Offer?> createOffer(OfferDraft draft) async {
    _isSubmitting = true;
    _notify();

    try {
      final offer = await _repository.create(draft);
      await load(showLoading: false);
      return offer;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<Offer?> updateOffer(String id, OfferDraft draft) async {
    _isSubmitting = true;
    _notify();

    try {
      final offer = await _repository.update(id, draft);
      await load(showLoading: false);
      return offer;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<bool> deleteOffer(String id) async {
    _isSubmitting = true;
    _notify();

    try {
      await _repository.delete(id);
      _offers = _offers.where((offer) => offer.id != id).toList();
      _status = _offers.isEmpty ? OffersStatus.empty : OffersStatus.success;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<bool?> toggleSaved(Offer offer) async {
    try {
      final saved = offer.isSaved
          ? await _repository.unsave(offer.id)
          : await _repository.save(offer.id);

      final index = _offers.indexWhere((item) => item.id == offer.id);

      if (index >= 0) {
        final updated = List<Offer>.of(_offers);

        if (_query.savedOnly && !saved) {
          updated.removeAt(index);
        } else {
          updated[index] = updated[index].copyWith(isSaved: saved);
        }

        _offers = updated;
        _status = _offers.isEmpty ? OffersStatus.empty : OffersStatus.success;
        _notify();
      }

      return saved;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _notify();
      return null;
    }
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    super.dispose();
  }
}
