import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/semester.dart';
import '../../providers/semester_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/custom_text_field_theme.dart';
import '../../utils/size_config.dart';
import '../../widgets/base_form_screen.dart';
import '../../widgets/custom_text_field.dart';

class EditSemesterScreen extends StatefulWidget {
  final int semesterId;

  const EditSemesterScreen({
    super.key,
    required this.semesterId,
  });

  @override
  State<EditSemesterScreen> createState() => _EditSemesterScreenState();
}

class _EditSemesterScreenState extends State<EditSemesterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  String? _selectedNumber;

  bool _isInit = true;
  late int _semesterId;

  @override
  void initState() {
    super.initState();
    _semesterId = widget.semesterId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Search for the semester to edit
      final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);

      Semester? semester;
      try {
        semester = semesterProvider.semesters.firstWhere((c) => c.id == _semesterId);
      } catch (e) {
        semester = null;
      }

      if (semester != null) {
        _yearController.text = semester.year.toString();
        _selectedNumber = semester.number.toString();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomToast.show(
            context: context,
            title: 'Error',
            detail: 'No se pudo encontrar el semestre para editar.',
            type: CustomToastType.error,
          );
          Navigator.of(context).pop();
        });
      }
      _isInit = false; // Ensures this block runs only once
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      // Process the form data
      final year = _yearController.text.trim();
      final number = _selectedNumber!;

      try {
        await semesterProvider.updateSemester(
          _semesterId,
          year,
          number,
        );

        if (mounted) {
          CustomToast.show(
            context: context,
            title: 'Semestre editado',
            detail: 'El semestre ha sido editado exitosamente.',
            type: CustomToastType.success,
            position: ToastPosition.top,
          );

          navigator.pop(); // Go back after saving
        }
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString().replaceFirst("Exception: ", "");
          CustomToast.show(
            context: context,
            title: 'Error al editar el semestre',
            detail: errorMessage,
            type: CustomToastType.error,
            position: ToastPosition.top,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return BaseCreationScreen(
        title: 'Semestres - Edición',
        onSave: _saveForm,
        body: _buildForm()
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final CustomTextFieldTheme? customTextFieldTheme = theme.extension<CustomTextFieldTheme>();

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.scaleWidth(8.9),
          vertical: SizeConfig.scaleHeight(2.3),
        ),
        children: [
          // Year
          CustomTextField(
            controller: _yearController,
            label: 'Año',
            hintText: 'Ingrese el año del semestre',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';
              if (trimmedValue.isEmpty) {
                return 'Por favor, ingrese un año.';
              }
              if (trimmedValue.length != 4) {
                return 'El año debe tener 4 dígitos.';
              }
              return null;
            }
          ),
          SizedBox(height: SizeConfig.scaleHeight(2.3)),
          // Number (0, 1, 2)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Número',
                style: customTextFieldTheme?.fieldNameStyle ?? AppTextStyles.heading5().copyWith(
                  color: AppColors.neutralDarkDark,
                ),
              ),
              SizedBox(height: SizeConfig.scaleHeight(1.25)),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: theme.colorScheme.primary,
                  highlightColor: theme.colorScheme.primary,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedNumber,
                  hint: Text(
                    'Seleccione el número de semestre',
                    style: AppTextStyles.bodyXS().copyWith(
                      color: theme.inputDecorationTheme.hintStyle?.color ?? AppColors.neutralDarkLightest,
                    ),
                  ),
                  icon: Icon(
                    Symbols.expand_more_rounded,
                    size: SizeConfig.scaleHeight(3.1),
                    color: theme.inputDecorationTheme.hintStyle?.color ?? AppColors.neutralDarkLightest,
                  ),
                  dropdownColor: theme.colorScheme.surface,
                  elevation: 2,
                  isExpanded: true,
                  decoration: const InputDecoration(
                  ),
                  items: ['0', '1', '2'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNumber = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione un número.';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: customTextFieldTheme?.inputTextStyle ?? AppTextStyles.bodyM().copyWith(
                    color: AppColors.neutralDarkDarkest,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
