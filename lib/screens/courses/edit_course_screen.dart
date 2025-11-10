import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../utils/size_config.dart';
import '../../widgets/base_form_screen.dart';
import '../../widgets/custom_text_field.dart';

class EditCourseScreen extends StatefulWidget {
  final int courseId;

  const EditCourseScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  String _currentCode = '';
  String _currentName = '';

  bool _isInit = true;
  late int _courseId;

  @override
  void initState() {
    super.initState();
    _courseId = widget.courseId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // Search for the course to edit
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);

      Course? course;
      try {
        course = courseProvider.courses.firstWhere((c) => c.id == _courseId);
      } catch (e) {
        course = null;
      }

      if (course != null) {
        _codeController.text = _currentCode = course.code;
        _nameController.text = _currentName = course.name;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomToast.show(
            context: context,
            title: 'Error',
            detail: 'No se pudo encontrar el curso para editar.',
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

      final currentCode = _currentCode.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      final currentName = _currentName.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

      final bool hasChanges =
          code != currentCode ||
          name != currentName;

      if (hasChanges) {
        try {
          await courseProvider.updateCourse(
            _courseId,
            code,
            name,
          );

          if (mounted) {
            CustomToast.show(
              context: context,
              title: 'Curso editado',
              detail: 'El curso ha sido editado exitosamente.',
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
              title: 'Error al editar el curso',
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

    return BaseCreationScreen(
        title: 'Cursos - Edición',
        onSave: _saveForm,
        body: _buildForm()
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
