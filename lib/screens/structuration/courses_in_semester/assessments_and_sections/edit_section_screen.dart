import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/section.dart';
import '../../../../providers/section_provider.dart';
import '../../../../utils/size_config.dart';
import '../../../../widgets/base_form_screen.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/custom_toast.dart';

class EditSectionScreen extends StatefulWidget {
  final int sectionId;

  const EditSectionScreen({
    super.key,
    required this.sectionId,
  });

  @override
  State<EditSectionScreen> createState() => _EditSectionScreenState();
}

class _EditSectionScreenState extends State<EditSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _currentName = '';

  bool _isInit = true;
  late int _sectionId;

  @override
  void initState() {
    super.initState();
    _sectionId = widget.sectionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final sectionProvider = Provider.of<SectionProvider>(context, listen: false);

      Section? section;
      try {
        section = sectionProvider.sections.firstWhere((sec) => sec.id == _sectionId);
      } catch (e) {
        section = null;
      }

      if (section != null) {
        _nameController.text = _currentName = section.name;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomToast.show(
            context: context,
            title: 'Error',
            detail: 'No se pudo encontrar el horario para editar.',
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
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    if (_formKey.currentState!.validate()) {
      // Process the form data
      final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

      final currentName = _currentName.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

      final bool hasChanges = name != currentName;

      if (hasChanges) {
        try {
          await sectionProvider.updateSection(
            _sectionId,
            name,
          );

          if (mounted) {
            CustomToast.show(
              context: context,
              title: 'Horario editado',
              detail: 'El horario ha sido editado exitosamente.',
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
              title: 'Error al editar el horario',
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

    final isLoading = context.watch<SectionProvider>().isLoading;

    return BaseFormScreen(
        title: 'Horarios - Edición',
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
