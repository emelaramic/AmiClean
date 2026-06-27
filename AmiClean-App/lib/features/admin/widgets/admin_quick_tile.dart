import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class AdminQuickTile extends StatelessWidget {
  const AdminQuickTile({
    super.key,
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
