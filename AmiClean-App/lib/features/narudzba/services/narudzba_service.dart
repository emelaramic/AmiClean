import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/cart_stavka.dart';
import '../models/nacin_predaje.dart';
import '../models/narudzba_admin.dart';
import '../models/narudzba_kreirana.dart';
import '../models/narudzba_pregled.dart';

class NarudzbaService {
  NarudzbaService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NarudzbaAdminPregled>> getSveNarudzbe() async {
    final payload = await _apiClient.getList(ApiConfig.getSveNarudzbeUri);
    return payload
        .map((e) => NarudzbaAdminPregled.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NarudzbaAdminDetalj> getDetaljNarudzbeAdmin(int narudzbaId) async {
    final payload = await _apiClient.get(
      ApiConfig.getDetaljNarudzbeAdminUri(narudzbaId),
    );
    return NarudzbaAdminDetalj.fromJson(payload);
  }

  Future<NarudzbaStatusPromjena> primijeniNarudzbu({
    required int narudzbaId,
    required int zaposlenikId,
    required DateTime rokZavrsetka,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.primijeniNarudzbuUri,
      {
        'narudzbaId': narudzbaId,
        'zaposlenikId': zaposlenikId,
        'rokZavrsetka': rokZavrsetka.toIso8601String(),
      },
    );
    return NarudzbaStatusPromjena.fromJson(payload);
  }

  Future<List<NarudzbaPregled>> getMojeNarudzbe(int korisnikId) async {
    final payload = await _apiClient.getList(
      ApiConfig.getMojeNarudzbeUri(korisnikId),
    );
    return payload
        .map((e) => NarudzbaPregled.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NarudzbaDetalj> getDetaljNarudzbe({
    required int narudzbaId,
    required int korisnikId,
  }) async {
    final payload = await _apiClient.get(
      ApiConfig.getDetaljNarudzbeUri(
        narudzbaId: narudzbaId,
        korisnikId: korisnikId,
      ),
    );
    return NarudzbaDetalj.fromJson(payload);
  }

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
