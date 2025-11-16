import 'dart:developer';

import 'package:app_tesis/providers/assessment_provider.dart';
import 'package:app_tesis/screens/structuration/courses_in_semester/assessments_and_sections/recording/recording_screen.dart';
import 'package:app_tesis/widgets/custom_text_field.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../models/assessment.dart';
import '../../../../models/section.dart';
import '../../../../providers/section_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../utils/size_config.dart';
import '../../../../widgets/action_button.dart';
import '../../../../widgets/app_divider.dart';
import '../../../../widgets/content_switcher.dart';
import '../../../../widgets/custom_dialog.dart';
import '../../../../widgets/custom_toast.dart';
import '../../../../widgets/info_card.dart';
import '../../../../widgets/search_app_bar.dart';
import '../../../../widgets/secondary_bottom_bar.dart';
import 'create_assessment_screen.dart';
import 'create_section_screen.dart';
import 'edit_assessment_screen.dart';
import 'edit_section_screen.dart';

enum ActiveMode { none, edit, delete }

class AssessmentsAndSectionsScreen extends StatefulWidget {
  final int semesterId;
  final int courseId;
  final String semesterAndCourseCodeNames;

  const AssessmentsAndSectionsScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.semesterAndCourseCodeNames,
  });

  @override
  State<AssessmentsAndSectionsScreen> createState() => _AssessmentsAndSectionsScreenState();
}

class _AssessmentsAndSectionsScreenState extends State<AssessmentsAndSectionsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  ActiveMode _activeMode = ActiveMode.none;
  late Color _modeColor;

  late AssessmentProvider _assessmentProvider;
  late SectionProvider _sectionProvider;

  bool _isNavigatingToModeAction = false;
  bool _isInit = true;
  late int _semesterId;
  late int _courseId;
  late String _semesterAndCourseCodeNames;

  int _currentTabIndex = 0; // 0 for Assessments, 1 for Sections
  int? _selectedAssessmentId;
  int? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    _semesterId = widget.semesterId;
    _courseId = widget.courseId;
    _semesterAndCourseCodeNames = widget.semesterAndCourseCodeNames;

    // Fetch assessments and sections when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          _assessmentProvider.fetchAssessments(_semesterId, _courseId);
        } catch (e) {
          final errorMessage = e.toString().replaceFirst("Exception: ", "");
          CustomToast.show(
            context: context,
            title: 'Error al cargar las evaluaciones',
            detail: errorMessage,
            type: CustomToastType.error,
            position: ToastPosition.top,
          );
        }

        try {
          _sectionProvider.fetchSections(_semesterId, _courseId);
        } catch (e) {
          final errorMessage = e.toString().replaceFirst("Exception: ", "");
          CustomToast.show(
            context: context,
            title: 'Error al cargar los horarios',
            detail: errorMessage,
            type: CustomToastType.error,
            position: ToastPosition.top,
          );
        }
      }
    });

    // Initialize search controller listener to filter assessments and sections in real-time
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _modeColor = Theme.of(context).colorScheme.onSurface;
      _assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
      _sectionProvider = Provider.of<SectionProvider>(context, listen: false);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _assessmentProvider.clearAssessmentsList();
    _sectionProvider.clearSectionsList();
    super.dispose();
  }

  void _toggleSearch() {
    if (mounted) {
      setState(() {
        _isSearching = !_isSearching;
        if (_isSearching) {
          _focusNode.requestFocus();
        } else {
          _searchController.clear();
          _searchQuery = '';
          _focusNode.unfocus();
        }
      });
    }
  }

  void _toggleMode(ActiveMode mode, Color buttonColor) {
    if (mounted) {
      setState(() {
        if (mode == ActiveMode.none || _activeMode == mode) {
          _activeMode = ActiveMode.none;
        } else {
          _activeMode = mode;
          _modeColor = buttonColor;
        }
        _selectedAssessmentId = null;
        _selectedSectionId = null;
      });
    }
  }

  void _onAssessmentTap(int assessmentId, bool isSelected) async {
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_activeMode == ActiveMode.edit) {
      log('Mode: $_activeMode - Assessment ID: $assessmentId. Navigating to EditAssessmentScreen.');

      setState(() {
        _isNavigatingToModeAction = true;
      });

      await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => EditAssessmentScreen(
              assessmentId: assessmentId,
            ),
          )
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else if (_activeMode == ActiveMode.delete) {
      log('Mode: $_activeMode - Assessment ID: $assessmentId. Showing DeleteAssessmentModal.');

      // Search for the assessment to delete
      Assessment? assessment;
      try {
        assessment = assessmentProvider.assessments.firstWhere((a) => a.id == assessmentId);
      } catch (e) {
        assessment = null;
      }

      if (!mounted) return;

      // If assessment not found, exit the delete flow
      if (assessment == null) {
        setState(() {
          _isNavigatingToModeAction = false;
          _activeMode = ActiveMode.none;
        });
        return;
      }

      setState(() {
        _isNavigatingToModeAction = true;
      });

      // Show confirmation dialog before deleting
      await showCustomDialog(
        context: context,
        title: "Eliminando Evaluación",
        color: AppColors.supportErrorDark,
        actionButtonText: "Eliminar",
        body: Text(
          "¿Está seguro de eliminar la evaluación ${assessment.type} ${assessment.number}? "
              "Esta acción no puede revertirse.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS().copyWith(
              color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        onActionPressed: (BuildContext dialogContext) async {
          return await _deleteAssessment(
              assessmentProvider,
              assessmentId,
              dialogContext
          );
        },
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else {
      setState(() {
        _selectedAssessmentId = isSelected ? null : assessmentId;
      });
    }
  }

  Future<bool> _deleteAssessment(
      AssessmentProvider provider,
      int assessmentId,
      BuildContext dialogContext
  ) async {
    try {
      await provider.deleteAssessment(assessmentId);

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Evaluación eliminada',
          detail: 'La evaluación ha sido eliminada exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Error al eliminar la evaluación',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }

      return false;
    }
  }

  void _onSectionTap(int sectionId, bool isSelected) async {
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_activeMode == ActiveMode.edit) {
      log('Mode: $_activeMode - Section ID: $sectionId. Navigating to EditSectionScreen.');

      setState(() {
        _isNavigatingToModeAction = true;
      });

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => EditSectionScreen(
            sectionId: sectionId,
          ),
        )
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else if (_activeMode == ActiveMode.delete) {
      log('Mode: $_activeMode - Section ID: $sectionId. Showing DeleteSectionModal.');

      // Search for the section to delete
      Section? section;
      try {
        section = sectionProvider.sections.firstWhere((s) => s.id == sectionId);
      } catch (e) {
        section = null;
      }

      if (!mounted) return;

      // If section not found, exit the delete flow
      if (section == null) {
        setState(() {
          _isNavigatingToModeAction = false;
          _activeMode = ActiveMode.none;
        });
        return;
      }

      setState(() {
        _isNavigatingToModeAction = true;
      });

      // Show confirmation dialog before deleting
      await showCustomDialog(
        context: context,
        title: "Eliminando Horario",
        color: AppColors.supportErrorDark,
        actionButtonText: "Eliminar",
        body: Text(
          "¿Está seguro de eliminar el horario ${section.name}? "
              "Esta acción no puede revertirse.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS().copyWith(
              color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        onActionPressed: (BuildContext dialogContext) async {
          return await _deleteSection(
              sectionProvider,
              sectionId,
              dialogContext
          );
        },
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else {
      setState(() {
        _selectedSectionId = isSelected ? null : sectionId;
      });
    }
  }

  Future<bool> _deleteSection(
      SectionProvider provider,
      int sectionId,
      BuildContext dialogContext
  ) async {
    try {
      await provider.deleteSection(sectionId);

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Horario eliminado',
          detail: 'El horario ha sido eliminado exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Error al eliminar el horario',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }

      return false;
    }
  }

  Map<String, String> _getModeData() {
    switch (_activeMode) {
      case ActiveMode.edit:
        if (_currentTabIndex == 0) {
          return {
            'title': 'Editar Evaluación',
            'subtitle': 'Seleccione una evaluación',
          };
        } else {
          return {
            'title': 'Editar Horario',
            'subtitle': 'Seleccione un horario',
          };
        }
      case ActiveMode.delete:
        if (_currentTabIndex == 0) {
          return {
            'title': 'Eliminar Evaluación',
            'subtitle': 'Seleccione una evaluación',
          };
        } else {
          return {
            'title': 'Eliminar Horario',
            'subtitle': 'Seleccione un horario',
          };
        }
      case ActiveMode.none:
        return {'title': '', 'subtitle': ''};
    }
  }

  Future<bool> _updateQuestionAmount(
      AssessmentProvider provider,
      Assessment selectedAssessment,
      String questionAmount,
      BuildContext dialogContext
  ) async {
    try {
      await provider.updateAssessment(
          selectedAssessment.id,
          selectedAssessment.type,
          selectedAssessment.number.toString(),
          questionAmount
      );

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Cantidad de preguntas actualizada',
          detail: 'La cantidad de preguntas ha sido actualizada exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Error al actualizar la cantidad de preguntas',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }

      return false;
    }
  }

  void _navigateToRecording(int assessmentId, int sectionId, int questionAmount) {
    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => RecordingScreen(
          assessmentId: assessmentId,
          sectionId: sectionId,
          questionAmount: questionAmount,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final modeData = _getModeData();

    final String currentHintText;
    if (_currentTabIndex == 0) {
      currentHintText = 'Buscar evaluación';
    } else {
      currentHintText = 'Buscar horario';
    }

    return VisibilityDetector(
      key: const Key('structuration-screen-visibility-detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (mounted) {
            setState(() {
              if (_isSearching) {
                _toggleSearch();
              }
              if (_activeMode != ActiveMode.none &&
                  !_isNavigatingToModeAction) {
                _toggleMode(ActiveMode.none, Colors.transparent);
              }
              _selectedAssessmentId = null;
              _selectedSectionId = null;
            });
          }
        }
      },
      child: Column(
        children: [
          SearchAppBar(
            title: _semesterAndCourseCodeNames,
            isSearching: _isSearching,
            searchController: _searchController,
            onSearchIconPressed: _toggleSearch,
            onBackIconPressed: () {
              Navigator.pop(context);
            },
            focusNode: _focusNode,
            hintText: currentHintText,
          ),
          AppDivider(
            thickness: SizeConfig.scaleHeight(0.08),
          ),
          Expanded(
            child: ContentSwitcher(
              tabTitles: const ['Evaluaciones', 'Horarios'],
              onTabChanged: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              tabContents: [
                _buildAssessmentList(context, _searchQuery),
                _buildSectionList(context, _searchQuery),
              ],
            ),
          ),
          SecondaryBottomBar(
            isModeActive: _activeMode != ActiveMode.none,
            modeTitle: modeData['title'],
            modeSubtitle: modeData['subtitle'],
            modeTitleColor: _modeColor,
            onCancelMode: () => _toggleMode(ActiveMode.none, Colors.transparent),
            spacingPercentage: 2.1,
            actions: [
              ActionButton(
                icon: Symbols.add_2_rounded,
                label: 'Crear',
                accentColor: AppColors.highlightDarkest,
                onTap: () {
                  if (_currentTabIndex == 0) {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => CreateAssessmentScreen(
                              semesterId: _semesterId,
                              courseId: _courseId
                          ),
                        )
                    );
                  } else {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => CreateSectionScreen(
                              semesterId: _semesterId,
                              courseId: _courseId
                          ),
                        )
                    );
                  }
                },
              ),
              ActionButton(
                icon: Symbols.edit_rounded,
                label: 'Editar',
                accentColor: AppColors.highlightDarkest,
                onTap: () {
                  _toggleMode(ActiveMode.edit, AppColors.highlightDarkest);
                },
              ),
              ActionButton(
                icon: Symbols.photo_camera_rounded,
                label: 'Grabar',
                accentColor: AppColors.supportSuccessDark,
                onTap: () async {
                  final int? currentAssessmentId = _selectedAssessmentId;
                  final int? currentSectionId = _selectedSectionId;

                  if (currentAssessmentId == null && currentSectionId == null) {
                    CustomToast.show(
                      context: context,
                      title: 'Opción no disponible',
                      detail: 'Debe seleccionar una evaluación y un horario.',
                      type: CustomToastType.warning,
                      position: ToastPosition.top,
                    );
                  } else if (currentAssessmentId == null) {
                    CustomToast.show(
                      context: context,
                      title: 'Opción no disponible',
                      detail: 'Debe seleccionar una evaluación.',
                      type: CustomToastType.warning,
                      position: ToastPosition.top,
                    );
                  } else if (currentSectionId == null) {
                    CustomToast.show(
                      context: context,
                      title: 'Opción no disponible',
                      detail: 'Debe seleccionar un horario.',
                      type: CustomToastType.warning,
                      position: ToastPosition.top,
                    );
                  } else {
                    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
                    final selectedAssessment = assessmentProvider.assessments.firstWhere(
                      (a) => a.id == currentAssessmentId,
                    );

                    int? finalQuestionAmount;
                    if (selectedAssessment.questionAmount != null) {
                      finalQuestionAmount = selectedAssessment.questionAmount;
                    } else {
                      final formKey = GlobalKey<FormState>();
                      final questionAmountController = TextEditingController();
                      questionAmountController.text = '';

                      final bool? didSave = await showCustomDialog<bool>(
                        context: context,
                        title: 'Cantidad de Preguntas',
                        color: AppColors.highlightDarkest,
                        actionButtonText: "Confirmar",
                        body: StatefulBuilder(
                          builder: (context, setState) {
                            final theme = Theme.of(context);

                            return Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                children: [
                                  SizedBox(height: SizeConfig.scaleHeight(1.25)),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: theme.colorScheme.primary,
                                      highlightColor: theme.colorScheme.primary,
                                    ),
                                    child: CustomTextField(
                                      controller: questionAmountController,
                                      hintText: 'Ingrese la cantidad de preguntas',
                                      hintStyle: AppTextStyles.bodyXS().copyWith(
                                        color: theme.inputDecorationTheme.hintStyle?.color ?? AppColors.neutralDarkLightest,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(2),
                                      ],
                                      validator: (value) {
                                        final trimmedValue = value?.trim() ?? '';
                                        if (trimmedValue.isEmpty) {
                                          return 'Por favor, ingrese una cantidad de preguntas.';
                                        }

                                        final intValue = int.tryParse(trimmedValue);

                                        if (intValue == null) {
                                          return 'Por favor, ingrese un número válido.';
                                        }
                                        if (intValue <= 0) {
                                          return 'La cantidad de preguntas debe ser mayor que cero.';
                                        }
                                        if (trimmedValue.length > 2) {
                                          return 'La cantidad de preguntas no debe exceder los 2 dígitos.';
                                        }
                                        return null;
                                      },
                                    )
                                  )
                                ],
                              ),
                            );
                          }
                        ),
                        onActionPressed: (BuildContext dialogContext) async {
                          if (formKey.currentState!.validate()) {
                            return await _updateQuestionAmount(
                              assessmentProvider,
                              selectedAssessment,
                              questionAmountController.text,
                              dialogContext
                            );
                          }
                          return false;
                        },
                      );

                      if (didSave == true) {
                        finalQuestionAmount = int.parse(questionAmountController.text.trim());
                      }
                    }

                    if (finalQuestionAmount != null) {
                      if (mounted) {
                        log('Navigating to RecordingScreen with Assessment ID: $currentAssessmentId and Section ID: $currentSectionId.');
                        _navigateToRecording(currentAssessmentId, currentSectionId, finalQuestionAmount);
                      }
                    }
                  }
                },
              ),
              ActionButton(
                icon: Symbols.delete_forever_rounded,
                label: 'Eliminar',
                accentColor: AppColors.supportErrorDark,
                onTap: () {
                  _toggleMode(ActiveMode.delete, AppColors.supportErrorDark);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentList(BuildContext context, String searchQuery) {
    return Consumer<AssessmentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                color: AppColors.highlightDarkest,
              )
          );
        }

        String normalizeString(String input) {
          String normalized = input.trim();
          normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
          normalized = removeDiacritics(normalized).toLowerCase();

          return normalized;
        }

        final allAssessments = provider.assessments;
        final filteredAssessments = searchQuery.isEmpty
            ? allAssessments
            : allAssessments.where((assessment) {
          final normalizedQuery = normalizeString(searchQuery);
          final normalizedType = normalizeString(assessment.type);
          final normalizedNumber = assessment.number.toString();
          final combined = normalizeString('$normalizedType $normalizedNumber');

          return normalizedType.contains(normalizedQuery) ||
              normalizedNumber.contains(normalizedQuery) ||
              combined.contains(normalizedQuery);
        }).toList();

        if (filteredAssessments.isEmpty) {
          return Center(
            child: Text(
              allAssessments.isEmpty ? 'No hay evaluaciones disponibles.'
                  : 'No se encontraron resultados.',
              style: AppTextStyles.bodyM().copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.scaleWidth(8.3),
            vertical: SizeConfig.scaleHeight(2.3),
          ),
          itemCount: filteredAssessments.length,
          itemBuilder: (context, index) {
            final assessment = filteredAssessments[index];
            final isSelected = assessment.id == _selectedAssessmentId;

            IconData trailingIcon;
            double? trailingIconSize;

            if (_activeMode == ActiveMode.edit ||
                _activeMode == ActiveMode.delete) {
              trailingIcon = Symbols.arrow_forward_ios_rounded;
            } else {
              trailingIcon = isSelected
                  ? Symbols.radio_button_checked_rounded
                  : Symbols.radio_button_unchecked_rounded;
              trailingIconSize = 3;
            }

            return InfoCard(
              title: '${assessment.type} ${assessment.number}',
              onTap: () => _onAssessmentTap(assessment.id, isSelected),
              trailingIcon: trailingIcon,
              trailingIconSize: trailingIconSize,
            );
          },
          separatorBuilder: (context,
              index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
        );
      },
    );
  }

  Widget _buildSectionList(BuildContext context, String searchQuery) {
    return Consumer<SectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(
                color: AppColors.highlightDarkest,
              )
          );
        }

        String normalizeString(String input) {
          String normalized = input.trim();
          normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
          normalized = removeDiacritics(normalized).toLowerCase();

          return normalized;
        }

        final allSections = provider.sections;
        final filteredSections = searchQuery.isEmpty
            ? allSections
            : allSections.where((section) {
          final normalizedQuery = normalizeString(searchQuery);
          final normalizedName = normalizeString(section.name);

          return normalizedName.contains(normalizedQuery);
        }).toList();

        if (filteredSections.isEmpty) {
          return Center(
              child: Text(
                allSections.isEmpty ? 'No hay horarios disponibles.'
                    : 'No se encontraron resultados.',
                style: AppTextStyles.bodyM().copyWith(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              )
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.scaleWidth(8.3),
            vertical: SizeConfig.scaleHeight(2.3),
          ),
          itemCount: filteredSections.length,
          itemBuilder: (context, index) {
            final section = filteredSections[index];
            final isSelected = section.id == _selectedSectionId;

            IconData trailingIcon;
            double? trailingIconSize;

            if (_activeMode == ActiveMode.edit ||
                _activeMode == ActiveMode.delete) {
              trailingIcon = Symbols.arrow_forward_ios_rounded;
            } else {
              trailingIcon = isSelected
                  ? Symbols.radio_button_checked_rounded
                  : Symbols.radio_button_unchecked_rounded;
              trailingIconSize = 3;
            }

            return InfoCard(
              title: section.name,
              onTap: () => _onSectionTap(section.id, isSelected),
              trailingIcon: trailingIcon,
              trailingIconSize: trailingIconSize,
            );
          },
          separatorBuilder: (context,
              index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
        );
      },
    );
  }
}
