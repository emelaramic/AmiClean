import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../../katalog/models/artikal_katalog.dart';
import '../../katalog/services/catalog_service.dart';
import '../../katalog/utils/ugao_artikli.dart';
import '../../katalog/widgets/artikal_odabir_panel.dart';
import '../../katalog/widgets/tepih_dimenzije_polja.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key, this.embedded = false});

  /// Kad je ugrađen u [KorisnikShellScreen], ne prikazuje vlastiti AppBar.
  final bool embedded;

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _apiClient = ApiClient();
  late final _catalogService = CatalogService(apiClient: _apiClient);

  List<String> _kategorije = [];
  List<ArtikalKatalog> _artikli = [];
  String? _odabranaKategorija;
  ArtikalIzbor? _odabraniIzbor;
  String? _odabranaUgaoVarijanta;
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
      _odabraniIzbor = null;
      _odabranaUgaoVarijanta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (widget.embedded) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AmiCleanColors.pageBackground,
        ),
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cjenovnik'),
      ),
      body: body,
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
        if (_odabranaKategorija != null) ...[
          const SizedBox(height: 16),
          ArtikalOdabirPanel(
            artikliZaKategoriju: _artikliZaKategoriju,
            sviArtikli: _artikli,
            odabraniIzbor: _odabraniIzbor,
            odabranaUgaoVarijanta: _odabranaUgaoVarijanta,
            kategorija: _odabranaKategorija,
            onIzborChanged: (ArtikalIzbor? izbor) =>
                setState(() => _odabraniIzbor = izbor),
            onUgaoVarijantaChanged: (String? v) =>
                setState(() => _odabranaUgaoVarijanta = v),
            uslugeBuilder: _buildUsluge,
          ),
        ],
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
        ...artikal.usluge.map((u) => _buildUslugaTile(u, artikal.kategorija)),
      ],
    );
  }

  Widget _buildUslugaTile(UslugaCijena usluga, String kategorija) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(usluga.uslugaNaziv),
        trailing: cijenaUslugeWidget(usluga, kategorija: kategorija),
      ),
    );
  }
}
