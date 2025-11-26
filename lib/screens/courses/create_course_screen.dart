import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../utils/size_config.dart';
import '../../widgets/base_form_screen.dart';
import '../../widgets/custom_text_field.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      // Process the form data
      final code = _codeController.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

      try {
        await courseProvider.addCourse(code, name);

        if (mounted) {
          CustomToast.show(
            context: context,
            title: 'Curso creado',
            detail: 'El curso $name ha sido creado exitosamente.',
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
            title: 'Error al crear el curso',
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

    final isLoading = context.watch<CourseProvider>().isLoading;

    return BaseFormScreen(
        title: 'Cursos - Creación',
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
          // Code
          CustomTextField(
            controller: _codeController,
            label: 'Código',
            hintText: 'Ingrese el código del curso',
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';
              if (trimmedValue.isEmpty) {
                return 'Por favor, ingrese un código.';
              }
              if (trimmedValue.length != 6) {
                return 'El código debe tener 6 caracteres.';
              }
              return null;
            }
          ),
          SizedBox(height: SizeConfig.scaleHeight(2.3)),
          // Name
          CustomTextField(
            controller: _nameController,
            label: 'Nombre',
            hintText: 'Ingrese el nombre del curso',
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';
              if (trimmedValue.isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (trimmedValue.length > 100) {
                return 'El nombre no debe exceder los 100 caracteres.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
