import 'dart:typed_data';

class TocEntry {
  final String title;
  final String filename;
  final String anchor;
  final int sectionIndex;

  TocEntry({
    required this.title,
    required this.filename,
    required this.anchor,
    required this.sectionIndex,
  });
}

class ImagePosition {
  final int start;
  final int end;
  final ImageInfo imageInfo;
  final String srcValue;

  ImagePosition({
    required this.start,
    required this.end,
    required this.imageInfo,
    required this.srcValue,
  });
}

class ImageInfo {
  final Uint8List data;
  final int width;
  final int height;

  ImageInfo({
    required this.data,
    required this.width,
    required this.height,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageInfo &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => data.length.hashCode ^ width.hashCode ^ height.hashCode;
}
