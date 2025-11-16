import 'package:dio/dio.dart';

import '../error/failure.dart';
import '../utils/result.dart';

/// EN: Abstract network client interface for dependency inversion
/// KO: 의존성 역전을 위한 추상 네트워크 클라이언트 인터페이스
abstract interface class NetworkClient {
  /// EN: Perform GET request
  /// KO: GET 요청 수행
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });

  /// EN: Perform POST request
  /// KO: POST 요청 수행
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });

  /// EN: Perform PUT request
  /// KO: PUT 요청 수행
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });

  /// EN: Perform PATCH request
  /// KO: PATCH 요청 수행
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });

  /// EN: Perform DELETE request
  /// KO: DELETE 요청 수행
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });

  /// EN: Download file
  /// KO: 파일 다운로드
  Future<Result<void>> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, String>? headers,
  });

  /// EN: Upload file
  /// KO: 파일 업로드
  Future<Result<T>> upload<T>(
    String path,
    FormData formData, {
    void Function(int, int)? onSendProgress,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  });
}

/// EN: Concrete implementation of NetworkClient using Dio
/// KO: Dio를 사용한 NetworkClient의 구체적 구현
class DioNetworkClient implements NetworkClient {
  DioNetworkClient({
    required this.dio,
    this.defaultDecoder,
  });

  /// EN: Dio instance for HTTP operations
  /// KO: HTTP 작업을 위한 Dio 인스턴스
  final Dio dio;

  /// EN: Default JSON decoder function
  /// KO: 기본 JSON 디코더 함수
  final Map<String, dynamic> Function(dynamic)? defaultDecoder;

  @override
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  @override
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  @override
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  @override
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  @override
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  @override
  Future<Result<void>> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, String>? headers,
  }) async {
    try {
      await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: _buildOptions(headers),
      );
      return const Success(null);
    } on DioException catch (e) {
      final failure = _handleDioException(e);
      return ResultFailure(failure);
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Result<T>> upload<T>(
    String path,
    FormData formData, {
    void Function(int, int)? onSendProgress,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? decoder,
  }) async {
    return _makeRequest<T>(
      () => dio.post<dynamic>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: _buildOptions(headers),
      ),
      decoder,
    );
  }

  /// EN: Helper method to build request options
  /// KO: 요청 옵션을 빌드하는 헬퍼 메서드
  Options _buildOptions(Map<String, String>? headers) {
    return Options(
      headers: headers,
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// EN: Generic method to make HTTP requests with error handling
  /// KO: 에러 처리와 함께 HTTP 요청을 만드는 제네릭 메서드
  Future<Result<T>> _makeRequest<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>)? decoder,
  ) async {
    try {
      final response = await request();
      return _handleResponse<T>(response, decoder);
    } on DioException catch (e) {
      final failure = _handleDioException(e);
      return ResultFailure(failure);
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected(e.toString()));
    }
  }

  /// EN: Handle successful HTTP response and decode data
  /// KO: 성공한 HTTP 응답 처리 및 데이터 디코딩
  Result<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? decoder,
  ) {
    final statusCode = response.statusCode ?? 0;

    // EN: Check if response is successful
    // KO: 응답이 성공적인지 확인
    if (statusCode < 200 || statusCode >= 300) {
      final failure = _createFailureFromStatusCode(statusCode, response.data);
      return ResultFailure(failure);
    }

    try {
      final data = response.data;

      // EN: Handle null/void responses
      // KO: null/void 응답 처리
      if (data == null) {
        return Success(null as T);
      }

      // EN: Return data as-is if type matches
      // KO: 타입이 일치하는 경우 데이터를 그대로 반환
      if (data is T) {
        return Success(data);
      }

      // EN: Use custom decoder if provided
      // KO: 제공된 경우 커스텀 디코더 사용
      if (decoder != null) {
        if (data is Map<String, dynamic>) {
          final normalized = _extractDataMap(data);
          final decodedData = decoder(normalized);
          return Success(decodedData);
        } else {
          return ResultFailure(
            const NetworkFailure(
              message: 'Invalid response format for custom decoder',
              code: 'INVALID_RESPONSE_FORMAT',
            ),
          );
        }
      }

      // EN: Use default decoder if available
      // KO: 사용 가능한 경우 기본 디코더 사용
      if (defaultDecoder != null && data != null) {
        final normalizedData = defaultDecoder!(data);
        return Success(normalizedData as T);
      }

      return ResultFailure(
        NetworkFailure(
          message: 'Unable to decode response data to type $T',
          code: 'DECODE_ERROR',
          data: {'responseType': data.runtimeType.toString()},
        ),
      );
    } catch (e) {
      return ResultFailure(
        NetworkFailure(
          message: 'Error decoding response: ${e.toString()}',
          code: 'DECODE_ERROR',
        ),
      );
    }
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> data) {
    final inner = data['data'];
    if (inner is Map<String, dynamic>) {
      return inner;
    }
    return data;
  }

  /// EN: Convert DioException to Failure
  /// KO: DioException을 Failure로 변환
  Failure _handleDioException(DioException exception) {
    final response = exception.response;
    final statusCode = response?.statusCode;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure.timeout();

      case DioExceptionType.connectionError:
        return NetworkFailure.connectionFailed();

      case DioExceptionType.badResponse:
        if (statusCode != null) {
          return _createFailureFromStatusCode(statusCode, response?.data);
        }
        return NetworkFailure.serverError(0);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkFailure(
          message: exception.message ?? 'Unknown network error',
          code: 'UNKNOWN_NETWORK_ERROR',
        );
    }
  }

  /// EN: Create appropriate failure based on HTTP status code
  /// KO: HTTP 상태 코드에 따른 적절한 실패 생성
  Failure _createFailureFromStatusCode(int statusCode, dynamic responseData) {
    switch (statusCode) {
      case 401:
        return NetworkFailure.unauthorized();
      case 403:
        return NetworkFailure.forbidden();
      case 404:
        return NetworkFailure.notFound();
      case >= 500:
        return NetworkFailure.serverError(statusCode);
      default:
        String message = 'Request failed with status $statusCode';
        
        // EN: Try to extract error message from response
        // KO: 응답에서 에러 메시지 추출 시도
        if (responseData is Map<String, dynamic>) {
          final errorMessage = responseData['message'] ?? 
                              responseData['error'] ?? 
                              responseData['detail'];
          if (errorMessage is String) {
            message = errorMessage;
          }
        }

        return NetworkFailure(
          message: message,
          code: 'HTTP_ERROR',
          statusCode: statusCode,
          data: {'responseData': responseData},
        );
    }
  }
}

/// EN: Configuration for network client setup
/// KO: 네트워크 클라이언트 설정을 위한 구성
class NetworkConfig {
  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers = const {},
    this.enableLogging = false,
  });

  /// EN: Base URL for all requests
  /// KO: 모든 요청의 기본 URL
  final String baseUrl;

  /// EN: Connection timeout duration
  /// KO: 연결 타임아웃 기간
  final Duration connectTimeout;

  /// EN: Receive timeout duration
  /// KO: 수신 타임아웃 기간
  final Duration receiveTimeout;

  /// EN: Send timeout duration
  /// KO: 송신 타임아웃 기간
  final Duration sendTimeout;

  /// EN: Default headers for all requests
  /// KO: 모든 요청의 기본 헤더
  final Map<String, String> headers;

  /// EN: Enable request/response logging
  /// KO: 요청/응답 로깅 활성화
  final bool enableLogging;
}
