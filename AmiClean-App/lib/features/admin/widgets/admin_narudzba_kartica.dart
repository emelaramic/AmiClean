import 'package:flutter/material.dart';

import '../../../core/theme/amiclean_colors.dart';
import '../../katalog/utils/cijena_display.dart';
import '../../narudzba/models/narudzba_admin.dart';

class AdminNarudzbaKartica extends StatelessWidget {
  const AdminNarudzbaKartica({
    super.key,
    required this.narudzba,
    required this.onTap,
  });

  final NarudzbaAdminPregled narudzba;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.08),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Narudžba #${narudzba.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AmiCleanColors.darkBlue,
                      ),
                    ),
                  ),
                  AdminStatusChip(status: narudzba.statusNaziv),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                narudzba.korisnikPunoIme,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (narudzba.korisnikTelefon != null)
                Text(
                  narudzba.korisnikTelefon!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _formatDatum(narudzba.datumKreiranja),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(narudzba.nacinPredajeNaziv),
              Text('${narudzba.brojStavki} stavki'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CijenaDisplay.km(narudzba.ukupnaCijena),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AmiCleanColors.darkBlue,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AmiCleanColors.mediumBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDatum(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}. $h:$min';
  }
}

class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AdminStatusChip.bojaZaStatus(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AdminStatusChip.bojaZaStatus(status),
        ),
      ),
    );
  }

  static Color bojaZaStatus(String status) {
    return switch (status) {
      'Kreirana' => const Color(0xFFE65100),
      'Primljena' => AmiCleanColors.skyBlue,
      'U obradi' => AmiCleanColors.mediumBlue,
      'Gotova' => const Color(0xFF2E7D32),
      'Preuzeta' => AmiCleanColors.slateBlue,
      'Otkazana' => const Color(0xFFC62828),
      _ => AmiCleanColors.darkBlue,
    };
  }
}
