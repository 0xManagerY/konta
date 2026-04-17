import 'package:drift/drift.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';

class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  Future<UserProfile?> getLocal(String userId) async {
    Logger.method('ProfileRepository', 'getLocal', {'userId': userId});
    return (_db.select(
      _db.userProfiles,
    )..where((p) => p.id.equals(userId))).getSingleOrNull();
  }

  Future<UserProfile?> getCurrentProfile() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      Logger.warning('No current user', tag: 'PROFILE_REPO');
      return null;
    }
    return getLocal(userId);
  }

  Future<bool> hasCompany() async {
    final profile = await getCurrentProfile();
    if (profile == null) return false;
    return profile.defaultCompanyId != null &&
        profile.defaultCompanyId!.isNotEmpty;
  }

  Future<UserProfile?> fetchFromRemote(String userId) async {
    Logger.method('ProfileRepository', 'fetchFromRemote', {'userId': userId});
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        Logger.warning('No profile found in remote', tag: 'PROFILE_REPO');
        return null;
      }

      Logger.ui('ProfileRepository', 'REMOTE_RESPONSE: $response');

      final profile = UserProfile(
        id: response['id'] as String,
        email: response['email'] as String,
        defaultCompanyId: response['default_company_id'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );

      await _upsertLocal(profile);
      Logger.success('Profile fetched and cached', tag: 'PROFILE_REPO');
      return profile;
    } catch (e, st) {
      Logger.error(
        'Failed to fetch profile',
        tag: 'PROFILE_REPO',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> _upsertLocal(UserProfile profile) async {
    Logger.db('UPSERT_LOCAL', 'profiles', {'id': profile.id});
    await _db.into(_db.userProfiles).insertOnConflictUpdate(profile);
  }

  Future<void> updateProfile(UserProfile profile) async {
    Logger.method('ProfileRepository', 'updateProfile', {'id': profile.id});

    await (_db.update(
      _db.userProfiles,
    )..where((p) => p.id.equals(profile.id))).write(
      UserProfilesCompanion(
        email: Value(profile.email),
        defaultCompanyId: Value(profile.defaultCompanyId),
        updatedAt: Value(DateTime.now()),
      ),
    );

    await SupabaseService.client
        .from('profiles')
        .update({
          'email': profile.email,
          'default_company_id': profile.defaultCompanyId,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', profile.id);

    Logger.success('Profile updated', tag: 'PROFILE_REPO');
  }

  Future<void> upsertProfile(UserProfile profile) async {
    Logger.method('ProfileRepository', 'upsertProfile', {'id': profile.id});
    Logger.ui('ProfileRepository', 'UPSERT_START id=${profile.id}');

    try {
      Logger.ui('ProfileRepository', 'LOCAL_UPSERT_START');
      await _upsertLocal(profile);
      Logger.ui('ProfileRepository', 'LOCAL_UPSERT_OK');
    } catch (e, st) {
      Logger.error(
        'LOCAL_UPSERT_FAILED',
        tag: 'PROFILE_REPO',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    Logger.ui('ProfileRepository', 'REMOTE_UPSERT_START');
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': profile.id,
        'email': profile.email,
        'default_company_id': profile.defaultCompanyId,
        'created_at': profile.createdAt.toIso8601String(),
        'updated_at': profile.updatedAt.toIso8601String(),
      }, onConflict: 'id');
      Logger.ui('ProfileRepository', 'REMOTE_UPSERT_OK');
    } catch (e, st) {
      Logger.error(
        'REMOTE_UPSERT_FAILED',
        tag: 'PROFILE_REPO',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    Logger.success('Profile upserted to remote', tag: 'PROFILE_REPO');
  }
}
