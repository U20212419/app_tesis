import 'package:app_tesis/utils/size_config.dart';
import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/statistics_provider.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../widgets/action_button.dart';
import '../../../../../widgets/app_divider.dart';
import '../../../../../widgets/custom_dialog.dart';
import '../../../../../widgets/score_text_field.dart';
import '../../../../../widgets/secondary_bottom_bar.dart';

class ScoresConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> statsData;
  final int questionAmount;
  final int assessmentId;
  final int sectionId;

  const ScoresConfirmationScreen({
    super.key,
    required this.statsData,
    required this.questionAmount,
    required this.assessmentId,
    required this.sectionId,
  });

  @override
  State<ScoresConfirmationScreen> createState() => _ScoresConfirmationScreenState();
}

class _ScoresConfirmationScreenState extends State<ScoresConfirmationScreen> {
  bool _isEditing = false;

  late List<Map<String, dynamic>> _originalBooklets;
  late List<Map<String, dynamic>> _editableBooklets;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  final Map<int, GlobalKey<FormState>> _formKeys = {};
  final Map<int, List<TextEditingController>> _pageControllers = {};

  late StatisticsProvider _statisticsProvider;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _originalBooklets = List<Map<String, dynamic>>.from(widget.statsData['scores'] ?? []);

    _editableBooklets = _originalBooklets.map((booklet) {
      return Map<String, dynamic>.from(booklet);
    }).toList();

    _generatePageControllers(0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      _isInit = false;
    }
  }

  void _generatePageControllers(int pageIndex) {
    if (_editableBooklets.isEmpty) return;

    if (_pageControllers.containsKey(pageIndex) && _formKeys.containsKey(pageIndex)) {
      return;
    }

    _formKeys[pageIndex] = GlobalKey<FormState>();

    final booklet = _editableBooklets[pageIndex];
    final controllers = <TextEditingController>[];

    // 8 questions at most per booklet
    for (int i = 1; i <= 8; i++) {
      final key = 'question_$i';
      String textValue;

      if (i > widget.questionAmount) {
        // Rows without an assigned score
        textValue = '---';
      } else {
        double score = (booklet[key] as num?)?.toDouble() ?? 0.0;
        // Format score to 2 decimal places
        textValue = score.toStringAsFixed(2);
      }
      controllers.add(TextEditingController(text: textValue));
    }
    _pageControllers[pageIndex] = controllers;
  }

  void _updateScore(int questionIndex, String value) {
    final key = 'question_${questionIndex + 1}';
    _editableBooklets[_currentPage][key] = double.tryParse(value) ?? 0.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controllers in _pageControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    _pageControllers.clear();
    _formKeys.clear();
    super.dispose();
  }

  void _onEditTapped() {
    setState(() {
      _isEditing = !_isEditing;

      // If cancelling edit, revert changes
      if (!_isEditing) {
        // Revert to original booklets
       _editableBooklets = _originalBooklets.map((booklet) => Map<String, dynamic>.from(booklet)).toList();
       // Clear and regenerate controllers to reflect original data
       _pageControllers.clear();
       _formKeys.clear();
       _generatePageControllers(_currentPage);
      }
    });
  }

  int? _validateAllBooklets() {
    // Validate each booklet
    for (int i = 0; i < _editableBooklets.length; i++) {
      // Validate each question in the booklet
      for (int q = 1; q <= widget.questionAmount; q++) {
        final formState = _formKeys[i]?.currentState;

        // If formState exists, use it to validate
        if (formState != null) {
          if (!formState.validate()) {
            return i;
          }
        } else {
          for (int q = 1; q <= widget.questionAmount; q++) {
            final key = 'question_$q';
            final score = _editableBooklets[i][key];

            if (score == null) {
              return i;
            }
            if (score < 0 || score > 20) {
              return i;
            }
          }
        }
      }
    }
    return null; // All valid
  }

  void _onSaveTapped() {
    final int? invalidPageIndex = _validateAllBooklets();

    if (invalidPageIndex != null) {
      // Navigate to the first invalid page
      if (_currentPage != invalidPageIndex) {
        _pageController.jumpToPage(invalidPageIndex);
      }

      CustomToast.show(
        context: context,
        title: 'Error de validación',
        detail: 'Por favor, corrija los errores en el formulario antes de guardar.',
        type: CustomToastType.error,
        position: ToastPosition.top,
      );
      return;
    }

    setState(() {
      _originalBooklets =
          _editableBooklets.map((booklet) =>
          Map<String, dynamic>.from(
              booklet)).toList();
      _isEditing = false;
      _pageControllers.clear();
      _generatePageControllers(_currentPage);
    });
  }

  void _onConfirmTapped() async {
    final theme = Theme.of(context);

    final int? invalidPageIndex = _validateAllBooklets();

    if (invalidPageIndex != null) {
      // Navigate to the first invalid page
      if (_currentPage != invalidPageIndex) {
        _pageController.jumpToPage(invalidPageIndex);
      }

      CustomToast.show(
        context: context,
        title: 'Error de validación',
        detail: 'Por favor, corrija los errores en el formulario antes de confirmar.',
        type: CustomToastType.error,
        position: ToastPosition.top,
      );
      return;
    }

    final bool? didConfirm = await showCustomDialog<bool>(
      context: context,
      title: "Confirmando Puntajes",
      body: Text(
        "¿Está conforme con los puntajes? No podrá editarlos luego de la generación de estadísticas.",
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyS().copyWith(
            color: theme.colorScheme.onSurfaceVariant
        ),
      ),
      color: AppColors.supportWarningDark,
      actionButtonText: "Confirmar",
      onActionPressed: (BuildContext dialogContext) async {
        return await _confirmScores(
          _statisticsProvider,
          widget.assessmentId,
          widget.sectionId,
          _editableBooklets,
          dialogContext
        );
      }
    );

    if (didConfirm != true) return; // User cancelled
  }

  Future<bool> _confirmScores(
      StatisticsProvider provider,
      int assessmentId,
      int sectionId,
      List<Map<String, dynamic>> editableBooklets,
      BuildContext dialogContext
  ) async {
    try {
      await provider.updateStatistics(
          assessmentId,
          sectionId,
          editableBooklets,
          'CONFIRMED'
      );

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: context,
          title: 'Puntajes guardados',
          detail: 'Los puntajes han sido registrados exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      if (mounted && dialogContext.mounted) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: context,
          title: 'Error al guardar puntajes',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }

      return false;
    }
  }

  void _onDiscardTapped() async {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final bool? didDiscard = await showCustomDialog<bool>(
      context: context,
      title: "Desechando Puntajes",
      body: Text(
        "¿Está seguro de desechar los puntajes? Esta acción no puede revertirse.",
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyS().copyWith(
            color: theme.colorScheme.onSurfaceVariant
        ),
      ),
      color: AppColors.supportErrorDark,
      actionButtonText: "Desechar",
      onActionPressed: (BuildContext dialogContext) async {
        return await _discardScores(
          _statisticsProvider,
          widget.assessmentId,
          widget.sectionId,
          widget.questionAmount,
          dialogContext
        );
      }
    );

    if (didDiscard == true) {
      navigator.pop(); // Go back to recording screen
    }
  }

  Future<bool> _discardScores(
      StatisticsProvider provider,
      int assessmentId,
      int sectionId,
      int questionAmount,
      BuildContext dialogContext
  ) async {
    try {
      await provider.deleteStatistics(widget.assessmentId, widget.sectionId);

      if (mounted && dialogContext.mounted) {
        CustomToast.show(
          context: context,
          title: 'Puntajes desechados',
          detail: 'Los puntajes han sido desechados exitosamente.',
          type: CustomToastType.success,
          position: ToastPosition.top,
        );
      }

      return true;
    } catch (e) {
      if (mounted && dialogContext.mounted) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: context,
          title: 'Error al desechar puntajes',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isEditing) {
          _onEditTapped(); // Cancel editing
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Custom title
          title: const Text(
            'Confirmación de Puntajes',
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: const [],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _editableBooklets.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _generatePageControllers(index);
                      });
                    },
                    itemBuilder: (context, pageIndex) {
                      _generatePageControllers(pageIndex);
                      return _buildScoreForm(
                        key: ValueKey('booklet_$pageIndex$_isEditing'),
                        formKey: _formKeys[pageIndex]!,
                        controllers: _pageControllers[pageIndex]!,
                      );
                    },
                  ),
                ),
                AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
                _buildPageIndicator(),

                _isEditing
                    ? SecondaryBottomBar(
                        actions: [
                          ActionButton(
                            icon: Symbols.cancel_rounded,
                            label: 'Cancelar',
                            accentColor: AppColors.highlightDarkest,
                            layout: ButtonLayout.horizontal,
                            onTap: () {
                              _onEditTapped();
                            },
                          ),
                          ActionButton(
                            icon: Symbols.save_rounded,
                            label: 'Guardar',
                            accentColor: AppColors.highlightDarkest,
                            layout: ButtonLayout.horizontal,
                            onTap: () {
                              setState(() {
                                _onSaveTapped();
                              });
                            },
                          ),
                        ],
                    )
                    : SecondaryBottomBar(
                        actions: [
                          ActionButton(
                            icon: Symbols.edit_rounded,
                            label: 'Editar',
                            accentColor: AppColors.highlightDarkest,
                            width: SizeConfig.scaleWidth(21),
                            onTap: () {
                              _onEditTapped();
                            },
                          ),
                          ActionButton(
                            icon: Symbols.check_circle_rounded,
                            label: 'Confirmar',
                            accentColor: AppColors.supportSuccessDark,
                            width: SizeConfig.scaleWidth(21),
                            onTap: () {
                              _onConfirmTapped();
                            },
                          ),
                          ActionButton(
                            icon: Symbols.delete_forever_rounded,
                            label: 'Desechar',
                            accentColor: AppColors.supportErrorDark,
                            width: SizeConfig.scaleWidth(21),
                            onTap: () {
                              _onDiscardTapped();
                            },
                          ),
                        ],
                    )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreForm({
    required Key key,
    required GlobalKey<FormState> formKey,
    required List<TextEditingController> controllers,
  }) {
    // 8 rows per booklet
    final int questionCount = 8;

    return Form(
      key: formKey,
      child: ListView.separated(
        key: key,
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.scaleHeight(2.5),
          horizontal: SizeConfig.scaleWidth(5.0),
        ),
        itemCount: questionCount,
        separatorBuilder: (context, index) => SizedBox(height: SizeConfig.scaleHeight(1.25)),
        itemBuilder: (context, index) {
          final int questionNumber = index + 1;
          final bool isReadOnly = (questionNumber > widget.questionAmount) || !_isEditing;

          return ScoreTextField(
            label: 'Pregunta $questionNumber',
            controller: controllers[index],
            isReadOnly: isReadOnly,
            onChanged: (value) {
              _updateScore(index, value);
            },
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.scaleWidth(8.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: _currentPage > 0,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              icon: const Icon(Symbols.arrow_back_ios_rounded),
              iconSize: SizeConfig.scaleHeight(3.1),
              color: AppColors.highlightDarkest,
              onPressed: _currentPage > 0
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
          ),
          Text(
            'Cuadernillo ${_currentPage + 1}/${_editableBooklets.length}',
            style: AppTextStyles.heading4().copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant
            ),
          ),
          Visibility(
            visible: _currentPage < _editableBooklets.length - 1,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: IconButton(
              icon: const Icon(Symbols.arrow_forward_ios_rounded),
              iconSize: SizeConfig.scaleHeight(3.1),
              color: AppColors.highlightDarkest,
              onPressed: _currentPage < _editableBooklets.length - 1
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
