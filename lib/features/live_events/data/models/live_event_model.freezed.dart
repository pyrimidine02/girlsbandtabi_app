// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LiveEventModel _$LiveEventModelFromJson(Map<String, dynamic> json) {
  return _LiveEventModel.fromJson(json);
}

/// @nodoc
mixin _$LiveEventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  DateTime get eventDate => throw _privateConstructorUsedError;
  String? get venue => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  List<LiveEventUnitModel> get units => throw _privateConstructorUsedError;
  List<LiveEventBandModel> get bands => throw _privateConstructorUsedError;
  List<LiveEventPhotoModel> get photos => throw _privateConstructorUsedError;
  @JsonKey(name: 'ticket_url')
  String? get ticketUrl => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  LiveEventStatus get status => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'attendee_count')
  int get attendeeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LiveEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveEventModelCopyWith<LiveEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventModelCopyWith<$Res> {
  factory $LiveEventModelCopyWith(
    LiveEventModel value,
    $Res Function(LiveEventModel) then,
  ) = _$LiveEventModelCopyWithImpl<$Res, LiveEventModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    @JsonKey(name: 'event_date') DateTime eventDate,
    String? venue,
    String? address,
    double? latitude,
    double? longitude,
    List<LiveEventUnitModel> units,
    List<LiveEventBandModel> bands,
    List<LiveEventPhotoModel> photos,
    @JsonKey(name: 'ticket_url') String? ticketUrl,
    String? price,
    LiveEventStatus status,
    List<String> tags,
    @JsonKey(name: 'is_favorite') bool isFavorite,
    @JsonKey(name: 'attendee_count') int attendeeCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$LiveEventModelCopyWithImpl<$Res, $Val extends LiveEventModel>
    implements $LiveEventModelCopyWith<$Res> {
  _$LiveEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventDate = null,
    Object? venue = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? units = null,
    Object? bands = null,
    Object? photos = null,
    Object? ticketUrl = freezed,
    Object? price = freezed,
    Object? status = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? attendeeCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            eventDate: null == eventDate
                ? _value.eventDate
                : eventDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            venue: freezed == venue
                ? _value.venue
                : venue // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            units: null == units
                ? _value.units
                : units // ignore: cast_nullable_to_non_nullable
                      as List<LiveEventUnitModel>,
            bands: null == bands
                ? _value.bands
                : bands // ignore: cast_nullable_to_non_nullable
                      as List<LiveEventBandModel>,
            photos: null == photos
                ? _value.photos
                : photos // ignore: cast_nullable_to_non_nullable
                      as List<LiveEventPhotoModel>,
            ticketUrl: freezed == ticketUrl
                ? _value.ticketUrl
                : ticketUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LiveEventStatus,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isFavorite: null == isFavorite
                ? _value.isFavorite
                : isFavorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            attendeeCount: null == attendeeCount
                ? _value.attendeeCount
                : attendeeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveEventModelImplCopyWith<$Res>
    implements $LiveEventModelCopyWith<$Res> {
  factory _$$LiveEventModelImplCopyWith(
    _$LiveEventModelImpl value,
    $Res Function(_$LiveEventModelImpl) then,
  ) = __$$LiveEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    @JsonKey(name: 'event_date') DateTime eventDate,
    String? venue,
    String? address,
    double? latitude,
    double? longitude,
    List<LiveEventUnitModel> units,
    List<LiveEventBandModel> bands,
    List<LiveEventPhotoModel> photos,
    @JsonKey(name: 'ticket_url') String? ticketUrl,
    String? price,
    LiveEventStatus status,
    List<String> tags,
    @JsonKey(name: 'is_favorite') bool isFavorite,
    @JsonKey(name: 'attendee_count') int attendeeCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$LiveEventModelImplCopyWithImpl<$Res>
    extends _$LiveEventModelCopyWithImpl<$Res, _$LiveEventModelImpl>
    implements _$$LiveEventModelImplCopyWith<$Res> {
  __$$LiveEventModelImplCopyWithImpl(
    _$LiveEventModelImpl _value,
    $Res Function(_$LiveEventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? eventDate = null,
    Object? venue = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? units = null,
    Object? bands = null,
    Object? photos = null,
    Object? ticketUrl = freezed,
    Object? price = freezed,
    Object? status = null,
    Object? tags = null,
    Object? isFavorite = null,
    Object? attendeeCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$LiveEventModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        eventDate: null == eventDate
            ? _value.eventDate
            : eventDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        venue: freezed == venue
            ? _value.venue
            : venue // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        units: null == units
            ? _value._units
            : units // ignore: cast_nullable_to_non_nullable
                  as List<LiveEventUnitModel>,
        bands: null == bands
            ? _value._bands
            : bands // ignore: cast_nullable_to_non_nullable
                  as List<LiveEventBandModel>,
        photos: null == photos
            ? _value._photos
            : photos // ignore: cast_nullable_to_non_nullable
                  as List<LiveEventPhotoModel>,
        ticketUrl: freezed == ticketUrl
            ? _value.ticketUrl
            : ticketUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LiveEventStatus,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isFavorite: null == isFavorite
            ? _value.isFavorite
            : isFavorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        attendeeCount: null == attendeeCount
            ? _value.attendeeCount
            : attendeeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveEventModelImpl implements _LiveEventModel {
  const _$LiveEventModelImpl({
    required this.id,
    required this.title,
    required this.description,
    @JsonKey(name: 'event_date') required this.eventDate,
    this.venue,
    this.address,
    this.latitude,
    this.longitude,
    final List<LiveEventUnitModel> units = const [],
    final List<LiveEventBandModel> bands = const [],
    final List<LiveEventPhotoModel> photos = const [],
    @JsonKey(name: 'ticket_url') this.ticketUrl,
    this.price,
    this.status = LiveEventStatus.scheduled,
    final List<String> tags = const [],
    @JsonKey(name: 'is_favorite') this.isFavorite = false,
    @JsonKey(name: 'attendee_count') this.attendeeCount = 0,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _units = units,
       _bands = bands,
       _photos = photos,
       _tags = tags;

  factory _$LiveEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  @override
  final String? venue;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  final List<LiveEventUnitModel> _units;
  @override
  @JsonKey()
  List<LiveEventUnitModel> get units {
    if (_units is EqualUnmodifiableListView) return _units;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_units);
  }

  final List<LiveEventBandModel> _bands;
  @override
  @JsonKey()
  List<LiveEventBandModel> get bands {
    if (_bands is EqualUnmodifiableListView) return _bands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bands);
  }

  final List<LiveEventPhotoModel> _photos;
  @override
  @JsonKey()
  List<LiveEventPhotoModel> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  @JsonKey(name: 'ticket_url')
  final String? ticketUrl;
  @override
  final String? price;
  @override
  @JsonKey()
  final LiveEventStatus status;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  @JsonKey(name: 'attendee_count')
  final int attendeeCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LiveEventModel(id: $id, title: $title, description: $description, eventDate: $eventDate, venue: $venue, address: $address, latitude: $latitude, longitude: $longitude, units: $units, bands: $bands, photos: $photos, ticketUrl: $ticketUrl, price: $price, status: $status, tags: $tags, isFavorite: $isFavorite, attendeeCount: $attendeeCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._units, _units) &&
            const DeepCollectionEquality().equals(other._bands, _bands) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.ticketUrl, ticketUrl) ||
                other.ticketUrl == ticketUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.attendeeCount, attendeeCount) ||
                other.attendeeCount == attendeeCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    eventDate,
    venue,
    address,
    latitude,
    longitude,
    const DeepCollectionEquality().hash(_units),
    const DeepCollectionEquality().hash(_bands),
    const DeepCollectionEquality().hash(_photos),
    ticketUrl,
    price,
    status,
    const DeepCollectionEquality().hash(_tags),
    isFavorite,
    attendeeCount,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of LiveEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventModelImplCopyWith<_$LiveEventModelImpl> get copyWith =>
      __$$LiveEventModelImplCopyWithImpl<_$LiveEventModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveEventModelImplToJson(this);
  }
}

abstract class _LiveEventModel implements LiveEventModel {
  const factory _LiveEventModel({
    required final String id,
    required final String title,
    required final String description,
    @JsonKey(name: 'event_date') required final DateTime eventDate,
    final String? venue,
    final String? address,
    final double? latitude,
    final double? longitude,
    final List<LiveEventUnitModel> units,
    final List<LiveEventBandModel> bands,
    final List<LiveEventPhotoModel> photos,
    @JsonKey(name: 'ticket_url') final String? ticketUrl,
    final String? price,
    final LiveEventStatus status,
    final List<String> tags,
    @JsonKey(name: 'is_favorite') final bool isFavorite,
    @JsonKey(name: 'attendee_count') final int attendeeCount,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$LiveEventModelImpl;

  factory _LiveEventModel.fromJson(Map<String, dynamic> json) =
      _$LiveEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'event_date')
  DateTime get eventDate;
  @override
  String? get venue;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  List<LiveEventUnitModel> get units;
  @override
  List<LiveEventBandModel> get bands;
  @override
  List<LiveEventPhotoModel> get photos;
  @override
  @JsonKey(name: 'ticket_url')
  String? get ticketUrl;
  @override
  String? get price;
  @override
  LiveEventStatus get status;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  @JsonKey(name: 'attendee_count')
  int get attendeeCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of LiveEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveEventModelImplCopyWith<_$LiveEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveEventUnitModel _$LiveEventUnitModelFromJson(Map<String, dynamic> json) {
  return _LiveEventUnitModel.fromJson(json);
}

/// @nodoc
mixin _$LiveEventUnitModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this LiveEventUnitModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveEventUnitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveEventUnitModelCopyWith<LiveEventUnitModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventUnitModelCopyWith<$Res> {
  factory $LiveEventUnitModelCopyWith(
    LiveEventUnitModel value,
    $Res Function(LiveEventUnitModel) then,
  ) = _$LiveEventUnitModelCopyWithImpl<$Res, LiveEventUnitModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  });
}

/// @nodoc
class _$LiveEventUnitModelCopyWithImpl<$Res, $Val extends LiveEventUnitModel>
    implements $LiveEventUnitModelCopyWith<$Res> {
  _$LiveEventUnitModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveEventUnitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveEventUnitModelImplCopyWith<$Res>
    implements $LiveEventUnitModelCopyWith<$Res> {
  factory _$$LiveEventUnitModelImplCopyWith(
    _$LiveEventUnitModelImpl value,
    $Res Function(_$LiveEventUnitModelImpl) then,
  ) = __$$LiveEventUnitModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  });
}

/// @nodoc
class __$$LiveEventUnitModelImplCopyWithImpl<$Res>
    extends _$LiveEventUnitModelCopyWithImpl<$Res, _$LiveEventUnitModelImpl>
    implements _$$LiveEventUnitModelImplCopyWith<$Res> {
  __$$LiveEventUnitModelImplCopyWithImpl(
    _$LiveEventUnitModelImpl _value,
    $Res Function(_$LiveEventUnitModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveEventUnitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(
      _$LiveEventUnitModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveEventUnitModelImpl implements _LiveEventUnitModel {
  const _$LiveEventUnitModelImpl({
    required this.id,
    required this.name,
    this.description,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
  });

  factory _$LiveEventUnitModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveEventUnitModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @override
  String toString() {
    return 'LiveEventUnitModel(id: $id, name: $name, description: $description, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventUnitModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, avatarUrl);

  /// Create a copy of LiveEventUnitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventUnitModelImplCopyWith<_$LiveEventUnitModelImpl> get copyWith =>
      __$$LiveEventUnitModelImplCopyWithImpl<_$LiveEventUnitModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveEventUnitModelImplToJson(this);
  }
}

abstract class _LiveEventUnitModel implements LiveEventUnitModel {
  const factory _LiveEventUnitModel({
    required final String id,
    required final String name,
    final String? description,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
  }) = _$LiveEventUnitModelImpl;

  factory _LiveEventUnitModel.fromJson(Map<String, dynamic> json) =
      _$LiveEventUnitModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// Create a copy of LiveEventUnitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveEventUnitModelImplCopyWith<_$LiveEventUnitModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveEventBandModel _$LiveEventBandModelFromJson(Map<String, dynamic> json) {
  return _LiveEventBandModel.fromJson(json);
}

/// @nodoc
mixin _$LiveEventBandModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'set_time')
  DateTime? get setTime => throw _privateConstructorUsedError;

  /// Serializes this LiveEventBandModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveEventBandModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveEventBandModelCopyWith<LiveEventBandModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventBandModelCopyWith<$Res> {
  factory $LiveEventBandModelCopyWith(
    LiveEventBandModel value,
    $Res Function(LiveEventBandModel) then,
  ) = _$LiveEventBandModelCopyWithImpl<$Res, LiveEventBandModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'set_time') DateTime? setTime,
  });
}

/// @nodoc
class _$LiveEventBandModelCopyWithImpl<$Res, $Val extends LiveEventBandModel>
    implements $LiveEventBandModelCopyWith<$Res> {
  _$LiveEventBandModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveEventBandModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? setTime = freezed,
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
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            setTime: freezed == setTime
                ? _value.setTime
                : setTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveEventBandModelImplCopyWith<$Res>
    implements $LiveEventBandModelCopyWith<$Res> {
  factory _$$LiveEventBandModelImplCopyWith(
    _$LiveEventBandModelImpl value,
    $Res Function(_$LiveEventBandModelImpl) then,
  ) = __$$LiveEventBandModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'set_time') DateTime? setTime,
  });
}

/// @nodoc
class __$$LiveEventBandModelImplCopyWithImpl<$Res>
    extends _$LiveEventBandModelCopyWithImpl<$Res, _$LiveEventBandModelImpl>
    implements _$$LiveEventBandModelImplCopyWith<$Res> {
  __$$LiveEventBandModelImplCopyWithImpl(
    _$LiveEventBandModelImpl _value,
    $Res Function(_$LiveEventBandModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveEventBandModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? avatarUrl = freezed,
    Object? setTime = freezed,
  }) {
    return _then(
      _$LiveEventBandModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        setTime: freezed == setTime
            ? _value.setTime
            : setTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveEventBandModelImpl implements _LiveEventBandModel {
  const _$LiveEventBandModelImpl({
    required this.id,
    required this.name,
    this.description,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    @JsonKey(name: 'set_time') this.setTime,
  });

  factory _$LiveEventBandModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveEventBandModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'set_time')
  final DateTime? setTime;

  @override
  String toString() {
    return 'LiveEventBandModel(id: $id, name: $name, description: $description, avatarUrl: $avatarUrl, setTime: $setTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventBandModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.setTime, setTime) || other.setTime == setTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, avatarUrl, setTime);

  /// Create a copy of LiveEventBandModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventBandModelImplCopyWith<_$LiveEventBandModelImpl> get copyWith =>
      __$$LiveEventBandModelImplCopyWithImpl<_$LiveEventBandModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveEventBandModelImplToJson(this);
  }
}

abstract class _LiveEventBandModel implements LiveEventBandModel {
  const factory _LiveEventBandModel({
    required final String id,
    required final String name,
    final String? description,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    @JsonKey(name: 'set_time') final DateTime? setTime,
  }) = _$LiveEventBandModelImpl;

  factory _LiveEventBandModel.fromJson(Map<String, dynamic> json) =
      _$LiveEventBandModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'set_time')
  DateTime? get setTime;

  /// Create a copy of LiveEventBandModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveEventBandModelImplCopyWith<_$LiveEventBandModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LiveEventPhotoModel _$LiveEventPhotoModelFromJson(Map<String, dynamic> json) {
  return _LiveEventPhotoModel.fromJson(json);
}

/// @nodoc
mixin _$LiveEventPhotoModel {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(name: 'uploaded_by')
  String? get uploadedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'uploaded_at')
  DateTime? get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this LiveEventPhotoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveEventPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveEventPhotoModelCopyWith<LiveEventPhotoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventPhotoModelCopyWith<$Res> {
  factory $LiveEventPhotoModelCopyWith(
    LiveEventPhotoModel value,
    $Res Function(LiveEventPhotoModel) then,
  ) = _$LiveEventPhotoModelCopyWithImpl<$Res, LiveEventPhotoModel>;
  @useResult
  $Res call({
    String id,
    String url,
    String? caption,
    @JsonKey(name: 'uploaded_by') String? uploadedBy,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  });
}

/// @nodoc
class _$LiveEventPhotoModelCopyWithImpl<$Res, $Val extends LiveEventPhotoModel>
    implements $LiveEventPhotoModelCopyWith<$Res> {
  _$LiveEventPhotoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveEventPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? caption = freezed,
    Object? uploadedBy = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedBy: freezed == uploadedBy
                ? _value.uploadedBy
                : uploadedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LiveEventPhotoModelImplCopyWith<$Res>
    implements $LiveEventPhotoModelCopyWith<$Res> {
  factory _$$LiveEventPhotoModelImplCopyWith(
    _$LiveEventPhotoModelImpl value,
    $Res Function(_$LiveEventPhotoModelImpl) then,
  ) = __$$LiveEventPhotoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String url,
    String? caption,
    @JsonKey(name: 'uploaded_by') String? uploadedBy,
    @JsonKey(name: 'uploaded_at') DateTime? uploadedAt,
  });
}

/// @nodoc
class __$$LiveEventPhotoModelImplCopyWithImpl<$Res>
    extends _$LiveEventPhotoModelCopyWithImpl<$Res, _$LiveEventPhotoModelImpl>
    implements _$$LiveEventPhotoModelImplCopyWith<$Res> {
  __$$LiveEventPhotoModelImplCopyWithImpl(
    _$LiveEventPhotoModelImpl _value,
    $Res Function(_$LiveEventPhotoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LiveEventPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? caption = freezed,
    Object? uploadedBy = freezed,
    Object? uploadedAt = freezed,
  }) {
    return _then(
      _$LiveEventPhotoModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedBy: freezed == uploadedBy
            ? _value.uploadedBy
            : uploadedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveEventPhotoModelImpl implements _LiveEventPhotoModel {
  const _$LiveEventPhotoModelImpl({
    required this.id,
    required this.url,
    this.caption,
    @JsonKey(name: 'uploaded_by') this.uploadedBy,
    @JsonKey(name: 'uploaded_at') this.uploadedAt,
  });

  factory _$LiveEventPhotoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveEventPhotoModelImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String? caption;
  @override
  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;
  @override
  @JsonKey(name: 'uploaded_at')
  final DateTime? uploadedAt;

  @override
  String toString() {
    return 'LiveEventPhotoModel(id: $id, url: $url, caption: $caption, uploadedBy: $uploadedBy, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventPhotoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.uploadedBy, uploadedBy) ||
                other.uploadedBy == uploadedBy) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, caption, uploadedBy, uploadedAt);

  /// Create a copy of LiveEventPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventPhotoModelImplCopyWith<_$LiveEventPhotoModelImpl> get copyWith =>
      __$$LiveEventPhotoModelImplCopyWithImpl<_$LiveEventPhotoModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveEventPhotoModelImplToJson(this);
  }
}

abstract class _LiveEventPhotoModel implements LiveEventPhotoModel {
  const factory _LiveEventPhotoModel({
    required final String id,
    required final String url,
    final String? caption,
    @JsonKey(name: 'uploaded_by') final String? uploadedBy,
    @JsonKey(name: 'uploaded_at') final DateTime? uploadedAt,
  }) = _$LiveEventPhotoModelImpl;

  factory _LiveEventPhotoModel.fromJson(Map<String, dynamic> json) =
      _$LiveEventPhotoModelImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String? get caption;
  @override
  @JsonKey(name: 'uploaded_by')
  String? get uploadedBy;
  @override
  @JsonKey(name: 'uploaded_at')
  DateTime? get uploadedAt;

  /// Create a copy of LiveEventPhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveEventPhotoModelImplCopyWith<_$LiveEventPhotoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
