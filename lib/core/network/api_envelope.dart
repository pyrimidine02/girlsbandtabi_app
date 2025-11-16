/// Represents the metadata block returned alongside API responses.
class ApiResponseMetadata {
  const ApiResponseMetadata({
    this.requestId,
    this.timestamp,
    this.version,
    this.processingTimeMs,
    this.correlationId,
    this.serverId,
  });

  factory ApiResponseMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiResponseMetadata();
    return ApiResponseMetadata(
      requestId: json['requestId']?.toString(),
      timestamp: json['timestamp']?.toString(),
      version: json['version']?.toString(),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt(),
      correlationId: json['correlationId']?.toString(),
      serverId: json['serverId']?.toString(),
    );
  }

  final String? requestId;
  final String? timestamp;
  final String? version;
  final int? processingTimeMs;
  final String? correlationId;
  final String? serverId;

  Map<String, dynamic> toJson() => {
        if (requestId != null) 'requestId': requestId,
        if (timestamp != null) 'timestamp': timestamp,
        if (version != null) 'version': version,
        if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
        if (correlationId != null) 'correlationId': correlationId,
        if (serverId != null) 'serverId': serverId,
      };
}

/// Pagination descriptor following the backend specification.
class ApiPagination {
  const ApiPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.numberOfItems,
    required this.isFirst,
    required this.isLast,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ApiPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ApiPagination(
        currentPage: 0,
        pageSize: 0,
        totalPages: 0,
        totalItems: 0,
        numberOfItems: 0,
        isFirst: true,
        isLast: true,
        hasNext: false,
        hasPrevious: false,
      );
    }
    return ApiPagination(
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      numberOfItems: (json['numberOfItems'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
      isFirst: json['isFirst'] as bool? ?? json['first'] as bool? ?? false,
      isLast: json['isLast'] as bool? ?? json['last'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }

  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final int numberOfItems;
  final bool isFirst;
  final bool isLast;
  final bool hasNext;
  final bool hasPrevious;

  Map<String, dynamic> toJson() => {
        'currentPage': currentPage,
        'pageSize': pageSize,
        'totalPages': totalPages,
        'totalItems': totalItems,
        'numberOfItems': numberOfItems,
        'isFirst': isFirst,
        'isLast': isLast,
        'hasNext': hasNext,
        'hasPrevious': hasPrevious,
      };
}

/// Field-level validation error details.
class ApiFieldError {
  const ApiFieldError({
    required this.field,
    required this.message,
    this.rejectedValue,
    this.code,
  });

  factory ApiFieldError.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiFieldError(field: '', message: '');
    return ApiFieldError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      rejectedValue: json['rejectedValue'],
      code: json['code']?.toString(),
    );
  }

  final String field;
  final String message;
  final Object? rejectedValue;
  final String? code;
}

/// Structured error block when `success` is false.
class ApiErrorDetails {
  const ApiErrorDetails({
    this.code,
    this.message,
    this.details,
    this.type,
    this.instance,
    this.fieldErrors = const [],
    this.recoveryActions = const [],
    this.retryInfo,
    this.severity,
    this.operationId,
  });

  factory ApiErrorDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiErrorDetails();
    return ApiErrorDetails(
      code: json['code']?.toString(),
      message: json['message']?.toString(),
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : null,
      type: json['type']?.toString(),
      instance: json['instance']?.toString(),
      fieldErrors: (json['fieldErrors'] as List?)
              ?.map((e) => ApiFieldError.fromJson(e as Map<String, dynamic>?))
              .where((e) => e.field.isNotEmpty || e.message.isNotEmpty)
              .toList(growable: false) ??
          const <ApiFieldError>[],
      recoveryActions: (json['recoveryActions'] as List?)
              ?.map((e) => e?.toString())
              .whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      retryInfo: json['retryInfo'] is Map<String, dynamic>
          ? json['retryInfo'] as Map<String, dynamic>
          : null,
      severity: json['details'] is Map<String, dynamic>
          ? (json['details']['severity']?.toString())
          : null,
      operationId: json['details'] is Map<String, dynamic>
          ? json['details']['operationId']?.toString()
          : null,
    );
  }

  final String? code;
  final String? message;
  final Map<String, dynamic>? details;
  final String? type;
  final String? instance;
  final List<ApiFieldError> fieldErrors;
  final List<String> recoveryActions;
  final Map<String, dynamic>? retryInfo;
  final String? severity;
  final String? operationId;
}

/// Envelope returned by API client. Supports both standardized and raw responses.
class ApiEnvelope {
  ApiEnvelope({
    required this.statusCode,
    required this.data,
    this.success,
    this.metadata,
    this.pagination,
    this.error,
    this.raw,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    final success = json['success'] as bool?;
    final metadata = ApiResponseMetadata.fromJson(
      json['metadata'] as Map<String, dynamic>?,
    );
    final pagination = ApiPagination.fromJson(
      json['pagination'] as Map<String, dynamic>?,
    );
    final error = ApiErrorDetails.fromJson(
      json['error'] as Map<String, dynamic>?,
    );

    return ApiEnvelope(
      success: success,
      statusCode: statusCode,
      data: json['data'],
      metadata: metadata,
      pagination: json.containsKey('pagination') ? pagination : null,
      error: success == false ? error : null,
      raw: json,
    );
  }

  /// Builds a fallback envelope when the backend does not use the standardized format.
  factory ApiEnvelope.fallback({
    required int? statusCode,
    required dynamic data,
  }) {
    return ApiEnvelope(
      success: statusCode != null ? statusCode < 400 : null,
      statusCode: statusCode,
      data: data,
      metadata: null,
      pagination: null,
      error: null,
      raw: data,
    );
  }

  final bool? success;
  final int? statusCode;
  final dynamic data;
  final ApiResponseMetadata? metadata;
  final ApiPagination? pagination;
  final ApiErrorDetails? error;
  final dynamic raw;

  bool get isStandardFormat => success != null;

  bool get isSuccess {
    if (success != null) return success!;
    if (statusCode != null) return statusCode! >= 200 && statusCode! < 300;
    return true;
  }

  /// Ensures the envelope contains JSON object data and returns it.
  Map<String, dynamic> requireDataAsMap({String errorMessage = '데이터를 불러오지 못했습니다.'}) {
    final value = data;
    if (value is Map<String, dynamic>) return value;
    if (value == null) {
      throw StateError(errorMessage);
    }
    throw StateError('Unexpected data type: ${value.runtimeType}');
  }

  /// Ensures the envelope contains a list and returns a copy.
  List<dynamic> requireDataAsList({String errorMessage = '목록 데이터를 불러오지 못했습니다.'}) {
    final value = data;
    if (value is List) return List<dynamic>.from(value);
    if (value == null) {
      throw StateError(errorMessage);
    }
    throw StateError('Unexpected data type: ${value.runtimeType}');
  }

  /// Maps the underlying data into a strongly typed value.
  T mapData<T>(T Function(dynamic value) convert) {
    return convert(data);
  }

  ApiEnvelope copyWith({
    bool? success,
    int? statusCode,
    dynamic data,
    ApiResponseMetadata? metadata,
    ApiPagination? pagination,
    ApiErrorDetails? error,
    dynamic raw,
  }) {
    return ApiEnvelope(
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
      pagination: pagination ?? this.pagination,
      error: error ?? this.error,
      raw: raw ?? this.raw,
    );
  }
}
