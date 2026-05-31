sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkApiException extends ApiException {
  const NetworkApiException([
    super.message = 'Nema veze s backendom. Provjeri je li API pokrenut.',
  ]);
}

final class TimeoutApiException extends ApiException {
  const TimeoutApiException([
    super.message = 'Backend nije odgovorio na vrijeme.',
  ]);
}

final class ServerApiException extends ApiException {
  const ServerApiException(super.message, {this.statusCode});

  final int? statusCode;
}

final class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException([
    super.message = 'Neispravni podaci za prijavu.',
  ]);
}

final class ValidationApiException extends ApiException {
  const ValidationApiException(super.message);
}
