// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VisitVerificationRequest _$VisitVerificationRequestFromJson(
  Map<String, dynamic> json,
) {
  return _VisitVerificationRequest.fromJson(json);
}

/// @nodoc
mixin _$VisitVerificationRequest {
  String get token => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lon => throw _privateConstructorUsedError;
  double get accuracyM => throw _privateConstructorUsedError;
  String get clientTs => throw _privateConstructorUsedError;

  /// Serializes this VisitVerificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitVerificationRequestCopyWith<VisitVerificationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitVerificationRequestCopyWith<$Res> {
  factory $VisitVerificationRequestCopyWith(
    VisitVerificationRequest value,
    $Res Function(VisitVerificationRequest) then,
  ) = _$VisitVerificationRequestCopyWithImpl<$Res, VisitVerificationRequest>;
  @useResult
  $Res call({
    String token,
    double lat,
    double lon,
    double accuracyM,
    String clientTs,
  });
}

/// @nodoc
class _$VisitVerificationRequestCopyWithImpl<
  $Res,
  $Val extends VisitVerificationRequest
>
    implements $VisitVerificationRequestCopyWith<$Res> {
  _$VisitVerificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? lat = null,
    Object? lon = null,
    Object? accuracyM = null,
    Object? clientTs = null,
  }) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lon: null == lon
                ? _value.lon
                : lon // ignore: cast_nullable_to_non_nullable
                      as double,
            accuracyM: null == accuracyM
                ? _value.accuracyM
                : accuracyM // ignore: cast_nullable_to_non_nullable
                      as double,
            clientTs: null == clientTs
                ? _value.clientTs
                : clientTs // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitVerificationRequestImplCopyWith<$Res>
    implements $VisitVerificationRequestCopyWith<$Res> {
  factory _$$VisitVerificationRequestImplCopyWith(
    _$VisitVerificationRequestImpl value,
    $Res Function(_$VisitVerificationRequestImpl) then,
  ) = __$$VisitVerificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String token,
    double lat,
    double lon,
    double accuracyM,
    String clientTs,
  });
}

/// @nodoc
class __$$VisitVerificationRequestImplCopyWithImpl<$Res>
    extends
        _$VisitVerificationRequestCopyWithImpl<
          $Res,
          _$VisitVerificationRequestImpl
        >
    implements _$$VisitVerificationRequestImplCopyWith<$Res> {
  __$$VisitVerificationRequestImplCopyWithImpl(
    _$VisitVerificationRequestImpl _value,
    $Res Function(_$VisitVerificationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? lat = null,
    Object? lon = null,
    Object? accuracyM = null,
    Object? clientTs = null,
  }) {
    return _then(
      _$VisitVerificationRequestImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lon: null == lon
            ? _value.lon
            : lon // ignore: cast_nullable_to_non_nullable
                  as double,
        accuracyM: null == accuracyM
            ? _value.accuracyM
            : accuracyM // ignore: cast_nullable_to_non_nullable
                  as double,
        clientTs: null == clientTs
            ? _value.clientTs
            : clientTs // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitVerificationRequestImpl implements _VisitVerificationRequest {
  const _$VisitVerificationRequestImpl({
    required this.token,
    required this.lat,
    required this.lon,
    required this.accuracyM,
    required this.clientTs,
  });

  factory _$VisitVerificationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitVerificationRequestImplFromJson(json);

  @override
  final String token;
  @override
  final double lat;
  @override
  final double lon;
  @override
  final double accuracyM;
  @override
  final String clientTs;

  @override
  String toString() {
    return 'VisitVerificationRequest(token: $token, lat: $lat, lon: $lon, accuracyM: $accuracyM, clientTs: $clientTs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitVerificationRequestImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lon, lon) || other.lon == lon) &&
            (identical(other.accuracyM, accuracyM) ||
                other.accuracyM == accuracyM) &&
            (identical(other.clientTs, clientTs) ||
                other.clientTs == clientTs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, token, lat, lon, accuracyM, clientTs);

  /// Create a copy of VisitVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitVerificationRequestImplCopyWith<_$VisitVerificationRequestImpl>
  get copyWith =>
      __$$VisitVerificationRequestImplCopyWithImpl<
        _$VisitVerificationRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitVerificationRequestImplToJson(this);
  }
}

abstract class _VisitVerificationRequest implements VisitVerificationRequest {
  const factory _VisitVerificationRequest({
    required final String token,
    required final double lat,
    required final double lon,
    required final double accuracyM,
    required final String clientTs,
  }) = _$VisitVerificationRequestImpl;

  factory _VisitVerificationRequest.fromJson(Map<String, dynamic> json) =
      _$VisitVerificationRequestImpl.fromJson;

  @override
  String get token;
  @override
  double get lat;
  @override
  double get lon;
  @override
  double get accuracyM;
  @override
  String get clientTs;

  /// Create a copy of VisitVerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitVerificationRequestImplCopyWith<_$VisitVerificationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

VisitVerificationResponse _$VisitVerificationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _VisitVerificationResponse.fromJson(json);
}

/// @nodoc
mixin _$VisitVerificationResponse {
  String get placeId => throw _privateConstructorUsedError;
  String get result => throw _privateConstructorUsedError;
  double? get distanceM => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this VisitVerificationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitVerificationResponseCopyWith<VisitVerificationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitVerificationResponseCopyWith<$Res> {
  factory $VisitVerificationResponseCopyWith(
    VisitVerificationResponse value,
    $Res Function(VisitVerificationResponse) then,
  ) = _$VisitVerificationResponseCopyWithImpl<$Res, VisitVerificationResponse>;
  @useResult
  $Res call({
    String placeId,
    String result,
    double? distanceM,
    String? message,
  });
}

/// @nodoc
class _$VisitVerificationResponseCopyWithImpl<
  $Res,
  $Val extends VisitVerificationResponse
>
    implements $VisitVerificationResponseCopyWith<$Res> {
  _$VisitVerificationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? result = null,
    Object? distanceM = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            placeId: null == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as String,
            result: null == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as String,
            distanceM: freezed == distanceM
                ? _value.distanceM
                : distanceM // ignore: cast_nullable_to_non_nullable
                      as double?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitVerificationResponseImplCopyWith<$Res>
    implements $VisitVerificationResponseCopyWith<$Res> {
  factory _$$VisitVerificationResponseImplCopyWith(
    _$VisitVerificationResponseImpl value,
    $Res Function(_$VisitVerificationResponseImpl) then,
  ) = __$$VisitVerificationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String placeId,
    String result,
    double? distanceM,
    String? message,
  });
}

/// @nodoc
class __$$VisitVerificationResponseImplCopyWithImpl<$Res>
    extends
        _$VisitVerificationResponseCopyWithImpl<
          $Res,
          _$VisitVerificationResponseImpl
        >
    implements _$$VisitVerificationResponseImplCopyWith<$Res> {
  __$$VisitVerificationResponseImplCopyWithImpl(
    _$VisitVerificationResponseImpl _value,
    $Res Function(_$VisitVerificationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? result = null,
    Object? distanceM = freezed,
    Object? message = freezed,
  }) {
    return _then(
      _$VisitVerificationResponseImpl(
        placeId: null == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as String,
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as String,
        distanceM: freezed == distanceM
            ? _value.distanceM
            : distanceM // ignore: cast_nullable_to_non_nullable
                  as double?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitVerificationResponseImpl implements _VisitVerificationResponse {
  const _$VisitVerificationResponseImpl({
    required this.placeId,
    required this.result,
    this.distanceM,
    this.message,
  });

  factory _$VisitVerificationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitVerificationResponseImplFromJson(json);

  @override
  final String placeId;
  @override
  final String result;
  @override
  final double? distanceM;
  @override
  final String? message;

  @override
  String toString() {
    return 'VisitVerificationResponse(placeId: $placeId, result: $result, distanceM: $distanceM, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitVerificationResponseImpl &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.distanceM, distanceM) ||
                other.distanceM == distanceM) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, placeId, result, distanceM, message);

  /// Create a copy of VisitVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitVerificationResponseImplCopyWith<_$VisitVerificationResponseImpl>
  get copyWith =>
      __$$VisitVerificationResponseImplCopyWithImpl<
        _$VisitVerificationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitVerificationResponseImplToJson(this);
  }
}

abstract class _VisitVerificationResponse implements VisitVerificationResponse {
  const factory _VisitVerificationResponse({
    required final String placeId,
    required final String result,
    final double? distanceM,
    final String? message,
  }) = _$VisitVerificationResponseImpl;

  factory _VisitVerificationResponse.fromJson(Map<String, dynamic> json) =
      _$VisitVerificationResponseImpl.fromJson;

  @override
  String get placeId;
  @override
  String get result;
  @override
  double? get distanceM;
  @override
  String? get message;

  /// Create a copy of VisitVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitVerificationResponseImplCopyWith<_$VisitVerificationResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LiveEventVerificationResponse _$LiveEventVerificationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _LiveEventVerificationResponse.fromJson(json);
}

/// @nodoc
mixin _$LiveEventVerificationResponse {
  String get liveEventId => throw _privateConstructorUsedError;
  String get result => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this LiveEventVerificationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveEventVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveEventVerificationResponseCopyWith<LiveEventVerificationResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventVerificationResponseCopyWith<$Res> {
  factory $LiveEventVerificationResponseCopyWith(
    LiveEventVerificationResponse value,
    $Res Function(LiveEventVerificationResponse) then,
  ) =
      _$LiveEventVerificationResponseCopyWithImpl<
        $Res,
        LiveEventVerificationResponse
      >;
  @useResult
  $Res call({String liveEventId, String result, String? message});
}

/// @nodoc
class _$LiveEventVerificationResponseCopyWithImpl<
  $Res,
  $Val extends LiveEventVerificationResponse
>
    implements $LiveEventVerificationResponseCopyWith<$Res> {
  _$LiveEventVerificationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveEventVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liveEventId = null,
    Object? result = null,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            liveEventId: null == liveEventId
                ? _value.liveEventId
                : liveEventId // ignore: cast_nullable_to_non_nullable
                      as String,
            result: null == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveEventVerificationResponseImplCopyWith<$Res>
    implements $LiveEventVerificationResponseCopyWith<$Res> {
  factory _$$LiveEventVerificationResponseImplCopyWith(
    _$LiveEventVerificationResponseImpl value,
    $Res Function(_$LiveEventVerificationResponseImpl) then,
  ) = __$$LiveEventVerificationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String liveEventId, String result, String? message});
}

/// @nodoc
class __$$LiveEventVerificationResponseImplCopyWithImpl<$Res>
    extends
        _$LiveEventVerificationResponseCopyWithImpl<
          $Res,
          _$LiveEventVerificationResponseImpl
        >
    implements _$$LiveEventVerificationResponseImplCopyWith<$Res> {
  __$$LiveEventVerificationResponseImplCopyWithImpl(
    _$LiveEventVerificationResponseImpl _value,
    $Res Function(_$LiveEventVerificationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveEventVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? liveEventId = null,
    Object? result = null,
    Object? message = freezed,
  }) {
    return _then(
      _$LiveEventVerificationResponseImpl(
        liveEventId: null == liveEventId
            ? _value.liveEventId
            : liveEventId // ignore: cast_nullable_to_non_nullable
                  as String,
        result: null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveEventVerificationResponseImpl
    implements _LiveEventVerificationResponse {
  const _$LiveEventVerificationResponseImpl({
    required this.liveEventId,
    required this.result,
    this.message,
  });

  factory _$LiveEventVerificationResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$LiveEventVerificationResponseImplFromJson(json);

  @override
  final String liveEventId;
  @override
  final String result;
  @override
  final String? message;

  @override
  String toString() {
    return 'LiveEventVerificationResponse(liveEventId: $liveEventId, result: $result, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventVerificationResponseImpl &&
            (identical(other.liveEventId, liveEventId) ||
                other.liveEventId == liveEventId) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, liveEventId, result, message);

  /// Create a copy of LiveEventVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventVerificationResponseImplCopyWith<
    _$LiveEventVerificationResponseImpl
  >
  get copyWith =>
      __$$LiveEventVerificationResponseImplCopyWithImpl<
        _$LiveEventVerificationResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveEventVerificationResponseImplToJson(this);
  }
}

abstract class _LiveEventVerificationResponse
    implements LiveEventVerificationResponse {
  const factory _LiveEventVerificationResponse({
    required final String liveEventId,
    required final String result,
    final String? message,
  }) = _$LiveEventVerificationResponseImpl;

  factory _LiveEventVerificationResponse.fromJson(Map<String, dynamic> json) =
      _$LiveEventVerificationResponseImpl.fromJson;

  @override
  String get liveEventId;
  @override
  String get result;
  @override
  String? get message;

  /// Create a copy of LiveEventVerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveEventVerificationResponseImplCopyWith<
    _$LiveEventVerificationResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
