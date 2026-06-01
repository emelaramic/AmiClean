import 'package:flutter/material.dart';

import '../models/artikal_katalog.dart';
import '../utils/ugao_artikli.dart';

/// Padajući izbor artikla + odabir Ugao (manji/veliki) s prikazom cijene.
class ArtikalOdabirPanel extends StatelessWidget {
  const ArtikalOdabirPanel({
    super.key,
    required this.artikliZaKategoriju,
    required this.sviArtikli,
    required this.odabraniIzbor,
    required this.odabranaUgaoVarijanta,
    required this.onIzborChanged,
    required this.onUgaoVarijantaChanged,
    required this.uslugeBuilder,
    this.kategorija,
  });

  final List<ArtikalKatalog> artikliZaKategoriju;
  final List<ArtikalKatalog> sviArtikli;
  final ArtikalIzbor? odabraniIzbor;
  final String? odabranaUgaoVarijanta;
  final String? kategorija;
  final ValueChanged<ArtikalIzbor?> onIzborChanged;
  final ValueChanged<String?> onUgaoVarijantaChanged;
  final Widget Function(ArtikalKatalog artikal) uslugeBuilder;

  List<ArtikalIzbor> get _opcije => artikalIzbori(artikliZaKategoriju);

  ArtikalKatalog? get _rijeseniArtikal => rijeseniArtikal(
        sviArtikli: sviArtikli,
        izbor: odabraniIzbor,
        ugaoVarijantaNaziv: odabranaUgaoVarijanta,
      );

  @override
  Widget build(BuildContext context) {
    final ugaoVarijante = UgaoArtikli.varijante(artikliZaKategoriju);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: odabraniIzbor == null
              ? null
              : artikalIzborNaziv(odabraniIzbor!),
          decoration: const InputDecoration(
            labelText: 'Artikal',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Odaberite artikal'),
          items: _opcije
              .map(
                (o) => DropdownMenuItem(
                  value: artikalIzborNaziv(o),
                  child: Text(artikalIzborNaziv(o)),
                ),
              )
              .toList(),
          onChanged: (naziv) {
            if (naziv == null) {
              onIzborChanged(null);
              onUgaoVarijantaChanged(null);
              return;
            }
            onIzborChanged(artikalIzborPoNazivu(_opcije, naziv));
            if (artikalIzborPoNazivu(_opcije, naziv) is! ArtikalIzborUgao) {
              onUgaoVarijantaChanged(null);
            }
          },
        ),
        if (odabraniIzbor is ArtikalIzborUgao) ...[
          const SizedBox(height: 16),
          Text(
            'Veličina ugla',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: odabranaUgaoVarijanta,
            onChanged: (value) => onUgaoVarijantaChanged(value),
            child: Column(
              children: ugaoVarijante.map((a) {
                final cijena =
                    a.usluge.isEmpty ? '' : a.usluge.first.cijenaTekst;
                final label = a.naziv == UgaoArtikli.manjiNaziv
                    ? 'Manji'
                    : 'Veliki';
                return RadioListTile<String>(
                  value: a.naziv,
                  title: Text('$label — $cijena'),
                );
              }).toList(),
            ),
          ),
        ],
        if (_rijeseniArtikal?.opis != null) ...[
          const SizedBox(height: 8),
          Text(
            _rijeseniArtikal!.opis!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        if (_rijeseniArtikal != null) ...[
          const SizedBox(height: 24),
          uslugeBuilder(_rijeseniArtikal!),
        ],
      ],
    );
  }
}
