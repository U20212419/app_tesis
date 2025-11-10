import 'package:app_tesis/providers/assessment_provider.dart';
import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/custom_text_field_theme.dart';
import '../../../../utils/size_config.dart';
import '../../../../widgets/base_form_screen.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_toast.dart';

class CreateAssessmentScreen extends StatefulWidget {
  final int semesterId;
  final int courseId;

  const CreateAssessmentScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
  });

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _questionAmountController = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _questionAmountController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      // Process the form data
      final number = _numberController.text.trim();
      final String questionAmountText = _questionAmountController.text.trim();
      final String? questionAmount = questionAmountText.isEmpty ? null : questionAmountText;
      final type = _selectedType!;

      try {
        await assessmentProvider.addAssessment(
            type,
            number,
            questionAmount,
            widget.semesterId,
            widget.courseId,
            courseInSemesterProvider
        );

        if (mounted) {
          CustomToast.show(
            context: context,
            title: 'Evaluación creada',
            detail: 'La evaluación $type $number ha sido creada exitosamente.',
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
            title: 'Error al crear la evaluación',
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
        title: 'Evaluaciones - Creación',
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
          // Type
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo',
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
                  initialValue: _selectedType,
                  hint: Text(
                    'Seleccione el tipo de evaluación',
                    style: AppTextStyles.bodyXS().copyWith(
                      color: theme.inputDecorationTheme.hintStyle?.color ?? AppColors.neutralDarkLightest,
                    ),
                  ),
                  icon: Icon(
                    Symbols.expand_more_rounded,
                    size: SizeConfig.scaleHeight(3.1),
                    color: theme.inputDecorationTheme.hintStyle?.color ??
                        AppColors.neutralDarkLightest,
                  ),
                  dropdownColor: theme.colorScheme.surface,
                  elevation: 2,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    errorMaxLines: 2,
                  ),
                  items: [
                    'Examen',
                    'Práctica Dirigida',
                    'Práctica Tipo A',
                    'Práctica Tipo B',
                    'Tarea Académica'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, seleccione un tipo de evaluación.';
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
          SizedBox(height: SizeConfig.scaleHeight(2.3)),
          // Number
          CustomTextField(
            controller: _numberController,
            label: 'Número',
            hintText: 'Ingrese el número de evaluación',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';
              if (trimmedValue.isEmpty) {
                return 'Por favor, ingrese un número.';
              }
              if (trimmedValue.length > 2) {
                return 'El número no debe exceder los 2 dígitos.';
              }
              return null;
            }
          ),
          SizedBox(height: SizeConfig.scaleHeight(2.3)),
          // Question amount
          CustomTextField(
              controller: _questionAmountController,
              label: 'Cantidad de preguntas',
              isOptional: true,
              hintText: 'Ingrese la cantidad de preguntas',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              validator: (value) {
                final trimmedValue = value?.trim() ?? '';
                if (trimmedValue.length > 2) {
                  return 'La cantidad de preguntas no debe exceder los 2 dígitos.';
                }
                return null;
              }
          ),
        ],
      ),
    );
  }
}
