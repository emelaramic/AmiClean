import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/cart/cart_session.dart';
import '../models/cart_stavka.dart';
import 'nova_narudzba_screen.dart';
import 'potvrda_narudzbe_screen.dart';

class KosaricaScreen extends StatelessWidget {
  const KosaricaScreen({
    super.key,
    required this.cart,
    required this.session,
  });

  final CartSession cart;
  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pregled narudžbe'),
          ),
          body: cart.isEmpty ? _buildPrazno(context) : _buildSadrzaj(context),
        );
      },
    );
  }

  Widget _buildPrazno(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Narudžba je prazna.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dodaj stavke'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSadrzaj(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.stavke.length,
            itemBuilder: (context, index) {
              final stavka = cart.stavke[index];
              return _StavkaTile(
                stavka: stavka,
                onRemove: () => cart.ukloniStavku(stavka.id),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ukupno',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _formatKm(cart.ukupno),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Procijenjena cijena. Konačan iznos može varirati za artikle s rasponom cijena.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PotvrdaNarudzbeScreen(
                        cart: cart,
                        session: session,
                      ),
                    ),
                  );
                },
                child: const Text('Nastavi na potvrdu'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => NovaNarudzbaScreen(cart: cart, session: session),
                    ),
                  );
                },
                child: const Text('Dodaj još stavki'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatKm(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} KM';
    }
    return '${value.toStringAsFixed(2)} KM';
  }
}

class _StavkaTile extends StatelessWidget {
  const _StavkaTile({required this.stavka, required this.onRemove});

  final CartStavka stavka;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    stavka.artikalNaziv,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Ukloni',
                ),
              ],
            ),
            Text(stavka.kolicinaTekst),
            Text(stavka.uslugeTekst),
            if (stavka.napomena != null) Text('Napomena: ${stavka.napomena}'),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                stavka.formatKm(stavka.ukupnaCijena),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
