class PickedFile {
  const PickedFile({
    required this.name,
    required this.bytes,
  });

  final String name;
  final List<int> bytes;

  String get extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }
}
