import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/artikal_katalog.dart';
import '../utils/cijena_display.dart';
import '../utils/tepih_katalog.dart';

/// Unos dimenzija tepiha (dužina × širina) s prikazom izračunate površine.
class TepihDimenzijePolja extends StatelessWidget {
  const TepihDimenzijePolja({
    super.key,
    required this.duzinaController,
    required this.sirinaController,
    required this.onChanged,
  });

  final TextEditingController duzinaController;
  final TextEditingController sirinaController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final povrsina = TepihKatalog.povrsina(
      duzina: duzinaController.text,
      sirina: sirinaController.text,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: duzinaController,
                decoration: const InputDecoration(
                  labelText: 'Dužina (m)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(decimalDimenzijaRegex),
                ],
                onChanged: (_) => onChanged(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16, left: 8, right: 8),
              child: Text('×', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: TextFormField(
                controller: sirinaController,
                decoration: const InputDecoration(
                  labelText: 'Širina (m)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(decimalDimenzijaRegex),
                ],
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        if (povrsina != null) ...[
          const SizedBox(height: 8),
          Text(
            'Površina: ${TepihKatalog.formatM2(povrsina)} m²',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}

/// Trenutni izračun cijene stavke prije dodavanja u narudžbu.
class StavkaCijenaPreview extends StatelessWidget {
  const StavkaCijenaPreview({
    super.key,
    required this.ukupno,
    required this.povrsinaM2,
    required this.jeTepih,
    required this.imaOdabraneUsluge,
  });

  final double ukupno;
  final double? povrsinaM2;
  final bool jeTepih;
  final bool imaOdabraneUsluge;

  @override
  Widget build(BuildContext context) {
    if (!imaOdabraneUsluge) return const SizedBox.shrink();

    final theme = Theme.of(context);

    if (jeTepih && (povrsinaM2 == null || povrsinaM2! <= 0)) {
      return Card(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unesite dužinu i širinu tepiha da vidite cijenu.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (ukupno <= 0) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Procijenjena cijena',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (jeTepih && povrsinaM2 != null) ...[
              const SizedBox(height: 4),
              Text(
                '${TepihKatalog.formatM2(povrsinaM2!)} m² × odabrana usluga',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              CijenaDisplay.km(ukupno),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cijena usluge — KM/m² za tepihe, inače obična cijena.
Widget cijenaUslugeWidget(UslugaCijena usluga, {required String kategorija}) {
  if (TepihKatalog.jeTepih(kategorija)) {
    return CijenaDisplay.kmPoM2Widget(usluga.cijena);
  }
  return CijenaDisplay.kmWidget(usluga.cijena);
}

double izracunajUkupnoStavke({
  required ArtikalKatalog artikal,
  required Set<int> odabraneUslugeIds,
  required double kolicina,
}) {
  if (odabraneUslugeIds.isEmpty || kolicina <= 0) return 0;

  final cijenaPoJedinici = artikal.usluge
      .where((u) => odabraneUslugeIds.contains(u.uslugaId))
      .fold(0.0, (sum, u) => sum + u.cijena);

  return kolicina * cijenaPoJedinici;
}
