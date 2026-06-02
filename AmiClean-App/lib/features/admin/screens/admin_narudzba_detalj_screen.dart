import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../katalog/utils/cijena_display.dart';
import '../../narudzba/models/narudzba_admin.dart';
import '../../narudzba/models/narudzba_pregled.dart';
import '../../narudzba/services/narudzba_service.dart';

class AdminNarudzbaDetaljScreen extends StatefulWidget {
  const AdminNarudzbaDetaljScreen({
    super.key,
    required this.session,
    required this.narudzbaId,
  });

  final AuthSession session;
  final int narudzbaId;

  @override
  State<AdminNarudzbaDetaljScreen> createState() =>
      _AdminNarudzbaDetaljScreenState();
}

class _AdminNarudzbaDetaljScreenState extends State<AdminNarudzbaDetaljScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);

  NarudzbaAdminDetalj? _narudzba;
  bool _loading = true;
  bool _spremanje = false;
  String? _greska;
  DateTime? _rokZavrsetka;

  @override
  void initState() {
    super.initState();
    _ucitajDetalj();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajDetalj() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final detalj =
          await _narudzbaService.getDetaljNarudzbeAdmin(widget.narudzbaId);
      if (!mounted) return;
      setState(() {
        _narudzba = detalj;
        _rokZavrsetka = detalj.rokZavrsetka ??
            DateTime.now().add(const Duration(days: 3));
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Neuspješno učitavanje detalja narudžbe.';
        _loading = false;
      });
    }
  }

  Future<void> _odaberiRokZavrsetka() async {
    final rok = _rokZavrsetka ?? DateTime.now().add(const Duration(days: 3));
    final datum = await showDatePicker(
      context: context,
      initialDate: rok,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Rok završetka',
    );

    if (datum != null && mounted) {
      setState(() => _rokZavrsetka = datum);
    }
  }

  Future<void> _primijeniNarudzbu() async {
    final rok = _rokZavrsetka;
    if (rok == null) return;

    setState(() {
      _spremanje = true;
      _greska = null;
    });

    try {
      final rezultat = await _narudzbaService.primijeniNarudzbu(
        narudzbaId: widget.narudzbaId,
        zaposlenikId: widget.session.user!.id,
        rokZavrsetka: rok,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rezultat.poruka)),
      );

      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _spremanje = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Neuspješno primanje narudžbe.';
        _spremanje = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Narudžba #${widget.narudzbaId}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_greska != null && _narudzba == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_greska!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ucitajDetalj,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    final n = _narudzba!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_greska != null) ...[
          Text(
            _greska!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        _InfoSekcija(naslov: 'Status', vrijednost: n.statusNaziv),
        _InfoSekcija(naslov: 'Korisnik', vrijednost: n.korisnikPunoIme),
        if (n.korisnikEmail != null)
          _InfoSekcija(naslov: 'Email', vrijednost: n.korisnikEmail!),
        if (n.korisnikTelefon != null)
          _InfoSekcija(naslov: 'Telefon', vrijednost: n.korisnikTelefon!),
        _InfoSekcija(
          naslov: 'Datum',
          vrijednost: _formatDatum(n.datumKreiranja),
        ),
        _InfoSekcija(
          naslov: 'Način predaje',
          vrijednost: n.nacinPredajeNaziv,
        ),
        if (n.adresaPreuzimanja != null)
          _InfoSekcija(naslov: 'Adresa', vrijednost: n.adresaPreuzimanja!),
        if (n.rokZavrsetka != null)
          _InfoSekcija(
            naslov: 'Rok završetka',
            vrijednost: _formatDatum(n.rokZavrsetka!),
          ),
        if (n.napomena != null)
          _InfoSekcija(naslov: 'Napomena', vrijednost: n.napomena!),
        const SizedBox(height: 16),
        Text('Stavke', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...n.stavke.map(_buildStavka),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ukupno', style: Theme.of(context).textTheme.titleLarge),
            Text(
              CijenaDisplay.km(n.ukupnaCijena),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        if (n.mozeSePrimijeti) ...[
          const SizedBox(height: 24),
          Text(
            'Primanje u čistionici',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _spremanje ? null : _odaberiRokZavrsetka,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _rokZavrsetka == null
                  ? 'Odaberi rok završetka'
                  : 'Rok: ${_formatDatumSamo(_rokZavrsetka!)}',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _spremanje || _rokZavrsetka == null
                ? null
                : _primijeniNarudzbu,
            icon: _spremanje
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Primijeni narudžbu'),
          ),
        ],
      ],
    );
  }

  Widget _buildStavka(StavkaPregled stavka) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stavka.artikalNaziv,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(stavka.kolicinaTekst),
            const SizedBox(height: 4),
            ...stavka.usluge.map(
              (u) => Text('• ${u.uslugaNaziv} — ${CijenaDisplay.km(u.cijena)}'),
            ),
            if (stavka.napomena != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Napomena: ${stavka.napomena}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                CijenaDisplay.km(stavka.ukupno),
                style: const TextStyle(fontWeight: FontWeight.w600),
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
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}. $h:$min';
  }

  String _formatDatumSamo(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}.';
  }
}

class _InfoSekcija extends StatelessWidget {
  const _InfoSekcija({required this.naslov, required this.vrijednost});

  final String naslov;
  final String vrijednost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            naslov,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(vrijednost),
        ],
      ),
    );
  }
}
