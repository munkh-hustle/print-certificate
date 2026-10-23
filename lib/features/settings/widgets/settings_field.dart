import 'package:flutter/material.dart';

/// A labeled [TextFormField] with consistent spacing, optional helper text,
/// an optional footnote (e.g. "Coming in Step 10"), and an optional trailing
/// widget (used for the show/hide password toggle).
///
/// Pure presentation — no logic beyond forwarding to the inner field.
class SettingsField extends StatelessWidget {
  const SettingsField({
    super.key,
    required this.label,
    required this.controller,
    this.helperText,
    this.footnote,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.validator,
    this.trailing,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? helperText;
  final String? footnote;
  final String? hintText;
  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          if (trailing != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(context),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: trailing!,
                ),
              ],
            )
          else
            _buildField(context),
          if (footnote != null) ...[
            const SizedBox(height: 4),
            Text(
              footnote!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      autofillHints: const [],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      // Monospace reads better for pasted JSON / long IDs.
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }
}
