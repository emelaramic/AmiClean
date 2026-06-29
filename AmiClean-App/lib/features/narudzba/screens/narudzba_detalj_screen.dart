import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../katalog/utils/cijena_display.dart';
import '../../qr/stavka_oznaka_qr.dart';
import '../../qr/screens/stavka_oznaka_skeniraj_screen.dart';
import '../../recenzije/services/recenzija_service.dart';
import '../../recenzije/widgets/recenzija_sekcija.dart';
import '../models/narudzba_pregled.dart';
import '../models/narudzba_status.dart';
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
  late final _recenzijaService = RecenzijaService(apiClient: _apiClient);

  NarudzbaDetalj? _narudzba;
  bool _loading = true;
  bool _otkazivanje = false;
  bool _promijenjeno = false;
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

  Future<void> _ucitajDetalj({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
        _greska = null;
      });
    }

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

  Future<bool> _potvrdiOtkazivanje() async {
    final potvrda = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otkaži narudžbu'),
        content: const Text(
          'Narudžba se može otkazati samo dok nije primljena u čistionici. '
          'Jeste li sigurni?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Da, otkaži'),
          ),
        ],
      ),
    );
    return potvrda ?? false;
  }

  Future<void> _otkaziNarudzbu() async {
    if (!await _potvrdiOtkazivanje()) return;

    setState(() {
      _otkazivanje = true;
      _greska = null;
    });

    try {
      final rezultat = await _narudzbaService.otkaziNarudzbu(
        narudzbaId: widget.narudzbaId,
        korisnikId: widget.session.user!.id,
      );
      if (!mounted) return;

      _promijenjeno = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(rezultat.poruka)),
      );

      await _ucitajDetalj(showLoading: false);
      if (mounted) setState(() => _otkazivanje = false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _otkazivanje = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Otkazivanje narudžbe nije uspjelo.';
        _otkazivanje = false;
      });
    }
  }

  void _zatvori() {
    Navigator.of(context).pop(_promijenjeno);
  }

  Future<void> _otvoriPotvrduPreuzimanja() async {
    final rezultat = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => StavkaOznakaSkenirajScreen.korisnik(
          korisnikId: widget.session.user!.id,
        ),
      ),
    );

    if (rezultat != null && mounted) {
      _promijenjeno = true;
      await _ucitajDetalj(showLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Narudžba #${widget.narudzbaId}'),
        leading: BackButton(onPressed: _zatvori),
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
            vrijednost: n.statusNaziv == NarudzbaStatusi.primljena ||
                    n.statusNaziv == NarudzbaStatusi.uObradi
                ? 'Bit će potvrđen nakon pregleda u čistionici'
                : 'Bit će potvrđen nakon prijema u čistionici',
          ),
        if (n.napomena != null)
          _InfoSekcija(naslov: 'Napomena', vrijednost: n.napomena!),
        const SizedBox(height: 16),
        Text('Stavke', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...n.stavke.map(_buildStavka),
        const Divider(height: 32),
        if (n.imaPopust) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Međuzbroj', style: Theme.of(context).textTheme.bodyLarge),
              Text(CijenaDisplay.km(n.ukupnaCijena)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popust${n.kuponKod != null ? ' (${n.kuponKod})' : ''}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '-${CijenaDisplay.km(n.popustIznos)}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              n.imaPopust ? 'Ukupno za platiti' : 'Ukupno',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              CijenaDisplay.km(
                n.imaPopust ? n.ukupnoZaPlatiti : n.ukupnaCijena,
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        if (n.mozeSeOtkazati) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _otkazivanje ? null : _otkaziNarudzbu,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: _otkazivanje
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cancel_outlined),
            label: const Text('Otkaži narudžbu'),
          ),
        ] else if (n.statusNaziv == NarudzbaStatusi.gotova) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _otvoriPotvrduPreuzimanja,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Potvrdi preuzimanje'),
          ),
          const SizedBox(height: 8),
          Text(
            'Skenirajte QR kod na artiklu ili unesite broj oznake ručno '
            'kad preuzmete narudžbu u radnji ili od dostavljača.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ] else if (n.statusNaziv == NarudzbaStatusi.otkazana) ...[
          const SizedBox(height: 24),
          Text(
            'Ova narudžba je otkazana.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        if (n.recenzija != null) ...[
          const SizedBox(height: 24),
          RecenzijaPregledSekcija(recenzija: n.recenzija!),
        ] else if (n.mozeSeRecenzirati) ...[
          const SizedBox(height: 24),
          RecenzijaFormSekcija(
            recenzijaService: _recenzijaService,
            korisnikId: widget.session.user!.id,
            narudzbaId: widget.narudzbaId,
            onUspjesnoPoslano: () async {
              _promijenjeno = true;
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hvala na recenziji!')),
              );
              await _ucitajDetalj(showLoading: false);
            },
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
            if (stavka.imaBrojOznake) ...[
              const SizedBox(height: 12),
              StavkaOznakaQr(brojOznake: stavka.brojOznake!),
            ],
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
