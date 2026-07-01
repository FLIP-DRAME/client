import 'package:file_picker/file_picker.dart';

import 'picked_file.dart';

Future<List<PickedFile>> pickPlatformFilesImpl({
  required String accept,
  required bool allowMultiple,
}) async {
  final result = await FilePicker.pickFiles(
    type: accept == 'application/pdf' ? FileType.custom : FileType.image,
    allowedExtensions: accept == 'application/pdf' ? <String>['pdf'] : null,
    withData: true,
    allowMultiple: allowMultiple,
  );
  return (result?.files ?? const <PlatformFile>[])
      .where((file) => file.bytes != null)
      .map((file) => PickedFile(name: file.name, bytes: file.bytes!))
      .toList();
}
