import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_provider.dart';

// Re-export the background entry point so the Dart compiler includes it
export 'process_text_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appProvider = AppProvider();
  await appProvider.loadAll();

  runApp(
    ChangeNotifierProvider.value(value: appProvider, child: const AITextApp()),
  );
}
