import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../../narudzba/models/narudzba_admin.dart';
import '../../narudzba/services/narudzba_service.dart';
import '../widgets/admin_narudzba_kartica.dart';
import 'admin_narudzba_detalj_screen.dart';

class AdminNarudzbeScreen extends StatefulWidget {
  const AdminNarudzbeScreen({
    super.key,
    required this.session,
    this.initialFilterStatus,
  });

  final AuthSession session;
  final String? initialFilterStatus;

  @override
  State<AdminNarudzbeScreen> createState() => _AdminNarudzbeScreenState();
}

class _AdminNarudzbeScreenState extends State<AdminNarudzbeScreen> {
  final _apiClient = ApiClient();
  late final _narudzbaService = NarudzbaService(apiClient: _apiClient);

  List<NarudzbaAdminPregled> _narudzbe = [];
  bool _loading = true;
  String? _greska;
  late String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _filterStatus = widget.initialFilterStatus;
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
      final narudzbe = await _narudzbaService.getSveNarudzbe(
        statusNaziv: _filterStatus,
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

  void _postaviFilter(String? status) {
    if (_filterStatus == status) return;
    setState(() => _filterStatus = status);
    _ucitajNarudzbe();
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
      await _ucitajNarudzbe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sve narudžbe'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _ucitajNarudzbe,
            icon: const Icon(Icons.refresh),
            tooltip: 'Osvježi',
          ),
        ],
      ),
      body: ColoredBox(
        color: AmiCleanColors.mistBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.06),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: NarudzbaStatusi.filterOpcije.entries.map((entry) {
            final selected = _filterStatus == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(entry.value),
                selected: selected,
                showCheckmark: false,
                selectedColor: AmiCleanColors.darkBlue.withValues(alpha: 0.12),
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AmiCleanColors.darkBlue
                      : AmiCleanColors.slateBlue,
                ),
                side: BorderSide(
                  color: selected
                      ? AmiCleanColors.darkBlue
                      : AmiCleanColors.softBlue.withValues(alpha: 0.6),
                ),
                onSelected: (_) => _postaviFilter(entry.key),
              ),
            );
          }).toList(),
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
          child: Text(
            _filterStatus == null
                ? 'Nema narudžbi u sistemu.'
                : 'Nema narudžbi sa statusom "${NarudzbaStatusi.filterOpcije[_filterStatus]}".',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AmiCleanColors.slateBlue.withValues(alpha: 0.95),
            ),
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
          return AdminNarudzbaKartica(
            narudzba: n,
            onTap: () => _otvoriDetalj(n),
          );
        },
      ),
    );
  }
}
