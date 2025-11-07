import 'package:app_tesis/theme/search_field_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/size_config.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final String title;
  final TextEditingController searchController;
  final VoidCallback onSearchIconPressed;
  final VoidCallback? onBackIconPressed;
  final FocusNode? focusNode;
  final String? hintText;

  const SearchAppBar({
    super.key,
    required this.isSearching,
    required this.title,
    required this.searchController,
    required this.onSearchIconPressed,
    this.onBackIconPressed,
    this.focusNode,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final SearchFieldTheme? searchFieldTheme = Theme.of(context).extension<SearchFieldTheme>();

    return AppBar(
      title: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.scaleWidth(4.4),
              ),
              child: AnimatedOpacity(
                opacity: (isSearching || onBackIconPressed == null) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: (isSearching || onBackIconPressed == null),
                  child: IconButton(
                    icon: Icon(
                      Symbols.arrow_back_rounded,
                      size: SizeConfig.scaleHeight(3.2),
                      fill: 1.0,
                      color: AppColors.highlightDarkest,
                    ),
                    onPressed: onBackIconPressed,
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: isSearching ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Text(title),
          ),
          IgnorePointer(
            ignoring: !isSearching,
            child: AnimatedOpacity(
              opacity: isSearching ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Padding(
                padding: EdgeInsets.only(
                  left: SizeConfig.scaleWidth(8.3),
                  right: SizeConfig.scaleWidth(14.7),
                ),
                child: Container(
                  height: SizeConfig.scaleHeight(5.1),
                  decoration: BoxDecoration(
                    color: searchFieldTheme?.backgroundColor ?? AppColors.neutralLightLight,
                    borderRadius: BorderRadius.circular(
                        SizeConfig.scaleHeight(3.8)
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.scaleWidth(4.4),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                          selectionHandleColor: Colors.transparent,
                        ),
                      ),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: searchController,
                        focusNode: focusNode,
                        autofocus: false,
                        cursorColor: AppColors.highlightDarkest,
                        style: searchFieldTheme?.inputTextStyle ?? AppTextStyles.bodyM().copyWith(
                          color: AppColors.neutralDarkDarkest,
                        ),
                        // Placeholder text for the search field
                        decoration: InputDecoration(
                          hintText: hintText ?? 'Buscar...',
                          hintStyle: searchFieldTheme?.placeholderStyle ?? AppTextStyles.bodyM().copyWith(
                            color: AppColors.neutralDarkLightest,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => focusNode?.unfocus(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                right: SizeConfig.scaleWidth(4.4),
              ),
              child: IconButton(
                icon: Icon(
                  isSearching ? Symbols.close_rounded : Symbols.search_rounded,
                  size: SizeConfig.scaleHeight(3.2),
                  fill: 1.0,
                  color: AppColors.highlightDarkest,
                ),
                onPressed: onSearchIconPressed,
              ),
            ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      actions: const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
