import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    http.Response response;

    try {
      response = await _httpClient
          .post(
            Uri.parse(url),
            headers: _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const TimeoutApiException();
    } on http.ClientException {
      throw const NetworkApiException();
    }

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> get(String url) async {
    http.Response response;

    try {
      response = await _httpClient
          .get(Uri.parse(url), headers: _jsonHeaders)
          .timeout(_timeout);
    } on TimeoutException {
      throw const TimeoutApiException();
    } on http.ClientException {
      throw const NetworkApiException();
    }

    return _decodeResponse(response);
  }

  Future<List<dynamic>> getList(String url) async {
    http.Response response;

    try {
      response = await _httpClient
          .get(Uri.parse(url), headers: _jsonHeaders)
          .timeout(_timeout);
    } on TimeoutException {
      throw const TimeoutApiException();
    } on http.ClientException {
      throw const NetworkApiException();
    }

    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return [];
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
      throw const ServerApiException('Backend nije vratio listu podataka.');
    }

    Map<String, dynamic>? payload;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } on FormatException {
        // plain text greška
      }
    }

    final message = _extractErrorMessage(payload, response.body, statusCode);
    if (statusCode == 401) throw UnauthorizedApiException(message);
    if (statusCode == 400) throw ValidationApiException(message);
    throw ServerApiException(message, statusCode: statusCode);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic>? payload;

    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        }
      } on FormatException {
        // Backend ponekad vrati plain text grešku.
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return payload ?? <String, dynamic>{};
    }

    final message = _extractErrorMessage(payload, response.body, statusCode);
    if (statusCode == 401) {
      throw UnauthorizedApiException(message);
    }
    if (statusCode == 400) {
      throw ValidationApiException(message);
    }

    throw ServerApiException(message, statusCode: statusCode);
  }

  String _extractErrorMessage(
    Map<String, dynamic>? payload,
    String rawBody,
    int statusCode,
  ) {
    if (payload != null) {
      for (final key in ['title', 'detail', 'message', 'error']) {
        final value = payload[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    if (rawBody.isNotEmpty) {
      return rawBody;
    }

    return 'Backend je vratio grešku (HTTP $statusCode).';
  }

  void dispose() => _httpClient.close();
}
