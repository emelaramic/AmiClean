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
  });

  final int id;
  final String ime;
  final String prezime;
  final UserRole uloga;
  final String? email;
  final String? korisnickoIme;
  final String? ulogaZaposlenika;

  factory PrijavaResponse.fromJson(Map<String, dynamic> json) {
    return PrijavaResponse(
      id: json['id'] as int,
      ime: json['ime'] as String,
      prezime: json['prezime'] as String,
      uloga: UserRole.fromApiValue(json['uloga'] as String),
      email: json['email'] as String?,
      korisnickoIme: json['korisnicko_Ime'] as String?,
      ulogaZaposlenika: json['uloga_Zaposlenika'] as String?,
    );
  }

  String get punoIme => '$ime $prezime';
}
