import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'stavka_oznaka_parser.dart';

export 'stavka_oznaka_parser.dart';

class StavkaOznakaQr extends StatelessWidget {  const StavkaOznakaQr({
    super.key,
    required this.brojOznake,
    this.qrSize = 112,
    this.prikaziNaslov = true,
  });

  final String brojOznake;
  final double qrSize;
  final bool prikaziNaslov;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QrImageView(
            data: stavkaQrSadrzaj(brojOznake),
            size: qrSize,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prikaziNaslov)
                  Text(
                    'Broj oznake',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (prikaziNaslov) const SizedBox(height: 4),
                Text(
                  brojOznake,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Naljepnica za artikal u radnji.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
