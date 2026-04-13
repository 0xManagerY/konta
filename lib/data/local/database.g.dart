// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalStatusMeta = const VerificationMeta(
    'legalStatus',
  );
  @override
  late final GeneratedColumn<String> legalStatus = GeneratedColumn<String>(
    'legal_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iceMeta = const VerificationMeta('ice');
  @override
  late final GeneratedColumn<String> ice = GeneratedColumn<String>(
    'ice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ifNumberMeta = const VerificationMeta(
    'ifNumber',
  );
  @override
  late final GeneratedColumn<String> ifNumber = GeneratedColumn<String>(
    'if_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rcMeta = const VerificationMeta('rc');
  @override
  late final GeneratedColumn<String> rc = GeneratedColumn<String>(
    'rc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnssMeta = const VerificationMeta('cnss');
  @override
  late final GeneratedColumn<String> cnss = GeneratedColumn<String>(
    'cnss',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAutoEntrepreneurMeta =
      const VerificationMeta('isAutoEntrepreneur');
  @override
  late final GeneratedColumn<bool> isAutoEntrepreneur = GeneratedColumn<bool>(
    'is_auto_entrepreneur',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_auto_entrepreneur" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    companyName,
    legalStatus,
    ice,
    ifNumber,
    rc,
    cnss,
    address,
    phone,
    logoUrl,
    isAutoEntrepreneur,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('legal_status')) {
      context.handle(
        _legalStatusMeta,
        legalStatus.isAcceptableOrUnknown(
          data['legal_status']!,
          _legalStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_legalStatusMeta);
    }
    if (data.containsKey('ice')) {
      context.handle(
        _iceMeta,
        ice.isAcceptableOrUnknown(data['ice']!, _iceMeta),
      );
    }
    if (data.containsKey('if_number')) {
      context.handle(
        _ifNumberMeta,
        ifNumber.isAcceptableOrUnknown(data['if_number']!, _ifNumberMeta),
      );
    }
    if (data.containsKey('rc')) {
      context.handle(_rcMeta, rc.isAcceptableOrUnknown(data['rc']!, _rcMeta));
    }
    if (data.containsKey('cnss')) {
      context.handle(
        _cnssMeta,
        cnss.isAcceptableOrUnknown(data['cnss']!, _cnssMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('is_auto_entrepreneur')) {
      context.handle(
        _isAutoEntrepreneurMeta,
        isAutoEntrepreneur.isAcceptableOrUnknown(
          data['is_auto_entrepreneur']!,
          _isAutoEntrepreneurMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      legalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_status'],
      )!,
      ice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ice'],
      ),
      ifNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}if_number'],
      ),
      rc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rc'],
      ),
      cnss: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnss'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      isAutoEntrepreneur: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_entrepreneur'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String email;
  final String companyName;
  final String legalStatus;
  final String? ice;
  final String? ifNumber;
  final String? rc;
  final String? cnss;
  final String? address;
  final String? phone;
  final String? logoUrl;
  final bool isAutoEntrepreneur;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Profile({
    required this.id,
    required this.email,
    required this.companyName,
    required this.legalStatus,
    this.ice,
    this.ifNumber,
    this.rc,
    this.cnss,
    this.address,
    this.phone,
    this.logoUrl,
    required this.isAutoEntrepreneur,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['company_name'] = Variable<String>(companyName);
    map['legal_status'] = Variable<String>(legalStatus);
    if (!nullToAbsent || ice != null) {
      map['ice'] = Variable<String>(ice);
    }
    if (!nullToAbsent || ifNumber != null) {
      map['if_number'] = Variable<String>(ifNumber);
    }
    if (!nullToAbsent || rc != null) {
      map['rc'] = Variable<String>(rc);
    }
    if (!nullToAbsent || cnss != null) {
      map['cnss'] = Variable<String>(cnss);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    map['is_auto_entrepreneur'] = Variable<bool>(isAutoEntrepreneur);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      email: Value(email),
      companyName: Value(companyName),
      legalStatus: Value(legalStatus),
      ice: ice == null && nullToAbsent ? const Value.absent() : Value(ice),
      ifNumber: ifNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ifNumber),
      rc: rc == null && nullToAbsent ? const Value.absent() : Value(rc),
      cnss: cnss == null && nullToAbsent ? const Value.absent() : Value(cnss),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      isAutoEntrepreneur: Value(isAutoEntrepreneur),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      companyName: serializer.fromJson<String>(json['companyName']),
      legalStatus: serializer.fromJson<String>(json['legalStatus']),
      ice: serializer.fromJson<String?>(json['ice']),
      ifNumber: serializer.fromJson<String?>(json['ifNumber']),
      rc: serializer.fromJson<String?>(json['rc']),
      cnss: serializer.fromJson<String?>(json['cnss']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      isAutoEntrepreneur: serializer.fromJson<bool>(json['isAutoEntrepreneur']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'companyName': serializer.toJson<String>(companyName),
      'legalStatus': serializer.toJson<String>(legalStatus),
      'ice': serializer.toJson<String?>(ice),
      'ifNumber': serializer.toJson<String?>(ifNumber),
      'rc': serializer.toJson<String?>(rc),
      'cnss': serializer.toJson<String?>(cnss),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'isAutoEntrepreneur': serializer.toJson<bool>(isAutoEntrepreneur),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Profile copyWith({
    String? id,
    String? email,
    String? companyName,
    String? legalStatus,
    Value<String?> ice = const Value.absent(),
    Value<String?> ifNumber = const Value.absent(),
    Value<String?> rc = const Value.absent(),
    Value<String?> cnss = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    bool? isAutoEntrepreneur,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Profile(
    id: id ?? this.id,
    email: email ?? this.email,
    companyName: companyName ?? this.companyName,
    legalStatus: legalStatus ?? this.legalStatus,
    ice: ice.present ? ice.value : this.ice,
    ifNumber: ifNumber.present ? ifNumber.value : this.ifNumber,
    rc: rc.present ? rc.value : this.rc,
    cnss: cnss.present ? cnss.value : this.cnss,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    isAutoEntrepreneur: isAutoEntrepreneur ?? this.isAutoEntrepreneur,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      legalStatus: data.legalStatus.present
          ? data.legalStatus.value
          : this.legalStatus,
      ice: data.ice.present ? data.ice.value : this.ice,
      ifNumber: data.ifNumber.present ? data.ifNumber.value : this.ifNumber,
      rc: data.rc.present ? data.rc.value : this.rc,
      cnss: data.cnss.present ? data.cnss.value : this.cnss,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      isAutoEntrepreneur: data.isAutoEntrepreneur.present
          ? data.isAutoEntrepreneur.value
          : this.isAutoEntrepreneur,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('companyName: $companyName, ')
          ..write('legalStatus: $legalStatus, ')
          ..write('ice: $ice, ')
          ..write('ifNumber: $ifNumber, ')
          ..write('rc: $rc, ')
          ..write('cnss: $cnss, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('isAutoEntrepreneur: $isAutoEntrepreneur, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    companyName,
    legalStatus,
    ice,
    ifNumber,
    rc,
    cnss,
    address,
    phone,
    logoUrl,
    isAutoEntrepreneur,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.email == this.email &&
          other.companyName == this.companyName &&
          other.legalStatus == this.legalStatus &&
          other.ice == this.ice &&
          other.ifNumber == this.ifNumber &&
          other.rc == this.rc &&
          other.cnss == this.cnss &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.logoUrl == this.logoUrl &&
          other.isAutoEntrepreneur == this.isAutoEntrepreneur &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> companyName;
  final Value<String> legalStatus;
  final Value<String?> ice;
  final Value<String?> ifNumber;
  final Value<String?> rc;
  final Value<String?> cnss;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> logoUrl;
  final Value<bool> isAutoEntrepreneur;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.companyName = const Value.absent(),
    this.legalStatus = const Value.absent(),
    this.ice = const Value.absent(),
    this.ifNumber = const Value.absent(),
    this.rc = const Value.absent(),
    this.cnss = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.isAutoEntrepreneur = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String email,
    required String companyName,
    required String legalStatus,
    this.ice = const Value.absent(),
    this.ifNumber = const Value.absent(),
    this.rc = const Value.absent(),
    this.cnss = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.isAutoEntrepreneur = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       companyName = Value(companyName),
       legalStatus = Value(legalStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? companyName,
    Expression<String>? legalStatus,
    Expression<String>? ice,
    Expression<String>? ifNumber,
    Expression<String>? rc,
    Expression<String>? cnss,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? logoUrl,
    Expression<bool>? isAutoEntrepreneur,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (companyName != null) 'company_name': companyName,
      if (legalStatus != null) 'legal_status': legalStatus,
      if (ice != null) 'ice': ice,
      if (ifNumber != null) 'if_number': ifNumber,
      if (rc != null) 'rc': rc,
      if (cnss != null) 'cnss': cnss,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (isAutoEntrepreneur != null)
        'is_auto_entrepreneur': isAutoEntrepreneur,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? companyName,
    Value<String>? legalStatus,
    Value<String?>? ice,
    Value<String?>? ifNumber,
    Value<String?>? rc,
    Value<String?>? cnss,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? logoUrl,
    Value<bool>? isAutoEntrepreneur,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      companyName: companyName ?? this.companyName,
      legalStatus: legalStatus ?? this.legalStatus,
      ice: ice ?? this.ice,
      ifNumber: ifNumber ?? this.ifNumber,
      rc: rc ?? this.rc,
      cnss: cnss ?? this.cnss,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      logoUrl: logoUrl ?? this.logoUrl,
      isAutoEntrepreneur: isAutoEntrepreneur ?? this.isAutoEntrepreneur,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (legalStatus.present) {
      map['legal_status'] = Variable<String>(legalStatus.value);
    }
    if (ice.present) {
      map['ice'] = Variable<String>(ice.value);
    }
    if (ifNumber.present) {
      map['if_number'] = Variable<String>(ifNumber.value);
    }
    if (rc.present) {
      map['rc'] = Variable<String>(rc.value);
    }
    if (cnss.present) {
      map['cnss'] = Variable<String>(cnss.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (isAutoEntrepreneur.present) {
      map['is_auto_entrepreneur'] = Variable<bool>(isAutoEntrepreneur.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('companyName: $companyName, ')
          ..write('legalStatus: $legalStatus, ')
          ..write('ice: $ice, ')
          ..write('ifNumber: $ifNumber, ')
          ..write('rc: $rc, ')
          ..write('cnss: $cnss, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('isAutoEntrepreneur: $isAutoEntrepreneur, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iceMeta = const VerificationMeta('ice');
  @override
  late final GeneratedColumn<String> ice = GeneratedColumn<String>(
    'ice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rcMeta = const VerificationMeta('rc');
  @override
  late final GeneratedColumn<String> rc = GeneratedColumn<String>(
    'rc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ifNumberMeta = const VerificationMeta(
    'ifNumber',
  );
  @override
  late final GeneratedColumn<String> ifNumber = GeneratedColumn<String>(
    'if_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patenteMeta = const VerificationMeta(
    'patente',
  );
  @override
  late final GeneratedColumn<String> patente = GeneratedColumn<String>(
    'patente',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnssMeta = const VerificationMeta('cnss');
  @override
  late final GeneratedColumn<String> cnss = GeneratedColumn<String>(
    'cnss',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalFormMeta = const VerificationMeta(
    'legalForm',
  );
  @override
  late final GeneratedColumn<String> legalForm = GeneratedColumn<String>(
    'legal_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capitalMeta = const VerificationMeta(
    'capital',
  );
  @override
  late final GeneratedColumn<String> capital = GeneratedColumn<String>(
    'capital',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phonesMeta = const VerificationMeta('phones');
  @override
  late final GeneratedColumn<String> phones = GeneratedColumn<String>(
    'phones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faxMeta = const VerificationMeta('fax');
  @override
  late final GeneratedColumn<String> fax = GeneratedColumn<String>(
    'fax',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailsMeta = const VerificationMeta('emails');
  @override
  late final GeneratedColumn<String> emails = GeneratedColumn<String>(
    'emails',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    ice,
    rc,
    ifNumber,
    patente,
    cnss,
    legalForm,
    capital,
    status,
    address,
    phones,
    fax,
    emails,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ice')) {
      context.handle(
        _iceMeta,
        ice.isAcceptableOrUnknown(data['ice']!, _iceMeta),
      );
    }
    if (data.containsKey('rc')) {
      context.handle(_rcMeta, rc.isAcceptableOrUnknown(data['rc']!, _rcMeta));
    }
    if (data.containsKey('if_number')) {
      context.handle(
        _ifNumberMeta,
        ifNumber.isAcceptableOrUnknown(data['if_number']!, _ifNumberMeta),
      );
    }
    if (data.containsKey('patente')) {
      context.handle(
        _patenteMeta,
        patente.isAcceptableOrUnknown(data['patente']!, _patenteMeta),
      );
    }
    if (data.containsKey('cnss')) {
      context.handle(
        _cnssMeta,
        cnss.isAcceptableOrUnknown(data['cnss']!, _cnssMeta),
      );
    }
    if (data.containsKey('legal_form')) {
      context.handle(
        _legalFormMeta,
        legalForm.isAcceptableOrUnknown(data['legal_form']!, _legalFormMeta),
      );
    }
    if (data.containsKey('capital')) {
      context.handle(
        _capitalMeta,
        capital.isAcceptableOrUnknown(data['capital']!, _capitalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phones')) {
      context.handle(
        _phonesMeta,
        phones.isAcceptableOrUnknown(data['phones']!, _phonesMeta),
      );
    }
    if (data.containsKey('fax')) {
      context.handle(
        _faxMeta,
        fax.isAcceptableOrUnknown(data['fax']!, _faxMeta),
      );
    }
    if (data.containsKey('emails')) {
      context.handle(
        _emailsMeta,
        emails.isAcceptableOrUnknown(data['emails']!, _emailsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      ice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ice'],
      ),
      rc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rc'],
      ),
      ifNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}if_number'],
      ),
      patente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patente'],
      ),
      cnss: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnss'],
      ),
      legalForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_form'],
      ),
      capital: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capital'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phones'],
      ),
      fax: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fax'],
      ),
      emails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emails'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String userId;
  final String name;
  final String? ice;
  final String? rc;
  final String? ifNumber;
  final String? patente;
  final String? cnss;
  final String? legalForm;
  final String? capital;
  final String? status;
  final String? address;
  final String? phones;
  final String? fax;
  final String? emails;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Customer({
    required this.id,
    required this.userId,
    required this.name,
    this.ice,
    this.rc,
    this.ifNumber,
    this.patente,
    this.cnss,
    this.legalForm,
    this.capital,
    this.status,
    this.address,
    this.phones,
    this.fax,
    this.emails,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || ice != null) {
      map['ice'] = Variable<String>(ice);
    }
    if (!nullToAbsent || rc != null) {
      map['rc'] = Variable<String>(rc);
    }
    if (!nullToAbsent || ifNumber != null) {
      map['if_number'] = Variable<String>(ifNumber);
    }
    if (!nullToAbsent || patente != null) {
      map['patente'] = Variable<String>(patente);
    }
    if (!nullToAbsent || cnss != null) {
      map['cnss'] = Variable<String>(cnss);
    }
    if (!nullToAbsent || legalForm != null) {
      map['legal_form'] = Variable<String>(legalForm);
    }
    if (!nullToAbsent || capital != null) {
      map['capital'] = Variable<String>(capital);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phones != null) {
      map['phones'] = Variable<String>(phones);
    }
    if (!nullToAbsent || fax != null) {
      map['fax'] = Variable<String>(fax);
    }
    if (!nullToAbsent || emails != null) {
      map['emails'] = Variable<String>(emails);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      ice: ice == null && nullToAbsent ? const Value.absent() : Value(ice),
      rc: rc == null && nullToAbsent ? const Value.absent() : Value(rc),
      ifNumber: ifNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ifNumber),
      patente: patente == null && nullToAbsent
          ? const Value.absent()
          : Value(patente),
      cnss: cnss == null && nullToAbsent ? const Value.absent() : Value(cnss),
      legalForm: legalForm == null && nullToAbsent
          ? const Value.absent()
          : Value(legalForm),
      capital: capital == null && nullToAbsent
          ? const Value.absent()
          : Value(capital),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phones: phones == null && nullToAbsent
          ? const Value.absent()
          : Value(phones),
      fax: fax == null && nullToAbsent ? const Value.absent() : Value(fax),
      emails: emails == null && nullToAbsent
          ? const Value.absent()
          : Value(emails),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      ice: serializer.fromJson<String?>(json['ice']),
      rc: serializer.fromJson<String?>(json['rc']),
      ifNumber: serializer.fromJson<String?>(json['ifNumber']),
      patente: serializer.fromJson<String?>(json['patente']),
      cnss: serializer.fromJson<String?>(json['cnss']),
      legalForm: serializer.fromJson<String?>(json['legalForm']),
      capital: serializer.fromJson<String?>(json['capital']),
      status: serializer.fromJson<String?>(json['status']),
      address: serializer.fromJson<String?>(json['address']),
      phones: serializer.fromJson<String?>(json['phones']),
      fax: serializer.fromJson<String?>(json['fax']),
      emails: serializer.fromJson<String?>(json['emails']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'ice': serializer.toJson<String?>(ice),
      'rc': serializer.toJson<String?>(rc),
      'ifNumber': serializer.toJson<String?>(ifNumber),
      'patente': serializer.toJson<String?>(patente),
      'cnss': serializer.toJson<String?>(cnss),
      'legalForm': serializer.toJson<String?>(legalForm),
      'capital': serializer.toJson<String?>(capital),
      'status': serializer.toJson<String?>(status),
      'address': serializer.toJson<String?>(address),
      'phones': serializer.toJson<String?>(phones),
      'fax': serializer.toJson<String?>(fax),
      'emails': serializer.toJson<String?>(emails),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Customer copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> ice = const Value.absent(),
    Value<String?> rc = const Value.absent(),
    Value<String?> ifNumber = const Value.absent(),
    Value<String?> patente = const Value.absent(),
    Value<String?> cnss = const Value.absent(),
    Value<String?> legalForm = const Value.absent(),
    Value<String?> capital = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phones = const Value.absent(),
    Value<String?> fax = const Value.absent(),
    Value<String?> emails = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Customer(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    ice: ice.present ? ice.value : this.ice,
    rc: rc.present ? rc.value : this.rc,
    ifNumber: ifNumber.present ? ifNumber.value : this.ifNumber,
    patente: patente.present ? patente.value : this.patente,
    cnss: cnss.present ? cnss.value : this.cnss,
    legalForm: legalForm.present ? legalForm.value : this.legalForm,
    capital: capital.present ? capital.value : this.capital,
    status: status.present ? status.value : this.status,
    address: address.present ? address.value : this.address,
    phones: phones.present ? phones.value : this.phones,
    fax: fax.present ? fax.value : this.fax,
    emails: emails.present ? emails.value : this.emails,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      ice: data.ice.present ? data.ice.value : this.ice,
      rc: data.rc.present ? data.rc.value : this.rc,
      ifNumber: data.ifNumber.present ? data.ifNumber.value : this.ifNumber,
      patente: data.patente.present ? data.patente.value : this.patente,
      cnss: data.cnss.present ? data.cnss.value : this.cnss,
      legalForm: data.legalForm.present ? data.legalForm.value : this.legalForm,
      capital: data.capital.present ? data.capital.value : this.capital,
      status: data.status.present ? data.status.value : this.status,
      address: data.address.present ? data.address.value : this.address,
      phones: data.phones.present ? data.phones.value : this.phones,
      fax: data.fax.present ? data.fax.value : this.fax,
      emails: data.emails.present ? data.emails.value : this.emails,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('ice: $ice, ')
          ..write('rc: $rc, ')
          ..write('ifNumber: $ifNumber, ')
          ..write('patente: $patente, ')
          ..write('cnss: $cnss, ')
          ..write('legalForm: $legalForm, ')
          ..write('capital: $capital, ')
          ..write('status: $status, ')
          ..write('address: $address, ')
          ..write('phones: $phones, ')
          ..write('fax: $fax, ')
          ..write('emails: $emails, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    ice,
    rc,
    ifNumber,
    patente,
    cnss,
    legalForm,
    capital,
    status,
    address,
    phones,
    fax,
    emails,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.ice == this.ice &&
          other.rc == this.rc &&
          other.ifNumber == this.ifNumber &&
          other.patente == this.patente &&
          other.cnss == this.cnss &&
          other.legalForm == this.legalForm &&
          other.capital == this.capital &&
          other.status == this.status &&
          other.address == this.address &&
          other.phones == this.phones &&
          other.fax == this.fax &&
          other.emails == this.emails &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> ice;
  final Value<String?> rc;
  final Value<String?> ifNumber;
  final Value<String?> patente;
  final Value<String?> cnss;
  final Value<String?> legalForm;
  final Value<String?> capital;
  final Value<String?> status;
  final Value<String?> address;
  final Value<String?> phones;
  final Value<String?> fax;
  final Value<String?> emails;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.ice = const Value.absent(),
    this.rc = const Value.absent(),
    this.ifNumber = const Value.absent(),
    this.patente = const Value.absent(),
    this.cnss = const Value.absent(),
    this.legalForm = const Value.absent(),
    this.capital = const Value.absent(),
    this.status = const Value.absent(),
    this.address = const Value.absent(),
    this.phones = const Value.absent(),
    this.fax = const Value.absent(),
    this.emails = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.ice = const Value.absent(),
    this.rc = const Value.absent(),
    this.ifNumber = const Value.absent(),
    this.patente = const Value.absent(),
    this.cnss = const Value.absent(),
    this.legalForm = const Value.absent(),
    this.capital = const Value.absent(),
    this.status = const Value.absent(),
    this.address = const Value.absent(),
    this.phones = const Value.absent(),
    this.fax = const Value.absent(),
    this.emails = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? ice,
    Expression<String>? rc,
    Expression<String>? ifNumber,
    Expression<String>? patente,
    Expression<String>? cnss,
    Expression<String>? legalForm,
    Expression<String>? capital,
    Expression<String>? status,
    Expression<String>? address,
    Expression<String>? phones,
    Expression<String>? fax,
    Expression<String>? emails,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (ice != null) 'ice': ice,
      if (rc != null) 'rc': rc,
      if (ifNumber != null) 'if_number': ifNumber,
      if (patente != null) 'patente': patente,
      if (cnss != null) 'cnss': cnss,
      if (legalForm != null) 'legal_form': legalForm,
      if (capital != null) 'capital': capital,
      if (status != null) 'status': status,
      if (address != null) 'address': address,
      if (phones != null) 'phones': phones,
      if (fax != null) 'fax': fax,
      if (emails != null) 'emails': emails,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? ice,
    Value<String?>? rc,
    Value<String?>? ifNumber,
    Value<String?>? patente,
    Value<String?>? cnss,
    Value<String?>? legalForm,
    Value<String?>? capital,
    Value<String?>? status,
    Value<String?>? address,
    Value<String?>? phones,
    Value<String?>? fax,
    Value<String?>? emails,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      ice: ice ?? this.ice,
      rc: rc ?? this.rc,
      ifNumber: ifNumber ?? this.ifNumber,
      patente: patente ?? this.patente,
      cnss: cnss ?? this.cnss,
      legalForm: legalForm ?? this.legalForm,
      capital: capital ?? this.capital,
      status: status ?? this.status,
      address: address ?? this.address,
      phones: phones ?? this.phones,
      fax: fax ?? this.fax,
      emails: emails ?? this.emails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (ice.present) {
      map['ice'] = Variable<String>(ice.value);
    }
    if (rc.present) {
      map['rc'] = Variable<String>(rc.value);
    }
    if (ifNumber.present) {
      map['if_number'] = Variable<String>(ifNumber.value);
    }
    if (patente.present) {
      map['patente'] = Variable<String>(patente.value);
    }
    if (cnss.present) {
      map['cnss'] = Variable<String>(cnss.value);
    }
    if (legalForm.present) {
      map['legal_form'] = Variable<String>(legalForm.value);
    }
    if (capital.present) {
      map['capital'] = Variable<String>(capital.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phones.present) {
      map['phones'] = Variable<String>(phones.value);
    }
    if (fax.present) {
      map['fax'] = Variable<String>(fax.value);
    }
    if (emails.present) {
      map['emails'] = Variable<String>(emails.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('ice: $ice, ')
          ..write('rc: $rc, ')
          ..write('ifNumber: $ifNumber, ')
          ..write('patente: $patente, ')
          ..write('cnss: $cnss, ')
          ..write('legalForm: $legalForm, ')
          ..write('capital: $capital, ')
          ..write('status: $status, ')
          ..write('address: $address, ')
          ..write('phones: $phones, ')
          ..write('fax: $fax, ')
          ..write('emails: $emails, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    description,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Product({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Product(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    description,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tvaAmountMeta = const VerificationMeta(
    'tvaAmount',
  );
  @override
  late final GeneratedColumn<double> tvaAmount = GeneratedColumn<double>(
    'tva_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentDocumentIdMeta = const VerificationMeta(
    'parentDocumentId',
  );
  @override
  late final GeneratedColumn<String> parentDocumentId = GeneratedColumn<String>(
    'parent_document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentDocumentTypeMeta =
      const VerificationMeta('parentDocumentType');
  @override
  late final GeneratedColumn<String> parentDocumentType =
      GeneratedColumn<String>(
        'parent_document_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _refundReasonMeta = const VerificationMeta(
    'refundReason',
  );
  @override
  late final GeneratedColumn<String> refundReason = GeneratedColumn<String>(
    'refund_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isConvertedMeta = const VerificationMeta(
    'isConverted',
  );
  @override
  late final GeneratedColumn<bool> isConverted = GeneratedColumn<bool>(
    'is_converted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_converted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    customerId,
    type,
    number,
    status,
    issueDate,
    dueDate,
    subtotal,
    tvaAmount,
    total,
    notes,
    parentDocumentId,
    parentDocumentType,
    refundReason,
    isConverted,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    }
    if (data.containsKey('tva_amount')) {
      context.handle(
        _tvaAmountMeta,
        tvaAmount.isAcceptableOrUnknown(data['tva_amount']!, _tvaAmountMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('parent_document_id')) {
      context.handle(
        _parentDocumentIdMeta,
        parentDocumentId.isAcceptableOrUnknown(
          data['parent_document_id']!,
          _parentDocumentIdMeta,
        ),
      );
    }
    if (data.containsKey('parent_document_type')) {
      context.handle(
        _parentDocumentTypeMeta,
        parentDocumentType.isAcceptableOrUnknown(
          data['parent_document_type']!,
          _parentDocumentTypeMeta,
        ),
      );
    }
    if (data.containsKey('refund_reason')) {
      context.handle(
        _refundReasonMeta,
        refundReason.isAcceptableOrUnknown(
          data['refund_reason']!,
          _refundReasonMeta,
        ),
      );
    }
    if (data.containsKey('is_converted')) {
      context.handle(
        _isConvertedMeta,
        isConverted.isAcceptableOrUnknown(
          data['is_converted']!,
          _isConvertedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tvaAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tva_amount'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      parentDocumentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_document_id'],
      ),
      parentDocumentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_document_type'],
      ),
      refundReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_reason'],
      ),
      isConverted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_converted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String userId;
  final String customerId;
  final String type;
  final String number;
  final String status;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double subtotal;
  final double tvaAmount;
  final double total;
  final String? notes;
  final String? parentDocumentId;
  final String? parentDocumentType;
  final String? refundReason;
  final bool isConverted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Invoice({
    required this.id,
    required this.userId,
    required this.customerId,
    required this.type,
    required this.number,
    required this.status,
    required this.issueDate,
    this.dueDate,
    required this.subtotal,
    required this.tvaAmount,
    required this.total,
    this.notes,
    this.parentDocumentId,
    this.parentDocumentType,
    this.refundReason,
    required this.isConverted,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['customer_id'] = Variable<String>(customerId);
    map['type'] = Variable<String>(type);
    map['number'] = Variable<String>(number);
    map['status'] = Variable<String>(status);
    map['issue_date'] = Variable<DateTime>(issueDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['subtotal'] = Variable<double>(subtotal);
    map['tva_amount'] = Variable<double>(tvaAmount);
    map['total'] = Variable<double>(total);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || parentDocumentId != null) {
      map['parent_document_id'] = Variable<String>(parentDocumentId);
    }
    if (!nullToAbsent || parentDocumentType != null) {
      map['parent_document_type'] = Variable<String>(parentDocumentType);
    }
    if (!nullToAbsent || refundReason != null) {
      map['refund_reason'] = Variable<String>(refundReason);
    }
    map['is_converted'] = Variable<bool>(isConverted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      userId: Value(userId),
      customerId: Value(customerId),
      type: Value(type),
      number: Value(number),
      status: Value(status),
      issueDate: Value(issueDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      subtotal: Value(subtotal),
      tvaAmount: Value(tvaAmount),
      total: Value(total),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      parentDocumentId: parentDocumentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentDocumentId),
      parentDocumentType: parentDocumentType == null && nullToAbsent
          ? const Value.absent()
          : Value(parentDocumentType),
      refundReason: refundReason == null && nullToAbsent
          ? const Value.absent()
          : Value(refundReason),
      isConverted: Value(isConverted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      customerId: serializer.fromJson<String>(json['customerId']),
      type: serializer.fromJson<String>(json['type']),
      number: serializer.fromJson<String>(json['number']),
      status: serializer.fromJson<String>(json['status']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tvaAmount: serializer.fromJson<double>(json['tvaAmount']),
      total: serializer.fromJson<double>(json['total']),
      notes: serializer.fromJson<String?>(json['notes']),
      parentDocumentId: serializer.fromJson<String?>(json['parentDocumentId']),
      parentDocumentType: serializer.fromJson<String?>(
        json['parentDocumentType'],
      ),
      refundReason: serializer.fromJson<String?>(json['refundReason']),
      isConverted: serializer.fromJson<bool>(json['isConverted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'customerId': serializer.toJson<String>(customerId),
      'type': serializer.toJson<String>(type),
      'number': serializer.toJson<String>(number),
      'status': serializer.toJson<String>(status),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'subtotal': serializer.toJson<double>(subtotal),
      'tvaAmount': serializer.toJson<double>(tvaAmount),
      'total': serializer.toJson<double>(total),
      'notes': serializer.toJson<String?>(notes),
      'parentDocumentId': serializer.toJson<String?>(parentDocumentId),
      'parentDocumentType': serializer.toJson<String?>(parentDocumentType),
      'refundReason': serializer.toJson<String?>(refundReason),
      'isConverted': serializer.toJson<bool>(isConverted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? customerId,
    String? type,
    String? number,
    String? status,
    DateTime? issueDate,
    Value<DateTime?> dueDate = const Value.absent(),
    double? subtotal,
    double? tvaAmount,
    double? total,
    Value<String?> notes = const Value.absent(),
    Value<String?> parentDocumentId = const Value.absent(),
    Value<String?> parentDocumentType = const Value.absent(),
    Value<String?> refundReason = const Value.absent(),
    bool? isConverted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Invoice(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    customerId: customerId ?? this.customerId,
    type: type ?? this.type,
    number: number ?? this.number,
    status: status ?? this.status,
    issueDate: issueDate ?? this.issueDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    subtotal: subtotal ?? this.subtotal,
    tvaAmount: tvaAmount ?? this.tvaAmount,
    total: total ?? this.total,
    notes: notes.present ? notes.value : this.notes,
    parentDocumentId: parentDocumentId.present
        ? parentDocumentId.value
        : this.parentDocumentId,
    parentDocumentType: parentDocumentType.present
        ? parentDocumentType.value
        : this.parentDocumentType,
    refundReason: refundReason.present ? refundReason.value : this.refundReason,
    isConverted: isConverted ?? this.isConverted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      type: data.type.present ? data.type.value : this.type,
      number: data.number.present ? data.number.value : this.number,
      status: data.status.present ? data.status.value : this.status,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tvaAmount: data.tvaAmount.present ? data.tvaAmount.value : this.tvaAmount,
      total: data.total.present ? data.total.value : this.total,
      notes: data.notes.present ? data.notes.value : this.notes,
      parentDocumentId: data.parentDocumentId.present
          ? data.parentDocumentId.value
          : this.parentDocumentId,
      parentDocumentType: data.parentDocumentType.present
          ? data.parentDocumentType.value
          : this.parentDocumentType,
      refundReason: data.refundReason.present
          ? data.refundReason.value
          : this.refundReason,
      isConverted: data.isConverted.present
          ? data.isConverted.value
          : this.isConverted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('number: $number, ')
          ..write('status: $status, ')
          ..write('issueDate: $issueDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('tvaAmount: $tvaAmount, ')
          ..write('total: $total, ')
          ..write('notes: $notes, ')
          ..write('parentDocumentId: $parentDocumentId, ')
          ..write('parentDocumentType: $parentDocumentType, ')
          ..write('refundReason: $refundReason, ')
          ..write('isConverted: $isConverted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    customerId,
    type,
    number,
    status,
    issueDate,
    dueDate,
    subtotal,
    tvaAmount,
    total,
    notes,
    parentDocumentId,
    parentDocumentType,
    refundReason,
    isConverted,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.customerId == this.customerId &&
          other.type == this.type &&
          other.number == this.number &&
          other.status == this.status &&
          other.issueDate == this.issueDate &&
          other.dueDate == this.dueDate &&
          other.subtotal == this.subtotal &&
          other.tvaAmount == this.tvaAmount &&
          other.total == this.total &&
          other.notes == this.notes &&
          other.parentDocumentId == this.parentDocumentId &&
          other.parentDocumentType == this.parentDocumentType &&
          other.refundReason == this.refundReason &&
          other.isConverted == this.isConverted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> customerId;
  final Value<String> type;
  final Value<String> number;
  final Value<String> status;
  final Value<DateTime> issueDate;
  final Value<DateTime?> dueDate;
  final Value<double> subtotal;
  final Value<double> tvaAmount;
  final Value<double> total;
  final Value<String?> notes;
  final Value<String?> parentDocumentId;
  final Value<String?> parentDocumentType;
  final Value<String?> refundReason;
  final Value<bool> isConverted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.type = const Value.absent(),
    this.number = const Value.absent(),
    this.status = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tvaAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.notes = const Value.absent(),
    this.parentDocumentId = const Value.absent(),
    this.parentDocumentType = const Value.absent(),
    this.refundReason = const Value.absent(),
    this.isConverted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    required String id,
    required String userId,
    required String customerId,
    required String type,
    required String number,
    required String status,
    required DateTime issueDate,
    this.dueDate = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tvaAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.notes = const Value.absent(),
    this.parentDocumentId = const Value.absent(),
    this.parentDocumentType = const Value.absent(),
    this.refundReason = const Value.absent(),
    this.isConverted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       customerId = Value(customerId),
       type = Value(type),
       number = Value(number),
       status = Value(status),
       issueDate = Value(issueDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? customerId,
    Expression<String>? type,
    Expression<String>? number,
    Expression<String>? status,
    Expression<DateTime>? issueDate,
    Expression<DateTime>? dueDate,
    Expression<double>? subtotal,
    Expression<double>? tvaAmount,
    Expression<double>? total,
    Expression<String>? notes,
    Expression<String>? parentDocumentId,
    Expression<String>? parentDocumentType,
    Expression<String>? refundReason,
    Expression<bool>? isConverted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (customerId != null) 'customer_id': customerId,
      if (type != null) 'type': type,
      if (number != null) 'number': number,
      if (status != null) 'status': status,
      if (issueDate != null) 'issue_date': issueDate,
      if (dueDate != null) 'due_date': dueDate,
      if (subtotal != null) 'subtotal': subtotal,
      if (tvaAmount != null) 'tva_amount': tvaAmount,
      if (total != null) 'total': total,
      if (notes != null) 'notes': notes,
      if (parentDocumentId != null) 'parent_document_id': parentDocumentId,
      if (parentDocumentType != null)
        'parent_document_type': parentDocumentType,
      if (refundReason != null) 'refund_reason': refundReason,
      if (isConverted != null) 'is_converted': isConverted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? customerId,
    Value<String>? type,
    Value<String>? number,
    Value<String>? status,
    Value<DateTime>? issueDate,
    Value<DateTime?>? dueDate,
    Value<double>? subtotal,
    Value<double>? tvaAmount,
    Value<double>? total,
    Value<String?>? notes,
    Value<String?>? parentDocumentId,
    Value<String?>? parentDocumentType,
    Value<String?>? refundReason,
    Value<bool>? isConverted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      number: number ?? this.number,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      tvaAmount: tvaAmount ?? this.tvaAmount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      parentDocumentId: parentDocumentId ?? this.parentDocumentId,
      parentDocumentType: parentDocumentType ?? this.parentDocumentType,
      refundReason: refundReason ?? this.refundReason,
      isConverted: isConverted ?? this.isConverted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tvaAmount.present) {
      map['tva_amount'] = Variable<double>(tvaAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (parentDocumentId.present) {
      map['parent_document_id'] = Variable<String>(parentDocumentId.value);
    }
    if (parentDocumentType.present) {
      map['parent_document_type'] = Variable<String>(parentDocumentType.value);
    }
    if (refundReason.present) {
      map['refund_reason'] = Variable<String>(refundReason.value);
    }
    if (isConverted.present) {
      map['is_converted'] = Variable<bool>(isConverted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('customerId: $customerId, ')
          ..write('type: $type, ')
          ..write('number: $number, ')
          ..write('status: $status, ')
          ..write('issueDate: $issueDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('subtotal: $subtotal, ')
          ..write('tvaAmount: $tvaAmount, ')
          ..write('total: $total, ')
          ..write('notes: $notes, ')
          ..write('parentDocumentId: $parentDocumentId, ')
          ..write('parentDocumentType: $parentDocumentType, ')
          ..write('refundReason: $refundReason, ')
          ..write('isConverted: $isConverted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tvaRateMeta = const VerificationMeta(
    'tvaRate',
  );
  @override
  late final GeneratedColumn<double> tvaRate = GeneratedColumn<double>(
    'tva_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(20),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    productId,
    productName,
    description,
    quantity,
    unitPrice,
    tvaRate,
    total,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('tva_rate')) {
      context.handle(
        _tvaRateMeta,
        tvaRate.isAcceptableOrUnknown(data['tva_rate']!, _tvaRateMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      tvaRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tva_rate'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final String? productId;
  final String? productName;
  final String description;
  final double quantity;
  final double unitPrice;
  final double tvaRate;
  final double total;
  final String syncStatus;
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    this.productId,
    this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.tvaRate,
    required this.total,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<String>(productId);
    }
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['tva_rate'] = Variable<double>(tvaRate);
    map['total'] = Variable<double>(total);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      description: Value(description),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      tvaRate: Value(tvaRate),
      total: Value(total),
      syncStatus: Value(syncStatus),
    );
  }

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      productId: serializer.fromJson<String?>(json['productId']),
      productName: serializer.fromJson<String?>(json['productName']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      tvaRate: serializer.fromJson<double>(json['tvaRate']),
      total: serializer.fromJson<double>(json['total']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'productId': serializer.toJson<String?>(productId),
      'productName': serializer.toJson<String?>(productName),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'tvaRate': serializer.toJson<double>(tvaRate),
      'total': serializer.toJson<double>(total),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    Value<String?> productId = const Value.absent(),
    Value<String?> productName = const Value.absent(),
    String? description,
    double? quantity,
    double? unitPrice,
    double? tvaRate,
    double? total,
    String? syncStatus,
  }) => InvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    productId: productId.present ? productId.value : this.productId,
    productName: productName.present ? productName.value : this.productName,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    tvaRate: tvaRate ?? this.tvaRate,
    total: total ?? this.total,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      tvaRate: data.tvaRate.present ? data.tvaRate.value : this.tvaRate,
      total: data.total.present ? data.total.value : this.total,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('tvaRate: $tvaRate, ')
          ..write('total: $total, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    productId,
    productName,
    description,
    quantity,
    unitPrice,
    tvaRate,
    total,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.tvaRate == this.tvaRate &&
          other.total == this.total &&
          other.syncStatus == this.syncStatus);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<String?> productId;
  final Value<String?> productName;
  final Value<String> description;
  final Value<double> quantity;
  final Value<double> unitPrice;
  final Value<double> tvaRate;
  final Value<double> total;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.tvaRate = const Value.absent(),
    this.total = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    required String id,
    required String invoiceId,
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    required String description,
    this.quantity = const Value.absent(),
    required double unitPrice,
    this.tvaRate = const Value.absent(),
    required double total,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       description = Value(description),
       unitPrice = Value(unitPrice),
       total = Value(total);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? tvaRate,
    Expression<double>? total,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (tvaRate != null) 'tva_rate': tvaRate,
      if (total != null) 'total': total,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<String?>? productId,
    Value<String?>? productName,
    Value<String>? description,
    Value<double>? quantity,
    Value<double>? unitPrice,
    Value<double>? tvaRate,
    Value<double>? total,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      tvaRate: tvaRate ?? this.tvaRate,
      total: total ?? this.total,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (tvaRate.present) {
      map['tva_rate'] = Variable<double>(tvaRate.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('tvaRate: $tvaRate, ')
          ..write('total: $total, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tvaAmountMeta = const VerificationMeta(
    'tvaAmount',
  );
  @override
  late final GeneratedColumn<double> tvaAmount = GeneratedColumn<double>(
    'tva_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptUrlMeta = const VerificationMeta(
    'receiptUrl',
  );
  @override
  late final GeneratedColumn<String> receiptUrl = GeneratedColumn<String>(
    'receipt_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptLocalPathMeta = const VerificationMeta(
    'receiptLocalPath',
  );
  @override
  late final GeneratedColumn<String> receiptLocalPath = GeneratedColumn<String>(
    'receipt_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeductibleMeta = const VerificationMeta(
    'isDeductible',
  );
  @override
  late final GeneratedColumn<bool> isDeductible = GeneratedColumn<bool>(
    'is_deductible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deductible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    category,
    amount,
    tvaAmount,
    date,
    description,
    receiptUrl,
    receiptLocalPath,
    isDeductible,
    createdAt,
    updatedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('tva_amount')) {
      context.handle(
        _tvaAmountMeta,
        tvaAmount.isAcceptableOrUnknown(data['tva_amount']!, _tvaAmountMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('receipt_url')) {
      context.handle(
        _receiptUrlMeta,
        receiptUrl.isAcceptableOrUnknown(data['receipt_url']!, _receiptUrlMeta),
      );
    }
    if (data.containsKey('receipt_local_path')) {
      context.handle(
        _receiptLocalPathMeta,
        receiptLocalPath.isAcceptableOrUnknown(
          data['receipt_local_path']!,
          _receiptLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('is_deductible')) {
      context.handle(
        _isDeductibleMeta,
        isDeductible.isAcceptableOrUnknown(
          data['is_deductible']!,
          _isDeductibleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      tvaAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tva_amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      receiptUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_url'],
      ),
      receiptLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_local_path'],
      ),
      isDeductible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deductible'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final double tvaAmount;
  final DateTime date;
  final String? description;
  final String? receiptUrl;
  final String? receiptLocalPath;
  final bool isDeductible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  const Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.tvaAmount,
    required this.date,
    this.description,
    this.receiptUrl,
    this.receiptLocalPath,
    required this.isDeductible,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['tva_amount'] = Variable<double>(tvaAmount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || receiptUrl != null) {
      map['receipt_url'] = Variable<String>(receiptUrl);
    }
    if (!nullToAbsent || receiptLocalPath != null) {
      map['receipt_local_path'] = Variable<String>(receiptLocalPath);
    }
    map['is_deductible'] = Variable<bool>(isDeductible);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      userId: Value(userId),
      category: Value(category),
      amount: Value(amount),
      tvaAmount: Value(tvaAmount),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      receiptUrl: receiptUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptUrl),
      receiptLocalPath: receiptLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptLocalPath),
      isDeductible: Value(isDeductible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      tvaAmount: serializer.fromJson<double>(json['tvaAmount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      receiptUrl: serializer.fromJson<String?>(json['receiptUrl']),
      receiptLocalPath: serializer.fromJson<String?>(json['receiptLocalPath']),
      isDeductible: serializer.fromJson<bool>(json['isDeductible']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'tvaAmount': serializer.toJson<double>(tvaAmount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'receiptUrl': serializer.toJson<String?>(receiptUrl),
      'receiptLocalPath': serializer.toJson<String?>(receiptLocalPath),
      'isDeductible': serializer.toJson<bool>(isDeductible),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    double? tvaAmount,
    DateTime? date,
    Value<String?> description = const Value.absent(),
    Value<String?> receiptUrl = const Value.absent(),
    Value<String?> receiptLocalPath = const Value.absent(),
    bool? isDeductible,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
  }) => Expense(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    tvaAmount: tvaAmount ?? this.tvaAmount,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
    receiptUrl: receiptUrl.present ? receiptUrl.value : this.receiptUrl,
    receiptLocalPath: receiptLocalPath.present
        ? receiptLocalPath.value
        : this.receiptLocalPath,
    isDeductible: isDeductible ?? this.isDeductible,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      tvaAmount: data.tvaAmount.present ? data.tvaAmount.value : this.tvaAmount,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      receiptUrl: data.receiptUrl.present
          ? data.receiptUrl.value
          : this.receiptUrl,
      receiptLocalPath: data.receiptLocalPath.present
          ? data.receiptLocalPath.value
          : this.receiptLocalPath,
      isDeductible: data.isDeductible.present
          ? data.isDeductible.value
          : this.isDeductible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('tvaAmount: $tvaAmount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('receiptLocalPath: $receiptLocalPath, ')
          ..write('isDeductible: $isDeductible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    category,
    amount,
    tvaAmount,
    date,
    description,
    receiptUrl,
    receiptLocalPath,
    isDeductible,
    createdAt,
    updatedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.tvaAmount == this.tvaAmount &&
          other.date == this.date &&
          other.description == this.description &&
          other.receiptUrl == this.receiptUrl &&
          other.receiptLocalPath == this.receiptLocalPath &&
          other.isDeductible == this.isDeductible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> category;
  final Value<double> amount;
  final Value<double> tvaAmount;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String?> receiptUrl;
  final Value<String?> receiptLocalPath;
  final Value<bool> isDeductible;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.tvaAmount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.receiptUrl = const Value.absent(),
    this.receiptLocalPath = const Value.absent(),
    this.isDeductible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String userId,
    required String category,
    required double amount,
    this.tvaAmount = const Value.absent(),
    required DateTime date,
    this.description = const Value.absent(),
    this.receiptUrl = const Value.absent(),
    this.receiptLocalPath = const Value.absent(),
    this.isDeductible = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       category = Value(category),
       amount = Value(amount),
       date = Value(date),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<double>? tvaAmount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? receiptUrl,
    Expression<String>? receiptLocalPath,
    Expression<bool>? isDeductible,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (tvaAmount != null) 'tva_amount': tvaAmount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (receiptUrl != null) 'receipt_url': receiptUrl,
      if (receiptLocalPath != null) 'receipt_local_path': receiptLocalPath,
      if (isDeductible != null) 'is_deductible': isDeductible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? category,
    Value<double>? amount,
    Value<double>? tvaAmount,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<String?>? receiptUrl,
    Value<String?>? receiptLocalPath,
    Value<bool>? isDeductible,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      tvaAmount: tvaAmount ?? this.tvaAmount,
      date: date ?? this.date,
      description: description ?? this.description,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptLocalPath: receiptLocalPath ?? this.receiptLocalPath,
      isDeductible: isDeductible ?? this.isDeductible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (tvaAmount.present) {
      map['tva_amount'] = Variable<double>(tvaAmount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (receiptUrl.present) {
      map['receipt_url'] = Variable<String>(receiptUrl.value);
    }
    if (receiptLocalPath.present) {
      map['receipt_local_path'] = Variable<String>(receiptLocalPath.value);
    }
    if (isDeductible.present) {
      map['is_deductible'] = Variable<bool>(isDeductible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('tvaAmount: $tvaAmount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('receiptUrl: $receiptUrl, ')
          ..write('receiptLocalPath: $receiptLocalPath, ')
          ..write('isDeductible: $isDeductible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkDueDateMeta = const VerificationMeta(
    'checkDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkDueDate = GeneratedColumn<DateTime>(
    'check_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    amount,
    method,
    paymentDate,
    checkDueDate,
    notes,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('check_due_date')) {
      context.handle(
        _checkDueDateMeta,
        checkDueDate.isAcceptableOrUnknown(
          data['check_due_date']!,
          _checkDueDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      checkDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_due_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String invoiceId;
  final double amount;
  final String method;
  final DateTime paymentDate;
  final DateTime? checkDueDate;
  final String? notes;
  final DateTime createdAt;
  final String syncStatus;
  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.paymentDate,
    this.checkDueDate,
    this.notes,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['amount'] = Variable<double>(amount);
    map['method'] = Variable<String>(method);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || checkDueDate != null) {
      map['check_due_date'] = Variable<DateTime>(checkDueDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      method: Value(method),
      paymentDate: Value(paymentDate),
      checkDueDate: checkDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(checkDueDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      amount: serializer.fromJson<double>(json['amount']),
      method: serializer.fromJson<String>(json['method']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      checkDueDate: serializer.fromJson<DateTime?>(json['checkDueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'amount': serializer.toJson<double>(amount),
      'method': serializer.toJson<String>(method),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'checkDueDate': serializer.toJson<DateTime?>(checkDueDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Payment copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    String? method,
    DateTime? paymentDate,
    Value<DateTime?> checkDueDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    String? syncStatus,
  }) => Payment(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    amount: amount ?? this.amount,
    method: method ?? this.method,
    paymentDate: paymentDate ?? this.paymentDate,
    checkDueDate: checkDueDate.present ? checkDueDate.value : this.checkDueDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amount: data.amount.present ? data.amount.value : this.amount,
      method: data.method.present ? data.method.value : this.method,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      checkDueDate: data.checkDueDate.present
          ? data.checkDueDate.value
          : this.checkDueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('checkDueDate: $checkDueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    amount,
    method,
    paymentDate,
    checkDueDate,
    notes,
    createdAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.amount == this.amount &&
          other.method == this.method &&
          other.paymentDate == this.paymentDate &&
          other.checkDueDate == this.checkDueDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<double> amount;
  final Value<String> method;
  final Value<DateTime> paymentDate;
  final Value<DateTime?> checkDueDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amount = const Value.absent(),
    this.method = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.checkDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String invoiceId,
    required double amount,
    required String method,
    required DateTime paymentDate,
    this.checkDueDate = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       invoiceId = Value(invoiceId),
       amount = Value(amount),
       method = Value(method),
       paymentDate = Value(paymentDate),
       createdAt = Value(createdAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<double>? amount,
    Expression<String>? method,
    Expression<DateTime>? paymentDate,
    Expression<DateTime>? checkDueDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amount != null) 'amount': amount,
      if (method != null) 'method': method,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (checkDueDate != null) 'check_due_date': checkDueDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<double>? amount,
    Value<String>? method,
    Value<DateTime>? paymentDate,
    Value<DateTime?>? checkDueDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      paymentDate: paymentDate ?? this.paymentDate,
      checkDueDate: checkDueDate ?? this.checkDueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (checkDueDate.present) {
      map['check_due_date'] = Variable<DateTime>(checkDueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('method: $method, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('checkDueDate: $checkDueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OwnerSalariesTable extends OwnerSalaries
    with TableInfo<$OwnerSalariesTable, OwnerSalary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OwnerSalariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    amount,
    month,
    year,
    paymentDate,
    createdAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'owner_salaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<OwnerSalary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OwnerSalary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OwnerSalary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $OwnerSalariesTable createAlias(String alias) {
    return $OwnerSalariesTable(attachedDatabase, alias);
  }
}

class OwnerSalary extends DataClass implements Insertable<OwnerSalary> {
  final String id;
  final String userId;
  final double amount;
  final int month;
  final int year;
  final DateTime? paymentDate;
  final DateTime createdAt;
  final String syncStatus;
  const OwnerSalary({
    required this.id,
    required this.userId,
    required this.amount,
    required this.month,
    required this.year,
    this.paymentDate,
    required this.createdAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || paymentDate != null) {
      map['payment_date'] = Variable<DateTime>(paymentDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  OwnerSalariesCompanion toCompanion(bool nullToAbsent) {
    return OwnerSalariesCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
      paymentDate: paymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDate),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory OwnerSalary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OwnerSalary(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      paymentDate: serializer.fromJson<DateTime?>(json['paymentDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'paymentDate': serializer.toJson<DateTime?>(paymentDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  OwnerSalary copyWith({
    String? id,
    String? userId,
    double? amount,
    int? month,
    int? year,
    Value<DateTime?> paymentDate = const Value.absent(),
    DateTime? createdAt,
    String? syncStatus,
  }) => OwnerSalary(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    amount: amount ?? this.amount,
    month: month ?? this.month,
    year: year ?? this.year,
    paymentDate: paymentDate.present ? paymentDate.value : this.paymentDate,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  OwnerSalary copyWithCompanion(OwnerSalariesCompanion data) {
    return OwnerSalary(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OwnerSalary(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    amount,
    month,
    year,
    paymentDate,
    createdAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OwnerSalary &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.month == this.month &&
          other.year == this.year &&
          other.paymentDate == this.paymentDate &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class OwnerSalariesCompanion extends UpdateCompanion<OwnerSalary> {
  final Value<String> id;
  final Value<String> userId;
  final Value<double> amount;
  final Value<int> month;
  final Value<int> year;
  final Value<DateTime?> paymentDate;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const OwnerSalariesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OwnerSalariesCompanion.insert({
    required String id,
    required String userId,
    required double amount,
    required int month,
    required int year,
    this.paymentDate = const Value.absent(),
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       amount = Value(amount),
       month = Value(month),
       year = Value(year),
       createdAt = Value(createdAt);
  static Insertable<OwnerSalary> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<int>? month,
    Expression<int>? year,
    Expression<DateTime>? paymentDate,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OwnerSalariesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<double>? amount,
    Value<int>? month,
    Value<int>? year,
    Value<DateTime?>? paymentDate,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return OwnerSalariesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OwnerSalariesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdminSettingsTable extends AdminSettings
    with TableInfo<$AdminSettingsTable, AdminSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdminSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdminSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AdminSettingsTable createAlias(String alias) {
    return $AdminSettingsTable(attachedDatabase, alias);
  }
}

class AdminSetting extends DataClass implements Insertable<AdminSetting> {
  final String id;
  final String key;
  final String value;
  final DateTime updatedAt;
  const AdminSetting({
    required this.id,
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AdminSettingsCompanion toCompanion(bool nullToAbsent) {
    return AdminSettingsCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AdminSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminSetting(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AdminSetting copyWith({
    String? id,
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => AdminSetting(
    id: id ?? this.id,
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AdminSetting copyWithCompanion(AdminSettingsCompanion data) {
    return AdminSetting(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminSetting(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminSetting &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AdminSettingsCompanion extends UpdateCompanion<AdminSetting> {
  final Value<String> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AdminSettingsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdminSettingsCompanion.insert({
    required String id,
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AdminSetting> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdminSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AdminSettingsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminSettingsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tblNameMeta = const VerificationMeta(
    'tblName',
  );
  @override
  late final GeneratedColumn<String> tblName = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldDataMeta = const VerificationMeta(
    'oldData',
  );
  @override
  late final GeneratedColumn<String> oldData = GeneratedColumn<String>(
    'old_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newDataMeta = const VerificationMeta(
    'newData',
  );
  @override
  late final GeneratedColumn<String> newData = GeneratedColumn<String>(
    'new_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    action,
    tblName,
    recordId,
    oldData,
    newData,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tblNameMeta,
        tblName.isAcceptableOrUnknown(data['table_name']!, _tblNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tblNameMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    }
    if (data.containsKey('old_data')) {
      context.handle(
        _oldDataMeta,
        oldData.isAcceptableOrUnknown(data['old_data']!, _oldDataMeta),
      );
    }
    if (data.containsKey('new_data')) {
      context.handle(
        _newDataMeta,
        newData.isAcceptableOrUnknown(data['new_data']!, _newDataMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      tblName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      ),
      oldData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_data'],
      ),
      newData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_data'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String? userId;
  final String action;
  final String tblName;
  final String? recordId;
  final String? oldData;
  final String? newData;
  final DateTime createdAt;
  const AuditLog({
    required this.id,
    this.userId,
    required this.action,
    required this.tblName,
    this.recordId,
    this.oldData,
    this.newData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['action'] = Variable<String>(action);
    map['table_name'] = Variable<String>(tblName);
    if (!nullToAbsent || recordId != null) {
      map['record_id'] = Variable<String>(recordId);
    }
    if (!nullToAbsent || oldData != null) {
      map['old_data'] = Variable<String>(oldData);
    }
    if (!nullToAbsent || newData != null) {
      map['new_data'] = Variable<String>(newData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      action: Value(action),
      tblName: Value(tblName),
      recordId: recordId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordId),
      oldData: oldData == null && nullToAbsent
          ? const Value.absent()
          : Value(oldData),
      newData: newData == null && nullToAbsent
          ? const Value.absent()
          : Value(newData),
      createdAt: Value(createdAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String?>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      tblName: serializer.fromJson<String>(json['tblName']),
      recordId: serializer.fromJson<String?>(json['recordId']),
      oldData: serializer.fromJson<String?>(json['oldData']),
      newData: serializer.fromJson<String?>(json['newData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String?>(userId),
      'action': serializer.toJson<String>(action),
      'tblName': serializer.toJson<String>(tblName),
      'recordId': serializer.toJson<String?>(recordId),
      'oldData': serializer.toJson<String?>(oldData),
      'newData': serializer.toJson<String?>(newData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AuditLog copyWith({
    String? id,
    Value<String?> userId = const Value.absent(),
    String? action,
    String? tblName,
    Value<String?> recordId = const Value.absent(),
    Value<String?> oldData = const Value.absent(),
    Value<String?> newData = const Value.absent(),
    DateTime? createdAt,
  }) => AuditLog(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    action: action ?? this.action,
    tblName: tblName ?? this.tblName,
    recordId: recordId.present ? recordId.value : this.recordId,
    oldData: oldData.present ? oldData.value : this.oldData,
    newData: newData.present ? newData.value : this.newData,
    createdAt: createdAt ?? this.createdAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      tblName: data.tblName.present ? data.tblName.value : this.tblName,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      oldData: data.oldData.present ? data.oldData.value : this.oldData,
      newData: data.newData.present ? data.newData.value : this.newData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('tblName: $tblName, ')
          ..write('recordId: $recordId, ')
          ..write('oldData: $oldData, ')
          ..write('newData: $newData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    action,
    tblName,
    recordId,
    oldData,
    newData,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.tblName == this.tblName &&
          other.recordId == this.recordId &&
          other.oldData == this.oldData &&
          other.newData == this.newData &&
          other.createdAt == this.createdAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<String> action;
  final Value<String> tblName;
  final Value<String?> recordId;
  final Value<String?> oldData;
  final Value<String?> newData;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.tblName = const Value.absent(),
    this.recordId = const Value.absent(),
    this.oldData = const Value.absent(),
    this.newData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String action,
    required String tblName,
    this.recordId = const Value.absent(),
    this.oldData = const Value.absent(),
    this.newData = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       action = Value(action),
       tblName = Value(tblName),
       createdAt = Value(createdAt);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? tblName,
    Expression<String>? recordId,
    Expression<String>? oldData,
    Expression<String>? newData,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (tblName != null) 'table_name': tblName,
      if (recordId != null) 'record_id': recordId,
      if (oldData != null) 'old_data': oldData,
      if (newData != null) 'new_data': newData,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<String>? action,
    Value<String>? tblName,
    Value<String?>? recordId,
    Value<String?>? oldData,
    Value<String?>? newData,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      tblName: tblName ?? this.tblName,
      recordId: recordId ?? this.recordId,
      oldData: oldData ?? this.oldData,
      newData: newData ?? this.newData,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (tblName.present) {
      map['table_name'] = Variable<String>(tblName.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (oldData.present) {
      map['old_data'] = Variable<String>(oldData.value);
    }
    if (newData.present) {
      map['new_data'] = Variable<String>(newData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('tblName: $tblName, ')
          ..write('recordId: $recordId, ')
          ..write('oldData: $oldData, ')
          ..write('newData: $newData, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tblNameMeta = const VerificationMeta(
    'tblName',
  );
  @override
  late final GeneratedColumn<String> tblName = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tblName,
    operation,
    recordId,
    data,
    retryCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _tblNameMeta,
        tblName.isAcceptableOrUnknown(data['table_name']!, _tblNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tblNameMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tblName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueItem extends DataClass implements Insertable<SyncQueueItem> {
  final int id;
  final String tblName;
  final String operation;
  final String recordId;
  final String? data;
  final int retryCount;
  final DateTime createdAt;
  const SyncQueueItem({
    required this.id,
    required this.tblName,
    required this.operation,
    required this.recordId,
    this.data,
    required this.retryCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['table_name'] = Variable<String>(tblName);
    map['operation'] = Variable<String>(operation);
    map['record_id'] = Variable<String>(recordId);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      tblName: Value(tblName),
      operation: Value(operation),
      recordId: Value(recordId),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueItem(
      id: serializer.fromJson<int>(json['id']),
      tblName: serializer.fromJson<String>(json['tblName']),
      operation: serializer.fromJson<String>(json['operation']),
      recordId: serializer.fromJson<String>(json['recordId']),
      data: serializer.fromJson<String?>(json['data']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tblName': serializer.toJson<String>(tblName),
      'operation': serializer.toJson<String>(operation),
      'recordId': serializer.toJson<String>(recordId),
      'data': serializer.toJson<String?>(data),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueItem copyWith({
    int? id,
    String? tblName,
    String? operation,
    String? recordId,
    Value<String?> data = const Value.absent(),
    int? retryCount,
    DateTime? createdAt,
  }) => SyncQueueItem(
    id: id ?? this.id,
    tblName: tblName ?? this.tblName,
    operation: operation ?? this.operation,
    recordId: recordId ?? this.recordId,
    data: data.present ? data.value : this.data,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueItem copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueItem(
      id: data.id.present ? data.id.value : this.id,
      tblName: data.tblName.present ? data.tblName.value : this.tblName,
      operation: data.operation.present ? data.operation.value : this.operation,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      data: data.data.present ? data.data.value : this.data,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueItem(')
          ..write('id: $id, ')
          ..write('tblName: $tblName, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('data: $data, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tblName,
    operation,
    recordId,
    data,
    retryCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueItem &&
          other.id == this.id &&
          other.tblName == this.tblName &&
          other.operation == this.operation &&
          other.recordId == this.recordId &&
          other.data == this.data &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueItem> {
  final Value<int> id;
  final Value<String> tblName;
  final Value<String> operation;
  final Value<String> recordId;
  final Value<String?> data;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.tblName = const Value.absent(),
    this.operation = const Value.absent(),
    this.recordId = const Value.absent(),
    this.data = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String tblName,
    required String operation,
    required String recordId,
    this.data = const Value.absent(),
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
  }) : tblName = Value(tblName),
       operation = Value(operation),
       recordId = Value(recordId),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueItem> custom({
    Expression<int>? id,
    Expression<String>? tblName,
    Expression<String>? operation,
    Expression<String>? recordId,
    Expression<String>? data,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tblName != null) 'table_name': tblName,
      if (operation != null) 'operation': operation,
      if (recordId != null) 'record_id': recordId,
      if (data != null) 'data': data,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? tblName,
    Value<String>? operation,
    Value<String>? recordId,
    Value<String?>? data,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      tblName: tblName ?? this.tblName,
      operation: operation ?? this.operation,
      recordId: recordId ?? this.recordId,
      data: data ?? this.data,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tblName.present) {
      map['table_name'] = Variable<String>(tblName.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('tblName: $tblName, ')
          ..write('operation: $operation, ')
          ..write('recordId: $recordId, ')
          ..write('data: $data, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $OwnerSalariesTable ownerSalaries = $OwnerSalariesTable(this);
  late final $AdminSettingsTable adminSettings = $AdminSettingsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    customers,
    products,
    invoices,
    invoiceItems,
    expenses,
    payments,
    ownerSalaries,
    adminSettings,
    auditLogs,
    syncQueue,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String email,
      required String companyName,
      required String legalStatus,
      Value<String?> ice,
      Value<String?> ifNumber,
      Value<String?> rc,
      Value<String?> cnss,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> logoUrl,
      Value<bool> isAutoEntrepreneur,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String> companyName,
      Value<String> legalStatus,
      Value<String?> ice,
      Value<String?> ifNumber,
      Value<String?> rc,
      Value<String?> cnss,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> logoUrl,
      Value<bool> isAutoEntrepreneur,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ice => $composableBuilder(
    column: $table.ice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifNumber => $composableBuilder(
    column: $table.ifNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rc => $composableBuilder(
    column: $table.rc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnss => $composableBuilder(
    column: $table.cnss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoEntrepreneur => $composableBuilder(
    column: $table.isAutoEntrepreneur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ice => $composableBuilder(
    column: $table.ice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifNumber => $composableBuilder(
    column: $table.ifNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rc => $composableBuilder(
    column: $table.rc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnss => $composableBuilder(
    column: $table.cnss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoEntrepreneur => $composableBuilder(
    column: $table.isAutoEntrepreneur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get legalStatus => $composableBuilder(
    column: $table.legalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ice =>
      $composableBuilder(column: $table.ice, builder: (column) => column);

  GeneratedColumn<String> get ifNumber =>
      $composableBuilder(column: $table.ifNumber, builder: (column) => column);

  GeneratedColumn<String> get rc =>
      $composableBuilder(column: $table.rc, builder: (column) => column);

  GeneratedColumn<String> get cnss =>
      $composableBuilder(column: $table.cnss, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isAutoEntrepreneur => $composableBuilder(
    column: $table.isAutoEntrepreneur,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> legalStatus = const Value.absent(),
                Value<String?> ice = const Value.absent(),
                Value<String?> ifNumber = const Value.absent(),
                Value<String?> rc = const Value.absent(),
                Value<String?> cnss = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<bool> isAutoEntrepreneur = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                email: email,
                companyName: companyName,
                legalStatus: legalStatus,
                ice: ice,
                ifNumber: ifNumber,
                rc: rc,
                cnss: cnss,
                address: address,
                phone: phone,
                logoUrl: logoUrl,
                isAutoEntrepreneur: isAutoEntrepreneur,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String companyName,
                required String legalStatus,
                Value<String?> ice = const Value.absent(),
                Value<String?> ifNumber = const Value.absent(),
                Value<String?> rc = const Value.absent(),
                Value<String?> cnss = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<bool> isAutoEntrepreneur = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                email: email,
                companyName: companyName,
                legalStatus: legalStatus,
                ice: ice,
                ifNumber: ifNumber,
                rc: rc,
                cnss: cnss,
                address: address,
                phone: phone,
                logoUrl: logoUrl,
                isAutoEntrepreneur: isAutoEntrepreneur,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> ice,
      Value<String?> rc,
      Value<String?> ifNumber,
      Value<String?> patente,
      Value<String?> cnss,
      Value<String?> legalForm,
      Value<String?> capital,
      Value<String?> status,
      Value<String?> address,
      Value<String?> phones,
      Value<String?> fax,
      Value<String?> emails,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> ice,
      Value<String?> rc,
      Value<String?> ifNumber,
      Value<String?> patente,
      Value<String?> cnss,
      Value<String?> legalForm,
      Value<String?> capital,
      Value<String?> status,
      Value<String?> address,
      Value<String?> phones,
      Value<String?> fax,
      Value<String?> emails,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ice => $composableBuilder(
    column: $table.ice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rc => $composableBuilder(
    column: $table.rc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ifNumber => $composableBuilder(
    column: $table.ifNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patente => $composableBuilder(
    column: $table.patente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnss => $composableBuilder(
    column: $table.cnss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalForm => $composableBuilder(
    column: $table.legalForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capital => $composableBuilder(
    column: $table.capital,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phones => $composableBuilder(
    column: $table.phones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fax => $composableBuilder(
    column: $table.fax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emails => $composableBuilder(
    column: $table.emails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ice => $composableBuilder(
    column: $table.ice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rc => $composableBuilder(
    column: $table.rc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ifNumber => $composableBuilder(
    column: $table.ifNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patente => $composableBuilder(
    column: $table.patente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnss => $composableBuilder(
    column: $table.cnss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalForm => $composableBuilder(
    column: $table.legalForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capital => $composableBuilder(
    column: $table.capital,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phones => $composableBuilder(
    column: $table.phones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fax => $composableBuilder(
    column: $table.fax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emails => $composableBuilder(
    column: $table.emails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get ice =>
      $composableBuilder(column: $table.ice, builder: (column) => column);

  GeneratedColumn<String> get rc =>
      $composableBuilder(column: $table.rc, builder: (column) => column);

  GeneratedColumn<String> get ifNumber =>
      $composableBuilder(column: $table.ifNumber, builder: (column) => column);

  GeneratedColumn<String> get patente =>
      $composableBuilder(column: $table.patente, builder: (column) => column);

  GeneratedColumn<String> get cnss =>
      $composableBuilder(column: $table.cnss, builder: (column) => column);

  GeneratedColumn<String> get legalForm =>
      $composableBuilder(column: $table.legalForm, builder: (column) => column);

  GeneratedColumn<String> get capital =>
      $composableBuilder(column: $table.capital, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phones =>
      $composableBuilder(column: $table.phones, builder: (column) => column);

  GeneratedColumn<String> get fax =>
      $composableBuilder(column: $table.fax, builder: (column) => column);

  GeneratedColumn<String> get emails =>
      $composableBuilder(column: $table.emails, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> ice = const Value.absent(),
                Value<String?> rc = const Value.absent(),
                Value<String?> ifNumber = const Value.absent(),
                Value<String?> patente = const Value.absent(),
                Value<String?> cnss = const Value.absent(),
                Value<String?> legalForm = const Value.absent(),
                Value<String?> capital = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phones = const Value.absent(),
                Value<String?> fax = const Value.absent(),
                Value<String?> emails = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                userId: userId,
                name: name,
                ice: ice,
                rc: rc,
                ifNumber: ifNumber,
                patente: patente,
                cnss: cnss,
                legalForm: legalForm,
                capital: capital,
                status: status,
                address: address,
                phones: phones,
                fax: fax,
                emails: emails,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> ice = const Value.absent(),
                Value<String?> rc = const Value.absent(),
                Value<String?> ifNumber = const Value.absent(),
                Value<String?> patente = const Value.absent(),
                Value<String?> cnss = const Value.absent(),
                Value<String?> legalForm = const Value.absent(),
                Value<String?> capital = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phones = const Value.absent(),
                Value<String?> fax = const Value.absent(),
                Value<String?> emails = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                ice: ice,
                rc: rc,
                ifNumber: ifNumber,
                patente: patente,
                cnss: cnss,
                legalForm: legalForm,
                capital: capital,
                status: status,
                address: address,
                phones: phones,
                fax: fax,
                emails: emails,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                userId: userId,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      required String id,
      required String userId,
      required String customerId,
      required String type,
      required String number,
      required String status,
      required DateTime issueDate,
      Value<DateTime?> dueDate,
      Value<double> subtotal,
      Value<double> tvaAmount,
      Value<double> total,
      Value<String?> notes,
      Value<String?> parentDocumentId,
      Value<String?> parentDocumentType,
      Value<String?> refundReason,
      Value<bool> isConverted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> customerId,
      Value<String> type,
      Value<String> number,
      Value<String> status,
      Value<DateTime> issueDate,
      Value<DateTime?> dueDate,
      Value<double> subtotal,
      Value<double> tvaAmount,
      Value<double> total,
      Value<String?> notes,
      Value<String?> parentDocumentId,
      Value<String?> parentDocumentType,
      Value<String?> refundReason,
      Value<bool> isConverted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tvaAmount => $composableBuilder(
    column: $table.tvaAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentDocumentId => $composableBuilder(
    column: $table.parentDocumentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentDocumentType => $composableBuilder(
    column: $table.parentDocumentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundReason => $composableBuilder(
    column: $table.refundReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isConverted => $composableBuilder(
    column: $table.isConverted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tvaAmount => $composableBuilder(
    column: $table.tvaAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentDocumentId => $composableBuilder(
    column: $table.parentDocumentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentDocumentType => $composableBuilder(
    column: $table.parentDocumentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundReason => $composableBuilder(
    column: $table.refundReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isConverted => $composableBuilder(
    column: $table.isConverted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tvaAmount =>
      $composableBuilder(column: $table.tvaAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get parentDocumentId => $composableBuilder(
    column: $table.parentDocumentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentDocumentType => $composableBuilder(
    column: $table.parentDocumentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundReason => $composableBuilder(
    column: $table.refundReason,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isConverted => $composableBuilder(
    column: $table.isConverted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
          Invoice,
          PrefetchHooks Function()
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> issueDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tvaAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> parentDocumentId = const Value.absent(),
                Value<String?> parentDocumentType = const Value.absent(),
                Value<String?> refundReason = const Value.absent(),
                Value<bool> isConverted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                userId: userId,
                customerId: customerId,
                type: type,
                number: number,
                status: status,
                issueDate: issueDate,
                dueDate: dueDate,
                subtotal: subtotal,
                tvaAmount: tvaAmount,
                total: total,
                notes: notes,
                parentDocumentId: parentDocumentId,
                parentDocumentType: parentDocumentType,
                refundReason: refundReason,
                isConverted: isConverted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String customerId,
                required String type,
                required String number,
                required String status,
                required DateTime issueDate,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tvaAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> parentDocumentId = const Value.absent(),
                Value<String?> parentDocumentType = const Value.absent(),
                Value<String?> refundReason = const Value.absent(),
                Value<bool> isConverted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                userId: userId,
                customerId: customerId,
                type: type,
                number: number,
                status: status,
                issueDate: issueDate,
                dueDate: dueDate,
                subtotal: subtotal,
                tvaAmount: tvaAmount,
                total: total,
                notes: notes,
                parentDocumentId: parentDocumentId,
                parentDocumentType: parentDocumentType,
                refundReason: refundReason,
                isConverted: isConverted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, BaseReferences<_$AppDatabase, $InvoicesTable, Invoice>),
      Invoice,
      PrefetchHooks Function()
    >;
typedef $$InvoiceItemsTableCreateCompanionBuilder =
    InvoiceItemsCompanion Function({
      required String id,
      required String invoiceId,
      Value<String?> productId,
      Value<String?> productName,
      required String description,
      Value<double> quantity,
      required double unitPrice,
      Value<double> tvaRate,
      required double total,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$InvoiceItemsTableUpdateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<String?> productId,
      Value<String?> productName,
      Value<String> description,
      Value<double> quantity,
      Value<double> unitPrice,
      Value<double> tvaRate,
      Value<double> total,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tvaRate => $composableBuilder(
    column: $table.tvaRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tvaRate => $composableBuilder(
    column: $table.tvaRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get tvaRate =>
      $composableBuilder(column: $table.tvaRate, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$InvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceItemsTable,
          InvoiceItem,
          $$InvoiceItemsTableFilterComposer,
          $$InvoiceItemsTableOrderingComposer,
          $$InvoiceItemsTableAnnotationComposer,
          $$InvoiceItemsTableCreateCompanionBuilder,
          $$InvoiceItemsTableUpdateCompanionBuilder,
          (
            InvoiceItem,
            BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>,
          ),
          InvoiceItem,
          PrefetchHooks Function()
        > {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> tvaRate = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                productName: productName,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                tvaRate: tvaRate,
                total: total,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                Value<String?> productId = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                required String description,
                Value<double> quantity = const Value.absent(),
                required double unitPrice,
                Value<double> tvaRate = const Value.absent(),
                required double total,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                productName: productName,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                tvaRate: tvaRate,
                total: total,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceItemsTable,
      InvoiceItem,
      $$InvoiceItemsTableFilterComposer,
      $$InvoiceItemsTableOrderingComposer,
      $$InvoiceItemsTableAnnotationComposer,
      $$InvoiceItemsTableCreateCompanionBuilder,
      $$InvoiceItemsTableUpdateCompanionBuilder,
      (
        InvoiceItem,
        BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem>,
      ),
      InvoiceItem,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String userId,
      required String category,
      required double amount,
      Value<double> tvaAmount,
      required DateTime date,
      Value<String?> description,
      Value<String?> receiptUrl,
      Value<String?> receiptLocalPath,
      Value<bool> isDeductible,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> category,
      Value<double> amount,
      Value<double> tvaAmount,
      Value<DateTime> date,
      Value<String?> description,
      Value<String?> receiptUrl,
      Value<String?> receiptLocalPath,
      Value<bool> isDeductible,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tvaAmount => $composableBuilder(
    column: $table.tvaAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptLocalPath => $composableBuilder(
    column: $table.receiptLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeductible => $composableBuilder(
    column: $table.isDeductible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tvaAmount => $composableBuilder(
    column: $table.tvaAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptLocalPath => $composableBuilder(
    column: $table.receiptLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeductible => $composableBuilder(
    column: $table.isDeductible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get tvaAmount =>
      $composableBuilder(column: $table.tvaAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptUrl => $composableBuilder(
    column: $table.receiptUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptLocalPath => $composableBuilder(
    column: $table.receiptLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeductible => $composableBuilder(
    column: $table.isDeductible,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
          Expense,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> tvaAmount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> receiptUrl = const Value.absent(),
                Value<String?> receiptLocalPath = const Value.absent(),
                Value<bool> isDeductible = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                userId: userId,
                category: category,
                amount: amount,
                tvaAmount: tvaAmount,
                date: date,
                description: description,
                receiptUrl: receiptUrl,
                receiptLocalPath: receiptLocalPath,
                isDeductible: isDeductible,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String category,
                required double amount,
                Value<double> tvaAmount = const Value.absent(),
                required DateTime date,
                Value<String?> description = const Value.absent(),
                Value<String?> receiptUrl = const Value.absent(),
                Value<String?> receiptLocalPath = const Value.absent(),
                Value<bool> isDeductible = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                userId: userId,
                category: category,
                amount: amount,
                tvaAmount: tvaAmount,
                date: date,
                description: description,
                receiptUrl: receiptUrl,
                receiptLocalPath: receiptLocalPath,
                isDeductible: isDeductible,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, BaseReferences<_$AppDatabase, $ExpensesTable, Expense>),
      Expense,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String invoiceId,
      required double amount,
      required String method,
      required DateTime paymentDate,
      Value<DateTime?> checkDueDate,
      Value<String?> notes,
      required DateTime createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<double> amount,
      Value<String> method,
      Value<DateTime> paymentDate,
      Value<DateTime?> checkDueDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceId => $composableBuilder(
    column: $table.invoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceId =>
      $composableBuilder(column: $table.invoiceId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkDueDate => $composableBuilder(
    column: $table.checkDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<DateTime?> checkDueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                method: method,
                paymentDate: paymentDate,
                checkDueDate: checkDueDate,
                notes: notes,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String invoiceId,
                required double amount,
                required String method,
                required DateTime paymentDate,
                Value<DateTime?> checkDueDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                method: method,
                paymentDate: paymentDate,
                checkDueDate: checkDueDate,
                notes: notes,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;
typedef $$OwnerSalariesTableCreateCompanionBuilder =
    OwnerSalariesCompanion Function({
      required String id,
      required String userId,
      required double amount,
      required int month,
      required int year,
      Value<DateTime?> paymentDate,
      required DateTime createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$OwnerSalariesTableUpdateCompanionBuilder =
    OwnerSalariesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<double> amount,
      Value<int> month,
      Value<int> year,
      Value<DateTime?> paymentDate,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$OwnerSalariesTableFilterComposer
    extends Composer<_$AppDatabase, $OwnerSalariesTable> {
  $$OwnerSalariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OwnerSalariesTableOrderingComposer
    extends Composer<_$AppDatabase, $OwnerSalariesTable> {
  $$OwnerSalariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OwnerSalariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OwnerSalariesTable> {
  $$OwnerSalariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$OwnerSalariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OwnerSalariesTable,
          OwnerSalary,
          $$OwnerSalariesTableFilterComposer,
          $$OwnerSalariesTableOrderingComposer,
          $$OwnerSalariesTableAnnotationComposer,
          $$OwnerSalariesTableCreateCompanionBuilder,
          $$OwnerSalariesTableUpdateCompanionBuilder,
          (
            OwnerSalary,
            BaseReferences<_$AppDatabase, $OwnerSalariesTable, OwnerSalary>,
          ),
          OwnerSalary,
          PrefetchHooks Function()
        > {
  $$OwnerSalariesTableTableManager(_$AppDatabase db, $OwnerSalariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OwnerSalariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OwnerSalariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OwnerSalariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<DateTime?> paymentDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnerSalariesCompanion(
                id: id,
                userId: userId,
                amount: amount,
                month: month,
                year: year,
                paymentDate: paymentDate,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required double amount,
                required int month,
                required int year,
                Value<DateTime?> paymentDate = const Value.absent(),
                required DateTime createdAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OwnerSalariesCompanion.insert(
                id: id,
                userId: userId,
                amount: amount,
                month: month,
                year: year,
                paymentDate: paymentDate,
                createdAt: createdAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OwnerSalariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OwnerSalariesTable,
      OwnerSalary,
      $$OwnerSalariesTableFilterComposer,
      $$OwnerSalariesTableOrderingComposer,
      $$OwnerSalariesTableAnnotationComposer,
      $$OwnerSalariesTableCreateCompanionBuilder,
      $$OwnerSalariesTableUpdateCompanionBuilder,
      (
        OwnerSalary,
        BaseReferences<_$AppDatabase, $OwnerSalariesTable, OwnerSalary>,
      ),
      OwnerSalary,
      PrefetchHooks Function()
    >;
typedef $$AdminSettingsTableCreateCompanionBuilder =
    AdminSettingsCompanion Function({
      required String id,
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AdminSettingsTableUpdateCompanionBuilder =
    AdminSettingsCompanion Function({
      Value<String> id,
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AdminSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdminSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdminSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdminSettingsTable> {
  $$AdminSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AdminSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdminSettingsTable,
          AdminSetting,
          $$AdminSettingsTableFilterComposer,
          $$AdminSettingsTableOrderingComposer,
          $$AdminSettingsTableAnnotationComposer,
          $$AdminSettingsTableCreateCompanionBuilder,
          $$AdminSettingsTableUpdateCompanionBuilder,
          (
            AdminSetting,
            BaseReferences<_$AppDatabase, $AdminSettingsTable, AdminSetting>,
          ),
          AdminSetting,
          PrefetchHooks Function()
        > {
  $$AdminSettingsTableTableManager(_$AppDatabase db, $AdminSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdminSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdminSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdminSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminSettingsCompanion(
                id: id,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AdminSettingsCompanion.insert(
                id: id,
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdminSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdminSettingsTable,
      AdminSetting,
      $$AdminSettingsTableFilterComposer,
      $$AdminSettingsTableOrderingComposer,
      $$AdminSettingsTableAnnotationComposer,
      $$AdminSettingsTableCreateCompanionBuilder,
      $$AdminSettingsTableUpdateCompanionBuilder,
      (
        AdminSetting,
        BaseReferences<_$AppDatabase, $AdminSettingsTable, AdminSetting>,
      ),
      AdminSetting,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      Value<String?> userId,
      required String action,
      required String tblName,
      Value<String?> recordId,
      Value<String?> oldData,
      Value<String?> newData,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<String> action,
      Value<String> tblName,
      Value<String?> recordId,
      Value<String?> oldData,
      Value<String?> newData,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tblName => $composableBuilder(
    column: $table.tblName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldData => $composableBuilder(
    column: $table.oldData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newData => $composableBuilder(
    column: $table.newData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tblName => $composableBuilder(
    column: $table.tblName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldData => $composableBuilder(
    column: $table.oldData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newData => $composableBuilder(
    column: $table.newData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get tblName =>
      $composableBuilder(column: $table.tblName, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get oldData =>
      $composableBuilder(column: $table.oldData, builder: (column) => column);

  GeneratedColumn<String> get newData =>
      $composableBuilder(column: $table.newData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> tblName = const Value.absent(),
                Value<String?> recordId = const Value.absent(),
                Value<String?> oldData = const Value.absent(),
                Value<String?> newData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                userId: userId,
                action: action,
                tblName: tblName,
                recordId: recordId,
                oldData: oldData,
                newData: newData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                required String action,
                required String tblName,
                Value<String?> recordId = const Value.absent(),
                Value<String?> oldData = const Value.absent(),
                Value<String?> newData = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                userId: userId,
                action: action,
                tblName: tblName,
                recordId: recordId,
                oldData: oldData,
                newData: newData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String tblName,
      required String operation,
      required String recordId,
      Value<String?> data,
      Value<int> retryCount,
      required DateTime createdAt,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> tblName,
      Value<String> operation,
      Value<String> recordId,
      Value<String?> data,
      Value<int> retryCount,
      Value<DateTime> createdAt,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tblName => $composableBuilder(
    column: $table.tblName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tblName => $composableBuilder(
    column: $table.tblName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tblName =>
      $composableBuilder(column: $table.tblName, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueItem,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueItem,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>,
          ),
          SyncQueueItem,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tblName = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                tblName: tblName,
                operation: operation,
                recordId: recordId,
                data: data,
                retryCount: retryCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tblName,
                required String operation,
                required String recordId,
                Value<String?> data = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                required DateTime createdAt,
              }) => SyncQueueCompanion.insert(
                id: id,
                tblName: tblName,
                operation: operation,
                recordId: recordId,
                data: data,
                retryCount: retryCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueItem,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueItem,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueItem>,
      ),
      SyncQueueItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$OwnerSalariesTableTableManager get ownerSalaries =>
      $$OwnerSalariesTableTableManager(_db, _db.ownerSalaries);
  $$AdminSettingsTableTableManager get adminSettings =>
      $$AdminSettingsTableTableManager(_db, _db.adminSettings);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
