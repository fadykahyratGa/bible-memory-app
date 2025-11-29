import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/supabase_client_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/game_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseClientProvider.supabaseUrl,
    anonKey: SupabaseClientProvider.supabaseAnonKey,
    authCallbackUrlHostname: 'login-callback',
  );
  await SupabaseClientProvider.ensureAnonymousUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const BibleMemoryApp(),
    ),
  );
}
