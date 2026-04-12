import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konta/config/routes.dart';
import 'package:konta/config/theme.dart';
import 'package:konta/core/utils/localization.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('Starting Konta app initialization');

  await dotenv.load(fileName: '.env');
  Logger.success('.env loaded');

  await SupabaseService.initialize();
  Logger.success('Supabase initialized');

  final sharedPreferences = await SharedPreferences.getInstance();
  Logger.success('SharedPreferences initialized');

  Logger.info('Running app');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const KontaApp(),
    ),
  );
}

class KontaApp extends ConsumerWidget {
  const KontaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Konta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr'), Locale('ar')],
      routerConfig: router,
    );
  }
}
