import 'platform_file_picker_app.dart'
    if (dart.library.js_interop) 'platform_file_picker_web.dart';
import 'picked_file.dart';

Future<PickedFile?> pickPlatformFile({required String accept}) {
  return pickPlatformFileImpl(accept: accept);
}
