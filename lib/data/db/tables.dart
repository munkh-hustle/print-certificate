import 'package:drift/drift.dart';

/// Drift table definitions for the Disbox certificate-printing database.
///
/// NOTE ON PII: `submissions.civilNumber` stores the Mongolian civil register
/// number (РД дугаар). It stays local-only; never log or sync it raw.
///
/// TODO(Step 8): Implement the sheet-row hashing helper exactly as specified:
///   sheetRowHash = SHA-256("$timestamp|$surname|$name|$civilNumber|$courseNameRaw")
///   Normalization: trim all parts; lowercase name & courseNameRaw; keep
///   civilNumber exact. This hash is the dedupe key when ingesting the
///   Google Sheet ("Timestamp | Менежер | төлбөр | Овог | Нэр | Утас |
///   РД дугаар | Хаяг | Сургалт | ...").
///
/// Ingest mapping (for reference; not columns here):
///   Timestamp → createdAt, Менежер → manager, Овог → surname, Нэр → name,
///   Утас → phone, РД дугаар → civilNumber, Сургалт → courseNameRaw.
/// Messy input rules: empty/whitespace-only strings → NULL in nullable
/// columns; Cyrillic stored as UTF-8; courseNameRaw is unbounded TEXT
/// (real values contain commas and embedded quotes).

/// Training courses (one row per course code, e.g. "HAIR_PAIR", "CRANE_TOWER").
class Courses extends Table {
  /// Text primary key, e.g. "HAIR_PAIR". Stable human-readable id.
  @override
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// 'A4' or 'A5'.
  TextColumn get paperSize => text()();

  /// Path to the PDF template asset/file. Null until templates are configured.
  TextColumn get templatePath => text().nullable()();

  /// JSON with x/y coords for name, civil number, portrait overlays.
  TextColumn get templateConfigJson => text().nullable()();

  /// Epoch millis.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per Google-Sheet submission awaiting/finishing certificate output.
@DataClassName('Submission')
class Submissions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dedupe key: SHA-256 of timestamp|surname|name|civil|course (see TODO above).
  TextColumn get sheetRowHash => text().unique()();

  /// Овог.
  TextColumn get surname => text()();

  /// Нэр.
  TextColumn get name => text()();

  /// РД дугаар — PII, sensitive.
  TextColumn get civilNumber => text()();

  /// Утас (nullable).
  TextColumn get phone => text().nullable()();

  /// Менежер (nullable).
  TextColumn get manager => text().nullable()();

  /// FK -> courses.id. Nullable: course may be unmapped initially.
  TextColumn get courseId =>
      text().nullable().references(Courses, #id)();

  /// Сургалт text straight from the sheet, before mapping to a Courses row.
  /// Unbounded TEXT: real values contain commas/quotes, e.g.
  /// 'Шивээс (хөмсөг, уруул, контр), "ХАБЭА..."'.
  TextColumn get courseNameRaw => text().nullable()();

  /// Original downloaded portrait image.
  TextColumn get portraitPath => text().nullable()();

  /// Portrait after remove.bg / rembg processing.
  TextColumn get portraitProcessedPath => text().nullable()();

  /// One of: new | ready | printed | error.
  TextColumn get status => text().withDefault(const Constant('new'))();

  /// Populated when status == 'error'.
  TextColumn get errorMessage => text().nullable()();

  /// CERT-YYYY-NNNNNN (from [AppDatabase.nextCertificateId]).
  TextColumn get certificateId => text().nullable()();

  /// Epoch millis (sheet Timestamp).
  IntColumn get createdAt => integer()();

  IntColumn get printedAt => integer().nullable()();

  // Indexes are declared in database.dart via `CREATE INDEX` migration
  // statements (drift's @Index annotation lives on the DB, not tables).
}

/// Generated certificate PDFs.
class Certificates extends Table {
  /// The CERT-YYYY-NNNNNN value.
  @override
  TextColumn get id => text()();

  IntColumn get submissionId => integer().references(Submissions, #id)();

  TextColumn get pdfPath => text()();

  /// 'A4' | 'A5' (copied from the course at generation time).
  TextColumn get paperSize => text()();

  IntColumn get generatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Simple key/value settings store.
class Settings extends Table {
  @override
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Race-safe certificate ID counter: one row per year.
class CertificateCounter extends Table {
  /// e.g. 2026.
  @override
  IntColumn get year => integer()();

  IntColumn get lastSeq => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {year};
}
