import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../../auth/services/korisnik_service.dart';
import '../../katalog/screens/katalog_screen.dart';
import '../../notifikacije/screens/notifikacije_screen.dart';
import '../../notifikacije/services/notifikacija_service.dart';
import '../../narudzba/screens/kosarica_screen.dart';
import '../../narudzba/screens/moje_narudzbe_screen.dart';
import '../../narudzba/screens/nova_narudzba_screen.dart';
import '../widgets/korisnik_top_bar.dart';
import 'korisnik_kontakt_tab.dart';
import 'korisnik_o_nama_tab.dart';
import 'korisnik_pocetna_tab.dart';
import 'korisnik_usluge_tab.dart';
import 'moj_profil_screen.dart';

/// Glavni korisnički okvir s gornjom navigacijom i tabovima sadržaja.
class KorisnikShellScreen extends StatefulWidget {
  const KorisnikShellScreen({
    super.key,
    required this.session,
    required this.cart,
    required this.korisnikService,
  });

  final AuthSession session;
  final CartSession cart;
  final KorisnikService korisnikService;

  @override
  State<KorisnikShellScreen> createState() => _KorisnikShellScreenState();
}

class _KorisnikShellScreenState extends State<KorisnikShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _notifikacijaApiClient = ApiClient();
  late final _notifikacijaService =
      NotifikacijaService(apiClient: _notifikacijaApiClient);

  int _selectedIndex = 0;
  int _neprocitaneNotifikacije = 0;

  @override
  void initState() {
    super.initState();
    _ucitajBrojNotifikacija();
  }

  @override
  void dispose() {
    _notifikacijaApiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajBrojNotifikacija() async {
    try {
      final broj = await _notifikacijaService.getBrojNeprocitanih(
        widget.session.user!.id,
      );
      if (mounted) {
        setState(() => _neprocitaneNotifikacije = broj);
      }
    } catch (_) {
      // Badge je opcionalan — ne blokira shell.
    }
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNovaNarudzba({
    String? initialKategorija,
    int? initialArtikalId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NovaNarudzbaScreen(
          cart: widget.cart,
          session: widget.session,
          initialKategorija: initialKategorija,
          initialArtikalId: initialArtikalId,
        ),
      ),
    );
  }

  void _openKosarica() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KosaricaScreen(
          cart: widget.cart,
          session: widget.session,
        ),
      ),
    );
  }

  Future<void> _openNotifikacije() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotifikacijeScreen(session: widget.session),
      ),
    );
    await _ucitajBrojNotifikacija();
  }

  void _openMojeNarudzbe() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MojeNarudzbeScreen(session: widget.session),
      ),
    );
  }

  void _openProfil() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MojProfilScreen(
          session: widget.session,
          korisnikService: widget.korisnikService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user!;

    return ListenableBuilder(
      listenable: widget.cart,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: KorisnikNavDrawer(
            selectedIndex: _selectedIndex,
            onNavSelected: _selectTab,
            onMojeNarudzbe: _openMojeNarudzbe,
            onProfil: _openProfil,
            onLogout: widget.session.logout,
          ),
          body: Column(
            children: [
              KorisnikTopBar(
                selectedIndex: _selectedIndex,
                onNavSelected: _selectTab,
                cartCount: widget.cart.brojStavki,
                notifikacijeCount: _neprocitaneNotifikacije,
                onNarudzba: _openNovaNarudzba,
                onCart: _openKosarica,
                onNotifikacije: _openNotifikacije,
                onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                onMojeNarudzbe: _openMojeNarudzbe,
                onProfil: _openProfil,
                onLogout: widget.session.logout,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    KorisnikPocetnaTab(
                      korisnikId: user.id,
                      imeKorisnika: user.punoIme,
                      onNovaNarudzba: _openNovaNarudzba,
                      onPreporukaNarudzba: ({
                        required kategorija,
                        required artikalId,
                      }) =>
                          _openNovaNarudzba(
                        initialKategorija: kategorija,
                        initialArtikalId: artikalId,
                      ),
                      onMojeNarudzbe: _openMojeNarudzbe,
                      onProfil: _openProfil,
                      onUsluge: () => _selectTab(2),
                      onCjenovnik: () => _selectTab(3),
                    ),
                    const KorisnikONamaTab(),
                    KorisnikUslugeTab(onNovaNarudzba: _openNovaNarudzba),
                    const KatalogScreen(embedded: true),
                    const KorisnikKontaktTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
