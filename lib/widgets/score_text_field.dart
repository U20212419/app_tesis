import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_text_styles.dart';

class ScoreTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;
  final ValueChanged<String>? onChanged;

  const ScoreTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPlaceHolder = controller.text == '---';

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.heading5().copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            readOnly: isReadOnly || isPlaceHolder,
            enabled: !isReadOnly && !isPlaceHolder,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              // Allow only numbers with up to two decimal places
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTextStyles.bodyM().copyWith(
              color: isPlaceHolder
                  ? theme.colorScheme.surface
                  : theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: (isReadOnly || isPlaceHolder)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              border: theme.inputDecorationTheme.border,
              enabledBorder: theme.inputDecorationTheme.enabledBorder,
              focusedBorder: theme.inputDecorationTheme.focusedBorder,
              errorBorder: theme.inputDecorationTheme.errorBorder,
              focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
              contentPadding: theme.inputDecorationTheme.contentPadding,
            ),
            onChanged: onChanged,
            validator: (value) {
              if (!isPlaceHolder && !isReadOnly) {
                final trimmedValue = value?.trim() ?? '';
                if (trimmedValue.isEmpty) {
                  return 'Por favor, ingrese un puntaje.';
                }

                final doubleValue = double.tryParse(trimmedValue);

                if (doubleValue == null) {
                  return 'Por favor, ingrese un número válido';
                }
                if (doubleValue < 0 || doubleValue > 20) {
                  return 'La puntuación debe estar entre 0 y 20';
                }
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      ],
    );
  }
}
