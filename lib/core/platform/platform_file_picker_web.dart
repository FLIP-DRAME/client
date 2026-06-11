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

  final reader = web.FileReader();
  final completer = Completer<Uint8List>();
  reader.addEventListener(
    'load',
    (web.Event event) {
      final result = reader.result;
      if (result == null) {
        completer.completeError('File could not be read.');
        return;
      }
      completer.complete(Uint8List.view((result as JSArrayBuffer).toDart));
    }.toJS,
  );
  reader.addEventListener(
    'error',
    ((web.Event event) => completer.completeError('File read failed.')).toJS,
  );
  reader.readAsArrayBuffer(file);

  return PickedFile(name: file.name, bytes: await completer.future);
}
