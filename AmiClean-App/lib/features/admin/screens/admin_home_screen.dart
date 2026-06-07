import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import 'admin_cjenovnik_screen.dart';
import 'admin_narudzbe_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    final user = session.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AmiClean Admin'),
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
                Icons.admin_panel_settings_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Admin: ${user.punoIme}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Uloga: ${user.ulogaZaposlenika ?? 'Administrator'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AdminNarudzbeScreen(session: session),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Pregled narudžbi'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminCjenovnikScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.price_change_outlined),
                label: const Text('Cjenovnik'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
