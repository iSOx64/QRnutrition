import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:qr_flutter/qr_flutter.dart';

String generateQrValue(String productId) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'QR-$productId-$timestamp';
}

Future<Uint8List> generateQrPngBytes(
  String value, {
  double size = 1024,
  double padding = 48,
}) async {
  final painter = QrPainter(
    data: value,
    version: QrVersions.auto,
    gapless: false,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Color(0xFF111111),
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Color(0xFF111111),
    ),
  );

  final qrByteData = await painter.toImageData(
    size,
    format: ImageByteFormat.png,
  );
  if (qrByteData == null) {
    throw StateError('QR rendering failed');
  }

  final qrImage =
      await _decodeImageFromList(qrByteData.buffer.asUint8List());
  final outputSize = size + (padding * 2);
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final background = Paint()..color = const Color(0xFFFFFFFF);

  canvas.drawRect(
    Rect.fromLTWH(0, 0, outputSize, outputSize),
    background,
  );
  final dstRect = Rect.fromLTWH(padding, padding, size, size);
  final srcRect =
      Rect.fromLTWH(0, 0, qrImage.width.toDouble(), qrImage.height.toDouble());
  canvas.drawImageRect(qrImage, srcRect, dstRect, Paint());
  final picture = recorder.endRecording();
  final image =
      await picture.toImage(outputSize.toInt(), outputSize.toInt());
  final finalByteData =
      await image.toByteData(format: ImageByteFormat.png);
  if (finalByteData == null) {
    throw StateError('QR rendering failed');
  }
  return finalByteData.buffer.asUint8List();
}

Future<Image> _decodeImageFromList(Uint8List bytes) {
  final completer = Completer<Image>();
  decodeImageFromList(bytes, (image) => completer.complete(image));
  return completer.future;
}
