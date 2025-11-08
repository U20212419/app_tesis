import 'package:app_tesis/screens/statistics/statistics_screen.dart';
import 'package:app_tesis/screens/structuration/courses/courses_in_semester_screen.dart';
import 'package:app_tesis/screens/structuration/structuration_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../utils/size_config.dart';
import '../widgets/app_divider.dart';
import '../widgets/bottom_nav_tab_item.dart';
import 'courses/courses_screen.dart';

enum AppSection { courses, structuration, statistics }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AppSection _selectedSection = AppSection.structuration;
  final ValueNotifier<bool> _showBottomBar = ValueNotifier(true);

  final Map<AppSection, GlobalKey<NavigatorState>> _navigatorKeys = {
    AppSection.courses: GlobalKey<NavigatorState>(),
    AppSection.structuration: GlobalKey<NavigatorState>(),
    AppSection.statistics: GlobalKey<NavigatorState>(),
  };

  int get _selectedIndex => _selectedSection.index;

  void _onItemTapped(AppSection section) {
    if (section == _selectedSection) {
      // Return to the first route of the current tab
      _navigatorKeys[section]!.currentState!.popUntil((r) => r.isFirst);
    } else {
      setState(() => _selectedSection = section);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildNavigator(AppSection.courses, const CoursesScreen()),
          _buildNavigator(
            AppSection.structuration,
            const StructurationScreen(),
          ),
          _buildNavigator(AppSection.statistics, const StatisticsScreen()),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _showBottomBar,
        builder: (_, visible, __) =>
        visible ? _buildBottomNavBar() : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNavigator(AppSection section, Widget screen) {
    return Navigator(
      key: _navigatorKeys[section],
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/coursesInSemester':
            final args = settings.arguments as Map<String, dynamic>;
            builder = (BuildContext context) => CoursesInSemesterScreen(
                semesterId: args['semesterId'],
                semesterName: args['semesterName'],
            );
            break;
          case '/':
          default:
            builder = (BuildContext context) => screen;
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
        Container(
          width: double.infinity,
          height: SizeConfig.scaleHeight(12),
          padding: EdgeInsets.fromLTRB(
            SizeConfig.scaleWidth(4.4), // Left
            SizeConfig.scaleHeight(2.5), // Top
            SizeConfig.scaleWidth(4.4), // Right
            SizeConfig.scaleHeight(0), // Bottom
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BottomNavTabItem(
                icon: Symbols.book_2_rounded,
                label: 'Cursos',
                isSelected: _selectedSection == AppSection.courses,
                onTap: () => _onItemTapped(AppSection.courses),
              ),
              BottomNavTabItem(
                icon: Symbols.grid_view_rounded,
                label: 'Estructuración',
                isSelected: _selectedSection == AppSection.structuration,
                onTap: () => _onItemTapped(AppSection.structuration),
              ),
              BottomNavTabItem(
                icon: Symbols.bar_chart_4_bars_rounded,
                label: 'Estadísticas',
                isSelected: _selectedSection == AppSection.statistics,
                onTap: () => _onItemTapped(AppSection.statistics),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
