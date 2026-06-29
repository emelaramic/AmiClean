import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/stavka_oznaka_info.dart';

class StavkaOznakaService {
  StavkaOznakaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<StavkaOznakaInfo> getInfoPoOznaci(
    String unos, {
    int? korisnikId,
  }) async {
    final payload = await _apiClient.get(
      ApiConfig.getInfoPoOznaciUri(unos, korisnikId: korisnikId),
    );
    return StavkaOznakaInfo.fromJson(payload);
  }

  Future<RadnikOznakaRezultat> radnikPokreniDostavu({
    required String unos,
    required int zaposlenikId,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.radnikPokreniDostavuUri,
      {
        'unos': unos,
        'zaposlenikId': zaposlenikId,
      },
    );
    return RadnikOznakaRezultat.fromJson(payload);
  }

  Future<KorisnikOznakaRezultat> korisnikPotvrdiPreuzimanje({
    required String unos,
    required int korisnikId,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.korisnikPotvrdiPreuzimanjeUri,
      {
        'unos': unos,
        'korisnikId': korisnikId,
      },
    );
    return KorisnikOznakaRezultat.fromJson(payload);
  }
}
