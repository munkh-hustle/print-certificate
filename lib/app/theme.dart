import 'package:flutter/material.dart';

/// Central place for the app's light and dark [ThemeData].
///
/// Used by `MaterialApp(theme: ..., darkTheme: ...)` in `lib/main.dart`.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF3D5AFE);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme:
            IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      // NOTE: these button themes must keep `tapTargetSize: shrinkWrap` and an
      // explicit `minimumSize`. The M3 defaults impose a 48dp-tall min through
      // MaterialTapTargetSize (a RenderConstrainedBox with
      // `minHeight: 48.0`) *inside* the button, while a tight vertical
      // constraint (maxHeight: 24) is handed to the child by the parent Row /
      // Align. That combination produces the classic overflow signature:
      //   constraints: BoxConstraints(0.0<=w<=Infinity, 0.0<=h<=24.0)
      //   additionalConstraints: BoxConstraints(0.0<=w<=Infinity, 48.0<=h<=Infinity)
      // i.e. "RenderConstrainedBox ... 24.0 pixels overflowing".
      // Overriding both knobs here makes the bug impossible to reintroduce for
      // any button placed in a height-limited slot (AppBar actions, table row
      // actions, dense toolbars).
      //
      // `minimumSize` stays at 0 width so buttons remain right-sized; only the
      // hard 48dp floor is removed. TextButton additionally gets a 24dp floor
      // because it is used inside AppBar actions and dialog actions where the
      // available height can be as small as 24dp.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 24),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 24),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 24),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const Size(0, 24),
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      // SegmentedButtonThemeData.style is a *plain* ButtonStyle (there is no
      // `.styleFrom` helper). Its `minimumSize`, `maximumSize`, `padding` and
      // `iconSize` fields require `WidgetStateProperty<...>` values, while
      // `tapTargetSize` and `visualDensity` are plain nullable enums — mixing
      // the two up is what produced the previous
      // `argument_type_not_assignable` analyzer errors here.
      //
      // More importantly, wrapping only the tap target was NOT enough to stop
      // the overflow seen in the debug dump
      // (`additionalConstraints: BoxConstraints(0.0<=w<=Infinity,
      // 48.0<=h<=Infinity)` inside a `0.0<=h<=24.0` slot): when the app runs
      // with a platform/brightness combination that has no dedicated theme
      // entry, or before this theme is applied, the M3 default still imposes
      // the 48dp floor. The definitive fix lives at the layout level in
      // `template_editor_page.dart`: every button-like widget is given LOOSE
      // height constraints instead of being squeezed into a tight 24dp slot.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          minimumSize: const WidgetStatePropertyAll<Size>(Size.zero),
          maximumSize: const WidgetStatePropertyAll<Size>(
            Size(double.infinity, 24),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
