import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'firebase_options.dart';

// Re-export the background entry point so the Dart compiler includes it
export 'process_text_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appProvider = AppProvider();
  await appProvider.loadAll();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AITextApp(),
    ),
  );
}
