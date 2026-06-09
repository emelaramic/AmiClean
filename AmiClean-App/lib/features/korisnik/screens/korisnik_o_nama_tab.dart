import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class KorisnikONamaTab extends StatelessWidget {
  const KorisnikONamaTab({super.key});

  static const _desktopBreakpoint = 900.0;

  static const _cards = [
    (
      icon: Icons.verified_outlined,
      title: 'Ko smo mi',
      text:
          'AmiClean je servis za profesionalno pranje tepiha, hemijsko čišćenje odjeće i dubinsko čišćenje namještaja. Naš cilj je jednostavna narudžba, jasan cjenovnik i pouzdana usluga.',
    ),
    (
      icon: Icons.schedule_outlined,
      title: 'Kako radimo',
      text:
          'Kreirate narudžbu u aplikaciji, donesete ili dogovorimo preuzimanje, a status pratite u stvarnom vremenu dok ne preuzmete gotov predmet.',
    ),
    (
      icon: Icons.eco_outlined,
      title: 'Zašto mi',
      text:
          'Koristimo provjerene postupke čišćenja, transparentne cijene i jasnu komunikaciju kroz cijeli proces.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AmiCleanColors.pageBackground),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'O AmiClean-u',
                  textAlign: isDesktop ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AmiCleanColors.darkBlue,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 24),
                if (isDesktop)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < _cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 16),
                          Expanded(
                            child: _InfoCard(
                              icon: _cards[i].icon,
                              title: _cards[i].title,
                              text: _cards[i].text,
                              columnLayout: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ...List.generate(_cards.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _cards.length - 1 ? 12 : 0,
                      ),
                      child: _InfoCard(
                        icon: _cards[index].icon,
                        title: _cards[index].title,
                        text: _cards[index].text,
                        columnLayout: false,
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.columnLayout,
  });

  final IconData icon;
  final String title;
  final String text;
  final bool columnLayout;

  @override
  Widget build(BuildContext context) {
    if (columnLayout) {
      return _DesktopColumnCard(
        icon: icon,
        title: title,
        text: text,
      );
    }

    return _MobileCard(
      icon: icon,
      title: title,
      text: text,
    );
  }
}

class _DesktopColumnCard extends StatelessWidget {
  const _DesktopColumnCard({
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AmiCleanColors.loginCard,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              icon,
              size: 88,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.5,
                    fontSize: 14,
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

class _MobileCard extends StatelessWidget {
  const _MobileCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AmiCleanColors.mediumBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AmiCleanColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              height: 1.45,
              color: AmiCleanColors.darkBlue.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
