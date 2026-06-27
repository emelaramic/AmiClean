import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../../narudzba/models/narudzba_admin.dart';
import '../../narudzba/services/narudzba_service.dart';
import '../../narudzba/models/narudzba_statistika.dart';
import '../widgets/admin_narudzba_kartica.dart';
import '../widgets/admin_quick_tile.dart';
import '../widgets/admin_stat_card.dart';
import 'admin_cjenovnik_screen.dart';
import 'admin_narudzba_detalj_screen.dart';
import 'admin_narudzbe_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key, required this.session});

  final AuthSession session;

  static const _desktopBreakpoint = 900.0;

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);

  NarudzbaStatistika? _statistika;
  List<NarudzbaAdminPregled> _najnovije = [];
  bool _loading = true;
  String? _greska;

  static const _statKartice = <_StatDef>[
    _StatDef(
      status: NarudzbaStatusi.kreirana,
      label: 'Kreirane',
      icon: Icons.inbox_outlined,
      accent: Color(0xFFE65100),
    ),
    _StatDef(
      status: NarudzbaStatusi.primljena,
      label: 'Primljene',
      icon: Icons.move_to_inbox_outlined,
      accent: AmiCleanColors.skyBlue,
    ),
    _StatDef(
      status: NarudzbaStatusi.uObradi,
      label: 'U obradi',
      icon: Icons.local_laundry_service_outlined,
      accent: AmiCleanColors.mediumBlue,
    ),
    _StatDef(
      status: NarudzbaStatusi.gotova,
      label: 'Gotove',
      icon: Icons.check_circle_outline,
      accent: Color(0xFF2E7D32),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ucitajDashboard();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajDashboard() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final results = await Future.wait([
        _narudzbaService.getBrojNarudzbiPoStatusu(),
        _narudzbaService.getSveNarudzbe(limit: 5),
      ]);
      if (!mounted) return;
      setState(() {
        _statistika = results[0] as NarudzbaStatistika;
        _najnovije = results[1] as List<NarudzbaAdminPregled>;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Neuspješno učitavanje admin pregleda.';
        _loading = false;
      });
    }
  }

  void _otvoriNarudzbe({String? statusFilter}) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AdminNarudzbeScreen(
          session: widget.session,
          initialFilterStatus: statusFilter,
        ),
      ),
    ).then((_) => _ucitajDashboard());
  }

  Future<void> _otvoriDetalj(NarudzbaAdminPregled narudzba) async {
    final osvjezeno = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AdminNarudzbaDetaljScreen(
          session: widget.session,
          narudzbaId: narudzba.id,
        ),
      ),
    );
    if (osvjezeno == true) {
      await _ucitajDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AmiClean Admin'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _ucitajDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
          ),
          IconButton(
            onPressed: widget.session.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Odjava',
          ),
        ],
      ),
      body: _buildBody(user.punoIme, user.ulogaZaposlenika ?? 'Administrator'),
    );
  }

  Widget _buildBody(String punoIme, String uloga) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_greska != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_greska!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ucitajDashboard,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    final stat = _statistika!;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AdminHomeScreen._desktopBreakpoint;
    final gridColumns = width >= 720 ? 4 : 2;

    return ColoredBox(
      color: AmiCleanColors.mistBlue,
      child: RefreshIndicator(
        onRefresh: _ucitajDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AdminHero(punoIme: punoIme, uloga: uloga, statistika: stat),
              Padding(
                padding: EdgeInsets.fromLTRB(isWide ? 32 : 20, 24, isWide ? 32 : 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stat.potrebnaPaznja > 0) ...[
                      _PaznjaBanner(broj: stat.potrebnaPaznja),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      'Narudžbe po statusu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AmiCleanColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.35 : 1.15,
                      children: _statKartice.map((def) {
                        return AdminStatCard(
                          label: def.label,
                          count: stat.brojZaStatus(def.status),
                          icon: def.icon,
                          accentColor: def.accent,
                          onTap: () => _otvoriNarudzbe(statusFilter: def.status),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Najnovije narudžbe',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AmiCleanColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 14),
                    if (_najnovije.isEmpty)
                      Text(
                        'Nema narudžbi u sistemu.',
                        style: TextStyle(
                          color: AmiCleanColors.slateBlue.withValues(alpha: 0.9),
                        ),
                      )
                    else
                      ..._najnovije.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AdminNarudzbaKartica(
                            narudzba: n,
                            onTap: () => _otvoriDetalj(n),
                          ),
                        ),
                      ),
                    if (_najnovije.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _otvoriNarudzbe(),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Sve narudžbe'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Upravljanje',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AmiCleanColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 14),
                    AdminQuickTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Sve narudžbe',
                      subtitle: '${stat.aktivne} aktivnih · ${stat.ukupno} ukupno',
                      onTap: () => _otvoriNarudzbe(),
                    ),
                    const SizedBox(height: 10),
                    AdminQuickTile(
                      icon: Icons.price_change_outlined,
                      title: 'Cjenovnik',
                      subtitle: 'Uredi cijene artikala i usluga',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AdminCjenovnikScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatDef {
  const _StatDef({
    required this.status,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String status;
  final String label;
  final IconData icon;
  final Color accent;
}

class _AdminHero extends StatelessWidget {
  const _AdminHero({
    required this.punoIme,
    required this.uloga,
    required this.statistika,
  });

  final String punoIme;
  final String uloga;
  final NarudzbaStatistika statistika;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AdminHomeScreen._desktopBreakpoint;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AmiCleanColors.heroBackground,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isWide ? 40 : 20,
          isWide ? 36 : 28,
          isWide ? 40 : 20,
          isWide ? 36 : 28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Text(
                uloga,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Dobrodošli, $punoIme',
              style: TextStyle(
                color: Colors.white,
                fontSize: isWide ? 32 : 26,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pregled narudžbi i brzo upravljanje čistionicom.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: isWide ? 16 : 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _HeroBadge(
                  icon: Icons.pending_actions_outlined,
                  label: '${statistika.aktivne} aktivnih',
                ),
                _HeroBadge(
                  icon: Icons.inventory_2_outlined,
                  label: '${statistika.ukupno} ukupno',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaznjaBanner extends StatelessWidget {
  const _PaznjaBanner({required this.broj});

  final int broj;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: Color(0xFFE65100)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                broj == 1
                    ? '1 narudžba čeka vašu akciju (kreirana ili primljena).'
                    : '$broj narudžbe čekaju vašu akciju (kreirane ili primljene).',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBF360C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
