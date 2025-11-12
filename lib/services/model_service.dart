import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/mood_result.dart';
import '../core/constants.dart';
import '../core/utils/logger.dart';

/// Service for on-device ML inference using TensorFlow Lite
///
/// Handles:
/// - Model initialization
/// - Image preprocessing
/// - Mood prediction inference
/// - Result parsing
class ModelService {
  static final ModelService instance = ModelService._internal();
  ModelService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize the TFLite model
  Future<void> initialize() async {
    if (_isInitialized) {
      Logger.warning('Model already initialized');
      return;
    }

    try {
      Logger.info('Loading TFLite model...');

      // Load model
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);

      // Allocate tensors
      _interpreter!.allocateTensors();

      _isInitialized = true;

      Logger.success('Model loaded successfully');
      Logger.debug('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      Logger.debug('Input type: ${_interpreter!.getInputTensor(0).type}');
      Logger.debug('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      Logger.debug('Output type: ${_interpreter!.getOutputTensor(0).type}');
    } catch (e, stack) {
      Logger.error('Failed to load model', e, stack);
      rethrow;
    }
  }

  /// Run inference on an image file
  Future<MoodResult> predictMood(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized. Call initialize() first.');
    }

    Logger.inference('Starting mood prediction');
    final startTime = DateTime.now();

    try {
      // Load and preprocess image
      final imageData = await _preprocessImage(imagePath);
      Logger.debug('Image preprocessed');

      // Run inference - output is uint8, so we need to use List<int>
      final output = List.generate(
        1,
        (_) => List.filled(AppConstants.modelClasses, 0),
      );
      _interpreter!.run(imageData, output);

      final endTime = DateTime.now();
      final inferenceTime = endTime.difference(startTime).inMilliseconds;

      // Convert uint8 output to probabilities (0-255 -> 0.0-1.0)
      final probabilities = output[0].map((e) => e / 255.0).toList();

      // Normalize probabilities to sum to 1.0
      final sum = probabilities.reduce((a, b) => a + b);
      final normalizedProbs = probabilities.map((p) => p / sum).toList();

      final maxIndex = normalizedProbs.indexOf(
        normalizedProbs.reduce((a, b) => a > b ? a : b),
      );
      final maxConfidence = normalizedProbs[maxIndex];

      final label = MoodLabel.values[maxIndex];

      Logger.inference(
        'Prediction: ${label.name} (${(maxConfidence * 100).toStringAsFixed(1)}%)',
        timeMs: inferenceTime,
      );

      return MoodResult(
        label: label,
        confidence: maxConfidence,
        embedding: normalizedProbs,
        timestamp: DateTime.now(),
        inferenceTimeMs: inferenceTime,
      );
    } catch (e, stack) {
      Logger.error('Prediction failed', e, stack);
      rethrow;
    }
  }

  /// Preprocess image for model input
  ///
  /// Steps:
  /// 1. Load image from file
  /// 2. Resize to 224x224
  /// 3. Convert to uint8 format [0-255] for model input
  /// 4. Convert to 4D tensor [1, 224, 224, 3]
  Future<List<List<List<List<int>>>>> _preprocessImage(
    String imagePath,
  ) async {
    try {
      // Load image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to model input size
      final resized = img.copyResize(
        image,
        width: AppConstants.modelInputSize,
        height: AppConstants.modelInputSize,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to uint8 [0-255] format for model input
      // Format: [batch, height, width, channels]
      final input = List.generate(
        1,
        (i) => List.generate(
          AppConstants.modelInputSize,
          (y) => List.generate(
            AppConstants.modelInputSize,
            (x) {
              final pixel = resized.getPixel(x, y);
              return [
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
              ];
            },
          ),
        ),
      );

      return input;
    } catch (e) {
      Logger.error('Image preprocessing failed', e);
      rethrow;
    }
  }

  /// Get detailed predictions for all classes
  Future<Map<MoodLabel, double>> getPredictions(String imagePath) async {
    if (!_isInitialized) {
      throw Exception('Model not initialized');
    }

    try {
      final imageData = await _preprocessImage(imagePath);
      final output = List.generate(
        1,
        (_) => List.filled(AppConstants.modelClasses, 0),
      );
      _interpreter!.run(imageData, output);

      // Convert uint8 output to probabilities (0-255 -> 0.0-1.0)
      final probabilities = output[0].map((e) => e / 255.0).toList();

      // Normalize probabilities to sum to 1.0
      final sum = probabilities.reduce((a, b) => a + b);
      final normalizedProbs = probabilities.map((p) => p / sum).toList();

      return Map.fromIterables(MoodLabel.values, normalizedProbs);
    } catch (e) {
      Logger.error('Failed to get predictions', e);
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    Logger.info('Disposing model service');
    _interpreter?.close();
    _isInitialized = false;
  }

  /// Get model info for debugging
  Map<String, dynamic> getModelInfo() {
    if (!_isInitialized || _interpreter == null) {
      return {'error': 'Model not initialized'};
    }

    return {
      'modelPath': AppConstants.modelPath,
      'inputShape': _interpreter!.getInputTensor(0).shape,
      'outputShape': _interpreter!.getOutputTensor(0).shape,
      'inputType': _interpreter!.getInputTensor(0).type.toString(),
      'outputType': _interpreter!.getOutputTensor(0).type.toString(),
      'isInitialized': _isInitialized,
    };
  }
}
