import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/auth_provider.dart';

class AuthWrapperScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapperScreen({super.key, required this.child});

  @override
  ConsumerState<AuthWrapperScreen> createState() => _AuthWrapperScreenState();
}

class _AuthWrapperScreenState extends ConsumerState<AuthWrapperScreen> {
  bool _isChecking = true;
  String _status = 'Vérification...';

  @override
  void initState() {
    super.initState();
    _checkAuthAndOnboarding();
  }

  Future<void> _checkAuthAndOnboarding() async {
    Logger.ui('AuthWrapper', 'CHECK_AUTH');

    if (!mounted) return;
    setState(() => _status = 'Vérification de l\'authentification...');

    await Future.delayed(const Duration(milliseconds: 100));

    if (!SupabaseService.isAuthenticated) {
      Logger.ui('AuthWrapper', 'NOT_AUTHENTICATED');
      if (mounted) {
        setState(() => _isChecking = false);
      }
      return;
    }

    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isChecking = false);
      return;
    }

    if (mounted) setState(() => _status = 'Récupération du profil...');

    try {
      final needsOnboarding = await ref.read(needsOnboardingProvider.future);
      Logger.ui('AuthWrapper', 'NEEDS_ONBOARDING: $needsOnboarding');

      if (needsOnboarding) {
        if (mounted) {
          context.go('/onboarding');
          return;
        }
      }

      if (mounted) setState(() => _status = 'Synchronisation...');

      await ref.read(syncServiceProvider).syncAll();
      Logger.ui('AuthWrapper', 'SYNC_COMPLETE');

      if (mounted) {
        setState(() => _isChecking = false);
      }
    } catch (e, st) {
      Logger.error(
        'Auth check failed',
        tag: 'AUTH_WRAPPER',
        error: e,
        stackTrace: st,
      );
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoading || _isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_status, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final isAuthenticated = authState.value?.session != null;

    if (!isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
