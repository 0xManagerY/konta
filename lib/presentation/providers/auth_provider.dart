import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/repositories/profile_repository.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/presentation/providers/database_provider.dart';
import 'package:konta/presentation/providers/sync_provider.dart';
import 'package:konta/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProfileRepository(db);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return SupabaseService.isAuthenticated;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return SupabaseService.currentUserId;
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final repo = ref.watch(profileRepoProvider);
  return repo.fetchFromRemote(userId);
});

final needsOnboardingProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return true;

  final repo = ref.watch(profileRepoProvider);
  final profile = await repo.fetchFromRemote(userId);

  if (profile == null) return true;

  return profile.defaultCompanyId == null;
});

final syncAndCheckOnboardingProvider = FutureProvider<void>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return;

  final syncService = ref.watch(syncServiceProvider);
  Logger.sync('AUTH_FLOW_SYNC', 'Starting sync for user: $userId');
  await syncService.syncAll();
  Logger.sync('AUTH_FLOW_SYNC_COMPLETE');

  ref.invalidate(needsOnboardingProvider);
});
