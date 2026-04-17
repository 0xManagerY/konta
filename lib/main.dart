import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konta/config/routes.dart';
import 'package:konta/config/theme.dart';
import 'package:konta/core/utils/localization.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/settings_provider.dart';
import 'package:konta/presentation/providers/log_service_provider.dart';
import 'package:konta/presentation/providers/sync_error_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final logService = LogService();
  logService.info(LogTags.config, 'Starting Konta app initialization');

  await dotenv.load(fileName: '.env');
  logService.info(LogTags.config, '.env loaded');

  await SupabaseService.initialize();
  logService.info(LogTags.config, 'Supabase initialized');

  final sharedPreferences = await SharedPreferences.getInstance();
  logService.info(LogTags.config, 'SharedPreferences initialized');

  logService.info(LogTags.config, 'Running app');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        logServiceProvider.overrideWithValue(logService),
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

    ref.listen<SyncErrorState>(syncErrorProvider, (previous, next) {
      if (next.lastError != null && next.lastError != previous?.lastError) {
        if (settings.notificationsEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${next.lastError}'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ref.read(syncErrorProvider.notifier).dismissLastError();
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

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
