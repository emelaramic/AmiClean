import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../../qr/screens/stavka_oznaka_skeniraj_screen.dart';
import '../models/radnik_dostava.dart';
import '../services/radnik_service.dart';

class RadnikDostavaDetaljScreen extends StatefulWidget {
  const RadnikDostavaDetaljScreen({
    super.key,
    required this.narudzbaId,
    required this.zaposlenikId,
  });

  final int narudzbaId;
  final int zaposlenikId;

  @override
  State<RadnikDostavaDetaljScreen> createState() =>
      _RadnikDostavaDetaljScreenState();
}

class _RadnikDostavaDetaljScreenState extends State<RadnikDostavaDetaljScreen> {
  final _apiClient = ApiClient();
  late final RadnikService _radnikService =
      RadnikService(apiClient: _apiClient);

  RadnikDostavaDetalj? _detalj;
  bool _loading = true;
  String? _greska;
  bool _promijenjeno = false;

  @override
  void initState() {
    super.initState();
    _ucitajDetalj();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajDetalj() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final detalj = await _radnikService.getDetaljDostave(
        narudzbaId: widget.narudzbaId,
        zaposlenikId: widget.zaposlenikId,
      );
      if (!mounted) return;
      setState(() {
        _detalj = detalj;
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
        _greska = 'Učitavanje detalja nije uspjelo.';
        _loading = false;
      });
    }
  }

  Future<void> _otvoriSkeniranje() async {
    final rezultat = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => StavkaOznakaSkenirajScreen.radnik(
          zaposlenikId: widget.zaposlenikId,
        ),
      ),
    );

    if (!mounted) return;

    if (rezultat != null) {
      _promijenjeno = true;
      await _ucitajDetalj();
    }
  }

  void _kopirajOznaku(String brojOznake) {
    Clipboard.setData(ClipboardData(text: brojOznake));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Kopirano: $brojOznake')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_promijenjeno);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dostava #${widget.narudzbaId}'),
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(_promijenjeno),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: _detalj == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: FilledButton.icon(
                    onPressed: _otvoriSkeniranje,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      _detalj!.mozePokrenuti
                          ? 'Skeniraj i kreni u dostavu'
                          : 'Skeniraj oznaku',
                    ),
                  ),
                ),
              ),
      ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_greska!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ucitajDetalj,
                child: const Text('Pokušaj ponovno'),
              ),
            ],
          ),
        ),
      );
    }

    final detalj = _detalj!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _InfoRed('Korisnik', detalj.korisnikPunoIme),
        if (detalj.korisnikTelefon != null &&
            detalj.korisnikTelefon!.trim().isNotEmpty)
          _InfoRed('Telefon', detalj.korisnikTelefon!),
        _InfoRed('Adresa', detalj.adresaDostave),
        _InfoRed('Status dostave', detalj.logistikaStatusNaziv),
        if (detalj.rokZavrsetka != null)
          _InfoRed('Rok završetka', _formatDatum(detalj.rokZavrsetka!)),
        if (detalj.jeUToku && detalj.vozacPunoIme != null)
          _InfoRed(
            'Vozač',
            detalj.jeMojaDostava
                ? 'Vi (${detalj.vozacPunoIme})'
                : detalj.vozacPunoIme!,
          ),
        if (detalj.napomena != null && detalj.napomena!.trim().isNotEmpty)
          _InfoRed('Napomena narudžbe', detalj.napomena!.trim()),
        const SizedBox(height: 16),
        Text(
          'Stavke za dostavu',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Skenirajte bilo koju oznaku ispod da pokrenete ili potvrdite dostavu.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...detalj.stavke.map(_buildStavka),
      ],
    );
  }

  Widget _buildStavka(RadnikDostavaStavka stavka) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stavka.artikalNaziv,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stavka.kolicinaTekst,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (stavka.imaBrojOznake) ...[
              const SizedBox(height: 12),
              Text(
                'Broj oznake',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Material(
                color: AmiCleanColors.lightBlue,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _kopirajOznaku(stavka.brojOznake!),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stavka.brojOznake!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AmiCleanColors.darkBlue,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.copy,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dodirni da kopiraš kod za ručni unos.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Oznaka još nije generisana — admin mora primijeniti narudžbu.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDatum(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}.';
  }
}

class _InfoRed extends StatelessWidget {
  const _InfoRed(this.label, this.vrijednost);

  final String label;
  final String vrijednost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              vrijednost,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
