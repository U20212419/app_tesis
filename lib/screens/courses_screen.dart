import 'package:app_tesis/theme/app_text_styles.dart';
import 'package:app_tesis/widgets/action_button.dart';
import 'package:app_tesis/widgets/secondary_bottom_bar.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../providers/course_provider.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/app_divider.dart';
import '../widgets/info_card.dart';
import '../widgets/search_app_bar.dart';

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

  @override
  void initState() {
    super.initState();

    // Fetch courses when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).fetchCoursesDetailed();
    });

    // Initialize search controller listener to filter courses in real-time
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return VisibilityDetector(
      key: const Key('courses-screen-visibility-detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (_isSearching) {
            _toggleSearch();
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
                  actions: [
                    ActionButton(
                      icon: Symbols.add_2_rounded,
                      label: 'Crear',
                      backgroundColor: AppColors.highlightDarkest,
                      onTap: () {},
                    ),
                    ActionButton(
                      icon: Symbols.edit_rounded,
                      label: 'Editar',
                      backgroundColor: AppColors.highlightDarkest,
                      onTap: () {},
                    ),
                    ActionButton(
                      icon: Symbols.delete_forever_rounded,
                      label: 'Eliminar',
                      backgroundColor: AppColors.supportErrorDark,
                      onTap: () {},
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
              color: AppColors.neutralDarkMedium
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
        return InfoCard(
          title: '${course.code} - ${course.name}',
          subtitle: course.semesterCount == 0
              ? 'En ningún semestre'
              : 'En ${course.semesterCount} ${course.semesterCount == 1 ? 'semestre' : 'semestres'}',
        );
      },
      separatorBuilder: (context,
          index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
    );
  }
}
