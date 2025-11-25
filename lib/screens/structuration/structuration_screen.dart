import 'dart:developer';

import 'package:app_tesis/providers/course_in_semester_provider.dart';
import 'package:app_tesis/screens/structuration/create_semester_screen.dart';
import 'package:app_tesis/screens/structuration/edit_semester_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/semester.dart';
import '../../providers/course_provider.dart';
import '../../providers/semester_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/size_config.dart';
import '../../widgets/action_button.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/info_card.dart';
import '../../widgets/search_app_bar.dart';
import '../../widgets/secondary_bottom_bar.dart';

enum ActiveMode { none, edit, delete }

class StructurationScreen extends StatefulWidget {
  const StructurationScreen({super.key});

  @override
  State<StructurationScreen> createState() => _StructurationScreenState();
}

class _StructurationScreenState extends State<StructurationScreen> {
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

    // Fetch semesters when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Provider
            .of<SemesterProvider>(context, listen: false)
            .fetchSemestersDetailed();
      } catch (e) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: context,
          title: 'Error al cargar los semestres',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }
    });

    // Initialize search controller listener to filter semesters in real-time
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

  void _onSemesterTap(int semesterId, String semesterName) async {
    final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    final theme = Theme.of(context);

    if (_activeMode == ActiveMode.none) {
      log('Mode: $_activeMode - Semester ID: $semesterId. Navigating to CoursesInSemesterScreen.');

      setState(() {
        _isNavigatingToModeAction = true;
      });

      await Navigator.pushNamed(
        context,
        '/coursesInSemester',
        arguments: {
          'semesterId': semesterId,
          'semesterName': semesterName,
        },
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else if (_activeMode == ActiveMode.edit) {
      log('Mode: $_activeMode - Semester ID: $semesterId. Navigating to EditSemesterScreen.');

      setState(() {
        _isNavigatingToModeAction = true;
      });

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => EditSemesterScreen(
            semesterId: semesterId,
          ),
        ),
      );

      if (mounted) {
        setState(() {
          _isNavigatingToModeAction = false;
        });
      }
    } else if (_activeMode == ActiveMode.delete) {
      log('Mode: $_activeMode - Semester ID: $semesterId. Showing DeleteSemesterModal.');

      // Search for the semester to delete
      Semester? semester;
      try {
        semester = semesterProvider.semesters.firstWhere((sem) => sem.id == semesterId);
      } catch (e) {
        semester = null;
      }

      if (!mounted) return;

      // If semester not found, exit the delete flow
      if (semester == null) {
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
        title: "Eliminando Semestre",
        color: AppColors.supportErrorDark,
        actionButtonText: "Eliminar",
        body: Text(
          "¿Está seguro de eliminar el semestre ${semester.year}-${semester.number}? Esta acción no puede revertirse.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyS().copyWith(
              color: theme.colorScheme.onSurfaceVariant
          ),
        ),
        onActionPressed: (BuildContext dialogContext) async {
          return await _deleteSemester(
              semesterProvider,
              semesterId,
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

  Future<bool> _deleteSemester(
      SemesterProvider provider,
      int semesterId,
      BuildContext dialogContext
  ) async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final courseInSemesterProvider = Provider.of<CourseInSemesterProvider>(context, listen: false);

    try {
      await provider.deleteSemester(semesterId, courseProvider, courseInSemesterProvider);

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: dialogContext,
          title: 'Semestre eliminado',
          detail: 'El semestre ha sido eliminado exitosamente.',
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
          title: 'Error al eliminar el semestre',
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
          'title': 'Editar Semestre',
          'subtitle': 'Seleccione un semestre',
        };
      case ActiveMode.delete:
        return {
          'title': 'Eliminar Semestre',
          'subtitle': 'Seleccione un semestre',
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
      child: Consumer<SemesterProvider>(
        builder: (context, semesterProvider, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: SearchAppBar(
              title: 'Semestres',
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchIconPressed: _toggleSearch,
              focusNode: _focusNode,
              hintText: 'Buscar semestre',
            ),
            body: Column(
              children: [
                AppDivider(
                  thickness: SizeConfig.scaleHeight(0.08),
                ),
                Expanded(
                  child: _buildSemesterList(context, semesterProvider, _searchQuery),
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
                            builder: (context) => const CreateSemesterScreen(),
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

  Widget _buildSemesterList(BuildContext context, SemesterProvider provider, String searchQuery) {
    if (provider.isLoading) {
      return const Center(
          child: CircularProgressIndicator(
            color: AppColors.highlightDarkest,
          )
      );
    }

    final allSemesters = provider.semesters;
    final filteredSemesters = searchQuery.isEmpty
        ? allSemesters
        : allSemesters.where((semester) {
      final semesterStr = '${semester.year}-${semester.number}'.toLowerCase().trim();
      final normalizedQuery = searchQuery.toLowerCase().trim();
      return semesterStr.contains(normalizedQuery);
    }).toList();
    filteredSemesters.sort((a, b) {
      final aVal = a.year * 10 + a.number; // 2024-2 -> 20242
      final bVal = b.year * 10 + b.number;
      return bVal.compareTo(aVal); // Descending
    });

    if (filteredSemesters.isEmpty) {
      return Center(
        child: Text(
          allSemesters.isEmpty ? 'No hay semestres disponibles.'
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
      itemCount: filteredSemesters.length,
      itemBuilder: (context, index) {
        final semester = filteredSemesters[index];
        final count = semester.courseCount ?? 0;

        return InfoCard(
          title: '${semester.year}-${semester.number}',
          subtitle: count == 0
              ? 'Sin cursos'
              : '$count ${count == 1 ? 'curso' : 'cursos'}',
          onTap: () => _onSemesterTap(semester.id, '${semester.year}-${semester.number}'),
          trailingIcon: Symbols.arrow_forward_ios_rounded,
        );
      },
      separatorBuilder: (context,
          index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
    );
  }
}
