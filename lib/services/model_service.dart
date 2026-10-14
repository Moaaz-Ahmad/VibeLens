import 'dart:math' as math;

import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/constants.dart';
import '../core/utils/logger.dart';
import '../models/mood_result.dart';
import 'image_preprocessor.dart';

/// On-device mood inference with TensorFlow Lite.
///
/// Contract with the model (ml/build_model.py): input [1,224,224,3] raw RGB
/// 0..255 (float32 or uint8), output one score per [MoodLabel], in enum order.
/// Tensor types, shapes and quantization are read from the model, not assumed.
class ModelService {
  static final ModelService instance = ModelService._internal();
  ModelService._internal();

  Interpreter? _interpreter;

  bool get isInitialized => _interpreter != null;

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      final interpreter = await Interpreter.fromAsset(ModelConfig.path);
      interpreter.allocateTensors();

      final inShape = interpreter.getInputTensor(0).shape;
      final outShape = interpreter.getOutputTensor(0).shape;
      final expectedIn = [1, ModelConfig.inputSize, ModelConfig.inputSize, 3];
      if (inShape.join(',') != expectedIn.join(',') ||
          outShape.last != MoodLabel.values.length) {
        interpreter.close();
        throw StateError(
          'Model shape mismatch: input $inShape (want $expectedIn), '
          'output $outShape (want ${MoodLabel.values.length} classes)',
        );
      }

      _interpreter = interpreter;
      Logger.success('Model loaded: ${getModelInfo()}');
    } catch (e, stack) {
      Logger.error('Failed to load model', e, stack);
      rethrow;
    }
  }

  Future<MoodResult> predictMood(String imagePath) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('Model not initialized. Call initialize() first.');
    }

    final watch = Stopwatch()..start();
    final inTensor = interpreter.getInputTensor(0);
    final outTensor = interpreter.getOutputTensor(0);
    final classes = MoodLabel.values.length;

    final input = await preprocessImage(
      imagePath,
      ModelConfig.inputSize,
      asFloat: inTensor.type == TensorType.float32,
    );
    watch.reset(); // time the model only, not decoding

    final isFloatOut = outTensor.type == TensorType.float32;
    final output = [List<num>.filled(classes, isFloatOut ? 0.0 : 0)];
    interpreter.run(
      (input as List<num>).reshape([
        1,
        ModelConfig.inputSize,
        ModelConfig.inputSize,
        3,
      ]),
      output,
    );
    final inferenceMs = watch.elapsedMilliseconds;

    // Dequantize if needed, then make sure we have a probability distribution.
    final p = outTensor.params;
    final scores = [
      for (final v in output[0])
        isFloatOut || p.scale == 0 ? v.toDouble() : (v - p.zeroPoint) * p.scale,
    ];
    final probs = _toProbabilities(scores);

    var best = 0;
    for (var i = 1; i < classes; i++) {
      if (probs[i] > probs[best]) best = i;
    }
    Logger.inference(
      'Prediction: ${MoodLabel.values[best].name} '
      '(${(probs[best] * 100).toStringAsFixed(1)}%)',
      timeMs: inferenceMs,
    );

    return MoodResult(
      label: MoodLabel.values[best],
      confidence: probs[best],
      embedding: probs,
      timestamp: DateTime.now(),
      inferenceTimeMs: inferenceMs,
    );
  }

  /// Returns [scores] unchanged if already a distribution, else softmax.
  List<double> _toProbabilities(List<double> scores) {
    final sum = scores.fold<double>(0, (a, b) => a + b);
    if (scores.every((s) => s >= 0) && (sum - 1).abs() < 0.02) {
      return scores.map((s) => s / sum).toList();
    }
    final maxScore = scores.reduce(math.max);
    final exps = scores.map((s) => math.exp(s - maxScore)).toList();
    final total = exps.fold<double>(0, (a, b) => a + b);
    return exps.map((e) => e / total).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  Map<String, dynamic> getModelInfo() {
    final i = _interpreter;
    if (i == null) return {'error': 'Model not initialized'};
    return {
      'modelPath': ModelConfig.path,
      'inputShape': i.getInputTensor(0).shape,
      'outputShape': i.getOutputTensor(0).shape,
      'inputType': i.getInputTensor(0).type.toString(),
      'outputType': i.getOutputTensor(0).type.toString(),
    };
  }
}
