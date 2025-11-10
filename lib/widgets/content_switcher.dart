import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';
import 'app_divider.dart';

class ContentSwitcher extends StatefulWidget {
  final List<String> tabTitles;
  final List<Widget> tabContents;
  final Function(int)? onTabChanged;

  const ContentSwitcher({
    super.key,
    required this.tabTitles,
    required this.tabContents,
    this.onTabChanged,
  }) : assert(tabTitles.length == tabContents.length,
  'tabTitles and tabContents must have the same length.');

  @override
  State<ContentSwitcher> createState() => _ContentSwitcherState();
}

class _ContentSwitcherState extends State<ContentSwitcher> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: SizeConfig.scaleHeight(6.1),
          width: SizeConfig.scaleWidth(92.2),
          margin: EdgeInsets.symmetric(
            vertical: SizeConfig.scaleHeight(1.6),
            horizontal: SizeConfig.scaleWidth(3.9),
          ),
          padding: EdgeInsets.fromLTRB(
            SizeConfig.scaleWidth(1.1),
            SizeConfig.scaleHeight(0.6),
            SizeConfig.scaleWidth(1.1),
            SizeConfig.scaleHeight(0.6),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(2.5)),
          ),
          child: Row(
            children: List.generate(widget.tabTitles.length, (index) {
              final isSelected = index == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    widget.onTabChanged?.call(index);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.scaffoldBackgroundColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(SizeConfig.scaleHeight(1.9)),
                    ),
                    child: Text(
                      widget.tabTitles[index],
                      style: AppTextStyles.heading5().copyWith(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        AppDivider(
          thickness: SizeConfig.scaleHeight(0.08),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}
