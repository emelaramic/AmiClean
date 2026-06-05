class Korisnik {
  const Korisnik({
    required this.id,
    required this.ime,
    required this.prezime,
    this.email,
    this.brojTelefona,
    this.adresaStanovanja,
    this.aktivan = true,
  });

  final int id;
  final String ime;
  final String prezime;
  final String? email;
  final String? brojTelefona;
  final String? adresaStanovanja;
  final bool aktivan;

  factory Korisnik.fromJson(Map<String, dynamic> json) {
    return Korisnik(
      id: json['id'] as int? ??
          json['id_Korisnika'] as int? ??
          json['iD_Korisnika'] as int? ??
          0,
      ime: json['ime'] as String,
      prezime: json['prezime'] as String,
      email: json['email'] as String?,
      brojTelefona:
          json['brojTelefona'] as String? ?? json['broj_Telefona'] as String?,
      adresaStanovanja: json['adresaStanovanja'] as String? ??
          json['adresa_Stanovanja'] as String?,
      aktivan: json['aktivan'] as bool? ?? true,
    );
  }

  String get punoIme => '$ime $prezime';
}
