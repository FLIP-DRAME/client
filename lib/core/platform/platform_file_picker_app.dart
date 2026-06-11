import 'package:file_picker/file_picker.dart';

import 'picked_file.dart';

Future<PickedFile?> pickPlatformFileImpl({required String accept}) async {
  final result = await FilePicker.pickFiles(
    type: accept == 'application/pdf' ? FileType.custom : FileType.image,
    allowedExtensions: accept == 'application/pdf' ? <String>['pdf'] : null,
    withData: true,
  );
  final files = result?.files;
  final file = files == null || files.isEmpty ? null : files.first;
  final bytes = file?.bytes;
  if (file == null || bytes == null) return null;
  return PickedFile(name: file.name, bytes: bytes);
}
