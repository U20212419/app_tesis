import 'dart:developer';

import 'package:app_tesis/theme/app_text_styles.dart';
import 'package:app_tesis/widgets/action_button.dart';
import 'package:app_tesis/widgets/secondary_bottom_bar.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/course.dart';
import '../../providers/course_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/info_card.dart';
import '../../widgets/search_app_bar.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';

enum ActiveMode { none, edit, delete }

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  ActiveMode _activeMode = ActiveMode.none;
  late Color _modeColor;

  bool _isNavigatingToModeAction = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();

    // Fetch courses when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider
            .of<CourseProvider>(context, listen: false)
            .fetchCoursesDetailed();
      } catch (e) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: context,
          title: 'Error al cargar los cursos',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
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
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_activeMode == ActiveMode.edit) {
      log('Mode: $_activeMode - Course ID: $courseId. Navigating to EditCourseScreen.');

      setState(() {
        _isNavigatingToModeAction = true;
      });

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => EditCourseScreen(
            courseId: courseId,
          ),
        ),
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else if (_activeMode == ActiveMode.delete) {
      log('Mode: $_activeMode - Course ID: $courseId. Showing DeleteCourseModal.');

      // Search for the course to delete
      Course? course;
      try {
        course = courseProvider.courses.firstWhere((c) => c.id == courseId);
      } catch (e) {
        course = null;
      }

      if (!mounted) return;

      // If course not found, exit the delete flow
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

      // Show confirmation dialog before deleting
      await showCustomDialog(
        context: context,
        title: "Eliminando Curso",
        color: AppColors.supportErrorDark,
        actionButtonText: "Eliminar",
        body: Text(
          "¿Está seguro de eliminar el curso ${course.code}? "
          "Esta acción no puede revertirse.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS().copyWith(
              color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        onActionPressed: (BuildContext dialogContext) async {
          return await _deleteCourse(
              courseProvider,
              courseId,
              dialogContext
          );
        },
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    }
  }

  Future<bool> _deleteCourse(
      CourseProvider provider,
      int courseId,
      BuildContext dialogContext
  ) async {
    try {
      await provider.deleteCourse(courseId);

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Curso eliminado',
          detail: 'El curso ha sido eliminado exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      if (mounted && dialogContext.mounted) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: dialogContext,
          title: 'Error al eliminar el curso',
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
        return {
          'title': 'Editar Curso',
          'subtitle': 'Seleccione un curso',
        };
      case ActiveMode.delete:
        return {
          'title': 'Eliminar Curso',
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

    return VisibilityDetector(
      key: const Key('courses-screen-visibility-detector'),
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
      child: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: SearchAppBar(
              title: 'Lista de Cursos',
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchIconPressed: _toggleSearch,
              focusNode: _focusNode,
              hintText: 'Buscar curso',
            ),
            body: Column(
              children: [
                AppDivider(
                  thickness: SizeConfig.scaleHeight(0.08),
                ),
                Expanded(
                  child: _buildCourseList(context, courseProvider, _searchQuery),
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
                      label: 'Crear',
                      accentColor: AppColors.highlightDarkest,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateCourseScreen(),
                          )
                        );
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
                      icon: Symbols.delete_forever_rounded,
                      label: 'Eliminar',
                      accentColor: AppColors.supportErrorDark,
                      onTap: () {
                        _toggleMode(ActiveMode.delete, AppColors.supportErrorDark);
                      },
                    ),
                  ],
                ),
              ]
            ),
          );
        }
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, CourseProvider provider, String searchQuery) {
    if (provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(
            color: AppColors.highlightDarkest,
          )
      );
    }

    String normalizeString(String input) {
      String normalized = input.replaceAll('-', ' ');
      normalized = normalized.trim();
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');
      normalized = removeDiacritics(normalized).toLowerCase();

      return normalized;
    }

    final allCourses = provider.courses;
    final filteredCourses = searchQuery.isEmpty
        ? allCourses
        : allCourses.where((course) {
      final normalizedQuery = normalizeString(searchQuery);
      final normalizedName = normalizeString(course.name);
      final normalizedCode = normalizeString(course.code);
      final combined = normalizeString('${course.code} ${course.name}');

      return normalizedName.contains(normalizedQuery) ||
          normalizedCode.contains(normalizedQuery) ||
          combined.contains(normalizedQuery);
    }).toList();
    filteredCourses.sort((a, b) => a.name.compareTo(b.name));

    if (filteredCourses.isEmpty) {
      return Center(
        child: Text(
          allCourses.isEmpty ? 'No hay cursos disponibles.'
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
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        final count = course.semesterCount ?? 0;

        IconData? trailingIcon;

        if (_activeMode != ActiveMode.none) {
          trailingIcon = Symbols.arrow_forward_ios_rounded;
        }

        return InfoCard(
          title: '${course.code} - ${course.name}',
          subtitle: count == 0
              ? 'En ningún semestre'
              : 'En $count ${count == 1 ? 'semestre' : 'semestres'}',
          onTap: () => _onCourseTap(course.id),
          trailingIcon: trailingIcon,
        );
      },
      separatorBuilder: (context,
          index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
    );
  }
}
