import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/azuriraj_profil_request.dart';
import '../models/korisnik.dart';
import '../models/registracija_request.dart';

class KorisnikService {
  KorisnikService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Korisnik> registriraj(RegistracijaRequest request) async {
    final payload = await _apiClient.post(
      ApiConfig.postKorisnikUri,
      request.toJson(),
    );

    return Korisnik.fromJson(payload);
  }

  Future<Korisnik> getProfil(int korisnikId) async {
    final payload = await _apiClient.get(ApiConfig.getProfilUri(korisnikId));
    return Korisnik.fromJson(payload);
  }

  Future<Korisnik> azurirajProfil(AzurirajProfilRequest request) async {
    final payload = await _apiClient.put(
      ApiConfig.azurirajProfilUri,
      request.toJson(),
    );
    return Korisnik.fromJson(payload);
  }
}
