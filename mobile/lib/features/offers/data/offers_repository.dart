import '../../../core/network/api_client.dart';
import 'offer.dart';
import 'offer_draft.dart';
import 'offer_query.dart';
import 'offers_api.dart';

class OffersRepository {
  OffersRepository({required ApiClient client, OffersApi? api})
      : _api = api ?? OffersApi(client);

  final OffersApi _api;

  Future<List<Offer>> list(OfferQuery query) => _api.list(query);

  Future<Offer> create(OfferDraft draft) => _api.create(draft);

  Future<Offer> update(String id, OfferDraft draft) => _api.update(id, draft);

  Future<void> delete(String id) => _api.delete(id);

  Future<bool> save(String id) => _api.save(id);

  Future<bool> unsave(String id) => _api.unsave(id);
}
