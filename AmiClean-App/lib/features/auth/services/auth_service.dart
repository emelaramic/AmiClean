import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/prijava_response.dart';

class AuthService {
  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PrijavaResponse> prijavaKorisnika({
    required String email,
    required String lozinka,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.prijavaKorisnikUri,
      {
        'email': email.trim(),
        'lozinka': lozinka,
      },
    );

    return PrijavaResponse.fromJson(payload);
  }

  Future<PrijavaResponse> prijavaZaposlenika({
    required String korisnickoIme,
    required String lozinka,
  }) async {
    final payload = await _apiClient.post(
      ApiConfig.prijavaZaposlenikUri,
      {
        'korisnicko_Ime': korisnickoIme.trim(),
        'lozinka': lozinka,
      },
    );

    return PrijavaResponse.fromJson(payload);
  }
}
