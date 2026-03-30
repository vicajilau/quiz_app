// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizdy/core/theme/app_theme.dart';

/// A styled text field that follows the Quizdy design system.
///
/// Features a filled background, rounded corners (10px radius), a 1.5px border
/// that highlights in [AppTheme.primaryColor] on focus, and 1.65 line-height
/// for the input text.
///
/// Use [QuizdyFieldLabel] to render the matching field label above this widget.
class QuizdyTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final int minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final TextAlign textAlign;
  final String? suffixText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const QuizdyTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.onChanged,
    this.readOnly = false,
    this.inputFormatters,
    this.errorText,
    this.textAlign = TextAlign.start,
    this.onSubmitted,
    this.suffixText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textColor;
    final fieldBg = isDark ? const Color(0xFF1C1C1F) : AppTheme.zinc100;
    final enabledBorderColor = isDark ? AppTheme.zinc700 : AppTheme.zinc200;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      obscureText: obscureText,
      style: TextStyle(fontSize: 14, color: textColor, height: 1.65),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.zinc500, fontSize: 14),
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.all(14),
        errorText: errorText,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: enabledBorderColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: enabledBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        ),
      ),
    );
  }
}

/// A small semibold label rendered above a [QuizdyTextField].
class QuizdyFieldLabel extends StatelessWidget {
  final String label;

  const QuizdyFieldLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.zinc600,
      ),
    );
  }
}
