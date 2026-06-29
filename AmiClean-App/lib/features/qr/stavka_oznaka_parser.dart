const stavkaQrScheme = 'amiclean://stavka/';

/// QR sadržaj stavke — isti format za prikaz i skeniranje.
String stavkaQrSadrzaj(String brojOznake) => '$stavkaQrScheme$brojOznake';

/// Iz QR sadržaja ili ručnog unosa izvlači broj oznake (npr. AC-2026-0001-01).
String parsirajStavkaOznaku(String unos) {
  final trimmed = unos.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('Unesite broj oznake ili skenirajte QR kod.');
  }

  if (trimmed.toLowerCase().startsWith(stavkaQrScheme)) {
    return trimmed.substring(stavkaQrScheme.length).trim();
  }

  return trimmed;
}
