class AzurirajProfilRequest {
  const AzurirajProfilRequest({
    required this.korisnikId,
    this.brojTelefona,
    this.adresaStanovanja,
  });

  final int korisnikId;
  final String? brojTelefona;
  final String? adresaStanovanja;

  Map<String, dynamic> toJson() => {
        'korisnikId': korisnikId,
        'brojTelefona': brojTelefona?.trim(),
        'adresaStanovanja': adresaStanovanja?.trim(),
      };
}
