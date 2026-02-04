/// EN: Upload domain entity.
/// KO: 업로드 도메인 엔티티.
library;

import '../../data/dto/upload_dto.dart';

/// EN: Domain entity representing an uploaded file.
/// KO: 업로드된 파일을 나타내는 도메인 엔티티.
class UploadInfo {
  const UploadInfo({
    required this.uploadId,
    required this.url,
    required this.filename,
    required this.isApproved,
  });

  final String uploadId;
  final String url;
  final String filename;
  final bool isApproved;

  factory UploadInfo.fromDto(UploadInfoResponse dto) {
    return UploadInfo(
      uploadId: dto.uploadId,
      url: dto.url,
      filename: dto.filename,
      isApproved: dto.isApproved,
    );
  }
}
