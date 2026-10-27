import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../providers/courses_provider.dart';
import '../../providers/db_provider.dart';
import 'template_config.dart';
import 'template_preview_service.dart';
import 'widgets/template_marker_overlay.dart';

/// Step 5 — the template editor screen.
///
/// Shows a rasterized preview of the course's template (PDF or image, page 1)
/// and lets the user place three markers on it: name, civil number and
/// portrait. Everything is edited in memory and written to
/// `Courses.templatePath` + `Courses.templateConfigJson` on **Save**.
///
/// Coordinates are stored in points (1/72") with a top-left origin — see the
/// locked schema doc comment in `template_config.dart`.
class TemplateEditorPage extends ConsumerStatefulWidget {
  const TemplateEditorPage({super.key, required this.courseId});

  final String courseId;

  static Future<void> open(BuildContext context, String courseId) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TemplateEditorPage(courseId: courseId),
        ),
      );

  @override
  ConsumerState<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends ConsumerState<TemplateEditorPage> {
  bool _loading = true;
  Course? _course;
  TemplatePreview? _preview;
  String? _previewError;
  TemplateConfig _config = TemplateConfig.initial;
  MarkerKind _selected = MarkerKind.name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Same reason as the Settings screen: never touch providers during build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      final row = await (db.select(db.courses)
            ..where((t) => t.id.equals(widget.courseId)))
          .getSingleOrNull();
      if (row == null) {
        if (!mounted) return;
        setState(() {
          _course = null;
          _loading = false;
        });
        return;
      }

      // The course's paper size drives the editor even when the PDF reports a
      // different one: marker coordinates are normalized against the *saved*
      // page size, so they always land back on the right spot after a reload.
      final config = TemplateConfig.tryParse(row.templateConfigJson)
          .copyWith(paperSize: TemplatePaperSize.fromLabel(row.paperSize));

      TemplatePreview? preview;
      String? previewError;
      if (row.templatePath != null && row.templatePath!.isNotEmpty) {
        try {
          preview = await loadTemplatePreview(
            row.templatePath!,
            fallbackPaperSize: config.paperSize,
          );
        } catch (e) {
          previewError = e is TemplateLoadException
              ? e.message
              : 'Could not open the template file:\n$e';
        }
      } else {
        // No file chosen yet → render a blank A4/A5 page so markers can still
        // be placed and verified (steps.txt wants the editor usable early).
        try {
          preview = TemplatePreview(
            imageBytes: await renderBlankPage(
              widthPt: config.paperSize.widthPt,
              heightPt: config.paperSize.heightPt,
              label: row.name,
            ),
            pageWidthPt: config.paperSize.widthPt,
            pageHeightPt: config.paperSize.heightPt,
            sourcePath: '',
            kind: TemplateFileKind.image,
          );
        } catch (e) {
          previewError = 'Could not render the blank page:\n$e';
        }
      }

      if (!mounted) return;
      setState(() {
        _course = row;
        _config = config;
        _preview = preview;
        _previewError = previewError;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _previewError = 'Could not load the course:\n$e';
      });
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Replaces the backdrop with [path] (already copied into the app folder).
  Future<void> _applyTemplateFile(String path) async {
    final preview = await loadTemplatePreview(
      path,
      fallbackPaperSize: _config.paperSize,
    );
    if (!mounted) return;
    setState(() {
      _preview = preview;
      _previewError = null;
    });
  }

  Future<void> _pickTemplateFile() async {
    final picked = await pickTemplateFile(context);
    if (picked == null) return;
    try {
      final stored = await importTemplateFile(picked);
      await _applyTemplateFile(stored);
      _snack('Template imported from ${_shortName(stored)}');
    } catch (e) {
      _snack(e is TemplateLoadException ? e.message : 'Could not use file:\n$e');
    }
  }

  String _shortName(String path) {
    final i = path.replaceAll('\\', '/').lastIndexOf('/');
    return i == -1 ? path : path.substring(i + 1);
  }

  void _onPlace(MarkerKind kind, Offset pointPt) {
    setState(() {
      switch (kind) {
        case MarkerKind.name:
          _config = _config.copyWith(
            name: _config.name.copyWith(x: pointPt.dx, y: pointPt.dy),
          );
        case MarkerKind.civil:
          _config = _config.copyWith(
            civil: _config.civil.copyWith(x: pointPt.dx, y: pointPt.dy),
          );
        case MarkerKind.portrait:
          _config = _config.copyWith(
            portrait: _config.portrait.copyWith(
              x: pointPt.dx,
              y: pointPt.dy,
              // First placement gets the default box size from the schema.
              width: _config.portrait.width ?? 120.0,
              height: _config.portrait.height ?? 160.0,
            ),
          );
      }
    });
  }

  void _onDrag(MarkerKind kind, Offset deltaPt) {
    setState(() {
      switch (kind) {
        case MarkerKind.name:
          _config = _config.copyWith(
            name: _config.name.copyWith(
              x: (_config.name.x ?? 0) + deltaPt.dx,
              y: (_config.name.y ?? 0) + deltaPt.dy,
            ),
          );
        case MarkerKind.civil:
          _config = _config.copyWith(
            civil: _config.civil.copyWith(
              x: (_config.civil.x ?? 0) + deltaPt.dx,
              y: (_config.civil.y ?? 0) + deltaPt.dy,
            ),
          );
        case MarkerKind.portrait:
          _config = _config.copyWith(
            portrait: _config.portrait.copyWith(
              x: (_config.portrait.x ?? 0) + deltaPt.dx,
              y: (_config.portrait.y ?? 0) + deltaPt.dy,
            ),
          );
      }
    });
  }

  void _onResizePortrait(Size sizePt) {
    setState(() {
      _config = _config.copyWith(
        portrait: _config.portrait.copyWith(
          width: sizePt.width.clamp(8.0, _config.paperSize.widthPt),
          height: sizePt.height.clamp(8.0, _config.paperSize.heightPt),
        ),
      );
    });
  }

  Future<void> _save() async {
    final course = _course;
    if (course == null || _saving) return;
    setState(() => _saving = true);
    try {
      final db = await ref.read(appDatabaseProvider.future);
      await db.updateCourse(
        course.id,
        paperSize: _config.paperSize.label,
        templatePath: _preview?.sourcePath,
        templateConfigJson: _config.encode(),
      );
      // Courses list feeds the Submissions dropdown too → refresh both.
      ref.invalidate(coursesListProvider);
      if (!mounted) return;
      _snack('Template saved for “${course.name}”');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Could not save the template:\n$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = _course;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Template editor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Template editor')),
        body: const Center(child: Text('This course no longer exists.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Template · ${course.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: _buildCanvas(),
            ),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 340,
            child: _buildInspector(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    if (_previewError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined,
                  size: 40, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text(_previewError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickTemplateFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pick another template'),
              ),
            ],
          ),
        ),
      );
    }

    final preview = _preview;
    if (preview == null) {
      return const Center(child: Text('No template loaded.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit the whole page inside the canvas while keeping the aspect ratio.
        final availableW = constraints.maxWidth - 48;
        final availableH = constraints.maxHeight - 48;
        final scale = [
          availableW / preview.pageWidthPt,
          availableH / preview.pageHeightPt,
        ].reduce((a, b) => a < b ? a : b);
        final previewSize = Size(
          preview.pageWidthPt * scale,
          preview.pageHeightPt * scale,
        );

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TemplateMarkerOverlay(
                preview: preview,
                config: _config,
                selected: _selected,
                previewSize: previewSize,
                onSelected: (k) => setState(() => _selected = k),
                onPlace: _onPlace,
                onDrag: _onDrag,
                onResizePortrait: _onResizePortrait,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspector(ThemeData theme) {
    final preview = _preview;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Template file', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          (preview != null && preview.sourcePath.isNotEmpty)
              ? preview.sourcePath
              : 'No file selected — showing a blank page.',
          style: theme.textTheme.bodySmall,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _pickTemplateFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('Pick PDF / image…'),
          ),
        ),
        const Divider(height: 32),
        Text('Paper size', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<TemplatePaperSize>(
          segments: const [
            ButtonSegment(value: TemplatePaperSize.a4, label: Text('A4')),
            ButtonSegment(value: TemplatePaperSize.a5, label: Text('A5')),
          ],
          selected: {_config.paperSize},
          onSelectionChanged: (s) =>
              setState(() => _config = _config.copyWith(paperSize: s.first)),
        ),
        const SizedBox(height: 4),
        Text(
          '${_config.paperSize.widthPt.toStringAsFixed(1)} × '
          '${_config.paperSize.heightPt.toStringAsFixed(1)} pt',
          style: theme.textTheme.bodySmall,
        ),
        const Divider(height: 32),
        Text('Markers', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final kind in MarkerKind.values)
          RadioListTile<MarkerKind>(
            value: kind,
            groupValue: _selected,
            dense: true,
            title: Text(kind.label),
            subtitle: Text(_markerSummary(kind)),
            onChanged: (v) => setState(() => _selected = v ?? kind),
          ),
        const Divider(height: 32),
        ..._fieldsFor(_selected, theme),
        const Divider(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _config = TemplateConfig.initial),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset all markers'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Coordinates are stored in points (1/72"), origin top-left, exactly '
          'as the pdf package expects them.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _markerSummary(MarkerKind kind) {
    switch (kind) {
      case MarkerKind.name:
        return _placeSummary(_config.name.x, _config.name.y);
      case MarkerKind.civil:
        return _placeSummary(_config.civil.x, _config.civil.y);
      case MarkerKind.portrait:
        final p = _config.portrait;
        return '${_fmt(p.x)}, ${_fmt(p.y)} · ${_fmt(p.width)}×${_fmt(p.height)} pt';
    }
  }

  String _placeSummary(double? x, double? y) =>
      'x ${_fmt(x)} · y ${_fmt(y)} pt';

  String _fmt(double? v) => v == null ? '—' : v.toStringAsFixed(1);

  /// Numeric editing for the selected marker (values in points).
  List<Widget> _fieldsFor(MarkerKind kind, ThemeData theme) {
    switch (kind) {
      case MarkerKind.name:
        return [
          _pointField('Name X (pt)', _config.name.x,
              (v) => _update(name: _config.name.copyWith(x: v))),
          _pointField('Name Y (pt)', _config.name.y,
              (v) => _update(name: _config.name.copyWith(y: v))),
          _pointField('Font size (pt)', _config.name.fontSize,
              (v) => _update(name: _config.name.copyWith(fontSize: v))),
          _pointField('Max width (pt)', _config.name.maxWidth,
              (v) => _update(name: _config.name.copyWith(maxWidth: v))),
          _alignDropdown(_config.name.align,
              (a) => _update(name: _config.name.copyWith(align: a))),
          _colorRow(
            _config.name.color,
            (c) => _update(name: _config.name.copyWith(color: c)),
            theme,
          ),
        ];
      case MarkerKind.civil:
        return [
          _pointField('Civil X (pt)', _config.civil.x,
              (v) => _update(civil: _config.civil.copyWith(x: v))),
          _pointField('Civil Y (pt)', _config.civil.y,
              (v) => _update(civil: _config.civil.copyWith(y: v))),
          _pointField('Font size (pt)', _config.civil.fontSize,
              (v) => _update(civil: _config.civil.copyWith(fontSize: v))),
          _pointField('Max width (pt)', _config.civil.maxWidth,
              (v) => _update(civil: _config.civil.copyWith(maxWidth: v))),
          _alignDropdown(_config.civil.align,
              (a) => _update(civil: _config.civil.copyWith(align: a))),
          _colorRow(
            _config.civil.color,
            (c) => _update(civil: _config.civil.copyWith(color: c)),
            theme,
          ),
        ];
      case MarkerKind.portrait:
        return [
          _pointField('Portrait X (pt)', _config.portrait.x,
              (v) => _update(portrait: _config.portrait.copyWith(x: v))),
          _pointField('Portrait Y (pt)', _config.portrait.y,
              (v) => _update(portrait: _config.portrait.copyWith(y: v))),
          _pointField('Width (pt)', _config.portrait.width,
              (v) => _update(portrait: _config.portrait.copyWith(width: v))),
          _pointField('Height (pt)', _config.portrait.height,
              (v) => _update(portrait: _config.portrait.copyWith(height: v))),
          DropdownButtonFormField<TemplateImageFit>(
            initialValue: _config.portrait.fit,
            decoration: const InputDecoration(labelText: 'Image fit'),
            items: const [
              DropdownMenuItem(
                  value: TemplateImageFit.cover, child: Text('cover')),
              DropdownMenuItem(
                  value: TemplateImageFit.contain, child: Text('contain')),
            ],
            onChanged: (f) => f == null
                ? null
                : _update(portrait: _config.portrait.copyWith(fit: f)),
          ),
        ];
    }
  }

  void _update({
    TemplateTextField? name,
    TemplateTextField? civil,
    TemplatePortraitField? portrait,
  }) =>
      setState(() => _config = _config.copyWith(
            name: name,
            civil: civil,
            portrait: portrait,
          ));

  Widget _pointField(String label, double? value, ValueChanged<double?> onChange) {
    return _NumberPointField(
      key: ValueKey('$label@${value?.toStringAsFixed(2)}'),
      label: label,
      value: value,
      onChanged: onChange,
    );
  }

  Widget _alignDropdown(
          TemplateTextAlign align, ValueChanged<TemplateTextAlign> onChange) =>
      DropdownButtonFormField<TemplateTextAlign>(
        initialValue: align,
        decoration: const InputDecoration(labelText: 'Alignment'),
        items: [
          for (final a in TemplateTextAlign.values)
            DropdownMenuItem(value: a, child: Text(a.label)),
        ],
        onChanged: (v) => v == null ? null : onChange(v),
      );

  Widget _colorRow(Color? color, ValueChanged<Color> onChange, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text('Colour', style: theme.textTheme.bodyMedium)),
          InkWell(
            onTap: () async {
              final picked = await showDialog<Color>(
                context: context,
                builder: (_) => const _ColorPickerDialog(),
              );
              if (picked != null) onChange(picked);
            },
            child: Container(
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: color ?? const Color(0xFF000000),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: theme.colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            color == null
                ? '#000000 (default)'
                : '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Small text field that commits a point value (blank == unplaced/null).
class _NumberPointField extends StatefulWidget {
  const _NumberPointField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  State<_NumberPointField> createState() => _NumberPointFieldState();
}

class _NumberPointFieldState extends State<_NumberPointField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value?.toStringAsFixed(2) ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null) {
      // Restore the previous value instead of silently dropping input.
      _controller.text = widget.value?.toStringAsFixed(2) ?? '';
      return;
    }
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(labelText: widget.label, isDense: true),
        onSubmitted: (_) => _commit(),
        onTapOutside: (_) {
          _commit();
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}

/// Minimal swatch picker — enough for "#RRGGBB" text colours without adding a
/// dependency.
class _ColorPickerDialog extends StatelessWidget {
  const _ColorPickerDialog();

  static const List<Color> _swatches = [
    Color(0xFF000000),
    Color(0xFF1A237E),
    Color(0xFF0B3D91),
    Color(0xFF004D40),
    Color(0xFF3E2723),
    Color(0xFF7F0000),
    Color(0xFF6A1B9A),
    Color(0xFFFFD600),
    Color(0xFF37474F),
    Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a colour'),
      content: SizedBox(
        width: 260,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _swatches)
              InkWell(
                onTap: () => Navigator.of(context).pop(c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

