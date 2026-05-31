import 'package:flutter_test/flutter_test.dart';

import 'package:amiclean_app/app.dart';

void main() {
  testWidgets('Login ekran se prikazuje', (WidgetTester tester) async {
    await tester.pumpWidget(AmiCleanApp());

    expect(find.text('AmiClean — Prijava'), findsOneWidget);
    expect(find.text('Korisnik'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
