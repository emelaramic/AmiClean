import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/preporuka.dart';

class PreporukaService {
  PreporukaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Preporuka>> getZaKorisnika({
    required int korisnikId,
    int limit = 3,
  }) async {
    final uri = ApiConfig.getPreporukeZaKorisnikaUri(
      korisnikId: korisnikId,
      limit: limit,
    );
    final payload = await _apiClient.getList(uri);
    return payload
        .map((e) => Preporuka.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
