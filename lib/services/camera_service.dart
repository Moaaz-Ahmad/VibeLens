import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

/// Service for camera operations
class CameraService {
  static final CameraService instance = CameraService._internal();
  CameraService._internal();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;
  List<CameraDescription>? get cameras => _cameras;

  /// Initialize camera
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use back camera by default
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Create controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize controller
      await _controller!.initialize();
      _isInitialized = true;

      // ignore: avoid_print
      print('✅ Camera initialized');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to initialize camera: $e');
      rethrow;
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (!_isInitialized || _cameras == null || _cameras!.length < 2) {
      return;
    }

    final currentLensDirection = _controller!.description.lensDirection;
    CameraDescription newCamera;

    if (currentLensDirection == CameraLensDirection.back) {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
    } else {
      newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
    }

    // Dispose old controller
    await _controller?.dispose();

    // Create new controller
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  /// Take a picture and return the file path
  Future<String> takePicture() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (!_controller!.value.isInitialized) {
      throw Exception('Camera controller not initialized');
    }

    try {
      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/vibelens_$timestamp.jpg';

      // Take picture
      final XFile picture = await _controller!.takePicture();

      // Copy to our path
      await File(picture.path).copy(filePath);

      return filePath;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Failed to take picture: $e');
      rethrow;
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized || _controller == null) return;
    await _controller!.setFlashMode(mode);
  }

  /// Get current flash mode
  FlashMode get flashMode {
    if (!_isInitialized || _controller == null) {
      return FlashMode.auto;
    }
    return _controller!.value.flashMode;
  }

  /// Dispose camera resources
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
