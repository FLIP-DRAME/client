import 'platform_file_picker_app.dart'
    if (dart.library.js_interop) 'platform_file_picker_web.dart';
import 'picked_file.dart';

export 'picked_file.dart';

Future<PickedFile?> pickPlatformFile({required String accept}) {
  return pickPlatformFiles(accept: accept).then(
    (files) => files.isEmpty ? null : files.first,
  );
}

Future<List<PickedFile>> pickPlatformFiles({
  required String accept,
  bool allowMultiple = false,
}) {
  return pickPlatformFilesImpl(
    accept: accept,
    allowMultiple: allowMultiple,
  );
}
