import '../../../core/network/api_client.dart';
import 'offer.dart';
import 'offer_draft.dart';
import 'offer_query.dart';

class OffersApi {
  OffersApi(this._client);

  final ApiClient _client;

  Future<List<Offer>> list(OfferQuery query) async {
    final data = await _client.get(
      '/offers',
      query: query.toQueryParameters(),
    ) as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>).cast<Map<String, dynamic>>();

    return items.map(Offer.fromJson).toList();
  }

  Future<Offer> create(OfferDraft draft) async {
    final data = await _client.post(
      '/offers',
      body: draft.toJson(),
    ) as Map<String, dynamic>;
    return Offer.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Offer> update(String id, OfferDraft draft) async {
    final data = await _client.put(
      '/offers/$id',
      body: draft.toJson(),
    ) as Map<String, dynamic>;
    return Offer.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _client.delete('/offers/$id');

  Future<bool> save(String id) async {
    final data = await _client.post('/offers/$id/save') as Map<String, dynamic>;
    final result = data['data'] as Map<String, dynamic>;
    return result['saved'] as bool;
  }

  Future<bool> unsave(String id) async {
    final data =
        await _client.delete('/offers/$id/save') as Map<String, dynamic>;
    final result = data['data'] as Map<String, dynamic>;
    return result['saved'] as bool;
  }
}
