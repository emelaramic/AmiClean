import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/cart_stavka.dart';
import '../models/nacin_predaje.dart';
import '../models/narudzba_kreirana.dart';

class NarudzbaService {
  NarudzbaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<NarudzbaKreirana> kreirajNarudzbu({
    required int korisnikId,
    required NacinPredaje nacinPredaje,
    required List<CartStavka> stavke,
    String? adresa,
    String? napomena,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.kreirajNarudzbuUri,
      {
        'korisnikId': korisnikId,
        'nacinPredaje': nacinPredaje.apiVrijednost,
        'adresa': adresa?.trim(),
        'napomena': napomena?.trim(),
        'stavke': stavke
            .map(
              (s) => {
                'artikalId': s.artikalId,
                'kolicina': s.kolicina,
                'uslugaIds': s.usluge.map((u) => u.uslugaId).toList(),
                'napomena': s.napomena,
              },
            )
            .toList(),
      },
    );

    return NarudzbaKreirana.fromJson(payload);
  }
}
