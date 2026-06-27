import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const Spacer(),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AmiCleanColors.darkBlue,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AmiCleanColors.slateBlue.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
