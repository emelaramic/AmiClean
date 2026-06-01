import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../katalog/utils/cijena_display.dart';
import '../models/narudzba_pregled.dart';
import '../services/narudzba_service.dart';
import 'narudzba_detalj_screen.dart';

class MojeNarudzbeScreen extends StatefulWidget {
  const MojeNarudzbeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<MojeNarudzbeScreen> createState() => _MojeNarudzbeScreenState();
}

class _MojeNarudzbeScreenState extends State<MojeNarudzbeScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);

  List<NarudzbaPregled> _narudzbe = [];
  bool _loading = true;
  String? _greska;

  @override
  void initState() {
    super.initState();
    _ucitajNarudzbe();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajNarudzbe() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final narudzbe = await _narudzbaService.getMojeNarudzbe(
        widget.session.user!.id,
      );
      if (!mounted) return;
      setState(() {
        _narudzbe = narudzbe;
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
        _greska = 'Neuspješno učitavanje narudžbi.';
        _loading = false;
      });
    }
  }

  void _otvoriDetalj(NarudzbaPregled narudzba) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NarudzbaDetaljScreen(
          session: widget.session,
          narudzbaId: narudzba.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje narudžbe'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _ucitajNarudzbe,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
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
                onPressed: _ucitajNarudzbe,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_narudzbe.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nemate narudžbi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Kreirajte prvu narudžbu s početnog ekrana.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ucitajNarudzbe,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _narudzbe.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final n = _narudzbe[index];
          return _NarudzbaKartica(
            narudzba: n,
            onTap: () => _otvoriDetalj(n),
          );
        },
      ),
    );
  }
}

class _NarudzbaKartica extends StatelessWidget {
  const _NarudzbaKartica({required this.narudzba, required this.onTap});

  final NarudzbaPregled narudzba;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(status: narudzba.statusNaziv),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDatum(narudzba.datumKreiranja),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(narudzba.nacinPredajeNaziv),
              Text(
                '${narudzba.brojStavki} stavki',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CijenaDisplay.km(narudzba.ukupnaCijena),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
