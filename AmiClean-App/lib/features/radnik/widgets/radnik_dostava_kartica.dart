import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';
import '../models/radnik_dostava.dart';

class RadnikDostavaKartica extends StatelessWidget {
  const RadnikDostavaKartica({
    super.key,
    required this.dostava,
    this.onSkeniraj,
  });

  final RadnikDostava dostava;
  final VoidCallback? onSkeniraj;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = dostava.jeUToku
        ? const Color(0xFF1565C0)
        : const Color(0xFF2E7D32);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Narudžba #${dostava.narudzbaId}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AmiCleanColors.darkBlue,
                    ),
                  ),
                ),
                _StatusChip(
                  label: dostava.logistikaStatusNaziv,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dostava.korisnikPunoIme,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dostava.korisnikTelefon != null &&
                dostava.korisnikTelefon!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dostava.korisnikTelefon!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dostava.adresaDostave,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${dostava.brojStavki} stavki',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (dostava.jeUToku && dostava.vozacPunoIme != null) ...[
              const SizedBox(height: 4),
              Text(
                dostava.jeMojaDostava
                    ? 'Vi ste na dostavi'
                    : 'Vozač: ${dostava.vozacPunoIme}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (onSkeniraj != null) ...[
              const SizedBox(height: 14),
              FilledButton.tonalIcon(
                onPressed: onSkeniraj,
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: Text(
                  dostava.mozePokrenuti ? 'Skeniraj i kreni' : 'Skeniraj oznaku',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
