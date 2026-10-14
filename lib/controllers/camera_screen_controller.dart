import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../models/mood_result.dart';
import '../services/camera_service.dart';
import '../services/mood_classifier_service.dart';

/// Orchestrates camera + model for the camera screen (capture -> infer -> cleanup).
class CameraScreenController extends ChangeNotifier {
  CameraScreenController({
    CameraService? camera,
    MoodClassifierService? classifier,
  })  : _camera = camera ?? CameraService.instance,
        _classifier = classifier ?? MoodClassifierService();

  final CameraService _camera;
  final MoodClassifierService _classifier;

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
        return await _classifier.classify(path);
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
