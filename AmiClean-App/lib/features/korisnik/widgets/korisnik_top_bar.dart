import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

/// Gornja navigacija korisničkog dijela — inspirisana web mockupom, prilagođena mobilnom.
class KorisnikTopBar extends StatelessWidget {
  const KorisnikTopBar({
    super.key,
    required this.selectedIndex,
    required this.onNavSelected,
    required this.cartCount,
    required this.onNarudzba,
    required this.onCart,
    this.onMenuTap,
    this.onMojeNarudzbe,
    this.onProfil,
    this.onLogout,
  });

  static const navLabels = [
    'Početna',
    'O nama',
    'Usluge',
    'Cjenovnik',
    'Kontakt',
  ];

  final int selectedIndex;
  final ValueChanged<int> onNavSelected;
  final int cartCount;
  final VoidCallback onNarudzba;
  final VoidCallback onCart;
  final VoidCallback? onMenuTap;
  final VoidCallback? onMojeNarudzbe;
  final VoidCallback? onProfil;
  final VoidCallback? onLogout;

  static const _compactBreakpoint = 720.0;
  static const _tightNavBreakpoint = 1080.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < _compactBreakpoint;
    final tightNav = !compact && width < _tightNavBreakpoint;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.12),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _Logo(compact: compact || tightNav),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _DesktopNav(
                    selectedIndex: selectedIndex,
                    onNavSelected: onNavSelected,
                    tight: tightNav,
                  ),
                ),
              ] else
                const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NarudzbaButton(
                    compact: compact || tightNav,
                    onPressed: onNarudzba,
                  ),
                  _CartButton(count: cartCount, onPressed: onCart),
                  if (!compact &&
                      onMojeNarudzbe != null &&
                      onProfil != null &&
                      onLogout != null)
                    _AccountMenu(
                      onMojeNarudzbe: onMojeNarudzbe!,
                      onProfil: onProfil!,
                      onLogout: onLogout!,
                    ),
                  if (compact)
                    IconButton(
                      onPressed: onMenuTap,
                      icon: const Icon(Icons.menu_rounded),
                      tooltip: 'Meni',
                      color: AmiCleanColors.darkBlue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/app_icon_round.png',
            width: compact ? 32 : 36,
            height: compact ? 32 : 36,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AmiClean',
          style: TextStyle(
            color: AmiCleanColors.darkBlue,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _DesktopNav extends StatelessWidget {
  const _DesktopNav({
    required this.selectedIndex,
    required this.onNavSelected,
    required this.tight,
  });

  final int selectedIndex;
  final ValueChanged<int> onNavSelected;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final buttons = List.generate(KorisnikTopBar.navLabels.length, (index) {
      final selected = index == selectedIndex;
      return TextButton(
        onPressed: () => onNavSelected(index),
        style: TextButton.styleFrom(
          foregroundColor: selected
              ? AmiCleanColors.darkBlue
              : const Color(0xFF4A5568),
          padding: EdgeInsets.symmetric(
            horizontal: tight ? 10 : 20,
            vertical: 10,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          KorisnikTopBar.navLabels[index],
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: tight ? 13 : 15,
            letterSpacing: 0.2,
            decoration: selected ? TextDecoration.underline : null,
            decorationColor: AmiCleanColors.mediumBlue,
            decorationThickness: 2,
          ),
        ),
      );
    });

    if (tight) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: buttons),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

class _NarudzbaButton extends StatelessWidget {
  const _NarudzbaButton({
    required this.compact,
    required this.onPressed,
  });

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AmiCleanColors.darkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Narudžba',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AmiCleanColors.darkBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: const Text(
        'Narudžba',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  const _AccountMenu({
    required this.onMojeNarudzbe,
    required this.onProfil,
    required this.onLogout,
  });

  final VoidCallback onMojeNarudzbe;
  final VoidCallback onProfil;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Nalog',
      icon: const Icon(Icons.person_outline, color: AmiCleanColors.darkBlue),
      onSelected: (action) => switch (action) {
        _AccountAction.narudzbe => onMojeNarudzbe(),
        _AccountAction.profil => onProfil(),
        _AccountAction.odjava => onLogout(),
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _AccountAction.narudzbe,
          child: ListTile(
            leading: Icon(Icons.receipt_long_outlined),
            title: Text('Moje narudžbe'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.profil,
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Moj profil'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _AccountAction.odjava,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Odjava'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _AccountAction { narudzbe, profil, odjava }

class _CartButton extends StatelessWidget {
  const _CartButton({
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: 'Košarica',
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: AmiCleanColors.darkBlue,
        ),
      ),
    );
  }
}

/// Mobilni bočni meni — navigacija + korisničke stavke.
class KorisnikNavDrawer extends StatelessWidget {
  const KorisnikNavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onNavSelected,
    required this.onMojeNarudzbe,
    required this.onProfil,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onNavSelected;
  final VoidCallback onMojeNarudzbe;
  final VoidCallback onProfil;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_icon_round.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AmiClean',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AmiCleanColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            ...List.generate(KorisnikTopBar.navLabels.length, (index) {
              final selected = index == selectedIndex;
              return ListTile(
                selected: selected,
                selectedTileColor:
                    AmiCleanColors.lightBlue.withValues(alpha: 0.45),
                leading: Icon(
                  _navIcon(index),
                  color: selected
                      ? AmiCleanColors.darkBlue
                      : AmiCleanColors.mediumBlue,
                ),
                title: Text(
                  KorisnikTopBar.navLabels[index],
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AmiCleanColors.darkBlue,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onNavSelected(index);
                },
              );
            }),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Moje narudžbe'),
              onTap: () {
                Navigator.of(context).pop();
                onMojeNarudzbe();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Moj profil'),
              onTap: () {
                Navigator.of(context).pop();
                onProfil();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Odjava'),
              onTap: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static IconData _navIcon(int index) => switch (index) {
        0 => Icons.home_outlined,
        1 => Icons.info_outline,
        2 => Icons.cleaning_services_outlined,
        3 => Icons.price_check_outlined,
        4 => Icons.contact_mail_outlined,
        _ => Icons.circle_outlined,
      };
}
