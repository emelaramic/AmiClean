import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/auth_session.dart';
import '../../auth/models/azuriraj_profil_request.dart';
import '../../auth/services/korisnik_service.dart';

class MojProfilScreen extends StatefulWidget {
  const MojProfilScreen({
    super.key,
    required this.session,
    required this.korisnikService,
  });

  final AuthSession session;
  final KorisnikService korisnikService;

  @override
  State<MojProfilScreen> createState() => _MojProfilScreenState();
}

class _MojProfilScreenState extends State<MojProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telefonController = TextEditingController();
  final _adresaController = TextEditingController();

  bool _loading = true;
  bool _spremanje = false;
  String? _greska;
  String? _imePrezime;
  String? _email;

  @override
  void initState() {
    super.initState();
    _ucitajProfil();
  }

  @override
  void dispose() {
    _telefonController.dispose();
    _adresaController.dispose();
    super.dispose();
  }

  Future<void> _ucitajProfil() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final profil = await widget.korisnikService.getProfil(
        widget.session.user!.id,
      );
      if (!mounted) return;

      setState(() {
        _imePrezime = profil.punoIme;
        _email = profil.email;
        _telefonController.text = profil.brojTelefona ?? '';
        _adresaController.text = profil.adresaStanovanja ?? '';
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
        _greska = 'Neuspješno učitavanje profila.';
        _loading = false;
      });
    }
  }

  Future<void> _spremiProfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _spremanje = true;
      _greska = null;
    });

    try {
      final profil = await widget.korisnikService.azurirajProfil(
        AzurirajProfilRequest(
          korisnikId: widget.session.user!.id,
          brojTelefona: _telefonController.text,
          adresaStanovanja: _adresaController.text,
        ),
      );
      if (!mounted) return;

      widget.session.syncProfil(profil);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil je ažuriran.')),
      );

      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _greska = e.message;
        _spremanje = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _greska = 'Spremanje profila nije uspjelo.';
        _spremanje = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moj profil')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_greska != null && _imePrezime == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_greska!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _ucitajProfil,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_greska != null) ...[
          Text(
            _greska!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        _InfoPolje(naslov: 'Ime i prezime', vrijednost: _imePrezime ?? ''),
        _InfoPolje(
          naslov: 'Email',
          vrijednost: _email?.isNotEmpty == true ? _email! : 'Nije uneseno',
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _telefonController,
                decoration: const InputDecoration(
                  labelText: 'Broj telefona',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_spremanje,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adresaController,
                decoration: const InputDecoration(
                  labelText: 'Adresa stanovanja',
                  helperText:
                      'Koristi se za predpopunjavanje adrese pri narudžbi.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_spremanje,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _spremanje ? null : _spremiProfil,
          child: Text(_spremanje ? 'Spremanje...' : 'Spremi promjene'),
        ),
      ],
    );
  }
}

class _InfoPolje extends StatelessWidget {
  const _InfoPolje({required this.naslov, required this.vrijednost});

  final String naslov;
  final String vrijednost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            naslov,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(vrijednost),
        ],
      ),
    );
  }
}
