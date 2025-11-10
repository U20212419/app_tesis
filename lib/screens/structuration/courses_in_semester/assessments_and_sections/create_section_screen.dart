import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/section_provider.dart';
import '../../../../utils/size_config.dart';
import '../../../../widgets/base_form_screen.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_toast.dart';

class CreateSectionScreen extends StatefulWidget {
  final int semesterId;
  final int courseId;

  const CreateSectionScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
  });

  @override
  State<CreateSectionScreen> createState() => _CreateSectionScreenState();
}

class _CreateSectionScreenState extends State<CreateSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      // Process the form data
      final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

      try {
        await sectionProvider.addSection(
            name,
            widget.semesterId,
            widget.courseId,
            courseInSemesterProvider
        );

        if (mounted) {
          CustomToast.show(
            context: context,
            title: 'Horario creado',
            detail: 'El horario $name ha sido creado exitosamente.',
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
            title: 'Error al crear el horario',
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
        title: 'Horarios - Creación',
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
          // Name
          CustomTextField(
            controller: _nameController,
            label: 'Nombre',
            hintText: 'Ingrese el nombre del horario',
            validator: (value) {
              final trimmedValue = value?.trim() ?? '';
              if (trimmedValue.isEmpty) {
                return 'Por favor, ingrese un nombre.';
              }
              if (trimmedValue.length > 20) {
                return 'El nombre no debe exceder los 20 caracteres.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
