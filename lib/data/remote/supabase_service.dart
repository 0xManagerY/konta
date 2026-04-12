import 'package:konta/config/env.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      Logger.warning('Supabase already initialized', tag: 'SUPABASE');
      return;
    }

    Logger.info('Initializing Supabase', tag: 'SUPABASE');
    Logger.network('CONNECT', EnvConfig.supabaseUrl);

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: false,
    );

    _client = Supabase.instance.client;
    _initialized = true;
    Logger.success('Supabase initialized', tag: 'SUPABASE');
  }

  static SupabaseClient get client {
    if (!_initialized || _client == null) {
      Logger.error('Supabase not initialized', tag: 'SUPABASE');
      throw StateError('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static GoTrueClient get auth => client.auth;

  static String? get currentUserId => auth.currentUser?.id;

  static bool get isAuthenticated => auth.currentUser != null;

  static Future<void> signIn(String email, String password) async {
    Logger.method('SupabaseService', 'signIn', {'email': email});
    try {
      await auth.signInWithPassword(email: email, password: password);
      Logger.auth('SIGN_IN_SUCCESS', currentUserId);
    } catch (e, st) {
      Logger.error('Sign in failed', tag: 'SUPABASE', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> signUp(String email, String password) async {
    Logger.method('SupabaseService', 'signUp', {'email': email});
    try {
      final response = await auth.signUp(email: email, password: password);
      Logger.auth('SIGN_UP_SUCCESS', response.user?.id);
    } catch (e, st) {
      Logger.error('Sign up failed', tag: 'SUPABASE', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> signOut() async {
    Logger.method('SupabaseService', 'signOut');
    try {
      await auth.signOut();
      Logger.auth('SIGN_OUT_SUCCESS');
    } catch (e, st) {
      Logger.error(
        'Sign out failed',
        tag: 'SUPABASE',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Future<void> resetPassword(String email) async {
    Logger.method('SupabaseService', 'resetPassword', {'email': email});
    try {
      await auth.resetPasswordForEmail(email);
      Logger.auth('PASSWORD_RESET_SENT', email);
    } catch (e, st) {
      Logger.error(
        'Password reset failed',
        tag: 'SUPABASE',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
