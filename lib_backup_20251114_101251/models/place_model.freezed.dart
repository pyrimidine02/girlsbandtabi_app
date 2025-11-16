// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlaceSummary _$PlaceSummaryFromJson(Map<String, dynamic> json) {
  return _PlaceSummary.fromJson(json);
}

/// @nodoc
mixin _$PlaceSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<String> get types => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get thumbnailFilename => throw _privateConstructorUsedError;
  int? get thumbnailSize => throw _privateConstructorUsedError;

  /// Serializes this PlaceSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceSummaryCopyWith<PlaceSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceSummaryCopyWith<$Res> {
  factory $PlaceSummaryCopyWith(
    PlaceSummary value,
    $Res Function(PlaceSummary) then,
  ) = _$PlaceSummaryCopyWithImpl<$Res, PlaceSummary>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    List<String> types,
    double latitude,
    double longitude,
    String? thumbnailUrl,
    String? thumbnailFilename,
    int? thumbnailSize,
  });
}

/// @nodoc
class _$PlaceSummaryCopyWithImpl<$Res, $Val extends PlaceSummary>
    implements $PlaceSummaryCopyWith<$Res> {
  _$PlaceSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? types = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? thumbnailUrl = freezed,
    Object? thumbnailFilename = freezed,
    Object? thumbnailSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            types: null == types
                ? _value.types
                : types // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailFilename: freezed == thumbnailFilename
                ? _value.thumbnailFilename
                : thumbnailFilename // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailSize: freezed == thumbnailSize
                ? _value.thumbnailSize
                : thumbnailSize // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceSummaryImplCopyWith<$Res>
    implements $PlaceSummaryCopyWith<$Res> {
  factory _$$PlaceSummaryImplCopyWith(
    _$PlaceSummaryImpl value,
    $Res Function(_$PlaceSummaryImpl) then,
  ) = __$$PlaceSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    List<String> types,
    double latitude,
    double longitude,
    String? thumbnailUrl,
    String? thumbnailFilename,
    int? thumbnailSize,
  });
}

/// @nodoc
class __$$PlaceSummaryImplCopyWithImpl<$Res>
    extends _$PlaceSummaryCopyWithImpl<$Res, _$PlaceSummaryImpl>
    implements _$$PlaceSummaryImplCopyWith<$Res> {
  __$$PlaceSummaryImplCopyWithImpl(
    _$PlaceSummaryImpl _value,
    $Res Function(_$PlaceSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? types = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? thumbnailUrl = freezed,
    Object? thumbnailFilename = freezed,
    Object? thumbnailSize = freezed,
  }) {
    return _then(
      _$PlaceSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        types: null == types
            ? _value._types
            : types // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailFilename: freezed == thumbnailFilename
            ? _value.thumbnailFilename
            : thumbnailFilename // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailSize: freezed == thumbnailSize
            ? _value.thumbnailSize
            : thumbnailSize // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceSummaryImpl implements _PlaceSummary {
  const _$PlaceSummaryImpl({
    required this.id,
    required this.name,
    required this.type,
    required final List<String> types,
    required this.latitude,
    required this.longitude,
    this.thumbnailUrl,
    this.thumbnailFilename,
    this.thumbnailSize,
  }) : _types = types;

  factory _$PlaceSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  final List<String> _types;
  @override
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? thumbnailUrl;
  @override
  final String? thumbnailFilename;
  @override
  final int? thumbnailSize;

  @override
  String toString() {
    return 'PlaceSummary(id: $id, name: $name, type: $type, types: $types, latitude: $latitude, longitude: $longitude, thumbnailUrl: $thumbnailUrl, thumbnailFilename: $thumbnailFilename, thumbnailSize: $thumbnailSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.thumbnailFilename, thumbnailFilename) ||
                other.thumbnailFilename == thumbnailFilename) &&
            (identical(other.thumbnailSize, thumbnailSize) ||
                other.thumbnailSize == thumbnailSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    const DeepCollectionEquality().hash(_types),
    latitude,
    longitude,
    thumbnailUrl,
    thumbnailFilename,
    thumbnailSize,
  );

  /// Create a copy of PlaceSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceSummaryImplCopyWith<_$PlaceSummaryImpl> get copyWith =>
      __$$PlaceSummaryImplCopyWithImpl<_$PlaceSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceSummaryImplToJson(this);
  }
}

abstract class _PlaceSummary implements PlaceSummary {
  const factory _PlaceSummary({
    required final String id,
    required final String name,
    required final String type,
    required final List<String> types,
    required final double latitude,
    required final double longitude,
    final String? thumbnailUrl,
    final String? thumbnailFilename,
    final int? thumbnailSize,
  }) = _$PlaceSummaryImpl;

  factory _PlaceSummary.fromJson(Map<String, dynamic> json) =
      _$PlaceSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  List<String> get types;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get thumbnailUrl;
  @override
  String? get thumbnailFilename;
  @override
  int? get thumbnailSize;

  /// Create a copy of PlaceSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceSummaryImplCopyWith<_$PlaceSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  PlaceType get type => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double latitude,
    double longitude,
    PlaceType type,
    String? address,
    String? imageUrl,
    List<String> tags,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? type = null,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PlaceType,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
    _$PlaceImpl value,
    $Res Function(_$PlaceImpl) then,
  ) = __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    double latitude,
    double longitude,
    PlaceType type,
    String? address,
    String? imageUrl,
    List<String> tags,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
    _$PlaceImpl _value,
    $Res Function(_$PlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? type = null,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$PlaceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PlaceType,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceImpl implements _Place {
  const _$PlaceImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.address,
    this.imageUrl,
    final List<String> tags = const <String>[],
    this.createdAt,
  }) : _tags = tags;

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final PlaceType type;
  @override
  final String? address;
  @override
  final String? imageUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Place(id: $id, name: $name, description: $description, latitude: $latitude, longitude: $longitude, type: $type, address: $address, imageUrl: $imageUrl, tags: $tags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    latitude,
    longitude,
    type,
    address,
    imageUrl,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
  );

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(this);
  }
}

abstract class _Place implements Place {
  const factory _Place({
    required final String id,
    required final String name,
    required final String description,
    required final double latitude,
    required final double longitude,
    required final PlaceType type,
    final String? address,
    final String? imageUrl,
    final List<String> tags,
    final DateTime? createdAt,
  }) = _$PlaceImpl;

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  PlaceType get type;
  @override
  String? get address;
  @override
  String? get imageUrl;
  @override
  List<String> get tags;
  @override
  DateTime? get createdAt;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaceCreateRequest _$PlaceCreateRequestFromJson(Map<String, dynamic> json) {
  return _PlaceCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$PlaceCreateRequest {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  PlaceType get type => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this PlaceCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCreateRequestCopyWith<PlaceCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCreateRequestCopyWith<$Res> {
  factory $PlaceCreateRequestCopyWith(
    PlaceCreateRequest value,
    $Res Function(PlaceCreateRequest) then,
  ) = _$PlaceCreateRequestCopyWithImpl<$Res, PlaceCreateRequest>;
  @useResult
  $Res call({
    String name,
    String description,
    double latitude,
    double longitude,
    PlaceType type,
    String? address,
    String? imageUrl,
    List<String> tags,
  });
}

/// @nodoc
class _$PlaceCreateRequestCopyWithImpl<$Res, $Val extends PlaceCreateRequest>
    implements $PlaceCreateRequestCopyWith<$Res> {
  _$PlaceCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? type = null,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PlaceType,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceCreateRequestImplCopyWith<$Res>
    implements $PlaceCreateRequestCopyWith<$Res> {
  factory _$$PlaceCreateRequestImplCopyWith(
    _$PlaceCreateRequestImpl value,
    $Res Function(_$PlaceCreateRequestImpl) then,
  ) = __$$PlaceCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    double latitude,
    double longitude,
    PlaceType type,
    String? address,
    String? imageUrl,
    List<String> tags,
  });
}

/// @nodoc
class __$$PlaceCreateRequestImplCopyWithImpl<$Res>
    extends _$PlaceCreateRequestCopyWithImpl<$Res, _$PlaceCreateRequestImpl>
    implements _$$PlaceCreateRequestImplCopyWith<$Res> {
  __$$PlaceCreateRequestImplCopyWithImpl(
    _$PlaceCreateRequestImpl _value,
    $Res Function(_$PlaceCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? type = null,
    Object? address = freezed,
    Object? imageUrl = freezed,
    Object? tags = null,
  }) {
    return _then(
      _$PlaceCreateRequestImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PlaceType,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceCreateRequestImpl implements _PlaceCreateRequest {
  const _$PlaceCreateRequestImpl({
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.address,
    this.imageUrl,
    final List<String> tags = const <String>[],
  }) : _tags = tags;

  factory _$PlaceCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final PlaceType type;
  @override
  final String? address;
  @override
  final String? imageUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'PlaceCreateRequest(name: $name, description: $description, latitude: $latitude, longitude: $longitude, type: $type, address: $address, imageUrl: $imageUrl, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    latitude,
    longitude,
    type,
    address,
    imageUrl,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of PlaceCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceCreateRequestImplCopyWith<_$PlaceCreateRequestImpl> get copyWith =>
      __$$PlaceCreateRequestImplCopyWithImpl<_$PlaceCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceCreateRequestImplToJson(this);
  }
}

abstract class _PlaceCreateRequest implements PlaceCreateRequest {
  const factory _PlaceCreateRequest({
    required final String name,
    required final String description,
    required final double latitude,
    required final double longitude,
    required final PlaceType type,
    final String? address,
    final String? imageUrl,
    final List<String> tags,
  }) = _$PlaceCreateRequestImpl;

  factory _PlaceCreateRequest.fromJson(Map<String, dynamic> json) =
      _$PlaceCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  PlaceType get type;
  @override
  String? get address;
  @override
  String? get imageUrl;
  @override
  List<String> get tags;

  /// Create a copy of PlaceCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceCreateRequestImplCopyWith<_$PlaceCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginatedPlaceResponse _$PaginatedPlaceResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PaginatedPlaceResponse.fromJson(json);
}

/// @nodoc
mixin _$PaginatedPlaceResponse {
  List<PlaceSummary> get places => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;

  /// Serializes this PaginatedPlaceResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedPlaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedPlaceResponseCopyWith<PaginatedPlaceResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedPlaceResponseCopyWith<$Res> {
  factory $PaginatedPlaceResponseCopyWith(
    PaginatedPlaceResponse value,
    $Res Function(PaginatedPlaceResponse) then,
  ) = _$PaginatedPlaceResponseCopyWithImpl<$Res, PaginatedPlaceResponse>;
  @useResult
  $Res call({List<PlaceSummary> places, int total, int page, int limit});
}

/// @nodoc
class _$PaginatedPlaceResponseCopyWithImpl<
  $Res,
  $Val extends PaginatedPlaceResponse
>
    implements $PaginatedPlaceResponseCopyWith<$Res> {
  _$PaginatedPlaceResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedPlaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(
      _value.copyWith(
            places: null == places
                ? _value.places
                : places // ignore: cast_nullable_to_non_nullable
                      as List<PlaceSummary>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginatedPlaceResponseImplCopyWith<$Res>
    implements $PaginatedPlaceResponseCopyWith<$Res> {
  factory _$$PaginatedPlaceResponseImplCopyWith(
    _$PaginatedPlaceResponseImpl value,
    $Res Function(_$PaginatedPlaceResponseImpl) then,
  ) = __$$PaginatedPlaceResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PlaceSummary> places, int total, int page, int limit});
}

/// @nodoc
class __$$PaginatedPlaceResponseImplCopyWithImpl<$Res>
    extends
        _$PaginatedPlaceResponseCopyWithImpl<$Res, _$PaginatedPlaceResponseImpl>
    implements _$$PaginatedPlaceResponseImplCopyWith<$Res> {
  __$$PaginatedPlaceResponseImplCopyWithImpl(
    _$PaginatedPlaceResponseImpl _value,
    $Res Function(_$PaginatedPlaceResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedPlaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
  }) {
    return _then(
      _$PaginatedPlaceResponseImpl(
        places: null == places
            ? _value._places
            : places // ignore: cast_nullable_to_non_nullable
                  as List<PlaceSummary>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginatedPlaceResponseImpl implements _PaginatedPlaceResponse {
  const _$PaginatedPlaceResponseImpl({
    required final List<PlaceSummary> places,
    required this.total,
    required this.page,
    required this.limit,
  }) : _places = places;

  factory _$PaginatedPlaceResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginatedPlaceResponseImplFromJson(json);

  final List<PlaceSummary> _places;
  @override
  List<PlaceSummary> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;

  @override
  String toString() {
    return 'PaginatedPlaceResponse(places: $places, total: $total, page: $page, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedPlaceResponseImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_places),
    total,
    page,
    limit,
  );

  /// Create a copy of PaginatedPlaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedPlaceResponseImplCopyWith<_$PaginatedPlaceResponseImpl>
  get copyWith =>
      __$$PaginatedPlaceResponseImplCopyWithImpl<_$PaginatedPlaceResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginatedPlaceResponseImplToJson(this);
  }
}

abstract class _PaginatedPlaceResponse implements PaginatedPlaceResponse {
  const factory _PaginatedPlaceResponse({
    required final List<PlaceSummary> places,
    required final int total,
    required final int page,
    required final int limit,
  }) = _$PaginatedPlaceResponseImpl;

  factory _PaginatedPlaceResponse.fromJson(Map<String, dynamic> json) =
      _$PaginatedPlaceResponseImpl.fromJson;

  @override
  List<PlaceSummary> get places;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;

  /// Create a copy of PaginatedPlaceResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedPlaceResponseImplCopyWith<_$PaginatedPlaceResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

VerificationRequest _$VerificationRequestFromJson(Map<String, dynamic> json) {
  return _VerificationRequest.fromJson(json);
}

/// @nodoc
mixin _$VerificationRequest {
  String get placeId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this VerificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationRequestCopyWith<VerificationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationRequestCopyWith<$Res> {
  factory $VerificationRequestCopyWith(
    VerificationRequest value,
    $Res Function(VerificationRequest) then,
  ) = _$VerificationRequestCopyWithImpl<$Res, VerificationRequest>;
  @useResult
  $Res call({String placeId, double latitude, double longitude});
}

/// @nodoc
class _$VerificationRequestCopyWithImpl<$Res, $Val extends VerificationRequest>
    implements $VerificationRequestCopyWith<$Res> {
  _$VerificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _value.copyWith(
            placeId: null == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VerificationRequestImplCopyWith<$Res>
    implements $VerificationRequestCopyWith<$Res> {
  factory _$$VerificationRequestImplCopyWith(
    _$VerificationRequestImpl value,
    $Res Function(_$VerificationRequestImpl) then,
  ) = __$$VerificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String placeId, double latitude, double longitude});
}

/// @nodoc
class __$$VerificationRequestImplCopyWithImpl<$Res>
    extends _$VerificationRequestCopyWithImpl<$Res, _$VerificationRequestImpl>
    implements _$$VerificationRequestImplCopyWith<$Res> {
  __$$VerificationRequestImplCopyWithImpl(
    _$VerificationRequestImpl _value,
    $Res Function(_$VerificationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? placeId = null,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _$VerificationRequestImpl(
        placeId: null == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationRequestImpl implements _VerificationRequest {
  const _$VerificationRequestImpl({
    required this.placeId,
    required this.latitude,
    required this.longitude,
  });

  factory _$VerificationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationRequestImplFromJson(json);

  @override
  final String placeId;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'VerificationRequest(placeId: $placeId, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationRequestImpl &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, placeId, latitude, longitude);

  /// Create a copy of VerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationRequestImplCopyWith<_$VerificationRequestImpl> get copyWith =>
      __$$VerificationRequestImplCopyWithImpl<_$VerificationRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationRequestImplToJson(this);
  }
}

abstract class _VerificationRequest implements VerificationRequest {
  const factory _VerificationRequest({
    required final String placeId,
    required final double latitude,
    required final double longitude,
  }) = _$VerificationRequestImpl;

  factory _VerificationRequest.fromJson(Map<String, dynamic> json) =
      _$VerificationRequestImpl.fromJson;

  @override
  String get placeId;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of VerificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationRequestImplCopyWith<_$VerificationRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VerificationResponse _$VerificationResponseFromJson(Map<String, dynamic> json) {
  return _VerificationResponse.fromJson(json);
}

/// @nodoc
mixin _$VerificationResponse {
  bool get verified => throw _privateConstructorUsedError;
  double get distance => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this VerificationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationResponseCopyWith<VerificationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationResponseCopyWith<$Res> {
  factory $VerificationResponseCopyWith(
    VerificationResponse value,
    $Res Function(VerificationResponse) then,
  ) = _$VerificationResponseCopyWithImpl<$Res, VerificationResponse>;
  @useResult
  $Res call({bool verified, double distance, String? message});
}

/// @nodoc
class _$VerificationResponseCopyWithImpl<
  $Res,
  $Val extends VerificationResponse
>
    implements $VerificationResponseCopyWith<$Res> {
  _$VerificationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verified = null,
    Object? distance = null,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            verified: null == verified
                ? _value.verified
                : verified // ignore: cast_nullable_to_non_nullable
                      as bool,
            distance: null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$VerificationResponseImplCopyWith<$Res>
    implements $VerificationResponseCopyWith<$Res> {
  factory _$$VerificationResponseImplCopyWith(
    _$VerificationResponseImpl value,
    $Res Function(_$VerificationResponseImpl) then,
  ) = __$$VerificationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool verified, double distance, String? message});
}

/// @nodoc
class __$$VerificationResponseImplCopyWithImpl<$Res>
    extends _$VerificationResponseCopyWithImpl<$Res, _$VerificationResponseImpl>
    implements _$$VerificationResponseImplCopyWith<$Res> {
  __$$VerificationResponseImplCopyWithImpl(
    _$VerificationResponseImpl _value,
    $Res Function(_$VerificationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verified = null,
    Object? distance = null,
    Object? message = freezed,
  }) {
    return _then(
      _$VerificationResponseImpl(
        verified: null == verified
            ? _value.verified
            : verified // ignore: cast_nullable_to_non_nullable
                  as bool,
        distance: null == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$VerificationResponseImpl implements _VerificationResponse {
  const _$VerificationResponseImpl({
    required this.verified,
    required this.distance,
    this.message,
  });

  factory _$VerificationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationResponseImplFromJson(json);

  @override
  final bool verified;
  @override
  final double distance;
  @override
  final String? message;

  @override
  String toString() {
    return 'VerificationResponse(verified: $verified, distance: $distance, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationResponseImpl &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, verified, distance, message);

  /// Create a copy of VerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationResponseImplCopyWith<_$VerificationResponseImpl>
  get copyWith =>
      __$$VerificationResponseImplCopyWithImpl<_$VerificationResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationResponseImplToJson(this);
  }
}

abstract class _VerificationResponse implements VerificationResponse {
  const factory _VerificationResponse({
    required final bool verified,
    required final double distance,
    final String? message,
  }) = _$VerificationResponseImpl;

  factory _VerificationResponse.fromJson(Map<String, dynamic> json) =
      _$VerificationResponseImpl.fromJson;

  @override
  bool get verified;
  @override
  double get distance;
  @override
  String? get message;

  /// Create a copy of VerificationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationResponseImplCopyWith<_$VerificationResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
