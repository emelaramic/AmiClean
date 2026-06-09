import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class KorisnikUslugeTab extends StatelessWidget {
  const KorisnikUslugeTab({super.key, required this.onNovaNarudzba});

  final VoidCallback onNovaNarudzba;

  static const _usluge = [
    (
      icon: Icons.dry_cleaning_outlined,
      title: 'Hemijsko čišćenje',
      text: 'Odijela, jakne, haljine i osjetljiva odjeća.',
    ),
    (
      icon: Icons.local_laundry_service_outlined,
      title: 'Pranje',
      text: 'Odjeća, posteljina i tekstil po komadu ili m².',
    ),
    (
      icon: Icons.iron_outlined,
      title: 'Peglanje',
      text: 'Uredno peglanje uz pranje ili samostalno.',
    ),
    (
      icon: Icons.weekend_outlined,
      title: 'Dubinsko čišćenje',
      text: 'Namještaj, madraci, tepisi i uglovi.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AmiCleanColors.pageBackground),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Naše usluge',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AmiCleanColors.darkBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Odaberite kategoriju i artikle prilikom kreiranja narudžbe.',
              style: TextStyle(color: AmiCleanColors.mediumBlue),
            ),
            const SizedBox(height: 20),
            ..._usluge.map(
              (u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UslugaCard(
                  icon: u.icon,
                  title: u.title,
                  text: u.text,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onNovaNarudzba,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: const Text('Kreiraj narudžbu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UslugaCard extends StatelessWidget {
  const _UslugaCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AmiCleanColors.lightBlue,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AmiCleanColors.lightBlue,
            child: Icon(icon, color: AmiCleanColors.darkBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AmiCleanColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    height: 1.35,
                    color: AmiCleanColors.darkBlue.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
