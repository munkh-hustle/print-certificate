import 'dart:io';
import 'dart:ui' show Offset, Size;

import 'package:file_picker/file_picker.dart';
// ignore: unnecessary_import — required for the `FilePicker.platform` getter.
import 'package:file_picker/platform/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfColors, PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show PdfRaster, Printing;

import 'template_config.dart';

/// Step 5 — loads a certificate template (PDF or image) and turns page 1 into
/// a raster PNG that the marker editor can display, together with the page's
/// real size in **points** (1/72") so screen↔point conversions stay exact.
///
/// Why a raster instead of a live `PdfPreview` widget: the editor has to
/// overlay interactive markers on top of the page, which is far simpler over a
/// plain [Image]. The `pdf` package cannot re-open an existing PDF (it only
/// writes them), so we rasterize with `printing`'s bundled PDFium
/// (`Printing.raster`).
class TemplatePreview {
  TemplatePreview({
    required this.imageBytes,
    required this.pageWidthPt,
    required this.pageHeightPt,
    required this.sourcePath,
    required this.kind,
  });

  /// PNG bytes ready for [Image.memory].
  final Uint8List imageBytes;

  /// Page size in points. Taken from the PDF itself when the template is one;
  /// for image templates we fall back to the course's configured paper size
  /// (a PNG has no intrinsic physical size).
  final double pageWidthPt;
  final double pageHeightPt;

  final String sourcePath;
  final TemplateFileKind kind;

  bool get isPdf => kind == TemplateFileKind.pdf;

  /// Converts a position inside the displayed preview (logical px) into PDF
  /// points with a top-left origin — the coordinate space of the JSON schema.
  Offset pointFromPreview(Offset previewLocal, Size previewSize) => Offset(
        previewLocal.dx / previewSize.width * pageWidthPt,
        previewLocal.dy / previewSize.height * pageHeightPt,
      );

  /// The inverse: where a stored point has to be drawn on screen.
  Offset previewFromPoint(Offset pointPt, Size previewSize) => Offset(
        pointPt.dx / pageWidthPt * previewSize.width,
        pointPt.dy / pageHeightPt * previewSize.height,
      );

  /// Scale factor (screen px per PDF pt) for the given preview size.
  double scaleFactor(Size previewSize) => previewSize.width / pageWidthPt;
}

enum TemplateFileKind { pdf, image }

/// DPI the preview is rasterized at (kept modest: fast, still readable).
const double kPreviewPixelDpi = 150;

TemplateFileKind? templateKindFor(String path) {
  final ext = p.extension(path).toLowerCase();
  if (ext == '.pdf') return TemplateFileKind.pdf;
  if (const {'.png', '.jpg', '.jpeg', '.webp', '.bmp', '.gif'}
      .contains(ext)) {
    return TemplateFileKind.image;
  }
  return null;
}

/// Errors surfaced to the UI (short readable messages, no stack traces).
class TemplateLoadException implements Exception {
  const TemplateLoadException(this.message);
  final String message;

  @override
  String toString() => message;
}

Future<Directory> _templatesDir() async {
  final support = await getApplicationSupportDirectory();
  final dir = Directory(p.join(support.path, 'templates'));
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Opens the native file dialog filtered to PDF + common images.
///
/// Returns the absolute path the user picked, or null when cancelled.
Future<String?> pickTemplateFile(BuildContext context) async {
  try {
    // `FilePicker.platform` lives in the `file_picker/platform/` part of the
    // library, which is NOT exported by the main barrel file — it must be
    // imported explicitly.
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose a certificate template (PDF or image)',
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'webp', 'bmp'],
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    if (templateKindFor(path) == null) {
      _notify(context, 'Unsupported template file type: ${p.extension(path)}');
      return null;
    }
    return path;
  } catch (e) {
    // file_picker throws on some platforms when the dialog cannot open.
    _notify(context, 'Could not open the file picker: $e');
    return null;
  }
}

void _notify(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Copies the picked file into the app's own templates folder
/// (`<application support>/templates/`) so the course keeps working even if
/// the original file is later moved or deleted.
///
/// Returns the stored absolute path — exactly what goes into
/// `Courses.templatePath`.
Future<String> importTemplateFile(String sourcePath) async {
  final src = File(sourcePath);
  if (!await src.exists()) {
    throw const TemplateLoadException('The selected file no longer exists.');
  }
  final dir = await _templatesDir();
  final target = File(p.join(dir.path, p.basename(sourcePath)));
  // Already imported (same location) → nothing to copy.
  if (p.equals(target.path, sourcePath)) return target.path;
  try {
    await src.copy(target.path);
  } catch (e) {
    throw TemplateLoadException('Could not copy the template: $e');
  }
  return target.path;
}

/// Where imported templates live. steps.txt asks for `assets/templates/`;
/// bundling files into the Flutter asset bundle would need a rebuild per
/// template, so the app keeps user-picked copies here instead.
Future<String> templatesDirPath() async => (await _templatesDir()).path;

/// Rasterizes/decodes [path] into a [TemplatePreview].
///
/// [fallbackPaperSize] supplies the page size for image templates (a PNG has
/// no intrinsic physical size) — pass the course's paper size.
Future<TemplatePreview> loadTemplatePreview(
  String path, {
  TemplatePaperSize fallbackPaperSize = TemplatePaperSize.a4,
}) async {
  final file = File(path);
  if (!await file.exists()) {
    throw TemplateLoadException('Template file not found:\n$path');
  }
  final kind = templateKindFor(path);
  if (kind == null) {
    throw const TemplateLoadException('Unknown template file type.');
  }
  final bytes = await file.readAsBytes();

  if (kind == TemplateFileKind.image) {
    // Let Flutter decode it; the editor scales it to the paper aspect ratio.
    return TemplatePreview(
      imageBytes: bytes,
      pageWidthPt: fallbackPaperSize.widthPt,
      pageHeightPt: fallbackPaperSize.heightPt,
      sourcePath: path,
      kind: kind,
    );
  }

  List<PdfRaster> rasters;
  try {
    rasters = await Printing.raster(bytes,
        pages: const [0], dpi: kPreviewPixelDpi.toInt()).toList();
  } catch (e) {
    throw TemplateLoadException('Could not render the PDF template:\n$e');
  }
  if (rasters.isEmpty) {
    throw const TemplateLoadException('The PDF has no pages.');
  }
  final raster = rasters.first;
  // PdfRaster reports pixels only; recover points from the DPI we asked for
  // (pixels = points * dpi / 72).
  final png = await raster.toPng();
  return TemplatePreview(
    imageBytes: png,
    pageWidthPt: raster.width * 72.0 / kPreviewPixelDpi,
    pageHeightPt: raster.height * 72.0 / kPreviewPixelDpi,
    sourcePath: path,
    kind: kind,
  );
}

/// A blank page of [widthPt] x [heightPt] with a centred [label], rendered as
/// a PNG through the `pdf` + `printing` packages. Used as the editor backdrop
/// when a course has no template file yet, so markers can still be placed.
Future<Uint8List> renderBlankPage({
  required double widthPt,
  required double heightPt,
  required String label,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(widthPt, heightPt, marginAll: 0),
      build: (context) => pw.Container(
        color: PdfColors.white,
        child: pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(
                      fontSize: 22, color: PdfColor.fromInt(0xFF888888))),
              pw.SizedBox(height: 10),
              pw.Text('No template file selected',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
            ],
          ),
        ),
      ),
    ),
  );
  final bytes = await doc.save();
  final rasters = await Printing.raster(bytes,
      pages: const [0], dpi: kPreviewPixelDpi.toInt()).toList();
  return rasters.first.toPng();
}
