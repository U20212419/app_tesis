import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/semester_provider.dart';
import '../../utils/size_config.dart';
import '../../widgets/base_form_screen.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_toast.dart';

class CreateSemesterScreen extends StatefulWidget {
  const CreateSemesterScreen({super.key});

  @override
  State<CreateSemesterScreen> createState() => _CreateSemesterScreenState();
}

class _CreateSemesterScreenState extends State<CreateSemesterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  String? _selectedNumber;

  @override
  void initState() {
    super.initState();
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
        await semesterProvider.addSemester(year, number);

        if (mounted) {
          CustomToast.show(
            context: context,
            title: 'Semestre creado',
            detail: 'El semestre $year-$number ha sido creado exitosamente.',
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
            title: 'Error al crear el semestre',
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

    final isLoading = context.watch<SemesterProvider>().isLoading;

    return BaseFormScreen(
        title: 'Semestres - Creación',
        onSave: _saveForm,
        body: _buildForm(),
        isLoading: isLoading,
    );
  }

  Widget _buildForm() {
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
          CustomDropdownField<String>(
            label: 'Número',
            hintText: 'Seleccione un número',
            value: _selectedNumber,
            items: ['0', '1', '2'],
            itemLabel: (number) => number,
            onChanged: (number) {
              setState(() {
                _selectedNumber = number;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, seleccione un número.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
