import '../error/failure.dart';

/// EN: Result type for error handling without exceptions
/// KO: 예외 없는 에러 처리를 위한 Result 타입
sealed class Result<T> {
  const Result();

  /// EN: Check if result is successful
  /// KO: 결과가 성공인지 확인
  bool get isSuccess => this is Success<T>;

  /// EN: Check if result is failure
  /// KO: 결과가 실패인지 확인
  bool get isFailure => this is ResultFailure<T>;

  /// EN: Get success data (null if failure)
  /// KO: 성공 데이터 가져오기 (실패시 null)
  T? get data => switch (this) {
        Success(:final data) => data,
        ResultFailure() => null,
      };

  /// EN: Get failure (null if success)
  /// KO: 실패 가져오기 (성공시 null)
  Failure? get failure => switch (this) {
        Success() => null,
        ResultFailure(:final failure) => failure,
      };

  /// EN: Transform data if success, otherwise return failure
  /// KO: 성공시 데이터 변환, 실패시 실패 반환
  Result<U> map<U>(U Function(T data) transform) => switch (this) {
        Success(:final data) => Success(transform(data)),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// EN: Transform data asynchronously if success
  /// KO: 성공시 비동기적으로 데이터 변환
  Future<Result<U>> mapAsync<U>(Future<U> Function(T data) transform) async => switch (this) {
        Success(:final data) => Success(await transform(data)),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// EN: Chain operations that return Result
  /// KO: Result를 반환하는 연산 체인
  Result<U> flatMap<U>(Result<U> Function(T data) transform) => switch (this) {
        Success(:final data) => transform(data),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// EN: Chain async operations that return Result
  /// KO: Result를 반환하는 비동기 연산 체인
  Future<Result<U>> flatMapAsync<U>(Future<Result<U>> Function(T data) transform) async => switch (this) {
        Success(:final data) => await transform(data),
        ResultFailure(:final failure) => ResultFailure(failure),
      };

  /// EN: Execute callback on success
  /// KO: 성공시 콜백 실행
  Result<T> onSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback(data as T);
    }
    return this;
  }

  /// EN: Execute callback on failure
  /// KO: 실패시 콜백 실행
  Result<T> onFailure(void Function(Failure failure) callback) {
    if (this is ResultFailure<T>) {
      callback(failure!);
    }
    return this;
  }

  /// EN: Get data or throw exception
  /// KO: 데이터 가져오기 또는 예외 발생
  T getOrThrow() => switch (this) {
        Success(:final data) => data,
        ResultFailure(:final failure) => throw Exception(failure.message),
      };

  /// EN: Get data or return default value
  /// KO: 데이터 가져오기 또는 기본값 반환
  T getOrElse(T defaultValue) => switch (this) {
        Success(:final data) => data,
        ResultFailure() => defaultValue,
      };

  /// EN: Get data or compute default value
  /// KO: 데이터 가져오기 또는 기본값 계산
  T getOrElseCompute(T Function(Failure failure) compute) => switch (this) {
        Success(:final data) => data,
        ResultFailure(:final failure) => compute(failure),
      };
}

/// EN: Successful result containing data
/// KO: 데이터를 포함하는 성공 결과
final class Success<T> extends Result<T> {
  /// EN: The successful data
  /// KO: 성공한 데이터
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// EN: Failed result containing failure information
/// KO: 실패 정보를 포함하는 실패 결과
final class ResultFailure<T> extends Result<T> {
  /// EN: The failure information
  /// KO: 실패 정보
  @override
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  String toString() => 'Failure($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// EN: Extension methods for easier Result handling
/// KO: 더 쉬운 Result 처리를 위한 확장 메서드
extension ResultExtensions<T> on T {
  /// EN: Wrap value in Success
  /// KO: 값을 Success로 래핑
  Success<T> toSuccess() => Success(this);
}

extension FailureExtensions on Failure {
  /// EN: Wrap failure in ResultFailure
  /// KO: 실패를 ResultFailure로 래핑
  ResultFailure<T> toFailure<T>() => ResultFailure<T>(this);
}

/// EN: Utilities for working with Results
/// KO: Result 작업을 위한 유틸리티
class ResultUtils {
  const ResultUtils._();

  /// EN: Combine multiple Results into one
  /// KO: 여러 Result를 하나로 결합
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> values = [];
    for (final result in results) {
      switch (result) {
        case Success(:final data):
          values.add(data);
        case ResultFailure(:final failure):
          return ResultFailure(failure);
      }
    }
    return Success(values);
  }

  /// EN: Execute async operation and catch exceptions
  /// KO: 비동기 작업 실행 및 예외 포착
  static Future<Result<T>> tryAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected(e.toString()));
    }
  }

  /// EN: Execute sync operation and catch exceptions
  /// KO: 동기 작업 실행 및 예외 포착
  static Result<T> trySync<T>(T Function() operation) {
    try {
      final result = operation();
      return Success(result);
    } catch (e) {
      return ResultFailure(UnknownFailure.unexpected(e.toString()));
    }
  }
}