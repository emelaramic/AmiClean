import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';

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
              const SizedBox(height: 16),
              Text(
                'Admin panel — ovdje će biti pregled svih narudžbi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
