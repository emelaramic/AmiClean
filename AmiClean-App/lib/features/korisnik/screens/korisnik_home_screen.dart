import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../katalog/screens/katalog_screen.dart';

class KorisnikHomeScreen extends StatelessWidget {
  const KorisnikHomeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final user = session.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AmiClean'),
        actions: [
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
  }
}
