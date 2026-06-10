import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class KorisnikPocetnaTab extends StatelessWidget {
  const KorisnikPocetnaTab({
    super.key,
    required this.imeKorisnika,
    required this.onNovaNarudzba,
    required this.onMojeNarudzbe,
    required this.onProfil,
    required this.onUsluge,
    required this.onCjenovnik,
  });

  final String imeKorisnika;
  final VoidCallback onNovaNarudzba;
  final VoidCallback onMojeNarudzbe;
  final VoidCallback onProfil;
  final VoidCallback onUsluge;
  final VoidCallback onCjenovnik;

  static const _desktopBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AmiCleanColors.mistBlue,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(
              imeKorisnika: imeKorisnika,
              onNovaNarudzba: onNovaNarudzba,
              onUsluge: onUsluge,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brzi pristup',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AmiCleanColors.darkBlue,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _QuickTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Moje narudžbe',
                    subtitle: 'Pratite status vaših narudžbi',
                    onTap: onMojeNarudzbe,
                  ),
                  const SizedBox(height: 10),
                  _QuickTile(
                    icon: Icons.price_check_outlined,
                    title: 'Cjenovnik',
                    subtitle: 'Pregledajte cijene usluga',
                    onTap: onCjenovnik,
                  ),
                  const SizedBox(height: 10),
                  _QuickTile(
                    icon: Icons.person_outline,
                    title: 'Moj profil',
                    subtitle: 'Telefon i adresa za dostavu',
                    onTap: onProfil,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.imeKorisnika,
    required this.onNovaNarudzba,
    required this.onUsluge,
  });

  final String imeKorisnika;
  final VoidCallback onNovaNarudzba;
  final VoidCallback onUsluge;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= KorisnikPocetnaTab._desktopBreakpoint;

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/pocetna_pozadina.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 40 : 20,
          isDesktop ? 40 : 28,
          isDesktop ? 40 : 20,
          isDesktop ? 48 : 32,
        ),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _HeroContent(
                      imeKorisnika: imeKorisnika,
                      onNovaNarudzba: onNovaNarudzba,
                      onUsluge: onUsluge,
                    ),
                  ),
                  const SizedBox(width: 28),
                  const Expanded(
                    child: _ServiceImageGrid(compact: false),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroContent(
                    imeKorisnika: imeKorisnika,
                    onNovaNarudzba: onNovaNarudzba,
                    onUsluge: onUsluge,
                  ),
                  const SizedBox(height: 24),
                  const _ServiceImageGrid(compact: true),
                ],
              ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.imeKorisnika,
    required this.onNovaNarudzba,
    required this.onUsluge,
  });

  final String imeKorisnika;
  final VoidCallback onNovaNarudzba;
  final VoidCallback onUsluge;

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery.sizeOf(context).width >= KorisnikPocetnaTab._desktopBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 20 : 16,
            vertical: isWide ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AmiCleanColors.darkBlue.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.waving_hand_outlined,
                size: isWide ? 20 : 18,
                color: AmiCleanColors.slateBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Dobrodošli, $imeKorisnika',
                style: TextStyle(
                  color: AmiCleanColors.darkBlue,
                  fontSize: isWide ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isWide ? 24 : 20),
        Text(
          'Mašinsko pranje tepiha, hemijsko čišćenje odjeće, pranje posteljine, '
          'te dubinsko čišćenje namještaja. Sve na jednom mjestu, s jasnim '
          'cijenama i praćenjem narudžbe.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.85),
            fontSize: isWide ? 20 : 17,
            height: 1.6,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
        ),
        SizedBox(height: isWide ? 32 : 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: [
            _HeroSecondaryButton(
              label: 'Pogledaj usluge',
              icon: Icons.arrow_forward_rounded,
              onPressed: onUsluge,
              compact: !isWide,
            ),
            _HeroPrimaryButton(
              label: 'Kreiraj narudžbu',
              icon: Icons.add_shopping_cart_outlined,
              onPressed: onNovaNarudzba,
              compact: !isWide,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPrimaryButton extends StatelessWidget {
  const _HeroPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AmiCleanColors.heroBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 22 : 28,
              vertical: compact ? 15 : 17,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: compact ? 20 : 22),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 15 : 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSecondaryButton extends StatelessWidget {
  const _HeroSecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 22 : 28,
              vertical: compact ? 15 : 17,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AmiCleanColors.darkBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 15 : 16,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: AmiCleanColors.mediumBlue,
                  size: compact ? 20 : 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceImageGrid extends StatelessWidget {
  const _ServiceImageGrid({required this.compact});

  final bool compact;

  static const _services = [
    'assets/images/services/service_pranje.png',
    'assets/images/services/service_namjestaj.png',
    'assets/images/services/service_tepisi.png',
    'assets/images/services/service_odjeca.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: compact ? 0.92 : 0.88,
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: compact ? 10 : 12,
          crossAxisSpacing: compact ? 10 : 12,
          childAspectRatio: compact ? 0.95 : 1.0,
          children: _services.map((asset) {
            return _ServiceCard(asset: asset);
          }).toList(),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
        ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AmiCleanColors.mistBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AmiCleanColors.slateBlue, size: 24),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AmiCleanColors.slateBlue.withValues(alpha: 0.9),
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
