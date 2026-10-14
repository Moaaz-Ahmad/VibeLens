import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../models/mood_result.dart';
import '../services/camera_service.dart';
import '../services/model_service.dart';

/// Orchestrates camera + model for the camera screen (capture -> infer -> cleanup).
class CameraScreenController extends ChangeNotifier {
  CameraScreenController({CameraService? camera, ModelService? model})
      : _camera = camera ?? CameraService.instance,
        _model = model ?? ModelService.instance;

  final CameraService _camera;
  final ModelService _model;

  bool isInitializing = true;
  bool isProcessing = false;
  String? error;
  FlashMode flashMode = FlashMode.auto;

  CameraController? get cameraController => _camera.controller;

  Future<void> initialize() async {
    isInitializing = true;
    error = null;
    notifyListeners();
    try {
      if (!_camera.isInitialized) await _camera.initialize();
      if (!_model.isInitialized) await _model.initialize();
    } catch (e) {
      error = e.toString();
    }
    isInitializing = false;
    notifyListeners();
  }

  /// Takes a photo and classifies it. Throws on failure; busy-guarded.
  Future<MoodResult?> captureAndAnalyze() async {
    if (isProcessing) return null;
    return _busy(() async {
      final path = await _camera.takePicture();
      try {
        return await _model.predictMood(path);
      } finally {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    });
  }

  Future<void> switchCamera() => _busy(_camera.switchCamera);

  Future<void> toggleFlash() async {
    flashMode = switch (flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };
    await _camera.setFlashMode(flashMode);
    notifyListeners();
  }

  Future<T> _busy<T>(Future<T> Function() action) async {
    isProcessing = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
