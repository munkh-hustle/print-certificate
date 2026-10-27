import 'dart:convert';
import 'dart:ui' show Color;

/// Step 5 — the JSON model for `Courses.templateConfigJson`.
///
/// ---------------------------------------------------------------------------
/// LOCKED JSON SHAPE (version 1) — Steps 6 and 8 read this exact structure.
/// Do not invent alternative field names or units.
///
/// ```json
/// {
///   "version": 1,
///   "paperSize": "A4",
///   "name":    { "x": 120.0, "y": 340.0, "fontSize": 14.0, "color": "#000000",
///                "maxWidth": 300.0, "align": "left" },
///   "civil":   { "x": 120.0, "y": 370.0, "fontSize": 12.0, "color": "#000000",
///                "maxWidth": 200.0, "align": "left" },
///   "portrait":{ "x": 40.0,  "y": 80.0,  "width": 120.0, "height": 160.0,
///                "fit": "cover" }
/// }
/// ```
///
/// * **Units:** points (1/72 inch), origin at the **top-left** corner of the
///   page. This matches the `pdf` package's `pw.Page` page size / coordinate
///   space, so Step 6 can pass `x`/`y` straight into `pw.Positioned`.
///   (`pdf` itself paints from a bottom-left origin, so the renderer flips:
///   `y_pdf = pageHeightPt - y - <element height>`.)
/// * `version`: int, always `1` for now (reserved for future migrations).
/// * `paperSize`: `'A4'` | `'A5'`.
/// * `align`: `"left"` | `"center"` | `"right"` (Step 6 maps to
///   `pw.Alignment`).
/// * `color`: `"#RRGGBB"` hex string.
/// * `fit`: `"cover"` | `"contain"`.
/// * All numeric fields are doubles in the JSON.
/// * A marker that has **not been placed yet** is serialized with `null`
///   values for its numeric fields (`align`/`fit` still carry their defaults).
///   The editor always saves the full object.
/// ---------------------------------------------------------------------------

/// Paper sizes supported by the app (mirrors `Courses.paperSize`).
enum TemplatePaperSize {
  a4('A4'),
  a5('A5');

  const TemplatePaperSize(this.label);

  /// The value stored in the DB / JSON.
  final String label;

  static TemplatePaperSize fromLabel(String? value) =>
      values.firstWhere((s) => s.label == value, orElse: () => a4);

  /// Page width in points (1/72"), portrait orientation.
  double get widthPt => this == a4 ? 595.0 : 419.5;

  /// Page height in points (1/72"), portrait orientation.
  double get heightPt => this == a4 ? 842.0 : 595.0;
}

/// Horizontal text alignment for a [TemplateTextField].
enum TemplateTextAlign {
  left('left'),
  center('center'),
  right('right');

  const TemplateTextAlign(this.label);
  final String label;

  static TemplateTextAlign fromLabel(String? value) =>
      values.firstWhere((a) => a.label == value, orElse: () => left);
}

/// How a portrait image is fitted inside its box.
enum TemplateImageFit {
  cover('cover'),
  contain('contain');

  const TemplateImageFit(this.label);
  final String label;

  static TemplateImageFit fromLabel(String? value) =>
      values.firstWhere((f) => f.label == value, orElse: () => cover);
}

double? _toDouble(Object? v) => v == null ? null : (v as num).toDouble();

String? _toHexColor(Color? c) {
  if (c == null) return null;
  final argb = c.toARGB32();
  // Keep only the RGB part — the schema is "#RRGGBB".
  return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color? _fromHexColor(String? s) {
  if (s == null || s.isEmpty) return null;
  var hex = s.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex'; // schema is opaque #RRGGBB
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(value);
}

/// One text marker (name / civil number) on the template.
class TemplateTextField {
  const TemplateTextField({
    this.x,
    this.y,
    this.fontSize,
    this.color,
    this.maxWidth,
    this.align = TemplateTextAlign.left,
  });

  /// Left edge of the text box, in points from the page's left edge
  /// (top-left origin). Null == not placed yet.
  final double? x;

  /// Top edge of the text box, in points from the page's top edge.
  final double? y;

  final double? fontSize;

  /// Text colour ("#RRGGBB" in JSON).
  final Color? color;

  /// Widest the text may grow before Step 6 wraps/shrinks it.
  final double? maxWidth;

  final TemplateTextAlign align;

  bool get isPlaced => x != null && y != null;

  TemplateTextField copyWith({
    double? x,
    double? y,
    double? fontSize,
    Color? color,
    double? maxWidth,
    TemplateTextAlign? align,
  }) =>
      TemplateTextField(
        x: x ?? this.x,
        y: y ?? this.y,
        fontSize: fontSize ?? this.fontSize,
        color: color ?? this.color,
        maxWidth: maxWidth ?? this.maxWidth,
        align: align ?? this.align,
      );

  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'fontSize': fontSize,
        'color': _toHexColor(color),
        'maxWidth': maxWidth,
        'align': align.label,
      };

  factory TemplateTextField.fromJson(Map<String, Object?> json) =>
      TemplateTextField(
        x: _toDouble(json['x']),
        y: _toDouble(json['y']),
        fontSize: _toDouble(json['fontSize']),
        color: _fromHexColor(json['color'] as String?),
        maxWidth: _toDouble(json['maxWidth']),
        align: TemplateTextAlign.fromLabel(json['align'] as String?),
      );
}

/// The portrait marker: a rectangle the photo is drawn into.
class TemplatePortraitField {
  const TemplatePortraitField({
    this.x,
    this.y,
    this.width,
    this.height,
    this.fit = TemplateImageFit.cover,
  });

  /// Top-left corner of the box, in points (top-left page origin).
  final double? x;
  final double? y;
  final double? width;
  final double? height;
  final TemplateImageFit fit;

  bool get isPlaced => x != null && y != null;

  TemplatePortraitField copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    TemplateImageFit? fit,
  }) =>
      TemplatePortraitField(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
        fit: fit ?? this.fit,
      );

  Map<String, Object?> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'fit': fit.label,
      };

  factory TemplatePortraitField.fromJson(Map<String, Object?> json) =>
      TemplatePortraitField(
        x: _toDouble(json['x']),
        y: _toDouble(json['y']),
        width: _toDouble(json['width']),
        height: _toDouble(json['height']),
        fit: TemplateImageFit.fromLabel(json['fit'] as String?),
      );
}

/// The whole `templateConfigJson` document.
class TemplateConfig {
  const TemplateConfig({
    this.version = currentVersion,
    this.paperSize = TemplatePaperSize.a4,
    this.name = const TemplateTextField(),
    this.civil = const TemplateTextField(),
    this.portrait = const TemplatePortraitField(),
  });

  /// Schema version written into every saved document.
  static const int currentVersion = 1;

  /// Starting values for a brand-new config (the numbers from steps.txt).
  /// Positions stay null until the user actually places each marker.
  static const TemplateConfig initial = TemplateConfig(
    name: TemplateTextField(fontSize: 14.0, maxWidth: 300.0),
    civil: TemplateTextField(fontSize: 12.0, maxWidth: 200.0),
    portrait: TemplatePortraitField(width: 120.0, height: 160.0),
  );

  final int version;
  final TemplatePaperSize paperSize;

  /// Surname + first name line.
  final TemplateTextField name;

  /// РД дугаар (civil / registration number) line.
  final TemplateTextField civil;

  final TemplatePortraitField portrait;

  TemplateConfig copyWith({
    TemplatePaperSize? paperSize,
    TemplateTextField? name,
    TemplateTextField? civil,
    TemplatePortraitField? portrait,
  }) =>
      TemplateConfig(
        version: version,
        paperSize: paperSize ?? this.paperSize,
        name: name ?? this.name,
        civil: civil ?? this.civil,
        portrait: portrait ?? this.portrait,
      );

  Map<String, Object?> toJson() => {
        'version': version,
        'paperSize': paperSize.label,
        'name': name.toJson(),
        'civil': civil.toJson(),
        'portrait': portrait.toJson(),
      };

  /// Strict parse — throws on malformed input.
  factory TemplateConfig.fromJson(Map<String, Object?> json) {
    Map<String, Object?> section(String key) {
      final raw = json[key];
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), v as Object?));
      }
      return const {};
    }

    return TemplateConfig(
      version: (json['version'] as num?)?.toInt() ?? currentVersion,
      paperSize: TemplatePaperSize.fromLabel(json['paperSize'] as String?),
      name: TemplateTextField.fromJson(section('name')),
      civil: TemplateTextField.fromJson(section('civil')),
      portrait: TemplatePortraitField.fromJson(section('portrait')),
    );
  }

  /// Tolerant parse used when loading from the DB: anything unreadable
  /// degrades to an empty (all-unplaced) config instead of crashing the
  /// editor screen.
  static TemplateConfig tryParse(String? source) {
    if (source == null || source.trim().isEmpty) return initial;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return initial;
      return TemplateConfig.fromJson(
        decoded.map((k, v) => MapEntry(k.toString(), v as Object?)),
      );
    } catch (_) {
      return initial;
    }
  }

  /// JSON string to store in `Courses.templateConfigJson`.
  String encode() => jsonEncode(toJson());
}
