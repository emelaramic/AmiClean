import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../katalog/utils/cijena_display.dart';
import '../models/cjenovnik_stavka.dart';
import '../services/cjenovnik_service.dart';
import 'admin_cjenovnik_edit_screen.dart';

class AdminCjenovnikScreen extends StatefulWidget {
  const AdminCjenovnikScreen({super.key});

  @override
  State<AdminCjenovnikScreen> createState() => _AdminCjenovnikScreenState();
}

class _AdminCjenovnikScreenState extends State<AdminCjenovnikScreen> {
  final _apiClient = ApiClient();
  late final _cjenovnikService = CjenovnikService(apiClient: _apiClient);

  List<CjenovnikStavka> _stavke = [];
  bool _loading = true;
  String? _greska;

  @override
  void initState() {
    super.initState();
    _ucitajCjenovnik();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajCjenovnik() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final stavke = await _cjenovnikService.getCjenovnik();
      if (!mounted) return;
      setState(() {
        _stavke = stavke;
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
        _greska = 'Neuspješno učitavanje cjenovnika.';
        _loading = false;
      });
    }
  }

  Future<void> _otvoriUredivanje(CjenovnikStavka stavka) async {
    final osvjezeno = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AdminCjenovnikEditScreen(stavka: stavka),
      ),
    );

    if (osvjezeno == true) {
      await _ucitajCjenovnik();
    }
  }

  String _formatCijena(CjenovnikStavka stavka) {
    if (stavka.jeTepih) {
      return CijenaDisplay.kmPoM2(stavka.cijena);
    }
    if (stavka.cijenaMax != null) {
      return '${CijenaDisplay.km(stavka.cijena)} – ${CijenaDisplay.km(stavka.cijenaMax!)}';
    }
    return CijenaDisplay.km(stavka.cijena);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cjenovnik'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _ucitajCjenovnik,
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
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _greska!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _ucitajCjenovnik,
                icon: const Icon(Icons.refresh),
                label: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stavke.isEmpty) {
      return Center(
        child: Text(
          'Cjenovnik je prazan.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ucitajCjenovnik,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _stavke.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final stavka = _stavke[index];
          return ListTile(
            onTap: () => _otvoriUredivanje(stavka),
            title: Text(stavka.artikalNaziv),
            subtitle: Text(
              '${stavka.artikalKategorija} · ${stavka.uslugaNaziv}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatCijena(stavka),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
