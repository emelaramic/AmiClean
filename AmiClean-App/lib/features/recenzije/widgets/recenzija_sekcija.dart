import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../models/recenzija.dart';
import '../services/recenzija_service.dart';

/// Zvjezdice za ocjenu (1–5) i forma za slanje recenzije.
class RecenzijaFormSekcija extends StatefulWidget {
  const RecenzijaFormSekcija({
    super.key,
    required this.recenzijaService,
    required this.korisnikId,
    required this.narudzbaId,
    required this.onUspjesnoPoslano,
  });

  final RecenzijaService recenzijaService;
  final int korisnikId;
  final int narudzbaId;
  final VoidCallback onUspjesnoPoslano;

  @override
  State<RecenzijaFormSekcija> createState() => _RecenzijaFormSekcijaState();
}

class _RecenzijaFormSekcijaState extends State<RecenzijaFormSekcija> {
  final _komentarController = TextEditingController();
  int _ocjena = 0;
  bool _salje = false;
  String? _greska;

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _posalji() async {
    if (_ocjena < 1) {
      setState(() => _greska = 'Odaberite ocjenu (1–5 zvjezdica).');
      return;
    }

    setState(() {
      _salje = true;
      _greska = null;
    });

    try {
      await widget.recenzijaService.kreirajRecenziju(
        korisnikId: widget.korisnikId,
        narudzbaId: widget.narudzbaId,
        ocjena: _ocjena,
        komentar: _komentarController.text,
      );
      if (!mounted) return;
      widget.onUspjesnoPoslano();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _salje = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Slanje recenzije nije uspjelo.';
        _salje = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ocijenite uslugu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vaša ocjena pomaže nam da budemo bolji.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OcjenaZvjezdice(
              ocjena: _ocjena,
              interaktivno: true,
              onPromjena: _salje ? null : (v) => setState(() => _ocjena = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _komentarController,
              enabled: !_salje,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Komentar (opcionalno)',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            if (_greska != null) ...[
              const SizedBox(height: 8),
              Text(
                _greska!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _salje ? null : _posalji,
                icon: _salje
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text('Pošalji recenziju'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Prikaz već ostavljene recenzije (read-only).
class RecenzijaPregledSekcija extends StatelessWidget {
  const RecenzijaPregledSekcija({
    super.key,
    required this.recenzija,
    this.naslov = 'Vaša recenzija',
  });

  final Recenzija recenzija;
  final String naslov;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              naslov,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            OcjenaZvjezdice(ocjena: recenzija.ocjena),
            if (recenzija.komentar != null && recenzija.komentar!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(recenzija.komentar!),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDatum(recenzija.datumObjave),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDatum(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}.';
  }
}

class OcjenaZvjezdice extends StatelessWidget {
  const OcjenaZvjezdice({
    super.key,
    required this.ocjena,
    this.interaktivno = false,
    this.onPromjena,
  });

  final int ocjena;
  final bool interaktivno;
  final ValueChanged<int>? onPromjena;

  @override
  Widget build(BuildContext context) {
    final boja = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final vrijednost = index + 1;
        final popunjena = vrijednost <= ocjena;

        return IconButton(
          onPressed: interaktivno && onPromjena != null
              ? () => onPromjena!(vrijednost)
              : null,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: Icon(
            popunjena ? Icons.star_rounded : Icons.star_outline_rounded,
            color: popunjena ? Colors.amber.shade700 : boja.withValues(alpha: 0.4),
            size: 32,
          ),
        );
      }),
    );
  }
}
