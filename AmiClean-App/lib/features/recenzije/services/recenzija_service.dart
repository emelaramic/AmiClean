import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/recenzija.dart';

class RecenzijaService {
  RecenzijaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Recenzija> kreirajRecenziju({
    required int korisnikId,
    required int narudzbaId,
    required int ocjena,
    String? komentar,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.kreirajRecenzijuUri,
      {
        'korisnikId': korisnikId,
        'narudzbaId': narudzbaId,
        'ocjena': ocjena,
        'komentar': komentar?.trim(),
      },
    );
    return Recenzija.fromJson(payload);
  }
}
