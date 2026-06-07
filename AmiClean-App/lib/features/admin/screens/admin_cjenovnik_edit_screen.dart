import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../katalog/utils/cijena_display.dart';
import '../models/cjenovnik_stavka.dart';
import '../services/cjenovnik_service.dart';

class AdminCjenovnikEditScreen extends StatefulWidget {
  const AdminCjenovnikEditScreen({super.key, required this.stavka});

  final CjenovnikStavka stavka;

  @override
  State<AdminCjenovnikEditScreen> createState() =>
      _AdminCjenovnikEditScreenState();
}

class _AdminCjenovnikEditScreenState extends State<AdminCjenovnikEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cijenaController = TextEditingController();
  final _apiClient = ApiClient();
  late final _cjenovnikService = CjenovnikService(apiClient: _apiClient);

  bool _spremanje = false;
  String? _greska;

  CjenovnikStavka get _stavka => widget.stavka;

  @override
  void initState() {
    super.initState();
    _cijenaController.text = _formatInputValue(_stavka.cijena);
  }

  @override
  void dispose() {
    _cijenaController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  String _formatInputValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _labelCijena() {
    return _stavka.jeTepih ? 'Cijena (KM/m²)' : 'Cijena (KM)';
  }

  String _trenutnaCijenaTekst() {
    if (_stavka.jeTepih) {
      return CijenaDisplay.kmPoM2(_stavka.cijena);
    }
    return CijenaDisplay.km(_stavka.cijena);
  }

  Future<void> _spremi() async {
    if (!_formKey.currentState!.validate()) return;

    final novaCijena = double.parse(
      _cijenaController.text.trim().replaceAll(',', '.'),
    );

    setState(() {
      _spremanje = true;
      _greska = null;
    });

    try {
      await _cjenovnikService.azurirajCijenu(
        stavka: _stavka,
        novaCijena: novaCijena,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cijena je uspješno spremljena.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _spremanje = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Neuspješno spremanje cijene.';
        _spremanje = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uredi cijenu'),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _spremanje,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoTile(
                      label: 'Artikal',
                      value: _stavka.artikalNaziv,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Kategorija',
                      value: _stavka.artikalKategorija,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Usluga',
                      value: _stavka.uslugaNaziv,
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      label: 'Trenutna cijena',
                      value: _trenutnaCijenaTekst(),
                    ),
                    if (_stavka.cijenaMax != null) ...[
                      const SizedBox(height: 12),
                      _InfoTile(
                        label: 'Raspon cijene',
                        value:
                            '${CijenaDisplay.km(_stavka.cijena)} – ${CijenaDisplay.km(_stavka.cijenaMax!)}',
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _cijenaController,
                      decoration: InputDecoration(
                        labelText: _labelCijena(),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (value) {
                        final text = value?.trim().replaceAll(',', '.') ?? '';
                        if (text.isEmpty) {
                          return 'Unesite cijenu.';
                        }
                        final parsed = double.tryParse(text);
                        if (parsed == null) {
                          return 'Unesite ispravan broj.';
                        }
                        if (parsed <= 0) {
                          return 'Cijena mora biti veća od 0.';
                        }
                        return null;
                      },
                    ),
                    if (_greska != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _greska!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _spremanje ? null : _spremi,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Spremi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_spremanje)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
