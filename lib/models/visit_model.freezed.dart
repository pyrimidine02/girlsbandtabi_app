// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Visit _$VisitFromJson(Map<String, dynamic> json) {
  return _Visit.fromJson(json);
}

/// @nodoc
mixin _$Visit {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Place get place => throw _privateConstructorUsedError;
  DateTime get visitDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  double? get distanceM => throw _privateConstructorUsedError;
  double? get accuracyM => throw _privateConstructorUsedError;
  String? get verificationMethod => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;

  /// Serializes this Visit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitCopyWith<Visit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitCopyWith<$Res> {
  factory $VisitCopyWith(Visit value, $Res Function(Visit) then) =
      _$VisitCopyWithImpl<$Res, Visit>;
  @useResult
  $Res call({
    String id,
    String userId,
    Place place,
    DateTime visitDate,
    String? notes,
    String? status,
    double? distanceM,
    double? accuracyM,
    String? verificationMethod,
    List<String> photoUrls,
  });

  $PlaceCopyWith<$Res> get place;
}

/// @nodoc
class _$VisitCopyWithImpl<$Res, $Val extends Visit>
    implements $VisitCopyWith<$Res> {
  _$VisitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? place = null,
    Object? visitDate = null,
    Object? notes = freezed,
    Object? status = freezed,
    Object? distanceM = freezed,
    Object? accuracyM = freezed,
    Object? verificationMethod = freezed,
    Object? photoUrls = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            place: null == place
                ? _value.place
                : place // ignore: cast_nullable_to_non_nullable
                      as Place,
            visitDate: null == visitDate
                ? _value.visitDate
                : visitDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            distanceM: freezed == distanceM
                ? _value.distanceM
                : distanceM // ignore: cast_nullable_to_non_nullable
                      as double?,
            accuracyM: freezed == accuracyM
                ? _value.accuracyM
                : accuracyM // ignore: cast_nullable_to_non_nullable
                      as double?,
            verificationMethod: freezed == verificationMethod
                ? _value.verificationMethod
                : verificationMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrls: null == photoUrls
                ? _value.photoUrls
                : photoUrls // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceCopyWith<$Res> get place {
    return $PlaceCopyWith<$Res>(_value.place, (value) {
      return _then(_value.copyWith(place: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VisitImplCopyWith<$Res> implements $VisitCopyWith<$Res> {
  factory _$$VisitImplCopyWith(
    _$VisitImpl value,
    $Res Function(_$VisitImpl) then,
  ) = __$$VisitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    Place place,
    DateTime visitDate,
    String? notes,
    String? status,
    double? distanceM,
    double? accuracyM,
    String? verificationMethod,
    List<String> photoUrls,
  });

  @override
  $PlaceCopyWith<$Res> get place;
}

/// @nodoc
class __$$VisitImplCopyWithImpl<$Res>
    extends _$VisitCopyWithImpl<$Res, _$VisitImpl>
    implements _$$VisitImplCopyWith<$Res> {
  __$$VisitImplCopyWithImpl(
    _$VisitImpl _value,
    $Res Function(_$VisitImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? place = null,
    Object? visitDate = null,
    Object? notes = freezed,
    Object? status = freezed,
    Object? distanceM = freezed,
    Object? accuracyM = freezed,
    Object? verificationMethod = freezed,
    Object? photoUrls = null,
  }) {
    return _then(
      _$VisitImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        place: null == place
            ? _value.place
            : place // ignore: cast_nullable_to_non_nullable
                  as Place,
        visitDate: null == visitDate
            ? _value.visitDate
            : visitDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        distanceM: freezed == distanceM
            ? _value.distanceM
            : distanceM // ignore: cast_nullable_to_non_nullable
                  as double?,
        accuracyM: freezed == accuracyM
            ? _value.accuracyM
            : accuracyM // ignore: cast_nullable_to_non_nullable
                  as double?,
        verificationMethod: freezed == verificationMethod
            ? _value.verificationMethod
            : verificationMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrls: null == photoUrls
            ? _value._photoUrls
            : photoUrls // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitImpl implements _Visit {
  const _$VisitImpl({
    required this.id,
    required this.userId,
    required this.place,
    required this.visitDate,
    this.notes,
    this.status,
    this.distanceM,
    this.accuracyM,
    this.verificationMethod,
    final List<String> photoUrls = const [],
  }) : _photoUrls = photoUrls;

  factory _$VisitImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final Place place;
  @override
  final DateTime visitDate;
  @override
  final String? notes;
  @override
  final String? status;
  @override
  final double? distanceM;
  @override
  final double? accuracyM;
  @override
  final String? verificationMethod;
  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  String toString() {
    return 'Visit(id: $id, userId: $userId, place: $place, visitDate: $visitDate, notes: $notes, status: $status, distanceM: $distanceM, accuracyM: $accuracyM, verificationMethod: $verificationMethod, photoUrls: $photoUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.place, place) || other.place == place) &&
            (identical(other.visitDate, visitDate) ||
                other.visitDate == visitDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.distanceM, distanceM) ||
                other.distanceM == distanceM) &&
            (identical(other.accuracyM, accuracyM) ||
                other.accuracyM == accuracyM) &&
            (identical(other.verificationMethod, verificationMethod) ||
                other.verificationMethod == verificationMethod) &&
            const DeepCollectionEquality().equals(
              other._photoUrls,
              _photoUrls,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    place,
    visitDate,
    notes,
    status,
    distanceM,
    accuracyM,
    verificationMethod,
    const DeepCollectionEquality().hash(_photoUrls),
  );

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitImplCopyWith<_$VisitImpl> get copyWith =>
      __$$VisitImplCopyWithImpl<_$VisitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitImplToJson(this);
  }
}

abstract class _Visit implements Visit {
  const factory _Visit({
    required final String id,
    required final String userId,
    required final Place place,
    required final DateTime visitDate,
    final String? notes,
    final String? status,
    final double? distanceM,
    final double? accuracyM,
    final String? verificationMethod,
    final List<String> photoUrls,
  }) = _$VisitImpl;

  factory _Visit.fromJson(Map<String, dynamic> json) = _$VisitImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  Place get place;
  @override
  DateTime get visitDate;
  @override
  String? get notes;
  @override
  String? get status;
  @override
  double? get distanceM;
  @override
  double? get accuracyM;
  @override
  String? get verificationMethod;
  @override
  List<String> get photoUrls;

  /// Create a copy of Visit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitImplCopyWith<_$VisitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VisitSummary _$VisitSummaryFromJson(Map<String, dynamic> json) {
  return _VisitSummary.fromJson(json);
}

/// @nodoc
mixin _$VisitSummary {
  String get placeId => throw _privateConstructorUsedError;
  int get totalVisits => throw _privateConstructorUsedError;
  DateTime? get firstVisit => throw _privateConstructorUsedError;
  DateTime? get lastVisit => throw _privateConstructorUsedError;
  int get userVisits => throw _privateConstructorUsedError;
  int? get uniqueSubjects => throw _privateConstructorUsedError;
  double? get avgAccuracyM => throw _privateConstructorUsedError;

  /// Serializes this VisitSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VisitSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VisitSummaryCopyWith<VisitSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VisitSummaryCopyWith<$Res> {
  factory $VisitSummaryCopyWith(
    VisitSummary value,
    $Res Function(VisitSummary) then,
  ) = _$VisitSummaryCopyWithImpl<$Res, VisitSummary>;
  @useResult
  $Res call({
    String placeId,
    int totalVisits,
    DateTime? firstVisit,
    DateTime? lastVisit,
    int userVisits,
    int? uniqueSubjects,
    double? avgAccuracyM,
  });
}

/// @nodoc
class _$VisitSummaryCopyWithImpl<$Res, $Val extends VisitSummary>
    implements $VisitSummaryCopyWith<$Res> {
  _$VisitSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VisitSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? totalVisits = null,
    Object? firstVisit = freezed,
    Object? lastVisit = freezed,
    Object? userVisits = null,
    Object? uniqueSubjects = freezed,
    Object? avgAccuracyM = freezed,
  }) {
    return _then(
      _value.copyWith(
            placeId: null == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as String,
            totalVisits: null == totalVisits
                ? _value.totalVisits
                : totalVisits // ignore: cast_nullable_to_non_nullable
                      as int,
            firstVisit: freezed == firstVisit
                ? _value.firstVisit
                : firstVisit // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastVisit: freezed == lastVisit
                ? _value.lastVisit
                : lastVisit // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            userVisits: null == userVisits
                ? _value.userVisits
                : userVisits // ignore: cast_nullable_to_non_nullable
                      as int,
            uniqueSubjects: freezed == uniqueSubjects
                ? _value.uniqueSubjects
                : uniqueSubjects // ignore: cast_nullable_to_non_nullable
                      as int?,
            avgAccuracyM: freezed == avgAccuracyM
                ? _value.avgAccuracyM
                : avgAccuracyM // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VisitSummaryImplCopyWith<$Res>
    implements $VisitSummaryCopyWith<$Res> {
  factory _$$VisitSummaryImplCopyWith(
    _$VisitSummaryImpl value,
    $Res Function(_$VisitSummaryImpl) then,
  ) = __$$VisitSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String placeId,
    int totalVisits,
    DateTime? firstVisit,
    DateTime? lastVisit,
    int userVisits,
    int? uniqueSubjects,
    double? avgAccuracyM,
  });
}

/// @nodoc
class __$$VisitSummaryImplCopyWithImpl<$Res>
    extends _$VisitSummaryCopyWithImpl<$Res, _$VisitSummaryImpl>
    implements _$$VisitSummaryImplCopyWith<$Res> {
  __$$VisitSummaryImplCopyWithImpl(
    _$VisitSummaryImpl _value,
    $Res Function(_$VisitSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VisitSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? totalVisits = null,
    Object? firstVisit = freezed,
    Object? lastVisit = freezed,
    Object? userVisits = null,
    Object? uniqueSubjects = freezed,
    Object? avgAccuracyM = freezed,
  }) {
    return _then(
      _$VisitSummaryImpl(
        placeId: null == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as String,
        totalVisits: null == totalVisits
            ? _value.totalVisits
            : totalVisits // ignore: cast_nullable_to_non_nullable
                  as int,
        firstVisit: freezed == firstVisit
            ? _value.firstVisit
            : firstVisit // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastVisit: freezed == lastVisit
            ? _value.lastVisit
            : lastVisit // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        userVisits: null == userVisits
            ? _value.userVisits
            : userVisits // ignore: cast_nullable_to_non_nullable
                  as int,
        uniqueSubjects: freezed == uniqueSubjects
            ? _value.uniqueSubjects
            : uniqueSubjects // ignore: cast_nullable_to_non_nullable
                  as int?,
        avgAccuracyM: freezed == avgAccuracyM
            ? _value.avgAccuracyM
            : avgAccuracyM // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VisitSummaryImpl implements _VisitSummary {
  const _$VisitSummaryImpl({
    required this.placeId,
    required this.totalVisits,
    this.firstVisit,
    this.lastVisit,
    this.userVisits = 0,
    this.uniqueSubjects,
    this.avgAccuracyM,
  });

  factory _$VisitSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VisitSummaryImplFromJson(json);

  @override
  final String placeId;
  @override
  final int totalVisits;
  @override
  final DateTime? firstVisit;
  @override
  final DateTime? lastVisit;
  @override
  @JsonKey()
  final int userVisits;
  @override
  final int? uniqueSubjects;
  @override
  final double? avgAccuracyM;

  @override
  String toString() {
    return 'VisitSummary(placeId: $placeId, totalVisits: $totalVisits, firstVisit: $firstVisit, lastVisit: $lastVisit, userVisits: $userVisits, uniqueSubjects: $uniqueSubjects, avgAccuracyM: $avgAccuracyM)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VisitSummaryImpl &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.totalVisits, totalVisits) ||
                other.totalVisits == totalVisits) &&
            (identical(other.firstVisit, firstVisit) ||
                other.firstVisit == firstVisit) &&
            (identical(other.lastVisit, lastVisit) ||
                other.lastVisit == lastVisit) &&
            (identical(other.userVisits, userVisits) ||
                other.userVisits == userVisits) &&
            (identical(other.uniqueSubjects, uniqueSubjects) ||
                other.uniqueSubjects == uniqueSubjects) &&
            (identical(other.avgAccuracyM, avgAccuracyM) ||
                other.avgAccuracyM == avgAccuracyM));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    placeId,
    totalVisits,
    firstVisit,
    lastVisit,
    userVisits,
    uniqueSubjects,
    avgAccuracyM,
  );

  /// Create a copy of VisitSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VisitSummaryImplCopyWith<_$VisitSummaryImpl> get copyWith =>
      __$$VisitSummaryImplCopyWithImpl<_$VisitSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VisitSummaryImplToJson(this);
  }
}

abstract class _VisitSummary implements VisitSummary {
  const factory _VisitSummary({
    required final String placeId,
    required final int totalVisits,
    final DateTime? firstVisit,
    final DateTime? lastVisit,
    final int userVisits,
    final int? uniqueSubjects,
    final double? avgAccuracyM,
  }) = _$VisitSummaryImpl;

  factory _VisitSummary.fromJson(Map<String, dynamic> json) =
      _$VisitSummaryImpl.fromJson;

  @override
  String get placeId;
  @override
  int get totalVisits;
  @override
  DateTime? get firstVisit;
  @override
  DateTime? get lastVisit;
  @override
  int get userVisits;
  @override
  int? get uniqueSubjects;
  @override
  double? get avgAccuracyM;

  /// Create a copy of VisitSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VisitSummaryImplCopyWith<_$VisitSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
