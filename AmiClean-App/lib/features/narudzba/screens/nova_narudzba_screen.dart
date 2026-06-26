import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../../katalog/models/artikal_katalog.dart';
import '../../katalog/services/catalog_service.dart';
import '../../katalog/utils/cijena_display.dart';
import '../../katalog/utils/tepih_katalog.dart';
import '../../katalog/utils/ugao_artikli.dart';
import '../../katalog/widgets/artikal_odabir_panel.dart';
import '../../katalog/widgets/tepih_dimenzije_polja.dart';
import 'kosarica_screen.dart';

class NovaNarudzbaScreen extends StatefulWidget {
  const NovaNarudzbaScreen({
    super.key,
    required this.cart,
    required this.session,
    this.initialKategorija,
    this.initialArtikalId,
  });

  final CartSession cart;
  final AuthSession session;
  final String? initialKategorija;
  final int? initialArtikalId;

  @override
  State<NovaNarudzbaScreen> createState() => _NovaNarudzbaScreenState();
}

class _NovaNarudzbaScreenState extends State<NovaNarudzbaScreen> {
  final _apiClient = ApiClient();
  late final _catalogService = CatalogService(apiClient: _apiClient);
  final _kolicinaController = TextEditingController(text: '1');
  final _duzinaController = TextEditingController();
  final _sirinaController = TextEditingController();
  final _napomenaController = TextEditingController();

  List<String> _kategorije = [];
  List<ArtikalKatalog> _artikli = [];
  String? _odabranaKategorija;
  ArtikalIzbor? _odabraniIzbor;
  String? _odabranaUgaoVarijanta;
  final Set<int> _odabraneUsluge = {};
  bool _loading = true;
  String? _greska;

  ArtikalKatalog? get _rijeseniArtikal => rijeseniArtikal(
        sviArtikli: _artikli,
        izbor: _odabraniIzbor,
        ugaoVarijantaNaziv: _odabranaUgaoVarijanta,
      );

  bool get _isTepih => TepihKatalog.jeTepih(_odabranaKategorija ?? '');

  double? get _povrsinaTepiha => _isTepih
      ? TepihKatalog.povrsina(
          duzina: _duzinaController.text,
          sirina: _sirinaController.text,
        )
      : null;

  double get _trenutnaKolicina {
    if (_isTepih) return _povrsinaTepiha ?? 0;
    return TepihKatalog.parsirajDecimal(_kolicinaController.text) ?? 0;
  }

  double get _trenutnaCijenaStavke {
    final artikal = _rijeseniArtikal;
    if (artikal == null) return 0;
    return izracunajUkupnoStavke(
      artikal: artikal,
      odabraneUslugeIds: _odabraneUsluge,
      kolicina: _trenutnaKolicina,
    );
  }

  @override
  void initState() {
    super.initState();
    _ucitajKatalog();
  }

  @override
  void dispose() {
    _kolicinaController.dispose();
    _duzinaController.dispose();
    _sirinaController.dispose();
    _napomenaController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  void _resetUnosKolicine() {
    _kolicinaController.text = '1';
    _duzinaController.clear();
    _sirinaController.clear();
  }

  void _primijeniPocetniOdabir() {
    final kategorija = widget.initialKategorija;
    final artikalId = widget.initialArtikalId;
    if (kategorija == null && artikalId == null) return;

    setState(() {
      if (kategorija != null && _kategorije.contains(kategorija)) {
        _odabranaKategorija = kategorija;
      }

      if (artikalId != null && _odabranaKategorija != null) {
        final artikal = _pronadjiArtikal(artikalId);
        if (artikal == null || artikal.kategorija != _odabranaKategorija) {
          return;
        }

        if (UgaoArtikli.jeVarijanta(artikal.naziv)) {
          _odabraniIzbor = ArtikalIzborUgao();
          _odabranaUgaoVarijanta = artikal.naziv;
        } else {
          _odabraniIzbor = ArtikalIzborObicni(artikal);
          _odabranaUgaoVarijanta = null;
        }
      }
    });
  }

  ArtikalKatalog? _pronadjiArtikal(int artikalId) {
    for (final artikal in _artikli) {
      if (artikal.id == artikalId) return artikal;
    }
    return null;
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
      _primijeniPocetniOdabir();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Neuspješno učitavanje kataloga.';
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
      _odabraneUsluge.clear();
      _resetUnosKolicine();
    });
  }

  void _dodajUKosaricu() {
    final artikal = _rijeseniArtikal;
    if (artikal == null) {
      if (_odabraniIzbor is ArtikalIzborUgao) {
        _prikaziGresku('Odaberite manji ili veliki ugao.');
      } else {
        _prikaziGresku('Odaberite artikal.');
      }
      return;
    }

    if (_odabraneUsluge.isEmpty) {
      _prikaziGresku('Odaberite barem jednu uslugu.');
      return;
    }

    final kolicina = _trenutnaKolicina;
    if (kolicina <= 0) {
      if (_isTepih) {
        _prikaziGresku('Unesite ispravnu dužinu i širinu tepiha.');
      } else {
        _prikaziGresku('Unesite ispravnu količinu.');
      }
      return;
    }

    if (!_isTepih && kolicina != kolicina.roundToDouble()) {
      _prikaziGresku('Za ovaj artikal unesite cijeli broj komada.');
      return;
    }

    final usluge = artikal.usluge
        .where((u) => _odabraneUsluge.contains(u.uslugaId))
        .toList();

    widget.cart.dodajStavku(
      artikal: artikal,
      odabraneUsluge: usluge,
      kolicina: kolicina,
      napomena: _napomenaController.text.trim().isEmpty
          ? null
          : _napomenaController.text.trim(),
    );

    setState(() {
      _odabraneUsluge.clear();
      _resetUnosKolicine();
      _napomenaController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${artikal.naziv} dodan u narudžbu.')),
    );
  }

  void _prikaziGresku(String poruka) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(poruka)),
    );
  }

  void _otvoriKosaricu() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KosaricaScreen(cart: widget.cart, session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.cart,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nova narudžba'),
            actions: [
              if (widget.cart.brojStavki > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _otvoriKosaricu,
                    icon: Badge(
                      label: Text('${widget.cart.brojStavki}'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    label: Text(CijenaDisplay.km(widget.cart.ukupno)),
                  ),
                ),
            ],
          ),
          body: _buildBody(),
        );
      },
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

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _odabranaKategorija,
              decoration: const InputDecoration(
                labelText: 'Kategorija',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Odaberite kategoriju'),
              items: _kategorije
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: _onKategorijaChanged,
            ),
        const SizedBox(height: 16),
        if (_odabranaKategorija != null)
          ArtikalOdabirPanel(
            artikliZaKategoriju: _artikliZaKategoriju,
            sviArtikli: _artikli,
            odabraniIzbor: _odabraniIzbor,
            odabranaUgaoVarijanta: _odabranaUgaoVarijanta,
            kategorija: _odabranaKategorija!,
            onIzborChanged: (ArtikalIzbor? izbor) => setState(() {
              _odabraniIzbor = izbor;
              _odabraneUsluge.clear();
              _resetUnosKolicine();
            }),
            onUgaoVarijantaChanged: (String? v) => setState(() {
              _odabranaUgaoVarijanta = v;
              _odabraneUsluge.clear();
            }),
            uslugeBuilder: (artikal) => _buildStavkaUnos(artikal),
          ),
            if (widget.cart.brojStavki > 0) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _otvoriKosaricu,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  'Pregled narudžbe (${widget.cart.brojStavki} stavki)',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStavkaUnos(ArtikalKatalog artikal) {
    final jeTepih = TepihKatalog.jeTepih(artikal.kategorija);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Usluge', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...artikal.usluge.map((u) => _buildUslugaCheckbox(u, artikal.kategorija)),
        const SizedBox(height: 16),
        if (jeTepih)
          TepihDimenzijePolja(
            duzinaController: _duzinaController,
            sirinaController: _sirinaController,
            onChanged: () => setState(() {}),
          )
        else
          TextFormField(
            controller: _kolicinaController,
            decoration: const InputDecoration(
              labelText: 'Količina (kom)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(cijeliBrojRegex),
            ],
            onChanged: (_) => setState(() {}),
          ),
        const SizedBox(height: 16),
        StavkaCijenaPreview(
          ukupno: _trenutnaCijenaStavke,
          povrsinaM2: _povrsinaTepiha,
          jeTepih: jeTepih,
          imaOdabraneUsluge: _odabraneUsluge.isNotEmpty,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _napomenaController,
          decoration: const InputDecoration(
            labelText: 'Napomena (opcionalno)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _dodajUKosaricu,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Dodaj u narudžbu'),
        ),
      ],
    );
  }

  Widget _buildUslugaCheckbox(UslugaCijena usluga, String kategorija) {
    return CheckboxListTile(
      value: _odabraneUsluge.contains(usluga.uslugaId),
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _odabraneUsluge.add(usluga.uslugaId);
          } else {
            _odabraneUsluge.remove(usluga.uslugaId);
          }
        });
      },
      title: Text(usluga.uslugaNaziv),
      secondary: cijenaUslugeWidget(usluga, kategorija: kategorija),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

