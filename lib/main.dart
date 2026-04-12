import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/config/routes.dart';
import 'package:konta/config/theme.dart';
import 'package:konta/core/utils/localization.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/remote/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('Starting Konta app initialization');

  await dotenv.load(fileName: '.env');
  Logger.success('.env loaded');

  await SupabaseService.initialize();
  Logger.success('Supabase initialized');

  Logger.info('Running app');
  runApp(const ProviderScope(child: KontaApp()));
}

class KontaApp extends StatelessWidget {
  const KontaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Konta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
