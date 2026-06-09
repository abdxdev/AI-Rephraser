import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'process_text_handler.dart' as handler;
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void processTextEntrypoint() {
  handler.processTextEntrypoint();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AdService.initialize();
  await NotificationService.initialize();

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
