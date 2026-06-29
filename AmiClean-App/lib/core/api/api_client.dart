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

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    http.Response response;

    try {
      response = await _httpClient
          .put(
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

  Future<void> postEmpty(String url) async {
    http.Response response;

    try {
      response = await _httpClient
          .post(Uri.parse(url), headers: _jsonHeaders)
          .timeout(_timeout);
    } on TimeoutException {
      throw const TimeoutApiException();
    } on http.ClientException {
      throw const NetworkApiException();
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
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

    final message = _extractErrorMessage(payload, response.body, response.statusCode);
    if (response.statusCode == 401) throw UnauthorizedApiException(message);
    if (response.statusCode == 400) throw ValidationApiException(message);
    throw ServerApiException(message, statusCode: response.statusCode);
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
      final validationMessages = _extractValidationMessages(payload);
      if (validationMessages.isNotEmpty) {
        return validationMessages.join(' ');
      }

      for (final key in ['message', 'detail', 'title', 'error']) {
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

  List<String> _extractValidationMessages(Map<String, dynamic> payload) {
    final errors = payload['errors'];
    if (errors is! Map) return const [];

    final messages = <String>[];
    for (final value in errors.values) {
      if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) {
            messages.add(item.trim());
          }
        }
      } else if (value is String && value.trim().isNotEmpty) {
        messages.add(value.trim());
      }
    }
    return messages;
  }

  void dispose() => _httpClient.close();
}
