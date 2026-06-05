import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';
import '../../../core/theme/amiclean_text_styles.dart';

/// Zajednički auth layout: gradient, avatar preklapa plavu karticu, AmiClean naslov.
class AuthBrandLayout extends StatelessWidget {
  const AuthBrandLayout({
    super.key,
    required this.child,
    this.avatarIcon = Icons.person_outline,
    this.subtitle,
    this.leading,
  });

  final Widget child;
  final IconData avatarIcon;
  final String? subtitle;
  final Widget? leading;

  static const _avatarSize = 88.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AmiCleanColors.pageBackground,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (leading != null)
                Positioned(
                  top: 4,
                  left: 8,
                  child: leading!,
                ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: _avatarSize / 2),
                          child: _AuthCard(
                            avatarSize: _avatarSize,
                            subtitle: subtitle,
                            child: child,
                          ),
                        ),
                        _AuthAvatar(
                          size: _avatarSize,
                          icon: avatarIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthAvatar extends StatelessWidget {
  const _AuthAvatar({required this.size, required this.icon});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AmiCleanColors.darkBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.avatarSize,
    required this.child,
    this.subtitle,
  });

  final double avatarSize;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AmiCleanColors.loginCard,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AmiCleanColors.darkBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          avatarSize / 2 + 16,
          24,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'AmiClean',
              textAlign: TextAlign.center,
              style: AmiCleanTextStyles.brandTitle(),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AmiCleanTextStyles.brandSubtitle(),
              ),
            ],
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
