import 'package:flutter/material.dart';

import '../template_config.dart';
import '../template_preview_service.dart';

/// Which marker the editor is currently manipulating.
enum MarkerKind {
  name('Name (surname + first name)'),
  civil('Civil number (РД дугаар)'),
  portrait('Portrait photo box');

  const MarkerKind(this.label);
  final String label;

  Color get accent => switch (this) {
        MarkerKind.name => const Color(0xFF3D5AFE),
        MarkerKind.civil => const Color(0xFF00897B),
        MarkerKind.portrait => const Color(0xFFF57C00),
      };
}

/// The interactive canvas of the Step 5 template editor.
///
/// Draws the rasterized template page at [previewSize] and overlays the three
/// markers on top. All pointer maths happens in *screen* logical pixels and is
/// converted to/from PDF points through [TemplatePreview], so what you see is
/// exactly what gets stored.
///
/// Interaction model:
///  * tap empty canvas → places the **selected** marker at that point;
///  * drag a marker   → moves it (fine positioning without pixel hunting);
///  * drag the corner handle of the portrait box → resizes it;
///  * tap a marker    → selects it.
class TemplateMarkerOverlay extends StatelessWidget {
  const TemplateMarkerOverlay({
    super.key,
    required this.preview,
    required this.config,
    required this.selected,
    required this.previewSize,
    required this.onSelected,
    required this.onPlace,
    required this.onDrag,
    required this.onResizePortrait,
  });

  final TemplatePreview preview;
  final TemplateConfig config;
  final MarkerKind selected;
  final Size previewSize;
  final ValueChanged<MarkerKind> onSelected;
  final void Function(MarkerKind kind, Offset pointPt) onPlace;
  final void Function(MarkerKind kind, Offset deltaPt) onDrag;
  final void Function(Size sizePt) onResizePortrait;

  double get _scaleX => previewSize.width / preview.pageWidthPt;
  double get _scaleY => previewSize.height / preview.pageHeightPt;

  Offset _toScreen(Offset pointPt) =>
      Offset(pointPt.dx * _scaleX, pointPt.dy * _scaleY);

  Offset _toPoints(Offset screenLocal) => Offset(
        _scaleX == 0 ? 0 : screenLocal.dx / _scaleX,
        _scaleY == 0 ? 0 : screenLocal.dy / _scaleY,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: previewSize.width,
      height: previewSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- template backdrop -------------------------------------------
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Image.memory(
                preview.imageBytes,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          // --- paper outline ----------------------------------------------
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                ),
              ),
            ),
          ),
          // --- tap-to-place layer (below the markers) ----------------------
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (d) => onPlace(selected, _toPoints(d.localPosition)),
            ),
          ),
          // --- markers -----------------------------------------------------
          ..._buildMarkers(context),
        ],
      ),
    );
  }

  List<Widget> _buildMarkers(BuildContext context) {
    final widgets = <Widget>[];

    if (config.name.isPlaced) {
      widgets.add(_textMarker(MarkerKind.name, config.name, 'N · ${config.name.x!.toStringAsFixed(0)},${config.name.y!.toStringAsFixed(0)}'));
    }
    if (config.civil.isPlaced) {
      widgets.add(_textMarker(MarkerKind.civil, config.civil, 'РД · ${config.civil.x!.toStringAsFixed(0)},${config.civil.y!.toStringAsFixed(0)}'));
    }
    if (config.portrait.isPlaced) {
      widgets.add(_portraitMarker());
    }
    if (widgets.isEmpty) {
      widgets.add(_hintBanner(context));
    }
    return widgets;
  }

  Widget _hintBanner(BuildContext context) {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: IgnorePointer(
        child: Material(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Tap the page to place “${selected.label}”. Drag a marker to '
              'nudge it; drag the orange corner to resize the portrait.',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _textMarker(MarkerKind kind, TemplateTextField field, String tag) {
    final topLeft = _toScreen(Offset(field.x!, field.y!));
    final fontSize = (field.fontSize ?? 14.0);
    final maxWidth = (field.maxWidth ?? 300.0) * _scaleX;
    final height = fontSize * _scaleY * 1.6;
    final isSelected = selected == kind;

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: _MarkerChrome(
        color: kind.accent,
        selected: isSelected,
        label: tag,
        width: maxWidth,
        height: height,
        onTap: () => onSelected(kind),
        onPanUpdate: (deltaScreen) => onDrag(kind, _toPoints(deltaScreen)),
        child: ColoredBox(
          color: kind.accent.withValues(alpha: isSelected ? 0.22 : 0.10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Align(
              alignment: switch (field.align) {
                TemplateTextAlign.center => Alignment.centerLeft,
                TemplateTextAlign.right => Alignment.centerRight,
                TemplateTextAlign.left => Alignment.centerLeft,
              },
              child: Text(
                kind == MarkerKind.name ? 'Овог Нэр' : 'У/РД-00000000',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: fontSize.clamp(6, 48),
                  height: 1.3,
                  color: field.color ?? const Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _portraitMarker() {
    final p = config.portrait;
    final topLeft = _toScreen(Offset(p.x!, p.y!));
    final w = (p.width ?? 120.0) * _scaleX;
    final h = (p.height ?? 160.0) * _scaleY;
    final isSelected = selected == MarkerKind.portrait;

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: _MarkerChrome(
        color: MarkerKind.portrait.accent,
        selected: isSelected,
        label: '${(p.width ?? 0).toStringAsFixed(0)}×'
            '${(p.height ?? 0).toStringAsFixed(0)} pt',
        width: w,
        height: h,
        onTap: () => onSelected(MarkerKind.portrait),
        onPanUpdate: (deltaScreen) =>
            onDrag(MarkerKind.portrait, _toPoints(deltaScreen)),
        child: ColoredBox(
          color:
              MarkerKind.portrait.accent.withValues(alpha: isSelected ? 0.20 : 0.08),
          child: Center(
            child: Icon(Icons.person_outline,
                size: (w < 40 ? 14 : 26).toDouble(), color: Colors.black54),
          ),
        ),
        handle: _ResizeHandle(
          color: MarkerKind.portrait.accent,
          onUpdate: (deltaScreen) {
            final deltaPt = _toPoints(deltaScreen);
            onResizePortrait(
              Size((p.width ?? 0) + deltaPt.dx, (p.height ?? 0) + deltaPt.dy),
            );
          },
        ),
      ),
    );
  }
}

/// Box around a marker: coloured border when selected, always visible label.
class _MarkerChrome extends StatelessWidget {
  const _MarkerChrome({
    required this.color,
    required this.selected,
    required this.label,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onPanUpdate,
    required this.child,
    this.handle,
  });

  final Color color;
  final bool selected;
  final String label;
  final double width;
  final double height;
  final VoidCallback onTap;
  final ValueChanged<Offset> onPanUpdate;
  final Widget child;
  final Widget? handle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onPanUpdate: (d) => onPanUpdate(d.delta),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: child),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: color, width: selected ? 2 : 1),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -16,
              left: 0,
              child: IgnorePointer(
                child: ColoredBox(
                  color: color,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    child: Text(
                      label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10, height: 1.2),
                    ),
                  ),
                ),
              ),
            ),
            if (handle != null)
              Positioned(right: -10, bottom: -10, child: handle!),
          ],
        ),
      ),
    );
  }
}

/// Draggable square in the corner of the portrait box that changes its size.
class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.color, required this.onUpdate});

  final Color color;
  final ValueChanged<Offset> onUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => onUpdate(d.delta),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.open_in_full, size: 11, color: Colors.white),
      ),
    );
  }
}
