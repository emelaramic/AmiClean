import '../../../core/security/password_hasher.dart';

class RegistracijaRequest {
  const RegistracijaRequest({
    required this.ime,
    required this.prezime,
    required this.lozinka,
    this.email,
    this.brojTelefona,
    this.adresaStanovanja,
  });

  final String ime;
  final String prezime;
  final String lozinka;
  final String? email;
  final String? brojTelefona;
  final String? adresaStanovanja;

  /// JSON tijelo usklađeno s ASP.NET camelCase serializacijom.
  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'ime': ime.trim(),
      'prezime': prezime.trim(),
      'lozinka_Hash': PasswordHasher.hash(lozinka),
      'aktivan': true,
    };

    final normalizedEmail = email?.trim();
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      payload['email'] = normalizedEmail;
    }

    final normalizedPhone = brojTelefona?.trim();
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      payload['broj_Telefona'] = normalizedPhone;
    }

    final normalizedAddress = adresaStanovanja?.trim();
    if (normalizedAddress != null && normalizedAddress.isNotEmpty) {
      payload['adresa_Stanovanja'] = normalizedAddress;
    }

    return payload;
  }
}
