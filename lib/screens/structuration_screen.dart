import 'package:app_tesis/providers/semester_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';
import '../widgets/action_button.dart';
import '../widgets/app_divider.dart';
import '../widgets/info_card.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/secondary_bottom_bar.dart';

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

  @override
  void initState() {
    super.initState();

    // Fetch semesters when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SemesterProvider>(context, listen: false).fetchSemestersDetailed();
    });

    // Initialize search controller listener to filter semesters in real-time
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
      key: const Key('structuration-screen-visibility-detector'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          if (_isSearching) {
            _toggleSearch();
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

  Widget _buildSemesterList(BuildContext context, SemesterProvider provider, String searchQuery) {
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
      itemCount: filteredSemesters.length,
      itemBuilder: (context, index) {
        final semester = filteredSemesters[index];
        return InfoCard(
          title: '${semester.year}-${semester.number}',
          subtitle: semester.courseCount == 0
              ? 'Sin cursos'
              : '${semester.courseCount} ${semester.courseCount == 1 ? 'curso' : 'cursos'}',
          onTap: () {},
          trailingIcon: Symbols.arrow_forward_ios_rounded,
        );
      },
      separatorBuilder: (context,
          index) => SizedBox(height: SizeConfig.scaleHeight(2.3)),
    );
  }
}
