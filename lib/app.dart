import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/game_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/range_selection_screen.dart';
import 'ui/screens/game_screen.dart';
import 'ui/screens/result_screen.dart';
import 'ui/screens/badges_screen.dart';
import 'ui/screens/settings_screen.dart';

class BibleMemoryApp extends StatefulWidget {
  const BibleMemoryApp({super.key});

  @override
  State<BibleMemoryApp> createState() => _BibleMemoryAppState();
}

class _BibleMemoryAppState extends State<BibleMemoryApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().init();
      context.read<ProgressProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'احفظ كلمة الله',
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          '/': (_) => const HomeScreen(),
          '/select-range': (_) => const RangeSelectionScreen(),
          '/game': (_) => const GameScreen(),
          '/result': (_) => const ResultScreen(),
          '/badges': (_) => const BadgesScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
        builder: (context, child) {
          if (settings.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return child!;
        },
      ),
    );
  }
}
