import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// Disbox — Drift table definitions (Step 2: local database layer only)
//
// Google Sheet column mapping (source of truth for later steps, Step 8):
//   Timestamp               -> createdAt (parse date; store epoch millis)
//   Менежер                 -> manager
//   төлбөр                  -> sheet-only payment status text ("тийм"/"Төлсөн")
//   Овог                    -> surname
//   Нэр                     -> name
//   Утас                    -> phone
//   РД дугаар               -> civilNumber  (PII — the sensitive one)
//   Хаяг                    -> not stored in Step 2
//   Сургалт                 -> courseNameRaw (mapped to Courses.id later)
//   Суралцах хоног          -> not stored
//   Төлбөр (amount)         -> not stored
//   Урьдчилгаа              -> not stored
//   Үлдэгдэл                -> not stored
//   Тайлбар (нэмэлт дугаар) -> not stored
//
// TODO(Step 8): implement the sheetRowHash helper as SHA-256 of the string
//   "$timestamp|$surname|$name|$civilNumber|$courseNameRaw"
// with normalization: trim everything, lowercase the name/course parts, keep
// civilNumber exact. Do NOT implement it here — but do not forget the format.
//
// Data hygiene notes (real sheet has messy rows 1–9):
//   - Empty strings and whitespace-only values must be trimmed and stored as
//     NULL where the column is nullable.
//   - Cyrillic (Mongolian) text is stored as UTF-8 — SQLite's default; never
//     mangle/encode it further.
//   - Course names can contain commas and quotes ('Шивээс (хөмсөг, уруул,
//     контр), "ХАБЭА..."') — courseNameRaw is unbounded TEXT.
// ---------------------------------------------------------------------------

/// Training courses (e.g. "HAIR_PAIR", "CRANE_TOWER").
@DataClassName('Course')
class Courses extends Table {
  /// Stable text primary key, e.g. "HAIR_PAIR", "CRANE_TOWER".
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// 'A4' or 'A5'.
  TextColumn get paperSize => text()();

  /// Path to the PDF template asset/file (nullable until configured).
  TextColumn get templatePath => text().nullable()();

  /// JSON with x/y coords for name, civil number, portrait on the template.
  TextColumn get templateConfigJson => text().nullable()();

  /// Epoch milliseconds.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One ingested Google-Sheet row = one certificate candidate.
@DataClassName('Submission')
class Submissions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dedupe key: SHA-256 of "timestamp|surname|name|civil|course" (see TODO above).
  TextColumn get sheetRowHash => text().unique()();

  TextColumn get surname => text()();

  TextColumn get name => text()();

  /// РД дугаар — PII, keep exact (no lowercasing).
  TextColumn get civilNumber => text()();

  /// Утас.
  TextColumn get phone => text().nullable()();

  /// Менежер.
  TextColumn get manager => text().nullable()();

  /// FK -> courses.id (nullable initially; course may be unassigned).
  TextColumn get courseId => text().nullable()();

  /// Сургалт text straight from the sheet, before mapping to a Courses row.
  TextColumn get courseNameRaw => text().nullable()();

  /// Original downloaded portrait image path.
  TextColumn get portraitPath => text().nullable()();

  /// Portrait path after remove.bg / rembg background removal.
  TextColumn get portraitProcessedPath => text().nullable()();

  /// One of: new | ready | printed | error.
  TextColumn get status => text().withDefault(const Constant('new'))();

  /// Populated when status == 'error'.
  TextColumn get errorMessage => text().nullable()();

  /// CERT-YYYY-NNNNNN (from nextCertificateId()).
  TextColumn get certificateId => text().nullable()();

  /// Epoch milliseconds (parsed from the sheet Timestamp).
  IntColumn get createdAt => integer()();

  /// Epoch milliseconds; null until actually printed.
  IntColumn get printedAt => integer().nullable()();
}

/// Rendered certificate PDFs.
@DataClassName('Certificate')
class Certificates extends Table {
  /// The certificate_id value (CERT-YYYY-NNNNNN).
  TextColumn get id => text()();

  /// FK -> submissions.id.
  IntColumn get submissionId => integer()();

  TextColumn get pdfPath => text()();

  /// 'A4' | 'A5'.
  TextColumn get paperSize => text()();

  /// Epoch milliseconds.
  IntColumn get generatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Simple key/value store for app settings.
@DataClassName('AppSetting')
class Settings extends Table {
  TextColumn get key => text()();

  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Race-safe per-year sequence counter for certificate IDs.
@DataClassName('CertificateCounterRow')
class CertificateCounter extends Table {
  /// e.g. 2026.
  IntColumn get year => integer()();

  /// NOT NULL, default 0. No `.withDefault()` here: that would make the
  /// generated insert companion expect `Value<int>` instead of plain `int`,
  /// breaking the required `CertificateCounterCompanion.insert(year:, lastSeq:)`
  /// call shape in database.dart. The SQL default is applied explicitly in
  /// AppDatabase's onCreate migration instead.
  IntColumn get lastSeq => integer()();

  @override
  Set<Column> get primaryKey => {year};
}
