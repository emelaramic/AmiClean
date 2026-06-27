import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/kupon_provjera.dart';

class KuponService {
  KuponService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<KuponProvjera> provjeri({
    required String kod,
    required double ukupnaCijena,
  }) async {
    final payload = await _apiClient.get(
      ApiConfig.provjeriKuponUri(kod: kod, ukupnaCijena: ukupnaCijena),
    );
    return KuponProvjera.fromJson(payload);
  }
}
