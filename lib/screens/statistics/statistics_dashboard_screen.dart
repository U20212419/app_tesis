import 'dart:developer';
import 'dart:io';

import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:app_tesis/widgets/dashboard_add_assessment_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:excel/excel.dart' as excel_package;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/assessment.dart';
import '../../models/assessment_section_id.dart';
import '../../models/course.dart';
import '../../models/section.dart';
import '../../models/semester.dart';
import '../../models/statistics_data.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/section_provider.dart';
import '../../providers/semester_provider.dart';
import '../../providers/statistics_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/comparison_question_bar_chart.dart';
import '../../widgets/comparison_question_radar_chart.dart';
import '../../widgets/stats_banner_card.dart';
import '../../widgets/total_score_histogram.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> initialStatsData;
  final int semesterId;
  final int courseId;
  final int assessmentId;
  final int sectionId;

  const StatisticsDashboardScreen({
    super.key,
    required this.initialStatsData,
    required this.semesterId,
    required this.courseId,
    required this.assessmentId,
    required this.sectionId,
  });

  @override
  State<StatisticsDashboardScreen> createState() => _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  late StatisticsDashboardProvider _dashboardProvider;

  @override
  void initState() {
    super.initState();
    _dashboardProvider = Provider.of<StatisticsDashboardProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final semesterProvider = Provider.of<SemesterProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final assessmentProvider = Provider.of<AssessmentProvider>(context, listen: false);
    final sectionProvider = Provider.of<SectionProvider>(context, listen: false);

    late Semester semester;
    late Course course;
    late Assessment assessment;
    late Section section;

    try {
      semester = await semesterProvider.fetchSemesterById(
          widget.semesterId);
      course = await courseProvider.fetchCourseById(widget.courseId);
      assessment = await assessmentProvider.fetchAssessmentById(
          widget.assessmentId);
      section = await sectionProvider.fetchSectionById(widget.sectionId);
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst("Exception: ", "");
        CustomToast.show(
          context: context,
          title: 'Error al cargar datos iniciales',
          detail: errorMessage,
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
      }
      return;
    }

    if (!mounted) return;

    final initialData = StatisticsData(
      semesterName: '${semester.year}-${semester.number}',
      courseName: '${course.code} - ${course.name}',
      assessmentName: '${assessment.type} ${assessment.number}',
      sectionName: section.name,
      stats: widget.initialStatsData,
      id: AssessmentSectionId(
        assessmentId: widget.assessmentId,
        sectionId: widget.sectionId,
      ),
    );

    _dashboardProvider.addStats(initialData);
  }

  void _showAddAssessmentDialog() {
    final currentStatsCount = _dashboardProvider.statsList.length;

    if (currentStatsCount >= 4) {
      // Show a dialog indicating the maximum number of assessments has been reached
      CustomToast.show(
        context: context,
        title: 'Límite alcanzado',
        detail: 'No se pueden agregar más de 4 evaluaciones al panel de estadísticas.',
        type: CustomToastType.warning,
        position: ToastPosition.top,
      );
      return;
    }

    final usedIds = _dashboardProvider.statsList
        .map((data) => data.id)
        .toSet();

    showDashboardAddAssessmentDialog(
      context: context,
      onSelectionComplete: (selectedIds) async {
        final semesterId = selectedIds['semesterId']!;
        final courseId = selectedIds['courseId']!;
        final assessmentId = selectedIds['assessmentId']!;
        final sectionId = selectedIds['sectionId']!;

        try {
          await _dashboardProvider.fetchAndAddStats(
            context: context,
            semesterId: semesterId,
            courseId: courseId,
            assessmentId: assessmentId,
            sectionId: sectionId,
          );

          return null;
        } catch (e) {
          if (mounted) {
            final errorMessage = e.toString().replaceFirst("Exception: ", "");
            CustomToast.show(
              context: context,
              title: 'Error al obtener estadísticas',
              detail: errorMessage,
              type: CustomToastType.error,
              position: ToastPosition.top,
            );
          }
          return {'error': e.toString()};
        }
      },
      usedIds: usedIds,
    );
  }

  void _handleCleanUp() {
    Future.microtask(() {
      if (mounted) {
        _dashboardProvider.clearStats();
      }
    });
  }

  void _goBackToStatisticsSection() {
    Navigator.of(context).pop();
    _handleCleanUp();
  }

  Excel _generateExcel(Set<StatisticsData> statsList) {
    final Excel excel = Excel.createExcel();
    // Retrieve default sheet and rename it
    final String defaultSheet = excel.getDefaultSheet().toString();
    excel.rename(defaultSheet, 'Estadísticas');
    final Sheet sheet = excel['Estadísticas'];

    // Add data rows
    for (int i = 0; i < statsList.length; i++) {
      final stats = statsList.elementAt(i);
      // Add header row
      const headers = [
        'Semestre',
        'Curso',
        'Evaluación',
        'Horario',
        'Cantidad',
        'Media',
        'Mediana',
        'Desv. Est.',
        'Mínimo',
        'Máximo'
      ];
      List<CellValue?> headersCellValue = headers.map((h) => TextCellValue(h)).toList();
      sheet.appendRow(headersCellValue);
      sheet.row(sheet.maxRows - 1).forEach((cell) {
        cell?.cellStyle = CellStyle(
            bold: true,
            horizontalAlign: HorizontalAlign.Center,
            topBorder: i > 0 ? excel_package.Border(
              borderStyle: excel_package.BorderStyle.Double,
              borderColorHex: ExcelColor.black,
            ) : null);
      });

      // Aggregate statistics
      final aggStats = stats.stats['statistics'] ?? {};
      final row = [
        TextCellValue(stats.semesterName),
        TextCellValue(stats.courseName),
        TextCellValue(stats.assessmentName),
        TextCellValue(stats.sectionName),
        IntCellValue((aggStats['count'] as num?)?.toInt() ?? 0),
        DoubleCellValue((aggStats['mean'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((aggStats['median'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((aggStats['std_dev'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((aggStats['min'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((aggStats['max'] as num?)?.toDouble() ?? 0.0),
      ];

      sheet.appendRow(row);

      // Detail per question (aggregate)
      final questionStats = (aggStats['question_stats'] as Map<String, dynamic>?) ?? {};

      if (questionStats.isNotEmpty) {
        const questionHeaders = [
          'Pregunta',
          'Máx.',
          'Mín.',
          'Media',
          'Mediana',
          'Desv. Est.'
        ];
        List<CellValue?> questionHeadersCellValue = questionHeaders.map((h) =>
            TextCellValue(h)).toList();
        sheet.appendRow(questionHeadersCellValue);
        sheet.row(sheet.maxRows - 1).forEach((cell) {
          cell?.cellStyle = CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              topBorder: excel_package.Border(
                borderStyle: excel_package.BorderStyle.Thin,
                borderColorHex: ExcelColor.black,
              ));
        });

        questionStats.forEach((questionKey, qData) {
          final row = [
            TextCellValue('Pregunta ${questionKey
                .split('_')
                .last}'),
            DoubleCellValue((qData['max'] as num?)?.toDouble() ?? 0.0),
            DoubleCellValue((qData['min'] as num?)?.toDouble() ?? 0.0),
            DoubleCellValue((qData['mean'] as num?)?.toDouble() ?? 0.0),
            DoubleCellValue((qData['median'] as num?)?.toDouble() ?? 0.0),
            DoubleCellValue((qData['std_dev'] as num?)?.toDouble() ?? 0.0),
          ];
          sheet.appendRow(row);
        });
      }

      // Detail per booklet
      final List<dynamic> individualScores = stats.stats['scores'] ?? [];

      if (individualScores.isNotEmpty) {
        final int numQuestions = questionStats.length;

        List<String> scoreHeaders = [
          'Contracarátula',
          'Puntaje Total',
        ];
        for (int i = 1; i <= numQuestions; i++) {
          scoreHeaders.add('Pregunta $i');
        }

        List<CellValue?> scoreHeadersCellValue = scoreHeaders
            .map((h) => TextCellValue(h))
            .toList();
        sheet.appendRow(scoreHeadersCellValue);
        sheet.row(sheet.maxRows - 1).forEach((cell) {
          cell?.cellStyle = CellStyle(
              bold: true,
              horizontalAlign: HorizontalAlign.Center,
              topBorder: excel_package.Border(
                borderStyle: excel_package.BorderStyle.Thin,
                borderColorHex: ExcelColor.black,
              ));
        });

        for (int i = 0; i < individualScores.length; i++) {
          final scoreEntry = individualScores[i];
          final List<CellValue?> scoreRow = [];
          final Map<String, dynamic> scoreData = scoreEntry as Map<String, dynamic>;

          scoreRow.add(IntCellValue(i + 1)); // Booklet number
          scoreRow.add(DoubleCellValue(
              (scoreData['total_score'] as num?)?.toDouble() ?? 0.0));

          for (int q = 1; q <= numQuestions; q++) {
            final questionKey = 'question_$q';
            scoreRow.add(DoubleCellValue(
                (scoreData[questionKey] as num?)?.toDouble() ?? 0.0));
          }

          sheet.appendRow(scoreRow);
        }
      }
    }

    return excel;
  }

  static const platform = MethodChannel("com.app_tesis.storage");

  Future<void> _exportExcel(Set<StatisticsData> statsList) async {
    final excel = _generateExcel(statsList);
    final encoded = excel.encode();
    if (encoded == null) {
      _showExportError("No se pudo generar el archivo.");
      return;
    }

    final fileBytes = Uint8List.fromList(encoded);

    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(now);
    final filename = "estadisticas_$timestamp.xlsx";

    bool isLegacyAndroid = false;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      isLegacyAndroid = sdkInt <= 28; // Android 9 and below
    }

    bool useShareFallback = false;

    // Try to save directly to Downloads folder on Android
    if (Platform.isAndroid) {
      PermissionStatus status = PermissionStatus.granted; // Default to granted (Android 10+)

      // Request storage permission for Android 9 and below
      if (isLegacyAndroid) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        try {
          // Save to Downloads folder via platform channel
          final bool ok = await platform.invokeMethod(
            "saveToDownloadFolder",
            {
              "filename": filename,
              "bytes": fileBytes,
            },
          );

          if (ok) {
            _showExportSuccess("Archivo guardado en la carpeta de Descargas.");
            return;
          } else {
            useShareFallback = true;
          }
        } catch (e) {
          log("Error saving file via platform channel: $e");
          useShareFallback = true;
        }
      } else {
        log("Storage permission denied.");
        useShareFallback = true;
      }
    }

    // iOS and other platforms: use Share Plus. Also works as fallback on Android.
    if (!Platform.isAndroid || useShareFallback) {
      if (useShareFallback) {
        _showExportError(
            "No se pudo guardar el archivo directamente. Se abrirá el diálogo de compartir.");
      }

      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsBytes(fileBytes, flush: true);

        final params = ShareParams(
          files: [
            XFile(file.path,
                mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
          ],
          text: 'Archivo de estadísticas exportado.',
        );
        await SharePlus.instance.share(params);
      } catch (e) {
        log("Error exporting Excel file: $e");
        _showExportError("Ocurrió un error inesperado al exportar el archivo.");
      }
    }
  }

  void _showExportSuccess(String message) {
    if (!mounted) return;
    CustomToast.show(
      context: context,
      title: 'Exportación exitosa',
      detail: message,
      type: CustomToastType.success,
      position: ToastPosition.top,
    );
  }

  void _showExportError(String errorMessage) {
    if (!mounted) return;
    CustomToast.show(
      context: context,
      title: 'Error al exportar',
      detail: errorMessage,
      type: CustomToastType.error,
      position: ToastPosition.top,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsList = context.watch<StatisticsDashboardProvider>().statsList;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _goBackToStatisticsSection();
        } else {
          _handleCleanUp();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.scaleWidth(4.4),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Symbols.arrow_back_rounded,
                      size: SizeConfig.scaleHeight(3.2),
                      fill: 1.0,
                      color: AppColors.highlightDarkest,
                    ),
                    onPressed: _goBackToStatisticsSection,
                  ),
                ),
              ),
              const Text('Dashboard'),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Symbols.download_rounded,
                        size: SizeConfig.scaleHeight(3.2),
                        fill: 1.0,
                        color: AppColors.highlightDarkest,
                      ),
                      onPressed: () async {
                        await _exportExcel(statsList);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        right: SizeConfig.scaleWidth(2.2),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Symbols.add_2_rounded,
                          size: SizeConfig.scaleHeight(3.2),
                          fill: 1.0,
                          color: AppColors.highlightDarkest,
                        ),
                        onPressed: () {
                          _showAddAssessmentDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: const [],
        ),
        body: _buildDashboardBody(statsList),
      ),
    );
  }
}

Widget _buildDashboardBody(Set<StatisticsData> statsList) {
  if (statsList.isEmpty) {
    return const Center(
        child: CircularProgressIndicator(
          color: AppColors.highlightDarkest,
        )
    );
  }
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppDivider(thickness: SizeConfig.scaleHeight(0.08)),
      Expanded(
        child: ListView(
          children: [
            ...statsList.map((data) => StatsBannerCard(
              statsData: data,
              color: switch (statsList.toList().indexOf(data) % 4) {
                0 => AppColors.highlightLightest,
                1 => AppColors.supportWarningLight,
                2 => AppColors.supportSuccessLight,
                _ => AppColors.supportErrorLight,
              },
            )),
            ComparisonTotalScoreHistogramChart(
              statsDataList: statsList,
              label: 'Distribución de Puntajes Totales',
            ),
            ComparisonQuestionBarChart(
              statsDataList: statsList,
              label: 'Promedio de Puntajes por Pregunta',
            ),
            ComparisonQuestionRadarChart(
              statsDataList: statsList,
            ),
          ],
        ),
      ),
    ],
  );
}
