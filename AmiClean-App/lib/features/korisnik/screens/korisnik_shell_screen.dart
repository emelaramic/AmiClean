import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../../auth/services/korisnik_service.dart';
import '../../katalog/screens/katalog_screen.dart';
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
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNovaNarudzba() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NovaNarudzbaScreen(
          cart: widget.cart,
          session: widget.session,
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
                onNarudzba: _openNovaNarudzba,
                onCart: _openKosarica,
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
                      imeKorisnika: user.punoIme,
                      onNovaNarudzba: _openNovaNarudzba,
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
