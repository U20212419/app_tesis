import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/semester.dart';
import '../../providers/semester_provider.dart';
import '../../utils/size_config.dart';
import '../../widgets/base_form_screen.dart';
import '../../widgets/custom_dropdown_field.dart';
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

  String _currentYear = '';
  String _currentNumber = '';

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
        _yearController.text = _currentYear = semester.year.toString();
        _selectedNumber = _currentNumber = semester.number.toString();
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

      final currentYear = _currentYear.trim();
      final currentNumber = _currentNumber;

      final bool hasChanges =
          year != currentYear ||
          number != currentNumber;

      if (hasChanges) {
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
      } else {
        // No changes made
        CustomToast.show(
          context: context,
          title: 'Sin cambios',
          detail: 'No se ha modificado ningún campo.',
          type: CustomToastType.warning,
          position: ToastPosition.top,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final isLoading = context.watch<SemesterProvider>().isLoading;

    return BaseFormScreen(
        title: 'Semestres - Edición',
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
