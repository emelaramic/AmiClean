import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../services/korisnik_service.dart';
import '../models/registracija_request.dart';

class RegistracijaScreen extends StatefulWidget {
  const RegistracijaScreen({super.key, required this.korisnikService});

  final KorisnikService korisnikService;

  @override
  State<RegistracijaScreen> createState() => _RegistracijaScreenState();
}

class _RegistracijaScreenState extends State<RegistracijaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _adresaController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _potvrdaLozinkeController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _adresaController.dispose();
    _lozinkaController.dispose();
    _potvrdaLozinkeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final korisnik = await widget.korisnikService.registriraj(
        RegistracijaRequest(
          ime: _imeController.text,
          prezime: _prezimeController.text,
          email: _emailController.text,
          brojTelefona: _telefonController.text,
          adresaStanovanja: _adresaController.text,
          lozinka: _lozinkaController.text,
        ),
      );

      if (!mounted) return;

      _clearForm();
      await _showSuccessDialog(korisnik.punoIme, korisnik.id);
    } on ApiException catch (error) {
      if (!mounted) return;
      _showErrorSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Neočekivana greška. Pokušaj ponovno.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _imeController.clear();
    _prezimeController.clear();
    _emailController.clear();
    _telefonController.clear();
    _adresaController.clear();
    _lozinkaController.clear();
    _potvrdaLozinkeController.clear();
  }

  Future<void> _showSuccessDialog(String punoIme, int id) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
        title: const Text('Registracija uspješna'),
        content: Text(
          'Korisnik $punoIme je spremljen u bazu.\nID: $id',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('U redu'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AmiClean — Registracija'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isSubmitting,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kreiraj korisnički račun',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Podaci se šalju na backend i spremaju u SQL bazu.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Osnovni podaci'),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Ime *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ime je obavezno';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _prezimeController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Prezime *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Prezime je obavezno';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return null;
                      final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailPattern.hasMatch(email)) {
                        return 'Unesi ispravan email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Kontakt'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _telefonController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Broj telefona',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adresaController,
                    textInputAction: TextInputAction.next,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Adresa stanovanja',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(theme, 'Sigurnost'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lozinkaController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Lozinka *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lozinka je obavezna';
                      }
                      if (value.length < 6) {
                        return 'Lozinka mora imati najmanje 6 znakova';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _potvrdaLozinkeController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Potvrda lozinke *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Potvrdi lozinku';
                      }
                      if (value != _lozinkaController.text) {
                        return 'Lozinke se ne podudaraju';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.person_add_outlined),
                    label: Text(
                      _isSubmitting ? 'Spremanje...' : 'Registriraj se',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
