import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../qr/screens/stavka_oznaka_skeniraj_screen.dart';
import '../models/radnik_dostava.dart';
import '../services/radnik_service.dart';
import '../widgets/radnik_dostava_kartica.dart';

/// Početni ekran radnika — lista dostava i skeniranje QR oznaka.
class RadnikHomeScreen extends StatefulWidget {
  const RadnikHomeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<RadnikHomeScreen> createState() => _RadnikHomeScreenState();
}

class _RadnikHomeScreenState extends State<RadnikHomeScreen> {
  final _apiClient = ApiClient();
  late final RadnikService _radnikService =
      RadnikService(apiClient: _apiClient);

  RadnikDostaveLista? _dostave;
  bool _loading = true;
  String? _greska;

  @override
  void initState() {
    super.initState();
    _ucitajDostave();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajDostave() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final lista = await _radnikService.getDostave(
        zaposlenikId: widget.session.user!.id,
      );
      if (!mounted) return;
      setState(() {
        _dostave = lista;
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
        _greska = 'Učitavanje dostava nije uspjelo.';
        _loading = false;
      });
    }
  }

  Future<void> _otvoriSkeniranje() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StavkaOznakaSkenirajScreen.radnik(
          zaposlenikId: widget.session.user!.id,
        ),
      ),
    );
    if (mounted) await _ucitajDostave();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radnik'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loading ? null : _ucitajDostave,
            tooltip: 'Osvježi',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: widget.session.logout,
            tooltip: 'Odjava',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentMaxWidth =
                constraints.maxWidth > 600 ? 520.0 : double.infinity;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: RefreshIndicator(
                  onRefresh: _ucitajDostave,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Text(
                        'Dobrodošli ${user.ime}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.ulogaZaposlenika ?? 'Radnik',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _otvoriSkeniranje,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Skeniraj ili unesi kod'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Dostave',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Narudžbe s preuzimanjem i dostavom koje su gotove u čistionici.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_greska != null)
                        _buildGreska(theme)
                      else if (_dostave == null || _dostave!.jePrazno)
                        _buildPrazno(theme)
                      else ...[
                        if (_dostave!.spremne.isNotEmpty) ...[
                          _buildSekcijaNaslov(
                            theme,
                            'Spremne za dostavu',
                            _dostave!.spremne.length,
                          ),
                          const SizedBox(height: 8),
                          ..._dostave!.spremne.map(
                            (d) => RadnikDostavaKartica(
                              dostava: d,
                              onSkeniraj: _otvoriSkeniranje,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (_dostave!.uToku.isNotEmpty) ...[
                          _buildSekcijaNaslov(
                            theme,
                            'U toku',
                            _dostave!.uToku.length,
                          ),
                          const SizedBox(height: 8),
                          ..._dostave!.uToku.map(
                            (d) => RadnikDostavaKartica(
                              dostava: d,
                              onSkeniraj: _otvoriSkeniranje,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSekcijaNaslov(ThemeData theme, String naslov, int broj) {
    return Row(
      children: [
        Text(
          naslov,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$broj',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreska(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _greska!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _ucitajDostave,
              child: const Text('Pokušaj ponovno'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrazno(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Nema aktivnih dostava',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kad admin označi narudžbu s dostavom kao gotovu, pojavit će se ovdje.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
