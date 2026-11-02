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
      // ROOT-CAUSE FIX for the render-tree dump that repeated the same
      // signature on EVERY child of the segment row
      // (children 1..54 in the debug output):
      //   constraints: BoxConstraints(0.0<=w<=Infinity, 0.0<=h<=24.0)
      //   additionalConstraints: BoxConstraints(0.0<=w<=Infinity, 48.0<=h<=Infinity)
      // i.e. "RenderConstrainedBox OVERFLOWED by 24.0 pixels" × N children.
      // The 48dp floor comes from the default MaterialTapTargetSize.padded
      // (enforced via a RenderConstrainedBox inside each segment); the 24dp
      // ceiling is the tight cross-axis constraint handed down by the parent
      // Row. Because every chip/segment renders through the same theme object,
      // fixing one instance fixes all of them ("from child 1 to all").
      //
      // NOTE: `maximumSize` must NEVER be capped at 24 here — an earlier
      // attempt did exactly that, which clamped the *outer* box to 24 while
      // the inner tap-target ConstrainedBox still demanded >= 48, reproducing
      // the very overflow it was supposed to prevent. Keep the max generous
      // (>= 48) and let `shrinkWrap` + compact density do the shrinking.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 24)),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          ),
        ),
      ),
      // ROOT-CAUSE FIX for the render dump where EVERY child of a row showed
      //   constraints: BoxConstraints(0.0<=w<=Infinity, 0.0<=h<=24.0)
      //   additionalConstraints: BoxConstraints(0.0<=w<=Infinity, 48.0<=h<=Infinity)
      // i.e. "RenderConstrainedBox OVERFLOWED by 24.0 pixels" x all children.
      // That signature is the Material 3 *list tile* tap-target box: every
      // ListTile-family widget (RadioListTile included) wraps its contents in a
      // ConstrainedBox whose minimum height comes from
      // `Material.of(context).tapTargetSize`. With the default
      // MaterialTapTargetSize.padded that floor is 48dp; when such tiles sit in
      // a dense row/slot that only offers 24dp of height, each tile's inner
      // RenderConstrainedBox overflows by exactly 24px - once per child.
      // Setting shrinkWrap here removes the 48dp floor for ALL list tiles
      // rendered through this theme at once ("from child 1 to all").
      // NOTE: ListTileThemeData's valid named parameters only -
      // `materialTapTargetSize`, `dense`, `minVerticalPadding`. It does NOT
      // expose `visualDensity` / `tapTargetSize` (those live on ThemeData and
      // ButtonStyle respectively); passing them here previously produced
      // `undefined_named_parameter` analyzer errors.
      listTileTheme: ListTileThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        dense: true,
        minVerticalPadding: 2,
      ),
      // Same class of bug for chips: an oversized chip layout enforces a
      // 48dp-tall RenderConstrainedBox, which overflows by 24px whenever a
      // chip sits in a 24dp-high slot (dense rows, toolbars, segment lists).
      // NOTE: `ChipThemeData` exposes NEITHER `tapTargetSize` NOR
      // `visualDensity` as named parameters (those live on ButtonStyle /
      // styleFrom APIs and on the individual chip widgets). Passing either
      // here produced `undefined_named_parameter` analyzer errors. The
      // explicit compact `padding`/`labelPadding` sizing below keeps each
      // chip's intrinsic height well under 24dp, which achieves the same
      // overflow-free result through the knobs that DO exist on ChipThemeData.
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Belt-and-braces coverage for the remaining button themes so the same
      // "RenderConstrainedBox 0<=h<=24 vs additionalConstraints 48<=h<=Infinity"
      // signature can never reappear from any themed button variant placed in
      // a height-limited slot ("from child 1 to all" in the render dump):
      // outlined / elevated / filled already override above; these complete
      // the set.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
