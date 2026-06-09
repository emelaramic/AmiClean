import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class KorisnikPocetnaTab extends StatelessWidget {
  const KorisnikPocetnaTab({
    super.key,
    required this.imeKorisnika,
    required this.onNovaNarudzba,
    required this.onMojeNarudzbe,
    required this.onProfil,
  });

  final String imeKorisnika;
  final VoidCallback onNovaNarudzba;
  final VoidCallback onMojeNarudzbe;
  final VoidCallback onProfil;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AmiCleanColors.pageBackground),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Dobrodošli, $imeKorisnika!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AmiCleanColors.darkBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profesionalno pranje tepiha, hemijsko čišćenje odjeće i tretman namještaja — brzo i pouzdano.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AmiCleanColors.mediumBlue,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 32),
            _HeroCard(onNovaNarudzba: onNovaNarudzba),
            const SizedBox(height: 24),
            Text(
              'Brzi pristup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AmiCleanColors.darkBlue,
                  ),
            ),
            const SizedBox(height: 12),
            _QuickTile(
              icon: Icons.receipt_long_outlined,
              title: 'Moje narudžbe',
              subtitle: 'Pratite status vaših narudžbi',
              onTap: onMojeNarudzbe,
            ),
            const SizedBox(height: 8),
            _QuickTile(
              icon: Icons.person_outline,
              title: 'Moj profil',
              subtitle: 'Telefon i adresa za dostavu',
              onTap: onProfil,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onNovaNarudzba});

  final VoidCallback onNovaNarudzba;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AmiCleanColors.loginCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zakažite čišćenje danas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Odaberite artikle, usluge i način predaje — mi se brinemo za ostalo.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onNovaNarudzba,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AmiCleanColors.darkBlue,
            ),
            child: const Text('Kreni s narudžbom'),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AmiCleanColors.mediumBlue, size: 28),
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
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AmiCleanColors.mediumBlue.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AmiCleanColors.mediumBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
