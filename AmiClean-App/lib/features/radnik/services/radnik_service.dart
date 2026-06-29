import '../../../config/api_config.dart';
import '../../../core/api/api_client.dart';
import '../models/radnik_dostava.dart';

class RadnikService {
  RadnikService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<RadnikDostaveLista> getDostave({required int zaposlenikId}) async {
    final payload = await _apiClient.get(
      ApiConfig.getDostaveZaRadnikaUri(zaposlenikId: zaposlenikId),
    );
    return RadnikDostaveLista.fromJson(payload);
  }

  Future<RadnikDostavaDetalj> getDetaljDostave({
    required int narudzbaId,
    required int zaposlenikId,
  }) async {
    final payload = await _apiClient.get(
      ApiConfig.getDetaljDostaveZaRadnikaUri(
        narudzbaId: narudzbaId,
        zaposlenikId: zaposlenikId,
      ),
    );
    return RadnikDostavaDetalj.fromJson(payload);
  }
}
