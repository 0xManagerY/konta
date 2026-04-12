import 'package:drift/drift.dart';
import 'package:konta/data/local/database.dart';
import 'package:konta/data/remote/supabase_service.dart';
import 'package:konta/core/utils/logger.dart';

class ProfileRepository {
  final AppDatabase _db;

  ProfileRepository(this._db);

  Future<Profile?> getLocal(String userId) async {
    Logger.method('ProfileRepository', 'getLocal', {'userId': userId});
    return (_db.select(
      _db.profiles,
    )..where((p) => p.id.equals(userId))).getSingleOrNull();
  }

  Future<Profile?> getCurrentProfile() async {
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
    return profile.companyName.isNotEmpty;
  }

  Future<Profile?> fetchFromRemote(String userId) async {
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

      final profile = Profile(
        id: response['id'] as String,
        email: response['email'] as String,
        companyName: (response['company_name'] as String?) ?? '',
        legalStatus: (response['legal_status'] as String?) ?? 'SARL',
        ice: response['ice'] as String?,
        ifNumber: response['if_number'] as String?,
        rc: response['rc'] as String?,
        cnss: response['cnss'] as String?,
        address: response['address'] as String?,
        phone: response['phone'] as String?,
        logoUrl: response['logo_url'] as String?,
        isAutoEntrepreneur:
            (response['is_auto_entrepreneur'] as bool?) ?? false,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
        syncStatus: (response['sync_status'] as String?) ?? 'synced',
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

  Future<void> _upsertLocal(Profile profile) async {
    Logger.db('UPSERT_LOCAL', 'profiles', {'id': profile.id});
    await _db.into(_db.profiles).insertOnConflictUpdate(profile);
  }

  Future<void> updateProfile(Profile profile) async {
    Logger.method('ProfileRepository', 'updateProfile', {'id': profile.id});

    await (_db.update(
      _db.profiles,
    )..where((p) => p.id.equals(profile.id))).write(
      ProfilesCompanion(
        companyName: Value(profile.companyName),
        legalStatus: Value(profile.legalStatus),
        ice: Value(profile.ice),
        ifNumber: Value(profile.ifNumber),
        rc: Value(profile.rc),
        cnss: Value(profile.cnss),
        address: Value(profile.address),
        phone: Value(profile.phone),
        logoUrl: Value(profile.logoUrl),
        isAutoEntrepreneur: Value(profile.isAutoEntrepreneur),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );

    await SupabaseService.client
        .from('profiles')
        .update({
          'company_name': profile.companyName,
          'legal_status': profile.legalStatus,
          'ice': profile.ice,
          'if_number': profile.ifNumber,
          'rc': profile.rc,
          'cnss': profile.cnss,
          'address': profile.address,
          'phone': profile.phone,
          'logo_url': profile.logoUrl,
          'is_auto_entrepreneur': profile.isAutoEntrepreneur,
          'updated_at': DateTime.now().toIso8601String(),
          'sync_status': 'synced',
        })
        .eq('id', profile.id);

    Logger.success('Profile updated', tag: 'PROFILE_REPO');
  }

  Future<void> upsertProfile(Profile profile) async {
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
        'company_name': profile.companyName,
        'legal_status': profile.legalStatus,
        'ice': profile.ice,
        'if_number': profile.ifNumber,
        'rc': profile.rc,
        'cnss': profile.cnss,
        'address': profile.address,
        'phone': profile.phone,
        'logo_url': profile.logoUrl,
        'is_auto_entrepreneur': profile.isAutoEntrepreneur,
        'created_at': profile.createdAt.toIso8601String(),
        'updated_at': profile.updatedAt.toIso8601String(),
        'sync_status': 'synced',
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
