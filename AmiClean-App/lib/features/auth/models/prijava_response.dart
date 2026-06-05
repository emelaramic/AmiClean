enum UserRole {
  korisnik,
  admin;

  static UserRole fromApiValue(String value) {
    return switch (value.toLowerCase()) {
      'admin' => UserRole.admin,
      _ => UserRole.korisnik,
    };
  }
}

class PrijavaResponse {
  const PrijavaResponse({
    required this.id,
    required this.ime,
    required this.prezime,
    required this.uloga,
    this.email,
    this.korisnickoIme,
    this.ulogaZaposlenika,
    this.brojTelefona,
    this.adresaStanovanja,
  });

  final int id;
  final String ime;
  final String prezime;
  final UserRole uloga;
  final String? email;
  final String? korisnickoIme;
  final String? ulogaZaposlenika;
  final String? brojTelefona;
  final String? adresaStanovanja;

  factory PrijavaResponse.fromJson(Map<String, dynamic> json) {
    return PrijavaResponse(
      id: json['id'] as int,
      ime: json['ime'] as String,
      prezime: json['prezime'] as String,
      uloga: UserRole.fromApiValue(json['uloga'] as String),
      email: json['email'] as String?,
      korisnickoIme:
          json['korisnickoIme'] as String? ?? json['korisnicko_Ime'] as String?,
      ulogaZaposlenika:
          json['ulogaZaposlenika'] as String? ?? json['uloga_Zaposlenika'] as String?,
      brojTelefona:
          json['brojTelefona'] as String? ?? json['broj_Telefona'] as String?,
      adresaStanovanja: json['adresaStanovanja'] as String? ??
          json['adresa_Stanovanja'] as String?,
    );
  }

  String get punoIme => '$ime $prezime';
}
