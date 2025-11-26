import 'dart:developer';
import 'dart:io';

import 'package:app_tesis/screens/structuration/courses_in_semester/assessments_and_sections/recording/scores_confirmation_screen.dart';
import 'package:app_tesis/widgets/custom_dialog.dart';
import 'package:app_tesis/widgets/custom_toast.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../../providers/statistics_provider.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../utils/size_config.dart';
import '../../../../../widgets/action_button.dart';

class RecordingScreen extends StatefulWidget {
  final int assessmentId;
  final int sectionId;
  final int questionAmount;
  final int semesterId;
  final int courseId;

  const RecordingScreen({
    super.key,
    required this.assessmentId,
    required this.sectionId,
    required this.questionAmount,
    required this.semesterId,
    required this.courseId,
  });

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isRecording = false;
  bool _isProcessing = false;

  final Stopwatch _recordingStopwatch = Stopwatch();
  final List<int> _capturedFrameTimestamps = [];

  late StatisticsProvider _statisticsProvider;
  bool _isInit = true;

  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    requestPermissions().then((_) => _initializeCamera());

    // Show informational toast after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomToast.show(
        context: context,
        title: 'Importante',
        detail: 'Asegúrese de que las contracarátulas queden capturadas '
                'sin ningún otro objeto (manos, otros cuadernillos, etc.) visible '
                'y que la tabla de puntajes se vea completamente.',
        type: CustomToastType.info,
        position: ToastPosition.top,
        duration: const Duration(seconds: 10),
      );
    });
  }

  Future<void> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();

    if (!cameraStatus.isGranted) {
      if (mounted) {
        CustomToast.show(
          context: context,
          title: 'Permiso denegado',
          detail: 'El permiso de cámara es necesario para grabar el video.',
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Update visibility status
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      if (_isProcessing) {
        setState(() {});
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInForeground = false;
    }

    // Handle camera state changes
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      if (_isRecording) {
        log('App inactive: stopping recording.');
        _onStopButtonPressed();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_controller!.value.isInitialized) {
        log('App resumed: re-initializing camera.');
        _initializeCamera();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();

    if (_statisticsProvider.isLoading || _statisticsProvider.isPollingActive) {
      _statisticsProvider.cancelPolling();
    }

    // Restore preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isCameraReady) return;

    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.veryHigh, // Very high resolution (1080p)
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );

      await _controller!.initialize();

      // Lock orientation to portrait mode
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      // Set focus mode to auto to ensure clarity
      await _controller!.setFocusMode(FocusMode.auto);

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      log('Error initializing camera: $e');
      if (mounted) {
        CustomToast.show(
          context: context,
          title: 'Error de cámara',
          detail: 'No se pudo inicializar la cámara. Verifique los permisos.',
          type: CustomToastType.error,
          position: ToastPosition.top,
        );
        Navigator.pop(context);
      }
    }
  }

  void _onStartButtonPressed() async {
    if (_isRecording || !_isCameraReady) return;

    try {
      _capturedFrameTimestamps.clear();
      _recordingStopwatch.reset();
      _recordingStopwatch.start();

      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      log('Error starting video recording: $e');
    }
  }

  Future<void> _deleteVideoFile(XFile videoFile) async {
    try {
      final file = File(videoFile.path);
      if (await file.exists()) {
        await file.delete();
        log('Video file deleted: ${videoFile.path}');
      }
    } catch (e) {
      log('Error deleting video file: $e');
    }
  }

  Future<void> _onStopButtonPressed() async {
    if (!_isRecording) return;

    try {
      _recordingStopwatch.stop();

      final XFile videoFile = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
      });

      if (mounted) {
        final bool? didConfirm = await _showConfirmationModal(videoFile);

        if (didConfirm == true) {
          log('User confirmed video for processing: ${videoFile.path}');
          // Start processing the video
          await _startProcessing(videoFile);
        } else {
          await _deleteVideoFile(videoFile); // Delete the file if not confirmed
          log('Video file deleted after user cancellation: ${videoFile.path}');
        }
      }
    } catch (e) {
      log('Error stopping video recording: $e');
    }
  }

  void _onCancelButtonPressed() async {
    final navigator = Navigator.of(context);

    if (_isRecording && _controller != null) {
      _recordingStopwatch.stop();

      final XFile file = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
      });

      await _deleteVideoFile(file);
    }
    navigator.pop();
  }

  void _onCaptureFramePressed() {
    if (!_isRecording) return;

    // Capture the current timestamp in milliseconds since recording started
    final int currentMs = _recordingStopwatch.elapsedMilliseconds;
    _capturedFrameTimestamps.add(currentMs);

    log('Captured frame at ${currentMs}ms. Total captured frames: ${_capturedFrameTimestamps.length}');

    CustomToast.show(
      context: context,
      title: 'Frame capturado',
      detail: 'Marca de tiempo: $currentMs ms',
      type: CustomToastType.info,
      duration: const Duration(seconds: 1),
      position: ToastPosition.bottom,
    );
  }

  Future<bool?> _showConfirmationModal(XFile videoFile) async {
    final theme = Theme.of(context);

    final bool? didConfirm = await showCustomDialog<bool>(
      context: context,
      title: "Confirmación de Video",
      color: AppColors.supportWarningDark,
      actionButtonText: "Confirmar",
      body: Text(
        "¿Está seguro de utilizar el video grabado para obtener las estadísticas? "
        "Cualquier toma de estadísticas realizada previamente será sobrescrita.",
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyS().copyWith(
            color: theme.colorScheme.onSurfaceVariant
        ),
      ),
      onActionPressed: (BuildContext _) {
        return true;
      },
    );

    return didConfirm;
  }

  Future<void> _startProcessing(XFile videoFile) async {
    WakelockPlus.enable(); // Keep the screen awake during processing
    setState(() {
      _isProcessing = true;
    });

    final provider = Provider.of<StatisticsProvider>(context, listen: false);
    bool success = false;
    Map<String, dynamic>? statsData;
    String? errorMessage;

    try {
      success = await provider.startVideoProcessing(
        videoFile: File(videoFile.path),
        fileName: videoFile.name,
        assessmentId: widget.assessmentId,
        sectionId: widget.sectionId,
        questionAmount: widget.questionAmount,
        framesIndexes: _capturedFrameTimestamps.isNotEmpty
            ? _capturedFrameTimestamps
            : null,
      );

      if (success) {
        provider.updateStatistics(widget.assessmentId, widget.sectionId, null, 'PENDING_CONFIRMATION');
        statsData = provider.latestStats;
        log('Received statistics data: $statsData');
      }
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      WakelockPlus.disable();
      // If the app is in background, wait until it comes to foreground to show results
      while (!_isAppInForeground && mounted) {
        log('App is in background, waiting to show processing result...');
        await Future.delayed(const Duration(milliseconds: 500));
      }
      log('App is in foreground, proceeding to show processing result.');

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        if (errorMessage != null) {
          CustomToast.show(
            context: context,
            title: 'Error de procesamiento',
            detail: errorMessage,
            type: CustomToastType.error,
            position: ToastPosition.top,
          );
        } else if (success && statsData != null) {
          final List<dynamic> scoresList = statsData['scores'] ?? [];

          if (scoresList.isEmpty) {
            log('No scores found in statistics data.');
            CustomToast.show(
              context: context,
              title: 'Procesamiento completo',
              detail: 'No se detectó ningún cuadernillo en el video. Por favor, intente grabar de nuevo.',
              type: CustomToastType.error,
              position: ToastPosition.top,
            );
          } else {
            log('Video processing completed successfully.');

            CustomToast.show(
              context: context,
              title: 'Procesamiento completo',
              detail: 'El video ha sido procesado correctamente.',
              type: CustomToastType.success,
              position: ToastPosition.top,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ScoresConfirmationScreen(
                      statsData: statsData!,
                      questionAmount: widget.questionAmount,
                      assessmentId: widget.assessmentId,
                      sectionId: widget.sectionId,
                      semesterId: widget.semesterId,
                      courseId: widget.courseId,
                    ),
              ),
            ).then((_) {
              if (mounted) {
                log('Returned from ScoresConfirmationScreen, resetting RecordingScreen.');
                setState(() {
                  _isRecording = false;
                  _isProcessing = false;
                  _capturedFrameTimestamps.clear();

                  _isCameraReady = false;
                });

                _restartCamera();
              }
            });
          }
        } else {
          log('Video processing failed or statistics not available.');
        }

        await _deleteVideoFile(videoFile); // Clean up the video file
        log('Video file deleted after processing: ${videoFile.path}');
      }
    }
  }

  Future<void> _restartCamera() async {
    final oldController = _controller;
    if (oldController != null) {
      _controller = null;
      await oldController.dispose();
    }
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isCameraReady && _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRect(
                      child: CameraPreview(_controller!),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.highlightDarkest,
                      ),
                    ),
                  ),
          ),
          _buildControlsOverlay(),

          if (_isProcessing)
            Container(
              color: AppColors.neutralDarkDarkest.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.highlightDarkest,
                    ),
                    SizedBox(height: SizeConfig.scaleHeight(2.3)),
                    Text(
                      'Procesando...',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.actionM().copyWith(
                        color: AppColors.neutralLightLightest,
                      ),
                    ),
                  ]
                )
              )
            ),
        ],
      )
    );
  }

  Widget _buildControlsOverlay() {
    if (_isRecording) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(
            vertical: SizeConfig.scaleHeight(1.1),
            horizontal: SizeConfig.scaleWidth(5.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                icon: Symbols.camera_rounded,
                label: 'Capturar',
                accentColor: AppColors.highlightDarkest,
                onTap: _onCaptureFramePressed,
                layout: ButtonLayout.vertical,
              ),
              ActionButton(
                icon: Symbols.photo_camera_rounded,
                label: 'Detener',
                accentColor: AppColors.supportWarningDark,
                onTap: _onStopButtonPressed,
                layout: ButtonLayout.vertical,
              )
            ]
          )
        )
      );
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.scaleHeight(1.1),
          horizontal: SizeConfig.scaleWidth(5.6),
        ),
        child: Stack(
          // Cancel button on the left, Start button centered
          alignment: Alignment.centerLeft,
          children: [
            ActionButton(
              icon: Symbols.cancel_rounded,
              label: 'Cancelar',
              accentColor: AppColors.supportErrorDark,
              onTap: _onCancelButtonPressed,
              layout: ButtonLayout.vertical,
            ),
            Align(
              alignment: Alignment.center,
              child: ActionButton(
                icon: Symbols.photo_camera_rounded,
                label: 'Iniciar',
                accentColor: AppColors.supportSuccessDark,
                onTap: _onStartButtonPressed,
                layout: ButtonLayout.vertical,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
