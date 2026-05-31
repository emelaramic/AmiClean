import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
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
}
