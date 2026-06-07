import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/cjenovnik_stavka.dart';

class CjenovnikService {
  CjenovnikService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CjenovnikStavka>> getCjenovnik() async {
    final payload = await _apiClient.getList(ApiConfig.getCjenovnikUri);
    return payload
        .map((e) => CjenovnikStavka.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> azurirajCijenu({
    required CjenovnikStavka stavka,
    required double novaCijena,
  }) async {
    await _apiClient.put(
      ApiConfig.putCjenovnikUri(stavka.id),
      stavka.toUpdateJson(novaCijena: novaCijena),
    );
  }
}
