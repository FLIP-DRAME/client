import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'picked_file.dart';

Future<PickedFile?> pickPlatformFileImpl({required String accept}) async {
  final input =
      web.HTMLInputElement()
        ..type = 'file'
        ..accept = accept;
  input.click();
  await Future.any(<Future<void>>[
    input.onChange.first.then((_) {}),
    Future<void>.delayed(const Duration(minutes: 2)),
  ]);
  final file = input.files?.item(0);
  if (file == null) return null;

  final blob =
      accept.startsWith('image/') ? await _resizeLargeImage(file) : file;
  final bytes = await _readBlob(blob);

  return PickedFile(name: file.name, bytes: bytes);
}

Future<web.Blob> _resizeLargeImage(web.File file) async {
  const maxBytes = 8 * 1024 * 1024;
  const maxSide = 1920;
  if (file.size <= maxBytes || !file.type.startsWith('image/')) return file;

  try {
    final bitmap = await web.window.createImageBitmap(file).toDart;
    final longest = bitmap.width > bitmap.height ? bitmap.width : bitmap.height;
    if (longest <= maxSide) {
      bitmap.close();
      return file;
    }

    final scale = maxSide / longest;
    final width = (bitmap.width * scale).round();
    final height = (bitmap.height * scale).round();
    final canvas =
        web.HTMLCanvasElement()
          ..width = width
          ..height = height;
    final context = canvas.getContext('2d') as web.CanvasRenderingContext2D?;
    if (context == null) {
      bitmap.close();
      return file;
    }

    context.drawImage(bitmap, 0, 0, width, height);
    bitmap.close();
    return await _canvasToJpegBlob(canvas);
  } catch (_) {
    return file;
  }
}

Future<web.Blob> _canvasToJpegBlob(web.HTMLCanvasElement canvas) {
  final completer = Completer<web.Blob>();
  canvas.toBlob(
    ((web.Blob? blob) {
      if (blob == null) {
        completer.completeError('Image could not be resized.');
        return;
      }
      completer.complete(blob);
    }).toJS,
    'image/jpeg',
    0.82.toJS,
  );
  return completer.future;
}

Future<Uint8List> _readBlob(web.Blob blob) async {
  final buffer = await blob.arrayBuffer().toDart;
  return Uint8List.view(buffer.toDart);
}
