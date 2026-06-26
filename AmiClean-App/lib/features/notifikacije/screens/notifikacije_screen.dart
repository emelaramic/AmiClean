import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../../narudzba/screens/narudzba_detalj_screen.dart';
import '../models/notifikacija.dart';
import '../services/notifikacija_service.dart';

class NotifikacijeScreen extends StatefulWidget {
  const NotifikacijeScreen({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<NotifikacijeScreen> createState() => _NotifikacijeScreenState();
}

class _NotifikacijeScreenState extends State<NotifikacijeScreen> {
  final _apiClient = ApiClient();
  late final _notifikacijaService = NotifikacijaService(apiClient: _apiClient);

  List<Notifikacija> _notifikacije = [];
  bool _loading = true;
  String? _greska;

  int get _korisnikId => widget.session.user!.id;

  @override
  void initState() {
    super.initState();
    _ucitajNotifikacije();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajNotifikacije() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final notifikacije =
          await _notifikacijaService.getZaKorisnika(_korisnikId);
      if (!mounted) return;
      setState(() {
        _notifikacije = notifikacije;
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
        _greska = 'Neuspješno učitavanje obavijesti.';
        _loading = false;
      });
    }
  }

  Future<void> _oznaciSveProcitanim() async {
    try {
      await _notifikacijaService.oznaciSveProcitanim(_korisnikId);
      await _ucitajNotifikacije();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _otvoriNotifikaciju(Notifikacija notifikacija) async {
    if (!notifikacija.procitano) {
      try {
        await _notifikacijaService.oznaciProcitanom(
          notifikacijaId: notifikacija.id,
          korisnikId: _korisnikId,
        );
      } on ApiException {
        // Nastavi na detalj čak i ako označavanje ne uspije.
      }
    }

    if (!mounted) return;

    if (notifikacija.narudzbaId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NarudzbaDetaljScreen(
            session: widget.session,
            narudzbaId: notifikacija.narudzbaId!,
          ),
        ),
      );
    }

    if (mounted) await _ucitajNotifikacije();
  }

  @override
  Widget build(BuildContext context) {
    final imaNeprocitanih = _notifikacije.any((n) => !n.procitano);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Obavijesti'),
        actions: [
          if (imaNeprocitanih)
            TextButton(
              onPressed: _oznaciSveProcitanim,
              child: const Text('Pročitaj sve'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
                onPressed: _ucitajNotifikacije,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifikacije.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 64,
                color: AmiCleanColors.mediumBlue.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Nemate obavijesti',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AmiCleanColors.darkBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ovdje ćete vidjeti ažuriranja o statusu vaših narudžbi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AmiCleanColors.slateBlue),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ucitajNotifikacije,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifikacije.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notifikacija = _notifikacije[index];
          return _NotifikacijaTile(
            notifikacija: notifikacija,
            datumTekst: _formatDatum(notifikacija.datumSlanja),
            onTap: () => _otvoriNotifikaciju(notifikacija),
          );
        },
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

class _NotifikacijaTile extends StatelessWidget {
  const _NotifikacijaTile({
    required this.notifikacija,
    required this.datumTekst,
    required this.onTap,
  });

  final Notifikacija notifikacija;
  final String datumTekst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neprocitano = !notifikacija.procitano;

    return Material(
      color: neprocitano
          ? AmiCleanColors.lightBlue.withValues(alpha: 0.55)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: neprocitano ? 0 : 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: neprocitano
                      ? AmiCleanColors.darkBlue.withValues(alpha: 0.12)
                      : AmiCleanColors.mistBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: neprocitano
                      ? AmiCleanColors.darkBlue
                      : AmiCleanColors.mediumBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notifikacija.naslov,
                            style: TextStyle(
                              fontWeight: neprocitano
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: AmiCleanColors.darkBlue,
                            ),
                          ),
                        ),
                        if (neprocitano)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notifikacija.poruka,
                      style: TextStyle(
                        height: 1.4,
                        color: AmiCleanColors.darkBlue.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      datumTekst,
                      style: TextStyle(
                        fontSize: 12,
                        color: AmiCleanColors.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
              if (notifikacija.narudzbaId != null)
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
