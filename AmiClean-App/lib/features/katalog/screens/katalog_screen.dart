import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/artikal_katalog.dart';
import '../services/catalog_service.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _apiClient = ApiClient();
  late final _catalogService = CatalogService(apiClient: _apiClient);

  List<String> _kategorije = [];
  List<ArtikalKatalog> _artikli = [];
  String? _odabranaKategorija;
  ArtikalKatalog? _odabraniArtikal;
  bool _loading = true;
  String? _greska;

  @override
  void initState() {
    super.initState();
    _ucitajKatalog();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajKatalog() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final results = await Future.wait([
        _catalogService.getKategorije(),
        _catalogService.getKatalog(),
      ]);

      if (!mounted) return;

      setState(() {
        _kategorije = results[0] as List<String>;
        _artikli = results[1] as List<ArtikalKatalog>;
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
        _greska = 'Neuspješno učitavanje cjenovnika.';
        _loading = false;
      });
    }
  }

  List<ArtikalKatalog> get _artikliZaKategoriju {
    if (_odabranaKategorija == null) return [];
    return _artikli
        .where((a) => a.kategorija == _odabranaKategorija)
        .toList()
      ..sort((a, b) => a.naziv.compareTo(b.naziv));
  }

  void _onKategorijaChanged(String? kategorija) {
    setState(() {
      _odabranaKategorija = kategorija;
      _odabraniArtikal = null;
    });
  }

  void _onArtikalChanged(ArtikalKatalog? artikal) {
    setState(() => _odabraniArtikal = artikal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cjenovnik'),
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
                onPressed: _ucitajKatalog,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _odabranaKategorija,
          decoration: const InputDecoration(
            labelText: 'Kategorija',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Odaberite kategoriju'),
          items: _kategorije
              .map(
                (k) => DropdownMenuItem(value: k, child: Text(k)),
              )
              .toList(),
          onChanged: _onKategorijaChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ArtikalKatalog>(
          initialValue: _odabraniArtikal,
          decoration: const InputDecoration(
            labelText: 'Artikal',
            border: OutlineInputBorder(),
          ),
          hint: Text(
            _odabranaKategorija == null
                ? 'Prvo odaberite kategoriju'
                : 'Odaberite artikal',
          ),
          items: _artikliZaKategoriju
              .map(
                (a) => DropdownMenuItem(value: a, child: Text(a.naziv)),
              )
              .toList(),
          onChanged:
              _odabranaKategorija == null ? null : _onArtikalChanged,
        ),
        if (_odabraniArtikal?.opis != null) ...[
          const SizedBox(height: 8),
          Text(
            _odabraniArtikal!.opis!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: 24),
        if (_odabraniArtikal != null) _buildUsluge(_odabraniArtikal!),
      ],
    );
  }

  Widget _buildUsluge(ArtikalKatalog artikal) {
    if (artikal.usluge.isEmpty) {
      return const Text('Za ovaj artikal nema definisanih usluga u cjenovniku.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dostupne usluge',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...artikal.usluge.map(_buildUslugaTile),
      ],
    );
  }

  Widget _buildUslugaTile(UslugaCijena usluga) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(usluga.uslugaNaziv),
        trailing: Text(
          usluga.cijenaTekst,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: usluga.cijenaOpis == null
            ? null
            : Text(usluga.cijenaOpis!),
      ),
    );
  }
}
