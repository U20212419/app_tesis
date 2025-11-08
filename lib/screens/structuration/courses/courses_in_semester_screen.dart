import 'dart:developer';

import 'package:app_tesis/providers/course_provider.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../models/course.dart';
import '../../../providers/course_in_semester_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/custom_text_field_theme.dart';
import '../../../utils/size_config.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/app_divider.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/search_app_bar.dart';
import '../../../widgets/secondary_bottom_bar.dart';

enum ActiveMode { none, remove }

class CoursesInSemesterScreen extends StatefulWidget {
  final int semesterId;
  final String semesterName;

  const CoursesInSemesterScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  State<CoursesInSemesterScreen> createState() => _CoursesInSemesterScreenState();
}

class _CoursesInSemesterScreenState extends State<CoursesInSemesterScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  ActiveMode _activeMode = ActiveMode.none;
  late Color _modeColor;

  late CourseInSemesterProvider _courseInSemesterProvider;

  bool _isNavigatingToModeAction = false;
  bool _isInit = true;
  late int _semesterId;
  late String _semesterName;

  @override
  void initState() {
    super.initState();
    _semesterId = widget.semesterId;
    _semesterName = widget.semesterName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Fetch courses in the semester when the widget is first built
        _courseInSemesterProvider.fetchCoursesInSemester(_semesterId);

        // Fetch all courses
        Provider.of<CourseProvider>(context, listen: false)
            .fetchCourses();
      }
    });

    // Initialize search controller listener to filter courses in real-time
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
      _courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _courseInSemesterProvider.clearCoursesInSemesterList();
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
      });
    }
  }

  void _onCourseTap(int courseId) async {
    final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_activeMode == ActiveMode.remove) {
      log('Mode: $_activeMode - Course ID: $courseId. Showing RemoveCourseModal.');

      // Search for the course to remove
      Course? course;
      try {
        course = courseProvider.courses.firstWhere((c) => c.id == courseId);
      } catch (e) {
        course = null;
      }

      if (!mounted) return;

      // If course not found, exit the remove flow
      if (course == null) {
        setState(() {
          _isNavigatingToModeAction = false;
          _activeMode = ActiveMode.none;
        });
        return;
      }

      setState(() {
        _isNavigatingToModeAction = true;
      });

      // Show confirmation dialog before removing
      await showCustomDialog(
        context: context,
        title: "Quitando Curso",
        color: AppColors.supportWarningDark,
        actionButtonText: "Quitar",
        body: Text(
          "¿Está seguro de quitar el curso ${course.code} del semestre? "
          "Puede volver a añadirlo luego, pero se perderán las evaluaciones "
          "y horarios configurados previamente.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS().copyWith(
              color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        onActionPressed: () {
          _removeCourse(courseInSemesterProvider, courseId);
        },
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    }
  }

  void _removeCourse(CourseInSemesterProvider provider, int courseId) async {
    try {
      await provider.removeCourseFromSemester(_semesterId, courseId);

      if (mounted) {
        CustomToast.show(
          context: context,
          title: 'Curso quitado',
          detail: 'El curso ha sido quitado del semestre exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context: context,
          title: 'Error al quitar el curso',
          detail: e.toString().trim(),
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }
    }
  }

  void _addCourse(CourseInSemesterProvider provider, int? courseId) {
    if (courseId == null) return;

    provider.addCourseToSemester(_semesterId, courseId);
  }

  Map<String, String> _getModeData() {
    switch (_activeMode) {
      case ActiveMode.remove:
        return {
          'title': 'Quitar Curso',
          'subtitle': 'Seleccione un curso',
        };
      case ActiveMode.none:
      return {'title': '', 'subtitle': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final modeData = _getModeData();
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    return VisibilityDetector(
      key: const Key('structuration-screen-visibility-detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (_isSearching) {
            _toggleSearch();
          }
          if (_activeMode != ActiveMode.none && !_isNavigatingToModeAction) {
            _toggleMode(ActiveMode.none, Colors.transparent);
          }
        }
      },
      child: Consumer<CourseInSemesterProvider>(
        builder: (context, courseInSemesterProvider, child) {
          return Column(
            children: [
              SearchAppBar(
                title: _semesterName,
                isSearching: _isSearching,
                searchController: _searchController,
                onSearchIconPressed: _toggleSearch,
                onBackIconPressed: () {
                  Navigator.pop(context);
                },
                focusNode: _focusNode,
                hintText: 'Buscar curso',
              ),
              AppDivider(
                thickness: SizeConfig.scaleHeight(0.08),
              ),
              Expanded(
                child: _buildCourseList(context, courseInSemesterProvider, _searchQuery),
              ),
              SecondaryBottomBar(
                isModeActive: _activeMode != ActiveMode.none,
                modeTitle: modeData['title'],
                modeSubtitle: modeData['subtitle'],
                modeTitleColor: _modeColor,
                onCancelMode: () => _toggleMode(ActiveMode.none, Colors.transparent),
                actions: [
                  ActionButton(
                    icon: Symbols.add_2_rounded,
                    label: 'Añadir',
                    accentColor: AppColors.highlightDarkest,
                    onTap: () {
                      final coursesAlreadyInSemester = Set<int>.from(
                        courseInSemesterProvider.courseInSemester
                            .map((cis) => cis.course.id)
                      );

                      final availableCourses = courseProvider.courses
                          .where((course) =>
                              !coursesAlreadyInSemester.contains(course.id))
                          .toList();

                      if (availableCourses.isEmpty) {
                        CustomToast.show(
                          context: context,
                          title: 'No hay cursos disponibles',
                          detail: 'No hay más cursos para añadir a este semestre. Intente crear un nuevo curso.',
                          type: CustomToastType.warning,
                          position: ToastPosition.top,
                        );
                        return;
                      }

                      final formKey = GlobalKey<FormState>();
                      int? selectedCourseId;

                      // Show dialog to select and add a course
                      showCustomDialog(
                        context: context,
                        title: 'Añadir Curso',
                        color: AppColors.highlightDarkest,
                        actionButtonText: "Añadir",
                        body: StatefulBuilder(
                          builder: (context, setState) {
                            final theme = Theme.of(context);
                            final CustomTextFieldTheme? customTextFieldTheme =
                              theme.extension<CustomTextFieldTheme>();

                            return Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: SizeConfig.scaleHeight(1.25)),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: theme.colorScheme.primary,
                                      highlightColor: theme.colorScheme.primary,
                                    ),
                                    child: DropdownButtonFormField<int>(
                                      initialValue: selectedCourseId,
                                      hint: Text(
                                        'Seleccione un curso',
                                        style: AppTextStyles.bodyXS().copyWith(
                                          color: theme.inputDecorationTheme.hintStyle?.color ??
                                              AppColors.neutralDarkLightest,
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
                                      ),
                                      items: availableCourses.map((Course course) {
                                        return DropdownMenuItem<int>(
                                          value: course.id,
                                          child: Text('${course.code} - ${course.name}'),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          selectedCourseId = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Por favor, seleccione un curso.';
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
                            );
                          },
                        ),
                        onActionPressed: () {
                          if (formKey.currentState!.validate()) {
                            _addCourse(courseInSemesterProvider,
                                selectedCourseId);
                          }
                        }
                      );
                    }
                  ),
                  ActionButton(
                    icon: Symbols.playlist_remove_rounded,
                    label: 'Quitar',
                    accentColor: AppColors.supportWarningDark,
                    onTap: () {
                      _toggleMode(ActiveMode.remove, AppColors.supportWarningDark);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, CourseInSemesterProvider provider, String searchQuery) {
    if (provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(
            color: AppColors.highlightDarkest,
          )
      );
    }
    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    String normalizeString(String input) {
      String normalized = input.replaceAll('-', ' ');
      normalized = normalized.trim();
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
      normalized = removeDiacritics(normalized).toLowerCase();

      return normalized;
    }

    final allCoursesInSemester = provider.courseInSemester;
    final filteredCoursesInSemester = searchQuery.isEmpty
        ? allCoursesInSemester
        : allCoursesInSemester.where((courseInSemester) {
      final normalizedQuery = normalizeString(searchQuery);
      final normalizedName = normalizeString(courseInSemester.course.name);
      final normalizedCode = normalizeString(courseInSemester.course.code);
      final combined = normalizeString('${courseInSemester.course.code} ${courseInSemester.course.name}');

      return normalizedName.contains(normalizedQuery) ||
          normalizedCode.contains(normalizedQuery) ||
          combined.contains(normalizedQuery);
    }).toList();
    filteredCoursesInSemester.sort((a, b) => a.course.name.compareTo(b.course.name));

    if (filteredCoursesInSemester.isEmpty) {
      return Center(
        child: Text(
          allCoursesInSemester.isEmpty ? 'No hay cursos disponibles.'
              : 'No se encontraron resultados.',
          style: AppTextStyles.bodyM().copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.scaleWidth(8.3),
        vertical: SizeConfig.scaleHeight(2.3),
      ),
      itemCount: filteredCoursesInSemester.length,
      itemBuilder: (context, index) {
        final courseInSemester = filteredCoursesInSemester[index];
        final assessmentCount = courseInSemester.assessmentCount ?? 0;
        final sectionCount = courseInSemester.sectionCount ?? 0;

        final String assessmentsSubtitle = assessmentCount == 0
            ? 'Sin evaluaciones'
            : '$assessmentCount ${assessmentCount == 1 ? 'evaluación' : 'evaluaciones'}';
        final String sectionsSubtitle = sectionCount == 0
            ? 'Sin horarios'
            : '$sectionCount ${sectionCount == 1 ? 'horario' : 'horarios'}';

        return InfoCard(
          title: '${courseInSemester.course.code} - ${courseInSemester.course.name}',
          subtitle: '$assessmentsSubtitle | $sectionsSubtitle',
          onTap: () => _onCourseTap(
              courseInSemester.course.id
          ),
          trailingIcon: Symbols.arrow_forward_ios_rounded,
        );
      },
      separatorBuilder: (context,
          index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
    );
  }
}
