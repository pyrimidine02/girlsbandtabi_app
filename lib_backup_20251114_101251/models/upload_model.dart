class UploadItem {
  UploadItem({
    required this.uploadId,
    this.filename,
    this.contentType,
    this.size,
    this.status,
    this.url,
    this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  final String uploadId;
  final String? filename;
  final String? contentType;
  final int? size;
  final String? status;
  final String? url;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  bool get isConfirmed {
    final normalized = status?.toUpperCase();
    if (normalized == 'CONFIRMED' || normalized == 'COMPLETED') {
      return true;
    }
    final metaStatus = metadata?['status']?.toString().toUpperCase();
    return metaStatus == 'CONFIRMED' || metaStatus == 'COMPLETED';
  }

  factory UploadItem.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return UploadItem(
      uploadId: map['uploadId']?.toString() ?? map['id']?.toString() ?? '',
      filename: map['filename']?.toString(),
      contentType: map['contentType']?.toString(),
      size: (map['size'] ?? map['fileSize']) is num
          ? (map['size'] ?? map['fileSize'] as num).toInt()
          : int.tryParse(map['size']?.toString() ?? ''),
      status: map['status']?.toString(),
      url: map['url']?.toString() ?? map['publicUrl']?.toString(),
      createdAt: parseDate(map['createdAt'] ?? map['uploadedAt']),
      expiresAt: parseDate(map['expiresAt']),
      metadata: map['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['metadata'] as Map<String, dynamic>)
          : null,
    );
  }
}

class UploadsPage {
  const UploadsPage({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  final List<UploadItem> items;
  final int page;
  final int size;
  final int total;
  final int? totalPages;
  final bool hasNext;
  final bool hasPrevious;
}

class PresignedUpload {
  PresignedUpload({
    required this.uploadId,
    required this.url,
    required this.fields,
    this.headers,
    this.expiresAt,
  });

  final String uploadId;
  final String url;
  final Map<String, dynamic> fields;
  final Map<String, dynamic>? headers;
  final DateTime? expiresAt;

  factory PresignedUpload.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return PresignedUpload(
      uploadId: map['uploadId']?.toString() ?? map['id']?.toString() ?? '',
      url: map['uploadUrl']?.toString() ?? map['url']?.toString() ?? '',
      fields: map['fields'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['fields'] as Map<String, dynamic>)
          : const {},
      headers: map['headers'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['headers'] as Map<String, dynamic>)
          : null,
      expiresAt: parseDate(map['expiresAt']),
    );
  }
}
