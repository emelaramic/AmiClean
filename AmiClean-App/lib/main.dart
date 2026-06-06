import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';

/// Vrijeme pokretanja — za minimalno trajanje splash ekrana.
final DateTime appStartedAt = DateTime.now();

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  runApp(AmiCleanApp(startedAt: appStartedAt));
}
