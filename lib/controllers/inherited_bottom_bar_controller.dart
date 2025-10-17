import 'package:flutter/widgets.dart';

class InheritedBottomBarController extends InheritedWidget {
  final void Function(bool) toggleBottomBar;

  const InheritedBottomBarController({
    super.key,
    required this.toggleBottomBar,
    required Widget child,
  }) : super(child: child);

  static InheritedBottomBarController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedBottomBarController>();
  }

  @override
  bool updateShouldNotify(InheritedBottomBarController oldWidget) =>
      oldWidget.toggleBottomBar != toggleBottomBar;
}
