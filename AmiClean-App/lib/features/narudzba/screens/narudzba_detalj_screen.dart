import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../katalog/utils/cijena_display.dart';
import '../models/narudzba_pregled.dart';
import '../services/narudzba_service.dart';

class NarudzbaDetaljScreen extends StatefulWidget {
  const NarudzbaDetaljScreen({
    super.key,
    required this.session,
    required this.narudzbaId,
  });

  final AuthSession session;
  final int narudzbaId;

  @override
  State<NarudzbaDetaljScreen> createState() => _NarudzbaDetaljScreenState();
}

class _NarudzbaDetaljScreenState extends State<NarudzbaDetaljScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);

  NarudzbaDetalj? _narudzba;
  bool _loading = true;
  String? _greska;

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
      final detalj = await _narudzbaService.getDetaljNarudzbe(
        narudzbaId: widget.narudzbaId,
        korisnikId: widget.session.user!.id,
      );
      if (!mounted) return;
      setState(() {
        _narudzba = detalj;
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

    if (_greska != null) {
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
        _InfoSekcija(
          naslov: 'Status',
          vrijednost: n.statusNaziv,
        ),
        _InfoSekcija(
          naslov: 'Datum',
          vrijednost: _formatDatum(n.datumKreiranja),
        ),
        _InfoSekcija(
          naslov: 'Način predaje',
          vrijednost: n.nacinPredajeNaziv,
        ),
        if (n.adresaPreuzimanja != null)
          _InfoSekcija(
            naslov: 'Adresa preuzimanja (ova narudžba)',
            vrijednost: n.adresaPreuzimanja!,
          ),
        if (n.rokZavrsetka != null)
          _InfoSekcija(
            naslov: 'Rok završetka',
            vrijednost: _formatDatum(n.rokZavrsetka!),
          )
        else
          _InfoSekcija(
            naslov: 'Rok završetka',
            vrijednost: 'Bit će potvrđen nakon prijema u čistionici',
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
            Text(
              'Ukupno',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              CijenaDisplay.km(n.ukupnaCijena),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
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
