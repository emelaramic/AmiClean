import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../../auth/services/korisnik_service.dart';
import '../../kuponi/models/kupon_provjera.dart';
import '../../kuponi/services/kupon_service.dart';
import '../models/nacin_predaje.dart';
import '../services/narudzba_service.dart';

class PotvrdaNarudzbeScreen extends StatefulWidget {
  const PotvrdaNarudzbeScreen({
    super.key,
    required this.cart,
    required this.session,
  });

  final CartSession cart;
  final AuthSession session;

  @override
  State<PotvrdaNarudzbeScreen> createState() => _PotvrdaNarudzbeScreenState();
}

class _PotvrdaNarudzbeScreenState extends State<PotvrdaNarudzbeScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);
  late final _korisnikService = KorisnikService(apiClient: _apiClient);
  late final _kuponService = KuponService(apiClient: _apiClient);
  final _adresaController = TextEditingController();
  final _napomenaController = TextEditingController();
  final _kuponController = TextEditingController();

  NacinPredaje _nacinPredaje = NacinPredaje.donosUCistionicu;
  bool _salje = false;
  bool _provjeraKupona = false;
  bool _ucitavanjeProfila = true;
  String? _profilAdresa;
  KuponProvjera? _primijenjeniKupon;

  @override
  void initState() {
    super.initState();
    _ucitajProfilAdresu();
  }

  @override
  void dispose() {
    _adresaController.dispose();
    _napomenaController.dispose();
    _kuponController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajProfilAdresu() async {
    final izSesije = widget.session.user?.adresaStanovanja?.trim();
    if (izSesije != null && izSesije.isNotEmpty) {
      if (mounted) {
        setState(() {
          _profilAdresa = izSesije;
          _ucitavanjeProfila = false;
        });
      }
      return;
    }

    try {
      final profil =
          await _korisnikService.getProfil(widget.session.user!.id);
      if (!mounted) return;
      setState(() {
        _profilAdresa = profil.adresaStanovanja?.trim();
        _ucitavanjeProfila = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _ucitavanjeProfila = false);
    }
  }

  void _onNacinPredajePromijenjen(NacinPredaje value) {
    setState(() {
      _nacinPredaje = value;
      if (value == NacinPredaje.preuzimanjeIDostava) {
        _predpopuniAdresu();
      }
    });
  }

  void _predpopuniAdresu() {
    if (_adresaController.text.trim().isNotEmpty) return;

    final adresa = _profilAdresa;
    if (adresa != null && adresa.isNotEmpty) {
      _adresaController.text = adresa;
    }
  }

  bool get _adresaJePredpopunjena {
    final profil = _profilAdresa;
    if (profil == null || profil.isEmpty) return false;
    return _adresaController.text.trim() == profil;
  }

  double get _ukupnoBezPopusta => widget.cart.ukupno;

  double get _popustIznos => _primijenjeniKupon?.popustIznos ?? 0;

  double get _ukupnoZaPlatiti =>
      _primijenjeniKupon?.ukupnoNakonPopusta ?? _ukupnoBezPopusta;

  void _ponistiKupon() {
    setState(() {
      _primijenjeniKupon = null;
      _kuponController.clear();
    });
  }

  Future<void> _primijeniKupon() async {
    final kod = _kuponController.text.trim();
    if (kod.isEmpty) {
      _prikaziGresku('Unesite kod kupona.');
      return;
    }

    setState(() => _provjeraKupona = true);

    try {
      final rezultat = await _kuponService.provjeri(
        kod: kod,
        ukupnaCijena: _ukupnoBezPopusta,
      );

      if (!mounted) return;

      if (!rezultat.vazeci) {
        setState(() {
          _primijenjeniKupon = null;
          _provjeraKupona = false;
        });
        _prikaziGresku(rezultat.poruka ?? 'Kupon nije važeći.');
        return;
      }

      setState(() {
        _primijenjeniKupon = rezultat;
        _provjeraKupona = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _provjeraKupona = false);
      _prikaziGresku('Provjera kupona nije uspjela.');
    }
  }

  Future<void> _potvrdiNarudzbu() async {
    if (widget.cart.isEmpty) {
      _prikaziGresku('Narudžba je prazna.');
      return;
    }

    if (_nacinPredaje == NacinPredaje.preuzimanjeIDostava &&
        _adresaController.text.trim().isEmpty) {
      _prikaziGresku('Unesite adresu za preuzimanje i dostavu.');
      return;
    }

    setState(() => _salje = true);

    try {
      final rezultat = await _narudzbaService.kreirajNarudzbu(
        korisnikId: widget.session.user!.id,
        nacinPredaje: _nacinPredaje,
        stavke: widget.cart.stavke,
        adresa: _nacinPredaje == NacinPredaje.preuzimanjeIDostava
            ? _adresaController.text.trim()
            : null,
        napomena: _napomenaController.text.trim().isEmpty
            ? null
            : _napomenaController.text.trim(),
        kuponKod: _primijenjeniKupon?.kod,
      );

      if (!mounted) return;

      widget.cart.ocisti();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Narudžba poslana'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Broj narudžbe: #${rezultat.id}'),
              Text('Status: ${rezultat.statusNaziv}'),
              if (rezultat.popustIznos > 0) ...[
                Text('Međuzbroj: ${_formatKm(rezultat.ukupnaCijena)}'),
                Text(
                  'Popust (${rezultat.kuponKod}): -${_formatKm(rezultat.popustIznos)}',
                ),
              ],
              Text(
                'Ukupno: ${_formatKm(rezultat.ukupnoZaPlatiti)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(rezultat.poruka),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('U redu'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      if (!mounted) return;
      _prikaziGresku(e.message);
    } catch (_) {
      if (!mounted) return;
      _prikaziGresku('Slanje narudžbe nije uspjelo.');
    } finally {
      if (mounted) setState(() => _salje = false);
    }
  }

  void _prikaziGresku(String poruka) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(poruka)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Potvrda narudžbe')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Način predaje',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          RadioGroup<NacinPredaje>(
            groupValue: _nacinPredaje,
            onChanged: (value) {
              if (_salje || value == null) return;
              _onNacinPredajePromijenjen(value);
            },
            child: Column(
              children: NacinPredaje.values
                  .map(
                    (n) => RadioListTile<NacinPredaje>(
                      value: n,
                      title: Text(n.naziv),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_nacinPredaje == NacinPredaje.preuzimanjeIDostava) ...[
            const SizedBox(height: 16),
            if (_ucitavanjeProfila)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(),
              ),
            TextFormField(
              controller: _adresaController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Adresa preuzimanja i dostave',
                helperText: _adresaJePredpopunjena
                    ? 'Adresa s vašeg profila. Možete je izmijeniti za ovu narudžbu.'
                    : _profilAdresa == null || _profilAdresa!.isEmpty
                        ? 'Nemate adresu u profilu — unesite adresu za ovu narudžbu.'
                        : null,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_salje && !_ucitavanjeProfila,
            ),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _napomenaController,
            decoration: const InputDecoration(
              labelText: 'Napomena za narudžbu (opcionalno)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            enabled: !_salje,
          ),
          const SizedBox(height: 24),
          Text(
            'Kupon za popust',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _kuponController,
                  onChanged: (_) {
                    if (_primijenjeniKupon != null) {
                      setState(() => _primijenjeniKupon = null);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Kod kupona (opcionalno)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_salje && !_provjeraKupona,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: _salje || _provjeraKupona ? null : _primijeniKupon,
                child: Text(_provjeraKupona ? '...' : 'Primijeni'),
              ),
            ],
          ),
          if (_primijenjeniKupon != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _primijenjeniKupon!.poruka ?? 'Kupon primijenjen.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _salje ? null : _ponistiKupon,
                  child: const Text('Ukloni'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildCijenaRed('Međuzbroj', _ukupnoBezPopusta),
          if (_popustIznos > 0) ...[
            const SizedBox(height: 8),
            _buildCijenaRed(
              'Popust',
              -_popustIznos,
              boja: Theme.of(context).colorScheme.error,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ukupno za platiti',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _formatKm(_ukupnoZaPlatiti),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _salje ? null : _potvrdiNarudzbu,
            child: Text(_salje ? 'Slanje...' : 'Potvrdi narudžbu'),
          ),
        ],
      ),
    );
  }

  String _formatKm(double value) {
    final apsolutna = value.abs();
    final tekst = apsolutna == apsolutna.roundToDouble()
        ? '${apsolutna.toInt()} KM'
        : '${apsolutna.toStringAsFixed(2)} KM';
    return value < 0 ? '-$tekst' : tekst;
  }

  Widget _buildCijenaRed(String label, double iznos, {Color? boja}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          _formatKm(iznos),
          style: boja != null ? TextStyle(color: boja) : null,
        ),
      ],
    );
  }
}
