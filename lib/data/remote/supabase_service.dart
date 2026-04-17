import 'package:konta/config/env.dart';
import 'package:konta/domain/services/log_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;
  static final LogService _log = LogService();

  static Future<void> initialize() async {
    if (_initialized) {
      _log.warn(LogTags.supabase, 'initialize - already initialized');
      return;
    }

    _log.info(LogTags.supabase, 'initialize - starting');
    _log.debug(
      LogTags.supabase,
      'initialize - connecting',
      data: {'url': EnvConfig.supabaseUrl},
    );

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: false,
    );

    _client = Supabase.instance.client;
    _initialized = true;
    _log.info(LogTags.supabase, 'initialize - completed');
  }

  static SupabaseClient get client {
    if (!_initialized || _client == null) {
      _log.error(LogTags.supabase, 'client getter - not initialized');
      throw StateError('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static GoTrueClient get auth => client.auth;

  static String? get currentUserId => auth.currentUser?.id;

  static bool get isAuthenticated => auth.currentUser != null;

  static Future<void> signIn(String email, String password) async {
    _log.debug(LogTags.auth, 'signIn - starting', data: {'email': email});
    try {
      await auth.signInWithPassword(email: email, password: password);
      _log.info(
        LogTags.auth,
        'signIn - success',
        data: {'userId': currentUserId},
      );
    } catch (e, st) {
      _log.error(
        LogTags.auth,
        'signIn - failed',
        error: e,
        stack: st,
        data: {'email': email},
      );
      rethrow;
    }
  }

  static Future<void> signUp(String email, String password) async {
    _log.debug(LogTags.auth, 'signUp - starting', data: {'email': email});
    try {
      final response = await auth.signUp(email: email, password: password);
      _log.info(
        LogTags.auth,
        'signUp - success',
        data: {'userId': response.user?.id},
      );
    } catch (e, st) {
      _log.error(LogTags.auth, 'signUp - failed', error: e, stack: st);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    _log.debug(LogTags.auth, 'signOut - starting');
    try {
      await auth.signOut();
      _log.info(LogTags.auth, 'signOut - success');
    } catch (e, st) {
      _log.error(LogTags.auth, 'signOut - failed', error: e, stack: st);
      rethrow;
    }
  }

  static Future<void> resetPassword(String email) async {
    _log.debug(
      LogTags.auth,
      'resetPassword - starting',
      data: {'email': email},
    );
    try {
      await auth.resetPasswordForEmail(email);
      _log.info(
        LogTags.auth,
        'resetPassword - email sent',
        data: {'email': email},
      );
    } catch (e, st) {
      _log.error(LogTags.auth, 'resetPassword - failed', error: e, stack: st);
      rethrow;
    }
  }

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
