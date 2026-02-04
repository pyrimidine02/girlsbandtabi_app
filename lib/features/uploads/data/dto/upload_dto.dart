/// EN: Upload DTOs for presigned URL, confirm, and info responses.
/// KO: presigned URL, 확인, 정보 응답을 위한 업로드 DTO.
library;

/// EN: Request to create a presigned upload URL.
/// KO: presigned 업로드 URL 생성 요청.
class CreateUploadUrlRequest {
  const CreateUploadUrlRequest({
    required this.filename,
    required this.contentType,
    required this.size,
  });

  final String filename;
  final String contentType;
  final int size;

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'contentType': contentType,
      'size': size,
    };
  }
}

/// EN: Response containing presigned URL for direct upload.
/// KO: 직접 업로드를 위한 presigned URL 응답.
class PresignedUrlResponse {
  const PresignedUrlResponse({
    required this.uploadId,
    required this.url,
    required this.headers,
  });

  final String uploadId;
  final String url;
  final Map<String, String> headers;

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      uploadId: json['uploadId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      headers: _stringMap(json['headers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'url': url,
      'headers': headers,
    };
  }
}

/// EN: Response after confirming an upload.
/// KO: 업로드 확인 후 응답.
class ConfirmUploadResponse {
  const ConfirmUploadResponse({
    required this.uploadId,
    required this.status,
  });

  final String uploadId;
  final String status;

  factory ConfirmUploadResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmUploadResponse(
      uploadId: json['uploadId'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'status': status,
    };
  }
}

/// EN: Upload info returned from list-my-uploads API.
/// KO: 내 업로드 목록 API에서 반환되는 업로드 정보.
class UploadInfoResponse {
  const UploadInfoResponse({
    required this.uploadId,
    required this.url,
    required this.filename,
    required this.isApproved,
  });

  final String uploadId;
  final String url;
  final String filename;
  final bool isApproved;

  factory UploadInfoResponse.fromJson(Map<String, dynamic> json) {
    return UploadInfoResponse(
      uploadId: json['uploadId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'url': url,
      'filename': filename,
      'isApproved': isApproved,
    };
  }
}

class ApproveUploadRequest {
  const ApproveUploadRequest({required this.isApproved});

  final bool isApproved;

  Map<String, dynamic> toJson() {
    return {'isApproved': isApproved};
  }
}

class ApproveUploadResponse {
  const ApproveUploadResponse({
    required this.uploadId,
    required this.isApproved,
  });

  final String uploadId;
  final bool isApproved;

  factory ApproveUploadResponse.fromJson(Map<String, dynamic> json) {
    return ApproveUploadResponse(
      uploadId: json['uploadId'] as String? ?? '',
      isApproved: json['isApproved'] as bool? ?? false,
    );
  }
}

Map<String, String> _stringMap(dynamic value) {
  if (value is Map) {
    return value.map(
      (key, val) => MapEntry(
        key.toString(),
        val?.toString() ?? '',
      ),
    );
  }
  return <String, String>{};
}
