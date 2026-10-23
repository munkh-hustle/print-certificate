// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _paperSizeMeta = const VerificationMeta(
    'paperSize',
  );
  @override
  late final GeneratedColumn<String> paperSize = GeneratedColumn<String>(
    'paper_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templatePathMeta = const VerificationMeta(
    'templatePath',
  );
  @override
  late final GeneratedColumn<String> templatePath = GeneratedColumn<String>(
    'template_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateConfigJsonMeta =
      const VerificationMeta('templateConfigJson');
  @override
  late final GeneratedColumn<String> templateConfigJson =
      GeneratedColumn<String>(
        'template_config_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    paperSize,
    templatePath,
    templateConfigJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('paper_size')) {
      context.handle(
        _paperSizeMeta,
        paperSize.isAcceptableOrUnknown(data['paper_size']!, _paperSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_paperSizeMeta);
    }
    if (data.containsKey('template_path')) {
      context.handle(
        _templatePathMeta,
        templatePath.isAcceptableOrUnknown(
          data['template_path']!,
          _templatePathMeta,
        ),
      );
    }
    if (data.containsKey('template_config_json')) {
      context.handle(
        _templateConfigJsonMeta,
        templateConfigJson.isAcceptableOrUnknown(
          data['template_config_json']!,
          _templateConfigJsonMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      paperSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paper_size'],
      )!,
      templatePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_path'],
      ),
      templateConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_config_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  /// Stable text primary key, e.g. "HAIR_PAIR", "CRANE_TOWER".
  final String id;
  final String name;

  /// 'A4' or 'A5'.
  final String paperSize;

  /// Path to the PDF template asset/file (nullable until configured).
  final String? templatePath;

  /// JSON with x/y coords for name, civil number, portrait on the template.
  final String? templateConfigJson;

  /// Epoch milliseconds.
  final int createdAt;
  const Course({
    required this.id,
    required this.name,
    required this.paperSize,
    this.templatePath,
    this.templateConfigJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['paper_size'] = Variable<String>(paperSize);
    if (!nullToAbsent || templatePath != null) {
      map['template_path'] = Variable<String>(templatePath);
    }
    if (!nullToAbsent || templateConfigJson != null) {
      map['template_config_json'] = Variable<String>(templateConfigJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      name: Value(name),
      paperSize: Value(paperSize),
      templatePath: templatePath == null && nullToAbsent
          ? const Value.absent()
          : Value(templatePath),
      templateConfigJson: templateConfigJson == null && nullToAbsent
          ? const Value.absent()
          : Value(templateConfigJson),
      createdAt: Value(createdAt),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      paperSize: serializer.fromJson<String>(json['paperSize']),
      templatePath: serializer.fromJson<String?>(json['templatePath']),
      templateConfigJson: serializer.fromJson<String?>(
        json['templateConfigJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'paperSize': serializer.toJson<String>(paperSize),
      'templatePath': serializer.toJson<String?>(templatePath),
      'templateConfigJson': serializer.toJson<String?>(templateConfigJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? paperSize,
    Value<String?> templatePath = const Value.absent(),
    Value<String?> templateConfigJson = const Value.absent(),
    int? createdAt,
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    paperSize: paperSize ?? this.paperSize,
    templatePath: templatePath.present ? templatePath.value : this.templatePath,
    templateConfigJson: templateConfigJson.present
        ? templateConfigJson.value
        : this.templateConfigJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      paperSize: data.paperSize.present ? data.paperSize.value : this.paperSize,
      templatePath: data.templatePath.present
          ? data.templatePath.value
          : this.templatePath,
      templateConfigJson: data.templateConfigJson.present
          ? data.templateConfigJson.value
          : this.templateConfigJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paperSize: $paperSize, ')
          ..write('templatePath: $templatePath, ')
          ..write('templateConfigJson: $templateConfigJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    paperSize,
    templatePath,
    templateConfigJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.name == this.name &&
          other.paperSize == this.paperSize &&
          other.templatePath == this.templatePath &&
          other.templateConfigJson == this.templateConfigJson &&
          other.createdAt == this.createdAt);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> paperSize;
  final Value<String?> templatePath;
  final Value<String?> templateConfigJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.paperSize = const Value.absent(),
    this.templatePath = const Value.absent(),
    this.templateConfigJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    required String name,
    required String paperSize,
    this.templatePath = const Value.absent(),
    this.templateConfigJson = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       paperSize = Value(paperSize),
       createdAt = Value(createdAt);
  static Insertable<Course> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? paperSize,
    Expression<String>? templatePath,
    Expression<String>? templateConfigJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (paperSize != null) 'paper_size': paperSize,
      if (templatePath != null) 'template_path': templatePath,
      if (templateConfigJson != null)
        'template_config_json': templateConfigJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? paperSize,
    Value<String?>? templatePath,
    Value<String?>? templateConfigJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      paperSize: paperSize ?? this.paperSize,
      templatePath: templatePath ?? this.templatePath,
      templateConfigJson: templateConfigJson ?? this.templateConfigJson,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (paperSize.present) {
      map['paper_size'] = Variable<String>(paperSize.value);
    }
    if (templatePath.present) {
      map['template_path'] = Variable<String>(templatePath.value);
    }
    if (templateConfigJson.present) {
      map['template_config_json'] = Variable<String>(templateConfigJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paperSize: $paperSize, ')
          ..write('templatePath: $templatePath, ')
          ..write('templateConfigJson: $templateConfigJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubmissionsTable extends Submissions
    with TableInfo<$SubmissionsTable, Submission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmissionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sheetRowHashMeta = const VerificationMeta(
    'sheetRowHash',
  );
  @override
  late final GeneratedColumn<String> sheetRowHash = GeneratedColumn<String>(
    'sheet_row_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _surnameMeta = const VerificationMeta(
    'surname',
  );
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
    'surname',
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
  static const VerificationMeta _civilNumberMeta = const VerificationMeta(
    'civilNumber',
  );
  @override
  late final GeneratedColumn<String> civilNumber = GeneratedColumn<String>(
    'civil_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _managerMeta = const VerificationMeta(
    'manager',
  );
  @override
  late final GeneratedColumn<String> manager = GeneratedColumn<String>(
    'manager',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNameRawMeta = const VerificationMeta(
    'courseNameRaw',
  );
  @override
  late final GeneratedColumn<String> courseNameRaw = GeneratedColumn<String>(
    'course_name_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portraitPathMeta = const VerificationMeta(
    'portraitPath',
  );
  @override
  late final GeneratedColumn<String> portraitPath = GeneratedColumn<String>(
    'portrait_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portraitProcessedPathMeta =
      const VerificationMeta('portraitProcessedPath');
  @override
  late final GeneratedColumn<String> portraitProcessedPath =
      GeneratedColumn<String>(
        'portrait_processed_path',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _certificateIdMeta = const VerificationMeta(
    'certificateId',
  );
  @override
  late final GeneratedColumn<String> certificateId = GeneratedColumn<String>(
    'certificate_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printedAtMeta = const VerificationMeta(
    'printedAt',
  );
  @override
  late final GeneratedColumn<int> printedAt = GeneratedColumn<int>(
    'printed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sheetRowHash,
    surname,
    name,
    civilNumber,
    phone,
    manager,
    courseId,
    courseNameRaw,
    portraitPath,
    portraitProcessedPath,
    status,
    errorMessage,
    certificateId,
    createdAt,
    printedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Submission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sheet_row_hash')) {
      context.handle(
        _sheetRowHashMeta,
        sheetRowHash.isAcceptableOrUnknown(
          data['sheet_row_hash']!,
          _sheetRowHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sheetRowHashMeta);
    }
    if (data.containsKey('surname')) {
      context.handle(
        _surnameMeta,
        surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta),
      );
    } else if (isInserting) {
      context.missing(_surnameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('civil_number')) {
      context.handle(
        _civilNumberMeta,
        civilNumber.isAcceptableOrUnknown(
          data['civil_number']!,
          _civilNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_civilNumberMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('manager')) {
      context.handle(
        _managerMeta,
        manager.isAcceptableOrUnknown(data['manager']!, _managerMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('course_name_raw')) {
      context.handle(
        _courseNameRawMeta,
        courseNameRaw.isAcceptableOrUnknown(
          data['course_name_raw']!,
          _courseNameRawMeta,
        ),
      );
    }
    if (data.containsKey('portrait_path')) {
      context.handle(
        _portraitPathMeta,
        portraitPath.isAcceptableOrUnknown(
          data['portrait_path']!,
          _portraitPathMeta,
        ),
      );
    }
    if (data.containsKey('portrait_processed_path')) {
      context.handle(
        _portraitProcessedPathMeta,
        portraitProcessedPath.isAcceptableOrUnknown(
          data['portrait_processed_path']!,
          _portraitProcessedPathMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('certificate_id')) {
      context.handle(
        _certificateIdMeta,
        certificateId.isAcceptableOrUnknown(
          data['certificate_id']!,
          _certificateIdMeta,
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
    if (data.containsKey('printed_at')) {
      context.handle(
        _printedAtMeta,
        printedAt.isAcceptableOrUnknown(data['printed_at']!, _printedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sheetRowHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sheet_row_hash'],
      )!,
      surname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surname'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      civilNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}civil_number'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      manager: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manager'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      courseNameRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name_raw'],
      ),
      portraitPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portrait_path'],
      ),
      portraitProcessedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portrait_processed_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      certificateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certificate_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      printedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}printed_at'],
      ),
    );
  }

  @override
  $SubmissionsTable createAlias(String alias) {
    return $SubmissionsTable(attachedDatabase, alias);
  }
}

class Submission extends DataClass implements Insertable<Submission> {
  final int id;

  /// Dedupe key: SHA-256 of "timestamp|surname|name|civil|course" (see TODO above).
  final String sheetRowHash;
  final String surname;
  final String name;

  /// РД дугаар — PII, keep exact (no lowercasing).
  final String civilNumber;

  /// Утас.
  final String? phone;

  /// Менежер.
  final String? manager;

  /// FK -> courses.id (nullable initially; course may be unassigned).
  final String? courseId;

  /// Сургалт text straight from the sheet, before mapping to a Courses row.
  final String? courseNameRaw;

  /// Original downloaded portrait image path.
  final String? portraitPath;

  /// Portrait path after remove.bg / rembg background removal.
  final String? portraitProcessedPath;

  /// One of: new | ready | printed | error.
  final String status;

  /// Populated when status == 'error'.
  final String? errorMessage;

  /// CERT-YYYY-NNNNNN (from nextCertificateId()).
  final String? certificateId;

  /// Epoch milliseconds (parsed from the sheet Timestamp).
  final int createdAt;

  /// Epoch milliseconds; null until actually printed.
  final int? printedAt;
  const Submission({
    required this.id,
    required this.sheetRowHash,
    required this.surname,
    required this.name,
    required this.civilNumber,
    this.phone,
    this.manager,
    this.courseId,
    this.courseNameRaw,
    this.portraitPath,
    this.portraitProcessedPath,
    required this.status,
    this.errorMessage,
    this.certificateId,
    required this.createdAt,
    this.printedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sheet_row_hash'] = Variable<String>(sheetRowHash);
    map['surname'] = Variable<String>(surname);
    map['name'] = Variable<String>(name);
    map['civil_number'] = Variable<String>(civilNumber);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || manager != null) {
      map['manager'] = Variable<String>(manager);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    if (!nullToAbsent || courseNameRaw != null) {
      map['course_name_raw'] = Variable<String>(courseNameRaw);
    }
    if (!nullToAbsent || portraitPath != null) {
      map['portrait_path'] = Variable<String>(portraitPath);
    }
    if (!nullToAbsent || portraitProcessedPath != null) {
      map['portrait_processed_path'] = Variable<String>(portraitProcessedPath);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || certificateId != null) {
      map['certificate_id'] = Variable<String>(certificateId);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || printedAt != null) {
      map['printed_at'] = Variable<int>(printedAt);
    }
    return map;
  }

  SubmissionsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionsCompanion(
      id: Value(id),
      sheetRowHash: Value(sheetRowHash),
      surname: Value(surname),
      name: Value(name),
      civilNumber: Value(civilNumber),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      manager: manager == null && nullToAbsent
          ? const Value.absent()
          : Value(manager),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      courseNameRaw: courseNameRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(courseNameRaw),
      portraitPath: portraitPath == null && nullToAbsent
          ? const Value.absent()
          : Value(portraitPath),
      portraitProcessedPath: portraitProcessedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(portraitProcessedPath),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      certificateId: certificateId == null && nullToAbsent
          ? const Value.absent()
          : Value(certificateId),
      createdAt: Value(createdAt),
      printedAt: printedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(printedAt),
    );
  }

  factory Submission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submission(
      id: serializer.fromJson<int>(json['id']),
      sheetRowHash: serializer.fromJson<String>(json['sheetRowHash']),
      surname: serializer.fromJson<String>(json['surname']),
      name: serializer.fromJson<String>(json['name']),
      civilNumber: serializer.fromJson<String>(json['civilNumber']),
      phone: serializer.fromJson<String?>(json['phone']),
      manager: serializer.fromJson<String?>(json['manager']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      courseNameRaw: serializer.fromJson<String?>(json['courseNameRaw']),
      portraitPath: serializer.fromJson<String?>(json['portraitPath']),
      portraitProcessedPath: serializer.fromJson<String?>(
        json['portraitProcessedPath'],
      ),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      certificateId: serializer.fromJson<String?>(json['certificateId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      printedAt: serializer.fromJson<int?>(json['printedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sheetRowHash': serializer.toJson<String>(sheetRowHash),
      'surname': serializer.toJson<String>(surname),
      'name': serializer.toJson<String>(name),
      'civilNumber': serializer.toJson<String>(civilNumber),
      'phone': serializer.toJson<String?>(phone),
      'manager': serializer.toJson<String?>(manager),
      'courseId': serializer.toJson<String?>(courseId),
      'courseNameRaw': serializer.toJson<String?>(courseNameRaw),
      'portraitPath': serializer.toJson<String?>(portraitPath),
      'portraitProcessedPath': serializer.toJson<String?>(
        portraitProcessedPath,
      ),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'certificateId': serializer.toJson<String?>(certificateId),
      'createdAt': serializer.toJson<int>(createdAt),
      'printedAt': serializer.toJson<int?>(printedAt),
    };
  }

  Submission copyWith({
    int? id,
    String? sheetRowHash,
    String? surname,
    String? name,
    String? civilNumber,
    Value<String?> phone = const Value.absent(),
    Value<String?> manager = const Value.absent(),
    Value<String?> courseId = const Value.absent(),
    Value<String?> courseNameRaw = const Value.absent(),
    Value<String?> portraitPath = const Value.absent(),
    Value<String?> portraitProcessedPath = const Value.absent(),
    String? status,
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> certificateId = const Value.absent(),
    int? createdAt,
    Value<int?> printedAt = const Value.absent(),
  }) => Submission(
    id: id ?? this.id,
    sheetRowHash: sheetRowHash ?? this.sheetRowHash,
    surname: surname ?? this.surname,
    name: name ?? this.name,
    civilNumber: civilNumber ?? this.civilNumber,
    phone: phone.present ? phone.value : this.phone,
    manager: manager.present ? manager.value : this.manager,
    courseId: courseId.present ? courseId.value : this.courseId,
    courseNameRaw: courseNameRaw.present
        ? courseNameRaw.value
        : this.courseNameRaw,
    portraitPath: portraitPath.present ? portraitPath.value : this.portraitPath,
    portraitProcessedPath: portraitProcessedPath.present
        ? portraitProcessedPath.value
        : this.portraitProcessedPath,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    certificateId: certificateId.present
        ? certificateId.value
        : this.certificateId,
    createdAt: createdAt ?? this.createdAt,
    printedAt: printedAt.present ? printedAt.value : this.printedAt,
  );
  Submission copyWithCompanion(SubmissionsCompanion data) {
    return Submission(
      id: data.id.present ? data.id.value : this.id,
      sheetRowHash: data.sheetRowHash.present
          ? data.sheetRowHash.value
          : this.sheetRowHash,
      surname: data.surname.present ? data.surname.value : this.surname,
      name: data.name.present ? data.name.value : this.name,
      civilNumber: data.civilNumber.present
          ? data.civilNumber.value
          : this.civilNumber,
      phone: data.phone.present ? data.phone.value : this.phone,
      manager: data.manager.present ? data.manager.value : this.manager,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      courseNameRaw: data.courseNameRaw.present
          ? data.courseNameRaw.value
          : this.courseNameRaw,
      portraitPath: data.portraitPath.present
          ? data.portraitPath.value
          : this.portraitPath,
      portraitProcessedPath: data.portraitProcessedPath.present
          ? data.portraitProcessedPath.value
          : this.portraitProcessedPath,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      certificateId: data.certificateId.present
          ? data.certificateId.value
          : this.certificateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      printedAt: data.printedAt.present ? data.printedAt.value : this.printedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submission(')
          ..write('id: $id, ')
          ..write('sheetRowHash: $sheetRowHash, ')
          ..write('surname: $surname, ')
          ..write('name: $name, ')
          ..write('civilNumber: $civilNumber, ')
          ..write('phone: $phone, ')
          ..write('manager: $manager, ')
          ..write('courseId: $courseId, ')
          ..write('courseNameRaw: $courseNameRaw, ')
          ..write('portraitPath: $portraitPath, ')
          ..write('portraitProcessedPath: $portraitProcessedPath, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('certificateId: $certificateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('printedAt: $printedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sheetRowHash,
    surname,
    name,
    civilNumber,
    phone,
    manager,
    courseId,
    courseNameRaw,
    portraitPath,
    portraitProcessedPath,
    status,
    errorMessage,
    certificateId,
    createdAt,
    printedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submission &&
          other.id == this.id &&
          other.sheetRowHash == this.sheetRowHash &&
          other.surname == this.surname &&
          other.name == this.name &&
          other.civilNumber == this.civilNumber &&
          other.phone == this.phone &&
          other.manager == this.manager &&
          other.courseId == this.courseId &&
          other.courseNameRaw == this.courseNameRaw &&
          other.portraitPath == this.portraitPath &&
          other.portraitProcessedPath == this.portraitProcessedPath &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage &&
          other.certificateId == this.certificateId &&
          other.createdAt == this.createdAt &&
          other.printedAt == this.printedAt);
}

class SubmissionsCompanion extends UpdateCompanion<Submission> {
  final Value<int> id;
  final Value<String> sheetRowHash;
  final Value<String> surname;
  final Value<String> name;
  final Value<String> civilNumber;
  final Value<String?> phone;
  final Value<String?> manager;
  final Value<String?> courseId;
  final Value<String?> courseNameRaw;
  final Value<String?> portraitPath;
  final Value<String?> portraitProcessedPath;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<String?> certificateId;
  final Value<int> createdAt;
  final Value<int?> printedAt;
  const SubmissionsCompanion({
    this.id = const Value.absent(),
    this.sheetRowHash = const Value.absent(),
    this.surname = const Value.absent(),
    this.name = const Value.absent(),
    this.civilNumber = const Value.absent(),
    this.phone = const Value.absent(),
    this.manager = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseNameRaw = const Value.absent(),
    this.portraitPath = const Value.absent(),
    this.portraitProcessedPath = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.certificateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.printedAt = const Value.absent(),
  });
  SubmissionsCompanion.insert({
    this.id = const Value.absent(),
    required String sheetRowHash,
    required String surname,
    required String name,
    required String civilNumber,
    this.phone = const Value.absent(),
    this.manager = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseNameRaw = const Value.absent(),
    this.portraitPath = const Value.absent(),
    this.portraitProcessedPath = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.certificateId = const Value.absent(),
    required int createdAt,
    this.printedAt = const Value.absent(),
  }) : sheetRowHash = Value(sheetRowHash),
       surname = Value(surname),
       name = Value(name),
       civilNumber = Value(civilNumber),
       createdAt = Value(createdAt);
  static Insertable<Submission> custom({
    Expression<int>? id,
    Expression<String>? sheetRowHash,
    Expression<String>? surname,
    Expression<String>? name,
    Expression<String>? civilNumber,
    Expression<String>? phone,
    Expression<String>? manager,
    Expression<String>? courseId,
    Expression<String>? courseNameRaw,
    Expression<String>? portraitPath,
    Expression<String>? portraitProcessedPath,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<String>? certificateId,
    Expression<int>? createdAt,
    Expression<int>? printedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sheetRowHash != null) 'sheet_row_hash': sheetRowHash,
      if (surname != null) 'surname': surname,
      if (name != null) 'name': name,
      if (civilNumber != null) 'civil_number': civilNumber,
      if (phone != null) 'phone': phone,
      if (manager != null) 'manager': manager,
      if (courseId != null) 'course_id': courseId,
      if (courseNameRaw != null) 'course_name_raw': courseNameRaw,
      if (portraitPath != null) 'portrait_path': portraitPath,
      if (portraitProcessedPath != null)
        'portrait_processed_path': portraitProcessedPath,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (certificateId != null) 'certificate_id': certificateId,
      if (createdAt != null) 'created_at': createdAt,
      if (printedAt != null) 'printed_at': printedAt,
    });
  }

  SubmissionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sheetRowHash,
    Value<String>? surname,
    Value<String>? name,
    Value<String>? civilNumber,
    Value<String?>? phone,
    Value<String?>? manager,
    Value<String?>? courseId,
    Value<String?>? courseNameRaw,
    Value<String?>? portraitPath,
    Value<String?>? portraitProcessedPath,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<String?>? certificateId,
    Value<int>? createdAt,
    Value<int?>? printedAt,
  }) {
    return SubmissionsCompanion(
      id: id ?? this.id,
      sheetRowHash: sheetRowHash ?? this.sheetRowHash,
      surname: surname ?? this.surname,
      name: name ?? this.name,
      civilNumber: civilNumber ?? this.civilNumber,
      phone: phone ?? this.phone,
      manager: manager ?? this.manager,
      courseId: courseId ?? this.courseId,
      courseNameRaw: courseNameRaw ?? this.courseNameRaw,
      portraitPath: portraitPath ?? this.portraitPath,
      portraitProcessedPath:
          portraitProcessedPath ?? this.portraitProcessedPath,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      certificateId: certificateId ?? this.certificateId,
      createdAt: createdAt ?? this.createdAt,
      printedAt: printedAt ?? this.printedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sheetRowHash.present) {
      map['sheet_row_hash'] = Variable<String>(sheetRowHash.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (civilNumber.present) {
      map['civil_number'] = Variable<String>(civilNumber.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (manager.present) {
      map['manager'] = Variable<String>(manager.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (courseNameRaw.present) {
      map['course_name_raw'] = Variable<String>(courseNameRaw.value);
    }
    if (portraitPath.present) {
      map['portrait_path'] = Variable<String>(portraitPath.value);
    }
    if (portraitProcessedPath.present) {
      map['portrait_processed_path'] = Variable<String>(
        portraitProcessedPath.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (certificateId.present) {
      map['certificate_id'] = Variable<String>(certificateId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (printedAt.present) {
      map['printed_at'] = Variable<int>(printedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('sheetRowHash: $sheetRowHash, ')
          ..write('surname: $surname, ')
          ..write('name: $name, ')
          ..write('civilNumber: $civilNumber, ')
          ..write('phone: $phone, ')
          ..write('manager: $manager, ')
          ..write('courseId: $courseId, ')
          ..write('courseNameRaw: $courseNameRaw, ')
          ..write('portraitPath: $portraitPath, ')
          ..write('portraitProcessedPath: $portraitProcessedPath, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('certificateId: $certificateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('printedAt: $printedAt')
          ..write(')'))
        .toString();
  }
}

class $CertificatesTable extends Certificates
    with TableInfo<$CertificatesTable, Certificate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CertificatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submissionIdMeta = const VerificationMeta(
    'submissionId',
  );
  @override
  late final GeneratedColumn<int> submissionId = GeneratedColumn<int>(
    'submission_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pdfPathMeta = const VerificationMeta(
    'pdfPath',
  );
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
    'pdf_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paperSizeMeta = const VerificationMeta(
    'paperSize',
  );
  @override
  late final GeneratedColumn<String> paperSize = GeneratedColumn<String>(
    'paper_size',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<int> generatedAt = GeneratedColumn<int>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    submissionId,
    pdfPath,
    paperSize,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'certificates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Certificate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('submission_id')) {
      context.handle(
        _submissionIdMeta,
        submissionId.isAcceptableOrUnknown(
          data['submission_id']!,
          _submissionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submissionIdMeta);
    }
    if (data.containsKey('pdf_path')) {
      context.handle(
        _pdfPathMeta,
        pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta),
      );
    } else if (isInserting) {
      context.missing(_pdfPathMeta);
    }
    if (data.containsKey('paper_size')) {
      context.handle(
        _paperSizeMeta,
        paperSize.isAcceptableOrUnknown(data['paper_size']!, _paperSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_paperSizeMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Certificate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Certificate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      submissionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submission_id'],
      )!,
      pdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_path'],
      )!,
      paperSize: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paper_size'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $CertificatesTable createAlias(String alias) {
    return $CertificatesTable(attachedDatabase, alias);
  }
}

class Certificate extends DataClass implements Insertable<Certificate> {
  /// The certificate_id value (CERT-YYYY-NNNNNN).
  final String id;

  /// FK -> submissions.id.
  final int submissionId;
  final String pdfPath;

  /// 'A4' | 'A5'.
  final String paperSize;

  /// Epoch milliseconds.
  final int generatedAt;
  const Certificate({
    required this.id,
    required this.submissionId,
    required this.pdfPath,
    required this.paperSize,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['submission_id'] = Variable<int>(submissionId);
    map['pdf_path'] = Variable<String>(pdfPath);
    map['paper_size'] = Variable<String>(paperSize);
    map['generated_at'] = Variable<int>(generatedAt);
    return map;
  }

  CertificatesCompanion toCompanion(bool nullToAbsent) {
    return CertificatesCompanion(
      id: Value(id),
      submissionId: Value(submissionId),
      pdfPath: Value(pdfPath),
      paperSize: Value(paperSize),
      generatedAt: Value(generatedAt),
    );
  }

  factory Certificate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Certificate(
      id: serializer.fromJson<String>(json['id']),
      submissionId: serializer.fromJson<int>(json['submissionId']),
      pdfPath: serializer.fromJson<String>(json['pdfPath']),
      paperSize: serializer.fromJson<String>(json['paperSize']),
      generatedAt: serializer.fromJson<int>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'submissionId': serializer.toJson<int>(submissionId),
      'pdfPath': serializer.toJson<String>(pdfPath),
      'paperSize': serializer.toJson<String>(paperSize),
      'generatedAt': serializer.toJson<int>(generatedAt),
    };
  }

  Certificate copyWith({
    String? id,
    int? submissionId,
    String? pdfPath,
    String? paperSize,
    int? generatedAt,
  }) => Certificate(
    id: id ?? this.id,
    submissionId: submissionId ?? this.submissionId,
    pdfPath: pdfPath ?? this.pdfPath,
    paperSize: paperSize ?? this.paperSize,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  Certificate copyWithCompanion(CertificatesCompanion data) {
    return Certificate(
      id: data.id.present ? data.id.value : this.id,
      submissionId: data.submissionId.present
          ? data.submissionId.value
          : this.submissionId,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      paperSize: data.paperSize.present ? data.paperSize.value : this.paperSize,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Certificate(')
          ..write('id: $id, ')
          ..write('submissionId: $submissionId, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('paperSize: $paperSize, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, submissionId, pdfPath, paperSize, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Certificate &&
          other.id == this.id &&
          other.submissionId == this.submissionId &&
          other.pdfPath == this.pdfPath &&
          other.paperSize == this.paperSize &&
          other.generatedAt == this.generatedAt);
}

class CertificatesCompanion extends UpdateCompanion<Certificate> {
  final Value<String> id;
  final Value<int> submissionId;
  final Value<String> pdfPath;
  final Value<String> paperSize;
  final Value<int> generatedAt;
  final Value<int> rowid;
  const CertificatesCompanion({
    this.id = const Value.absent(),
    this.submissionId = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.paperSize = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CertificatesCompanion.insert({
    required String id,
    required int submissionId,
    required String pdfPath,
    required String paperSize,
    required int generatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       submissionId = Value(submissionId),
       pdfPath = Value(pdfPath),
       paperSize = Value(paperSize),
       generatedAt = Value(generatedAt);
  static Insertable<Certificate> custom({
    Expression<String>? id,
    Expression<int>? submissionId,
    Expression<String>? pdfPath,
    Expression<String>? paperSize,
    Expression<int>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (submissionId != null) 'submission_id': submissionId,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (paperSize != null) 'paper_size': paperSize,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CertificatesCompanion copyWith({
    Value<String>? id,
    Value<int>? submissionId,
    Value<String>? pdfPath,
    Value<String>? paperSize,
    Value<int>? generatedAt,
    Value<int>? rowid,
  }) {
    return CertificatesCompanion(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      pdfPath: pdfPath ?? this.pdfPath,
      paperSize: paperSize ?? this.paperSize,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (submissionId.present) {
      map['submission_id'] = Variable<int>(submissionId.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (paperSize.present) {
      map['paper_size'] = Variable<String>(paperSize.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<int>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CertificatesCompanion(')
          ..write('id: $id, ')
          ..write('submissionId: $submissionId, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('paperSize: $paperSize, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(SettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CertificateCounterTable extends CertificateCounter
    with TableInfo<$CertificateCounterTable, CertificateCounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CertificateCounterTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeqMeta = const VerificationMeta(
    'lastSeq',
  );
  @override
  late final GeneratedColumn<int> lastSeq = GeneratedColumn<int>(
    'last_seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [year, lastSeq];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'certificate_counter';
  @override
  VerificationContext validateIntegrity(
    Insertable<CertificateCounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('last_seq')) {
      context.handle(
        _lastSeqMeta,
        lastSeq.isAcceptableOrUnknown(data['last_seq']!, _lastSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {year};
  @override
  CertificateCounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CertificateCounterRow(
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      lastSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seq'],
      )!,
    );
  }

  @override
  $CertificateCounterTable createAlias(String alias) {
    return $CertificateCounterTable(attachedDatabase, alias);
  }
}

class CertificateCounterRow extends DataClass
    implements Insertable<CertificateCounterRow> {
  /// e.g. 2026.
  final int year;
  final int lastSeq;
  const CertificateCounterRow({required this.year, required this.lastSeq});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['year'] = Variable<int>(year);
    map['last_seq'] = Variable<int>(lastSeq);
    return map;
  }

  CertificateCounterCompanion toCompanion(bool nullToAbsent) {
    return CertificateCounterCompanion(
      year: Value(year),
      lastSeq: Value(lastSeq),
    );
  }

  factory CertificateCounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CertificateCounterRow(
      year: serializer.fromJson<int>(json['year']),
      lastSeq: serializer.fromJson<int>(json['lastSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'year': serializer.toJson<int>(year),
      'lastSeq': serializer.toJson<int>(lastSeq),
    };
  }

  CertificateCounterRow copyWith({int? year, int? lastSeq}) =>
      CertificateCounterRow(
        year: year ?? this.year,
        lastSeq: lastSeq ?? this.lastSeq,
      );
  CertificateCounterRow copyWithCompanion(CertificateCounterCompanion data) {
    return CertificateCounterRow(
      year: data.year.present ? data.year.value : this.year,
      lastSeq: data.lastSeq.present ? data.lastSeq.value : this.lastSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CertificateCounterRow(')
          ..write('year: $year, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(year, lastSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CertificateCounterRow &&
          other.year == this.year &&
          other.lastSeq == this.lastSeq);
}

class CertificateCounterCompanion
    extends UpdateCompanion<CertificateCounterRow> {
  final Value<int> year;
  final Value<int> lastSeq;
  const CertificateCounterCompanion({
    this.year = const Value.absent(),
    this.lastSeq = const Value.absent(),
  });
  CertificateCounterCompanion.insert({
    this.year = const Value.absent(),
    this.lastSeq = const Value.absent(),
  });
  static Insertable<CertificateCounterRow> custom({
    Expression<int>? year,
    Expression<int>? lastSeq,
  }) {
    return RawValuesInsertable({
      if (year != null) 'year': year,
      if (lastSeq != null) 'last_seq': lastSeq,
    });
  }

  CertificateCounterCompanion copyWith({
    Value<int>? year,
    Value<int>? lastSeq,
  }) {
    return CertificateCounterCompanion(
      year: year ?? this.year,
      lastSeq: lastSeq ?? this.lastSeq,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (lastSeq.present) {
      map['last_seq'] = Variable<int>(lastSeq.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CertificateCounterCompanion(')
          ..write('year: $year, ')
          ..write('lastSeq: $lastSeq')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $SubmissionsTable submissions = $SubmissionsTable(this);
  late final $CertificatesTable certificates = $CertificatesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $CertificateCounterTable certificateCounter =
      $CertificateCounterTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courses,
    submissions,
    certificates,
    settings,
    certificateCounter,
  ];
}

typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  required String id,
  required String name,
  required String paperSize,
  Value<String?> templatePath,
  Value<String?> templateConfigJson,
  required int createdAt,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> paperSize,
  Value<String?> templatePath,
  Value<String?> templateConfigJson,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paperSize => $composableBuilder(
    column: $table.paperSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templatePath => $composableBuilder(
    column: $table.templatePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateConfigJson => $composableBuilder(
    column: $table.templateConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paperSize => $composableBuilder(
    column: $table.paperSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templatePath => $composableBuilder(
    column: $table.templatePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateConfigJson => $composableBuilder(
    column: $table.templateConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get paperSize =>
      $composableBuilder(column: $table.paperSize, builder: (column) => column);

  GeneratedColumn<String> get templatePath => $composableBuilder(
    column: $table.templatePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateConfigJson => $composableBuilder(
    column: $table.templateConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, BaseReferences<_$AppDatabase, $CoursesTable, Course>),
          Course,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> paperSize = const Value.absent(),
                Value<String?> templatePath = const Value.absent(),
                Value<String?> templateConfigJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                name: name,
                paperSize: paperSize,
                templatePath: templatePath,
                templateConfigJson: templateConfigJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String paperSize,
                Value<String?> templatePath = const Value.absent(),
                Value<String?> templateConfigJson = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                name: name,
                paperSize: paperSize,
                templatePath: templatePath,
                templateConfigJson: templateConfigJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoursesTable, Course>(table),
                  BaseReferences<_$AppDatabase, $CoursesTable, Course>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, BaseReferences<_$AppDatabase, $CoursesTable, Course>),
      Course,
      PrefetchHooks Function()
    >;
typedef $$SubmissionsTableCreateCompanionBuilder =
    SubmissionsCompanion Function({
      Value<int> id,
      required String sheetRowHash,
      required String surname,
      required String name,
      required String civilNumber,
      Value<String?> phone,
      Value<String?> manager,
      Value<String?> courseId,
      Value<String?> courseNameRaw,
      Value<String?> portraitPath,
      Value<String?> portraitProcessedPath,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> certificateId,
      required int createdAt,
      Value<int?> printedAt,
    });
typedef $$SubmissionsTableUpdateCompanionBuilder =
    SubmissionsCompanion Function({
      Value<int> id,
      Value<String> sheetRowHash,
      Value<String> surname,
      Value<String> name,
      Value<String> civilNumber,
      Value<String?> phone,
      Value<String?> manager,
      Value<String?> courseId,
      Value<String?> courseNameRaw,
      Value<String?> portraitPath,
      Value<String?> portraitProcessedPath,
      Value<String> status,
      Value<String?> errorMessage,
      Value<String?> certificateId,
      Value<int> createdAt,
      Value<int?> printedAt,
    });

class $$SubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableFilterComposer({
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

  ColumnFilters<String> get sheetRowHash => $composableBuilder(
    column: $table.sheetRowHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get civilNumber => $composableBuilder(
    column: $table.civilNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manager => $composableBuilder(
    column: $table.manager,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseNameRaw => $composableBuilder(
    column: $table.courseNameRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portraitProcessedPath => $composableBuilder(
    column: $table.portraitProcessedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certificateId => $composableBuilder(
    column: $table.certificateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get printedAt => $composableBuilder(
    column: $table.printedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableOrderingComposer({
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

  ColumnOrderings<String> get sheetRowHash => $composableBuilder(
    column: $table.sheetRowHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surname => $composableBuilder(
    column: $table.surname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get civilNumber => $composableBuilder(
    column: $table.civilNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manager => $composableBuilder(
    column: $table.manager,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseNameRaw => $composableBuilder(
    column: $table.courseNameRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portraitProcessedPath => $composableBuilder(
    column: $table.portraitProcessedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certificateId => $composableBuilder(
    column: $table.certificateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get printedAt => $composableBuilder(
    column: $table.printedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sheetRowHash => $composableBuilder(
    column: $table.sheetRowHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get civilNumber => $composableBuilder(
    column: $table.civilNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get manager =>
      $composableBuilder(column: $table.manager, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get courseNameRaw => $composableBuilder(
    column: $table.courseNameRaw,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portraitPath => $composableBuilder(
    column: $table.portraitPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portraitProcessedPath => $composableBuilder(
    column: $table.portraitProcessedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get certificateId => $composableBuilder(
    column: $table.certificateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get printedAt =>
      $composableBuilder(column: $table.printedAt, builder: (column) => column);
}

class $$SubmissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubmissionsTable,
          Submission,
          $$SubmissionsTableFilterComposer,
          $$SubmissionsTableOrderingComposer,
          $$SubmissionsTableAnnotationComposer,
          $$SubmissionsTableCreateCompanionBuilder,
          $$SubmissionsTableUpdateCompanionBuilder,
          (
            Submission,
            BaseReferences<_$AppDatabase, $SubmissionsTable, Submission>,
          ),
          Submission,
          PrefetchHooks Function()
        > {
  $$SubmissionsTableTableManager(_$AppDatabase db, $SubmissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sheetRowHash = const Value.absent(),
                Value<String> surname = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> civilNumber = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> manager = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseNameRaw = const Value.absent(),
                Value<String?> portraitPath = const Value.absent(),
                Value<String?> portraitProcessedPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> certificateId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> printedAt = const Value.absent(),
              }) => SubmissionsCompanion(
                id: id,
                sheetRowHash: sheetRowHash,
                surname: surname,
                name: name,
                civilNumber: civilNumber,
                phone: phone,
                manager: manager,
                courseId: courseId,
                courseNameRaw: courseNameRaw,
                portraitPath: portraitPath,
                portraitProcessedPath: portraitProcessedPath,
                status: status,
                errorMessage: errorMessage,
                certificateId: certificateId,
                createdAt: createdAt,
                printedAt: printedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sheetRowHash,
                required String surname,
                required String name,
                required String civilNumber,
                Value<String?> phone = const Value.absent(),
                Value<String?> manager = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseNameRaw = const Value.absent(),
                Value<String?> portraitPath = const Value.absent(),
                Value<String?> portraitProcessedPath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> certificateId = const Value.absent(),
                required int createdAt,
                Value<int?> printedAt = const Value.absent(),
              }) => SubmissionsCompanion.insert(
                id: id,
                sheetRowHash: sheetRowHash,
                surname: surname,
                name: name,
                civilNumber: civilNumber,
                phone: phone,
                manager: manager,
                courseId: courseId,
                courseNameRaw: courseNameRaw,
                portraitPath: portraitPath,
                portraitProcessedPath: portraitProcessedPath,
                status: status,
                errorMessage: errorMessage,
                certificateId: certificateId,
                createdAt: createdAt,
                printedAt: printedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubmissionsTable, Submission>(table),
                  BaseReferences<_$AppDatabase, $SubmissionsTable, Submission>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubmissionsTable,
      Submission,
      $$SubmissionsTableFilterComposer,
      $$SubmissionsTableOrderingComposer,
      $$SubmissionsTableAnnotationComposer,
      $$SubmissionsTableCreateCompanionBuilder,
      $$SubmissionsTableUpdateCompanionBuilder,
      (
        Submission,
        BaseReferences<_$AppDatabase, $SubmissionsTable, Submission>,
      ),
      Submission,
      PrefetchHooks Function()
    >;
typedef $$CertificatesTableCreateCompanionBuilder =
    CertificatesCompanion Function({
      required String id,
      required int submissionId,
      required String pdfPath,
      required String paperSize,
      required int generatedAt,
      Value<int> rowid,
    });
typedef $$CertificatesTableUpdateCompanionBuilder =
    CertificatesCompanion Function({
      Value<String> id,
      Value<int> submissionId,
      Value<String> pdfPath,
      Value<String> paperSize,
      Value<int> generatedAt,
      Value<int> rowid,
    });

class $$CertificatesTableFilterComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableFilterComposer({
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

  ColumnFilters<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paperSize => $composableBuilder(
    column: $table.paperSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CertificatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableOrderingComposer({
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

  ColumnOrderings<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paperSize => $composableBuilder(
    column: $table.paperSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CertificatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CertificatesTable> {
  $$CertificatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get submissionId => $composableBuilder(
    column: $table.submissionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<String> get paperSize =>
      $composableBuilder(column: $table.paperSize, builder: (column) => column);

  GeneratedColumn<int> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$CertificatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CertificatesTable,
          Certificate,
          $$CertificatesTableFilterComposer,
          $$CertificatesTableOrderingComposer,
          $$CertificatesTableAnnotationComposer,
          $$CertificatesTableCreateCompanionBuilder,
          $$CertificatesTableUpdateCompanionBuilder,
          (
            Certificate,
            BaseReferences<_$AppDatabase, $CertificatesTable, Certificate>,
          ),
          Certificate,
          PrefetchHooks Function()
        > {
  $$CertificatesTableTableManager(_$AppDatabase db, $CertificatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CertificatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CertificatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CertificatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> submissionId = const Value.absent(),
                Value<String> pdfPath = const Value.absent(),
                Value<String> paperSize = const Value.absent(),
                Value<int> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CertificatesCompanion(
                id: id,
                submissionId: submissionId,
                pdfPath: pdfPath,
                paperSize: paperSize,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int submissionId,
                required String pdfPath,
                required String paperSize,
                required int generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CertificatesCompanion.insert(
                id: id,
                submissionId: submissionId,
                pdfPath: pdfPath,
                paperSize: paperSize,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CertificatesTable, Certificate>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CertificatesTable,
                    Certificate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CertificatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CertificatesTable,
      Certificate,
      $$CertificatesTableFilterComposer,
      $$CertificatesTableOrderingComposer,
      $$CertificatesTableAnnotationComposer,
      $$CertificatesTableCreateCompanionBuilder,
      $$CertificatesTableUpdateCompanionBuilder,
      (
        Certificate,
        BaseReferences<_$AppDatabase, $CertificatesTable, Certificate>,
      ),
      Certificate,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          AppSetting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $SettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      AppSetting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (AppSetting, BaseReferences<_$AppDatabase, $SettingsTable, AppSetting>),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$CertificateCounterTableCreateCompanionBuilder =
    CertificateCounterCompanion Function({Value<int> year, Value<int> lastSeq});
typedef $$CertificateCounterTableUpdateCompanionBuilder =
    CertificateCounterCompanion Function({Value<int> year, Value<int> lastSeq});

class $$CertificateCounterTableFilterComposer
    extends Composer<_$AppDatabase, $CertificateCounterTable> {
  $$CertificateCounterTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CertificateCounterTableOrderingComposer
    extends Composer<_$AppDatabase, $CertificateCounterTable> {
  $$CertificateCounterTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeq => $composableBuilder(
    column: $table.lastSeq,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CertificateCounterTableAnnotationComposer
    extends Composer<_$AppDatabase, $CertificateCounterTable> {
  $$CertificateCounterTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get lastSeq =>
      $composableBuilder(column: $table.lastSeq, builder: (column) => column);
}

class $$CertificateCounterTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CertificateCounterTable,
          CertificateCounterRow,
          $$CertificateCounterTableFilterComposer,
          $$CertificateCounterTableOrderingComposer,
          $$CertificateCounterTableAnnotationComposer,
          $$CertificateCounterTableCreateCompanionBuilder,
          $$CertificateCounterTableUpdateCompanionBuilder,
          (
            CertificateCounterRow,
            BaseReferences<
              _$AppDatabase,
              $CertificateCounterTable,
              CertificateCounterRow
            >,
          ),
          CertificateCounterRow,
          PrefetchHooks Function()
        > {
  $$CertificateCounterTableTableManager(
    _$AppDatabase db,
    $CertificateCounterTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CertificateCounterTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CertificateCounterTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CertificateCounterTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback: ({
            Value<int> year = const Value.absent(),
            Value<int> lastSeq = const Value.absent(),
          }) => CertificateCounterCompanion(year: year, lastSeq: lastSeq),
          createCompanionCallback:
              ({
                Value<int> year = const Value.absent(),
                Value<int> lastSeq = const Value.absent(),
              }) => CertificateCounterCompanion.insert(
                year: year,
                lastSeq: lastSeq,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CertificateCounterTable, CertificateCounterRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CertificateCounterTable,
                    CertificateCounterRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CertificateCounterTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CertificateCounterTable,
      CertificateCounterRow,
      $$CertificateCounterTableFilterComposer,
      $$CertificateCounterTableOrderingComposer,
      $$CertificateCounterTableAnnotationComposer,
      $$CertificateCounterTableCreateCompanionBuilder,
      $$CertificateCounterTableUpdateCompanionBuilder,
      (
        CertificateCounterRow,
        BaseReferences<
          _$AppDatabase,
          $CertificateCounterTable,
          CertificateCounterRow
        >,
      ),
      CertificateCounterRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$SubmissionsTableTableManager get submissions =>
      $$SubmissionsTableTableManager(_db, _db.submissions);
  $$CertificatesTableTableManager get certificates =>
      $$CertificatesTableTableManager(_db, _db.certificates);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$CertificateCounterTableTableManager get certificateCounter =>
      $$CertificateCounterTableTableManager(_db, _db.certificateCounter);
}
