import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/theme/amiclean_colors.dart';
import '../models/preporuka.dart';
import '../services/preporuka_service.dart';

typedef PreporukaTapCallback = void Function({
  required String kategorija,
  required int artikalId,
});

class PreporukeSection extends StatefulWidget {
  const PreporukeSection({
    super.key,
    required this.korisnikId,
    required this.onPreporukaTap,
  });

  final int korisnikId;
  final PreporukaTapCallback onPreporukaTap;

  @override
  State<PreporukeSection> createState() => _PreporukeSectionState();
}

class _PreporukeSectionState extends State<PreporukeSection> {
  final _apiClient = ApiClient();
  late final _preporukaService = PreporukaService(apiClient: _apiClient);

  List<Preporuka> _preporuke = [];
  bool _loading = true;
  String? _greska;

  @override
  void initState() {
    super.initState();
    _ucitajPreporuke();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _ucitajPreporuke() async {
    setState(() {
      _loading = true;
      _greska = null;
    });

    try {
      final preporuke = await _preporukaService.getZaKorisnika(
        korisnikId: widget.korisnikId,
        limit: 3,
      );
      if (!mounted) return;
      setState(() {
        _preporuke = preporuke;
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
        _greska = 'Neuspješno učitavanje preporuka.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (_greska != null) {
      return _SectionShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_greska!, style: TextStyle(color: AmiCleanColors.slateBlue)),
            const SizedBox(height: 10),
            TextButton(onPressed: _ucitajPreporuke, child: const Text('Pokušaj ponovo')),
          ],
        ),
      );
    }

    if (_preporuke.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend_rounded, color: AmiCleanColors.mediumBlue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Preporučeno za vas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AmiCleanColors.darkBlue,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Personalizirane usluge na temelju vaše povijesti i popularnosti.',
            style: TextStyle(
              color: AmiCleanColors.slateBlue.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ..._preporuke.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PreporukaCard(
                preporuka: p,
                onTap: () => widget.onPreporukaTap(
                  kategorija: p.kategorija,
                  artikalId: p.artikalId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: child,
    );
  }
}

class _PreporukaCard extends StatelessWidget {
  const _PreporukaCard({
    required this.preporuka,
    required this.onTap,
  });

  final Preporuka preporuka;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      shadowColor: AmiCleanColors.darkBlue.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AmiCleanColors.mistBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      preporuka.tipIkona,
                      color: AmiCleanColors.darkBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preporuka.naziv,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AmiCleanColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preporuka.kategorija,
                          style: TextStyle(
                            fontSize: 13,
                            color: AmiCleanColors.mediumBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (preporuka.cijenaOpis != null)
                    Text(
                      preporuka.cijenaOpis!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AmiCleanColors.darkBlue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AmiCleanColors.lightBlue.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  preporuka.razlog,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AmiCleanColors.darkBlue.withValues(alpha: 0.88),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                  label: const Text('Naruči'),
                  style: TextButton.styleFrom(
                    foregroundColor: AmiCleanColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
