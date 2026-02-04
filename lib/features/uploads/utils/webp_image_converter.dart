/// EN: Convert images to WebP for upload.
/// KO: 업로드를 위해 이미지를 WebP로 변환합니다.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

class WebpImagePayload {
  const WebpImagePayload({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final Uint8List bytes;
  final String filename;
  final String contentType;
}

/// EN: Convert the image file to WebP. Best-effort keeps metadata.
/// KO: 이미지 파일을 WebP로 변환합니다. 메타데이터는 최대한 유지합니다.
Future<WebpImagePayload> convertToWebp({
  required String path,
  required String originalFilename,
  int maxWidth = 2048,
  int maxHeight = 2048,
  int quality = 85,
}) async {
  final ext = p.extension(originalFilename).toLowerCase();
  if (ext == '.webp') {
    final bytes = await File(path).readAsBytes();
    return WebpImagePayload(
      bytes: bytes,
      filename: originalFilename,
      contentType: 'image/webp',
    );
  }

  final useWebp = !(Platform.isIOS || Platform.isMacOS);
  final targetFormat = useWebp ? CompressFormat.webp : CompressFormat.jpeg;
  final targetExtension = useWebp ? '.webp' : '.jpg';
  final contentType = useWebp ? 'image/webp' : 'image/jpeg';

  final result = await FlutterImageCompress.compressWithFile(
    path,
    minWidth: maxWidth,
    minHeight: maxHeight,
    quality: quality,
    format: targetFormat,
    keepExif: true,
  );

  if (result == null || result.isEmpty) {
    throw StateError('Failed to convert image for upload.');
  }

  final filename =
      '${p.basenameWithoutExtension(originalFilename)}$targetExtension';
  return WebpImagePayload(
    bytes: Uint8List.fromList(result),
    filename: filename,
    contentType: contentType,
  );
}
