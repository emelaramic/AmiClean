import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/artikal_katalog.dart';

class CatalogService {
  CatalogService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<String>> getKategorije() async {
    final payload = await _apiClient.getList(ApiConfig.getKategorijeUri);
    return payload.map((e) => e as String).toList();
  }

  Future<List<ArtikalKatalog>> getKatalog() async {
    final payload = await _apiClient.getList(ApiConfig.getKatalogUri);
    return payload
        .map((e) => ArtikalKatalog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
