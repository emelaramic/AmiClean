import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/notifikacija.dart';

class NotifikacijaService {
  NotifikacijaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Notifikacija>> getZaKorisnika(int korisnikId) async {
    final payload = await _apiClient.getList(
      ApiConfig.getNotifikacijeZaKorisnikaUri(korisnikId: korisnikId),
    );
    return payload
        .map((e) => Notifikacija.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getBrojNeprocitanih(int korisnikId) async {
    final payload = await _apiClient.get(
      ApiConfig.getBrojNeprocitanihNotifikacijaUri(korisnikId: korisnikId),
    );
    return payload['broj'] as int? ?? 0;
  }

  Future<void> oznaciProcitanom({
    required int notifikacijaId,
    required int korisnikId,
  }) async {
    await _apiClient.postEmpty(
      ApiConfig.oznaciNotifikacijuProcitanomUri(
        notifikacijaId: notifikacijaId,
        korisnikId: korisnikId,
      ),
    );
  }

  Future<void> oznaciSveProcitanim(int korisnikId) async {
    await _apiClient.postEmpty(
      ApiConfig.oznaciSveNotifikacijeProcitanimUri(korisnikId: korisnikId),
    );
  }
}
