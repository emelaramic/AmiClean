import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
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
  final _adresaController = TextEditingController();
  final _napomenaController = TextEditingController();

  NacinPredaje _nacinPredaje = NacinPredaje.donosUCistionicu;
  bool _salje = false;

  @override
  void dispose() {
    _adresaController.dispose();
    _napomenaController.dispose();
    _apiClient.dispose();
    super.dispose();
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
              Text('Ukupno: ${_formatKm(rezultat.ukupnaCijena)}'),
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
              setState(() => _nacinPredaje = value);
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
            TextFormField(
              controller: _adresaController,
              decoration: const InputDecoration(
                labelText: 'Adresa preuzimanja i dostave',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !_salje,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ukupno'),
              Text(
                _formatKm(widget.cart.ukupno),
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
    if (value == value.roundToDouble()) {
      return '${value.toInt()} KM';
    }
    return '${value.toStringAsFixed(2)} KM';
  }
}
