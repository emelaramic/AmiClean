import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class KorisnikKontaktTab extends StatelessWidget {
  const KorisnikKontaktTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AmiCleanColors.pageBackground),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kontakt',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AmiCleanColors.darkBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Javite nam se za pitanja o narudžbi, cijenama ili preuzimanju.',
              style: TextStyle(color: AmiCleanColors.mediumBlue),
            ),
            const SizedBox(height: 20),
            const _KontaktTile(
              icon: Icons.phone_outlined,
              label: 'Telefon',
              value: '+387 61 566 715',
            ),
            const SizedBox(height: 10),
            const _KontaktTile(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: 'amiclean@gmail.com',
            ),
            const SizedBox(height: 10),
            const _KontaktTile(
              icon: Icons.location_on_outlined,
              label: 'Adresa',
              value: 'Varda T18',
            ),
            const SizedBox(height: 10),
            const _KontaktTile(
              icon: Icons.schedule_outlined,
              label: 'Radno vrijeme',
              value: 'Pon – Pet: 08:30 – 16:30\nSub: 09:00 – 13:00',
            ),
          ],
        ),
      ),
    );
  }
}

class _KontaktTile extends StatelessWidget {
  const _KontaktTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AmiCleanColors.mediumBlue),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AmiCleanColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    height: 1.4,
                    color: AmiCleanColors.darkBlue.withValues(alpha: 0.85),
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
