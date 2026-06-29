import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../qr/screens/stavka_oznaka_skeniraj_screen.dart';
import '../models/radnik_dostava.dart';
import '../services/radnik_service.dart';
import '../widgets/radnik_dostava_kartica.dart';
import 'radnik_dostava_detalj_screen.dart';

/// Početni ekran radnika — lista dostava i skeniranje QR oznaka.
class RadnikHomeScreen extends StatefulWidget {
  const RadnikHomeScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<RadnikHomeScreen> createState() => _RadnikHomeScreenState();
}

class _RadnikHomeScreenState extends State<RadnikHomeScreen> {
  final _apiClient = ApiClient();
  final _pretragaController = TextEditingController();
  late final RadnikService _radnikService =
      RadnikService(apiClient: _apiClient);

  RadnikDostaveLista? _dostave;
  bool _loading = true;
  String? _greska;
  String _upitPretrage = '';

  @override
  void initState() {
    super.initState();
    _pretragaController.addListener(() {
      setState(() => _upitPretrage = _pretragaController.text);
    });
    _ucitajDostave();
  }

  @override
  void dispose() {
    _pretragaController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  bool _odgovaraPretrazi(RadnikDostava dostava) {
    final upit = _upitPretrage.trim().toLowerCase();
    if (upit.isEmpty) return true;
    return dostava.korisnikPunoIme.toLowerCase().contains(upit);
  }

  List<RadnikDostava> _filtriraneSpremne() =>
      _dostave?.spremne.where(_odgovaraPretrazi).toList() ?? const [];

  List<RadnikDostava> _filtriraneUToku() =>
      _dostave?.uToku.where(_odgovaraPretrazi).toList() ?? const [];

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

  Future<void> _otvoriDetalj(int narudzbaId) async {
    final promijenjeno = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RadnikDostavaDetaljScreen(
          narudzbaId: narudzbaId,
          zaposlenikId: widget.session.user!.id,
        ),
      ),
    );
    if (promijenjeno == true && mounted) await _ucitajDostave();
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
                      TextField(
                        controller: _pretragaController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Pretraži po imenu korisnika',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _upitPretrage.trim().isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _pretragaController.clear();
                                  },
                                  tooltip: 'Obriši pretragu',
                                  icon: const Icon(Icons.clear),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        Builder(
                          builder: (context) {
                            final spremne = _filtriraneSpremne();
                            final uToku = _filtriraneUToku();
                            final imaRezultata =
                                spremne.isNotEmpty || uToku.isNotEmpty;

                            if (!imaRezultata) {
                              return _buildNemaRezultataPretrage(theme);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (spremne.isNotEmpty) ...[
                                  _buildSekcijaNaslov(
                                    theme,
                                    'Spremne za dostavu',
                                    spremne.length,
                                  ),
                                  const SizedBox(height: 8),
                                  ...spremne.map(
                                    (d) => RadnikDostavaKartica(
                                      dostava: d,
                                      onDetalj: () =>
                                          _otvoriDetalj(d.narudzbaId),
                                      onSkeniraj: _otvoriSkeniranje,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (uToku.isNotEmpty) ...[
                                  _buildSekcijaNaslov(
                                    theme,
                                    'U toku',
                                    uToku.length,
                                  ),
                                  const SizedBox(height: 8),
                                  ...uToku.map(
                                    (d) => RadnikDostavaKartica(
                                      dostava: d,
                                      onDetalj: () =>
                                          _otvoriDetalj(d.narudzbaId),
                                      onSkeniraj: _otvoriSkeniranje,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
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

  Widget _buildNemaRezultataPretrage(ThemeData theme) {
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
              Icons.person_search_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Nema dostava za „${_upitPretrage.trim()}”',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Probaj ime ili prezime korisnika (npr. Amra, Emela).',
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
