import 'package:flutter/material.dart';



import '../../../core/auth/auth_session.dart';

import '../../qr/screens/stavka_oznaka_skeniraj_screen.dart';



/// Početni ekran radnika u radnji.

class RadnikHomeScreen extends StatelessWidget {

  const RadnikHomeScreen({super.key, required this.session});



  final AuthSession session;



  @override

  Widget build(BuildContext context) {

    final user = session.user!;

    final theme = Theme.of(context);



    return Scaffold(

      appBar: AppBar(

        title: const Text('Radnik'),

        centerTitle: true,

        actions: [

          IconButton(

            onPressed: session.logout,

            tooltip: 'Odjava',

            icon: const Icon(Icons.logout),

          ),

        ],

      ),

      body: SafeArea(

        child: LayoutBuilder(

          builder: (context, constraints) {

            final contentMaxWidth = constraints.maxWidth > 600 ? 480.0 : double.infinity;



            return Align(

              alignment: Alignment.topCenter,

              child: ConstrainedBox(

                constraints: BoxConstraints(maxWidth: contentMaxWidth),

                child: ListView(

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

                    const SizedBox(height: 24),

                    Card(

                      elevation: 0,

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(12),

                        side: BorderSide(color: theme.colorScheme.outlineVariant),

                      ),

                      child: Padding(

                        padding: const EdgeInsets.all(20),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [

                            Icon(

                              Icons.qr_code_scanner,

                              size: 48,

                              color: theme.colorScheme.primary,

                            ),

                            const SizedBox(height: 16),

                            Text(

                              'Skeniranje QR oznaka',

                              style: theme.textTheme.titleLarge?.copyWith(

                                fontWeight: FontWeight.w600,

                              ),

                            ),

                            const SizedBox(height: 8),

                            Text(

                              'Kad je narudžba gotova, skenirajte QR naljepnicu na artiklu '

                              'ili unesite broj oznake ručno da pokrenete dostavu.',

                              style: theme.textTheme.bodyMedium?.copyWith(

                                color: theme.colorScheme.onSurfaceVariant,

                              ),

                            ),

                            const SizedBox(height: 20),

                            FilledButton.icon(

                              onPressed: () {

                                Navigator.of(context).push(

                                  MaterialPageRoute<void>(

                                    builder: (_) => StavkaOznakaSkenirajScreen.radnik(

                                      zaposlenikId: user.id,

                                    ),

                                  ),

                                );

                              },

                              icon: const Icon(Icons.qr_code_scanner),

                              label: const Text('Skeniraj ili unesi kod'),

                            ),

                          ],

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }

}

