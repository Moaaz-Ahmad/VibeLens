import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Decodes, orients and resizes an image into a flat NHWC RGB buffer.
///
/// Values stay in 0..255 (the model rescales internally, see ml/build_model.py).
/// Returns [Float32List] when [asFloat], otherwise [Uint8List]. Runs off the
/// UI isolate.
Future<TypedData> preprocessImage(
  String path,
  int size, {
  required bool asFloat,
}) async {
  final bytes = await File(path).readAsBytes();
  return compute(_toTensor, (bytes, size, asFloat));
}

TypedData _toTensor((Uint8List, int, bool) args) {
  final (bytes, size, asFloat) = args;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Failed to decode image');

  final resized = img.copyResize(
    img.bakeOrientation(decoded),
    width: size,
    height: size,
    interpolation: img.Interpolation.cubic,
  );

  final out =
      asFloat ? Float32List(size * size * 3) : Uint8List(size * size * 3);
  var i = 0;
  for (final p in resized) {
    for (final v in [p.r, p.g, p.b]) {
      out is Float32List
          ? out[i++] = v.toDouble()
          : (out as Uint8List)[i++] = v.toInt();
    }
  }
  return out;
}
