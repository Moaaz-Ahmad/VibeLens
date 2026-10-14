import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// JPEG bytes sized for upload to a cloud model (max side 768px, oriented).
/// Decoding/encoding runs off the UI isolate.
Future<Uint8List> encodeForUpload(String path) async {
  final bytes = await File(path).readAsBytes();
  return compute(_toJpeg, bytes);
}

Uint8List _toJpeg(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Failed to decode image');
  var image = img.bakeOrientation(decoded);
  if (image.width > 768 || image.height > 768) {
    image = image.width >= image.height
        ? img.copyResize(image, width: 768)
        : img.copyResize(image, height: 768);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 85));
}
