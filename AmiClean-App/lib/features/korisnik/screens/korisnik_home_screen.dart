import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../../auth/services/korisnik_service.dart';
import '../../katalog/screens/katalog_screen.dart';
import '../../narudzba/screens/kosarica_screen.dart';
import '../../narudzba/screens/moje_narudzbe_screen.dart';
import '../../narudzba/screens/nova_narudzba_screen.dart';
import 'moj_profil_screen.dart';

class KorisnikHomeScreen extends StatelessWidget {
  const KorisnikHomeScreen({
    super.key,
    required this.session,
    required this.cart,
    required this.korisnikService,
  });

  final AuthSession session;
  final CartSession cart;
  final KorisnikService korisnikService;

  @override
  Widget build(BuildContext context) {
    final user = session.user!;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AmiClean'),
            actions: [
              if (cart.brojStavki > 0)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => KosaricaScreen(
                          cart: cart,
                          session: session,
                        ),
                      ),
                    );
                  },
                  icon: Badge(
                    label: Text('${cart.brojStavki}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  tooltip: 'Pregled narudžbe',
                ),
              IconButton(
                onPressed: session.logout,
                icon: const Icon(Icons.logout),
                tooltip: 'Odjava',
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dobrodošli, ${user.punoIme}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pregledajte cjenovnik ili kreirajte narudžbu.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NovaNarudzbaScreen(
                            cart: cart,
                            session: session,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Nova narudžba'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MojeNarudzbeScreen(session: session),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Moje narudžbe'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MojProfilScreen(
                            session: session,
                            korisnikService: korisnikService,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Moj profil'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const KatalogScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.price_check_outlined),
                    label: const Text('Cjenovnik'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
