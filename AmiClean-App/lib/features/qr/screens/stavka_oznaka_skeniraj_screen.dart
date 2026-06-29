import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/stavka_oznaka_info.dart';
import '../services/stavka_oznaka_service.dart';
import '../stavka_oznaka_parser.dart';

enum StavkaOznakaSkenirajUloga { radnik, korisnik }

/// Skeniranje ili ručni unos QR oznake — radnik (dostava) ili korisnik (preuzimanje).
class StavkaOznakaSkenirajScreen extends StatefulWidget {
  const StavkaOznakaSkenirajScreen._({
    super.key,
    required this.uloga,
    this.zaposlenikId,
    this.korisnikId,
  });

  factory StavkaOznakaSkenirajScreen.radnik({
    Key? key,
    required int zaposlenikId,
  }) {
    return StavkaOznakaSkenirajScreen._(
      key: key,
      uloga: StavkaOznakaSkenirajUloga.radnik,
      zaposlenikId: zaposlenikId,
    );
  }

  factory StavkaOznakaSkenirajScreen.korisnik({
    Key? key,
    required int korisnikId,
  }) {
    return StavkaOznakaSkenirajScreen._(
      key: key,
      uloga: StavkaOznakaSkenirajUloga.korisnik,
      korisnikId: korisnikId,
    );
  }

  final StavkaOznakaSkenirajUloga uloga;
  final int? zaposlenikId;
  final int? korisnikId;

  @override
  State<StavkaOznakaSkenirajScreen> createState() =>
      _StavkaOznakaSkenirajScreenState();
}

class _StavkaOznakaSkenirajScreenState extends State<StavkaOznakaSkenirajScreen>
    with SingleTickerProviderStateMixin {
  final _apiClient = ApiClient();
  late final StavkaOznakaService _oznakaService =
      StavkaOznakaService(apiClient: _apiClient);
  late final TabController _tabController;
  late final TextEditingController _rucniUnosController;
  late final MobileScannerController _scannerController;

  bool _obrada = false;
  String? _greska;
  String? _zadnjiSkeniraniKod;

  bool get _jeRadnik => widget.uloga == StavkaOznakaSkenirajUloga.radnik;

  bool get _imaKameru =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _imaKameru ? 2 : 1, vsync: this);
    _rucniUnosController = TextEditingController();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rucniUnosController.dispose();
    _scannerController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _obradiUnos(String siroviUnos) async {
    if (_obrada) return;

    final trimmed = siroviUnos.trim();
    if (trimmed.isEmpty) {
      setState(() => _greska = 'Unesite broj oznake ili skenirajte QR kod.');
      return;
    }

    if (_zadnjiSkeniraniKod == trimmed) return;
    _zadnjiSkeniraniKod = trimmed;

    setState(() {
      _obrada = true;
      _greska = null;
    });

    try {
      parsirajStavkaOznaku(trimmed);
      final info = await _oznakaService.getInfoPoOznaci(
        trimmed,
        korisnikId: _jeRadnik ? null : widget.korisnikId,
      );
      if (!mounted) return;

      setState(() => _obrada = false);
      await _prikaziPotvrdu(info, trimmed);
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _obrada = false;
        _greska = e.message;
        _zadnjiSkeniraniKod = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _obrada = false;
        _greska = e.message;
        _zadnjiSkeniraniKod = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _obrada = false;
        _greska = 'Došlo je do neočekivane greške.';
        _zadnjiSkeniraniKod = null;
      });
    }
  }

  Future<void> _prikaziPotvrdu(StavkaOznakaInfo info, String unos) async {
    final potvrdi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PotvrdaOznakeSheet(
        info: info,
        jeRadnik: _jeRadnik,
      ),
    );

    if (!mounted) return;

    _zadnjiSkeniraniKod = null;

    if (potvrdi != true) return;

    setState(() {
      _obrada = true;
      _greska = null;
    });

    try {
      if (_jeRadnik) {
        final rezultat = await _oznakaService.radnikPokreniDostavu(
          unos: unos,
          zaposlenikId: widget.zaposlenikId!,
        );
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(rezultat.poruka)),
        );

        if (rezultat.dostavaPokrenuta || !info.imaDostavu) {
          Navigator.of(context).pop(rezultat);
        }
      } else {
        final rezultat = await _oznakaService.korisnikPotvrdiPreuzimanje(
          unos: unos,
          korisnikId: widget.korisnikId!,
        );
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(rezultat.poruka)),
        );

        if (rezultat.preuzimanjePotvrdeno) {
          Navigator.of(context).pop(rezultat);
        }
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _greska = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _greska = 'Došlo je do neočekivane greške.');
    } finally {
      if (mounted) setState(() => _obrada = false);
    }
  }

  void _onBarcode(BarcodeCapture capture) {
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .map((v) => v.trim())
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');

    if (value.isEmpty) return;
    _obradiUnos(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final naslov = _jeRadnik ? 'Skeniraj oznaku' : 'Potvrdi preuzimanje';

    return Scaffold(
      appBar: AppBar(
        title: Text(naslov),
        bottom: _imaKameru
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.qr_code_scanner), text: 'Kamera'),
                  Tab(icon: Icon(Icons.keyboard), text: 'Ručni unos'),
                ],
              )
            : null,
      ),
      body: Stack(
        children: [
          if (_imaKameru)
            TabBarView(
              controller: _tabController,
              children: [
                _KameraTab(
                  controller: _scannerController,
                  onDetect: _onBarcode,
                  uputa: _jeRadnik
                      ? 'Usmjerite kameru prema QR naljepnici na artiklu. '
                          'Radi i ako skenirate QR s ekrana računala.'
                      : 'Skenirajte QR kod na artiklu kad ga preuzmete '
                          'u radnji ili od dostavljača.',
                ),
                _RucniUnosTab(
                  controller: _rucniUnosController,
                  onPotvrdi: () => _obradiUnos(_rucniUnosController.text),
                ),
              ],
            )
          else
            _RucniUnosTab(
              controller: _rucniUnosController,
              onPotvrdi: () => _obradiUnos(_rucniUnosController.text),
              prikaziUputuZaWeb: true,
            ),
          if (_obrada)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _greska == null
          ? null
          : Material(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _greska!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
    );
  }
}

class _KameraTab extends StatelessWidget {
  const _KameraTab({
    required this.controller,
    required this.onDetect,
    required this.uputa,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;
  final String uputa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MobileScanner(
              controller: controller,
              onDetect: onDetect,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            uputa,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _RucniUnosTab extends StatelessWidget {
  const _RucniUnosTab({
    required this.controller,
    required this.onPotvrdi,
    this.prikaziUputuZaWeb = false,
  });

  final TextEditingController controller;
  final VoidCallback onPotvrdi;
  final bool prikaziUputuZaWeb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (prikaziUputuZaWeb) ...[
          Icon(
            Icons.info_outline,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Kamera nije dostupna u ovom pregledniku. Unesite broj oznake ručno.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
        ],
        Text(
          'Broj oznake',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pronađite kod ispod QR-a u detalju narudžbe (npr. AC-2026-0004-01).',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Broj oznake',
            hintText: 'AC-2026-0004-01',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tag),
          ),
          onSubmitted: (_) => onPotvrdi(),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onPotvrdi,
          icon: const Icon(Icons.check),
          label: const Text('Potvrdi'),
        ),
      ],
    );
  }
}

class _PotvrdaOznakeSheet extends StatelessWidget {
  const _PotvrdaOznakeSheet({
    required this.info,
    required this.jeRadnik,
  });

  final StavkaOznakaInfo info;
  final bool jeRadnik;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final mozePotvrditi =
        jeRadnik ? info.mozePokrenutiDostavu : info.mozePotvrditiPreuzimanje;
    final labelAkcije = jeRadnik
        ? (info.imaDostavu ? 'Kreni u dostavu' : 'Potvrdi stavku')
        : 'Potvrdi preuzimanje';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            jeRadnik ? 'Potvrda oznake' : 'Potvrda preuzimanja',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRed('Broj oznake', info.brojOznake),
          _InfoRed('Artikal', info.artikalNaziv),
          _InfoRed('Narudžba', '#${info.narudzbaId}'),
          if (jeRadnik) _InfoRed('Korisnik', info.korisnikPunoIme),
          _InfoRed('Status', info.statusNarudzbe),
          _InfoRed('Način', info.nacinPredajeNaziv),
          if (info.adresaDostave != null)
            _InfoRed('Adresa', info.adresaDostave!),
          if (info.logistikaStatusNaziv != null)
            _InfoRed('Dostava', info.logistikaStatusNaziv!),
          const SizedBox(height: 12),
          Text(
            info.poruka,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                mozePotvrditi ? () => Navigator.of(context).pop(true) : null,
            child: Text(labelAkcije),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
        ],
      ),
    );
  }
}

class _InfoRed extends StatelessWidget {
  const _InfoRed(this.label, this.vrijednost);

  final String label;
  final String vrijednost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              vrijednost,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
