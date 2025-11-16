// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'defaultTimezone')
  String get defaultTimezone => throw _privateConstructorUsedError;

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    String status,
    @JsonKey(name: 'defaultTimezone') String defaultTimezone,
  });
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? status = null,
    Object? defaultTimezone = null,
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
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultTimezone: null == defaultTimezone
                ? _value.defaultTimezone
                : defaultTimezone // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
    _$ProjectImpl value,
    $Res Function(_$ProjectImpl) then,
  ) = __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String code,
    String status,
    @JsonKey(name: 'defaultTimezone') String defaultTimezone,
  });
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
    _$ProjectImpl _value,
    $Res Function(_$ProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? status = null,
    Object? defaultTimezone = null,
  }) {
    return _then(
      _$ProjectImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultTimezone: null == defaultTimezone
            ? _value.defaultTimezone
            : defaultTimezone // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl implements _Project {
  _$ProjectImpl({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    @JsonKey(name: 'defaultTimezone') required this.defaultTimezone,
  });

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String status;
  @override
  @JsonKey(name: 'defaultTimezone')
  final String defaultTimezone;

  @override
  String toString() {
    return 'Project(id: $id, name: $name, code: $code, status: $status, defaultTimezone: $defaultTimezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.defaultTimezone, defaultTimezone) ||
                other.defaultTimezone == defaultTimezone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, code, status, defaultTimezone);

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(this);
  }
}

abstract class _Project implements Project {
  factory _Project({
    required final String id,
    required final String name,
    required final String code,
    required final String status,
    @JsonKey(name: 'defaultTimezone') required final String defaultTimezone,
  }) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String get status;
  @override
  @JsonKey(name: 'defaultTimezone')
  String get defaultTimezone;

  /// Create a copy of Project
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PageResponseProject _$PageResponseProjectFromJson(Map<String, dynamic> json) {
  return _PageResponseProject.fromJson(json);
}

/// @nodoc
mixin _$PageResponseProject {
  List<Project> get items => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int? get totalPages => throw _privateConstructorUsedError;
  bool get hasNext => throw _privateConstructorUsedError;
  bool get hasPrevious => throw _privateConstructorUsedError;

  /// Serializes this PageResponseProject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageResponseProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageResponseProjectCopyWith<PageResponseProject> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageResponseProjectCopyWith<$Res> {
  factory $PageResponseProjectCopyWith(
    PageResponseProject value,
    $Res Function(PageResponseProject) then,
  ) = _$PageResponseProjectCopyWithImpl<$Res, PageResponseProject>;
  @useResult
  $Res call({
    List<Project> items,
    int page,
    int size,
    int total,
    int? totalPages,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class _$PageResponseProjectCopyWithImpl<$Res, $Val extends PageResponseProject>
    implements $PageResponseProjectCopyWith<$Res> {
  _$PageResponseProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageResponseProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? total = null,
    Object? totalPages = freezed,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _value.copyWith(
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<Project>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: freezed == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int?,
            hasNext: null == hasNext
                ? _value.hasNext
                : hasNext // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPrevious: null == hasPrevious
                ? _value.hasPrevious
                : hasPrevious // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageResponseProjectImplCopyWith<$Res>
    implements $PageResponseProjectCopyWith<$Res> {
  factory _$$PageResponseProjectImplCopyWith(
    _$PageResponseProjectImpl value,
    $Res Function(_$PageResponseProjectImpl) then,
  ) = __$$PageResponseProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Project> items,
    int page,
    int size,
    int total,
    int? totalPages,
    bool hasNext,
    bool hasPrevious,
  });
}

/// @nodoc
class __$$PageResponseProjectImplCopyWithImpl<$Res>
    extends _$PageResponseProjectCopyWithImpl<$Res, _$PageResponseProjectImpl>
    implements _$$PageResponseProjectImplCopyWith<$Res> {
  __$$PageResponseProjectImplCopyWithImpl(
    _$PageResponseProjectImpl _value,
    $Res Function(_$PageResponseProjectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageResponseProject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? page = null,
    Object? size = null,
    Object? total = null,
    Object? totalPages = freezed,
    Object? hasNext = null,
    Object? hasPrevious = null,
  }) {
    return _then(
      _$PageResponseProjectImpl(
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<Project>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: freezed == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int?,
        hasNext: null == hasNext
            ? _value.hasNext
            : hasNext // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPrevious: null == hasPrevious
            ? _value.hasPrevious
            : hasPrevious // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageResponseProjectImpl implements _PageResponseProject {
  const _$PageResponseProjectImpl({
    required final List<Project> items,
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
    this.hasNext = false,
    this.hasPrevious = false,
  }) : _items = items;

  factory _$PageResponseProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageResponseProjectImplFromJson(json);

  final List<Project> _items;
  @override
  List<Project> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int page;
  @override
  final int size;
  @override
  final int total;
  @override
  final int? totalPages;
  @override
  @JsonKey()
  final bool hasNext;
  @override
  @JsonKey()
  final bool hasPrevious;

  @override
  String toString() {
    return 'PageResponseProject(items: $items, page: $page, size: $size, total: $total, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageResponseProjectImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasNext, hasNext) || other.hasNext == hasNext) &&
            (identical(other.hasPrevious, hasPrevious) ||
                other.hasPrevious == hasPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_items),
    page,
    size,
    total,
    totalPages,
    hasNext,
    hasPrevious,
  );

  /// Create a copy of PageResponseProject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageResponseProjectImplCopyWith<_$PageResponseProjectImpl> get copyWith =>
      __$$PageResponseProjectImplCopyWithImpl<_$PageResponseProjectImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PageResponseProjectImplToJson(this);
  }
}

abstract class _PageResponseProject implements PageResponseProject {
  const factory _PageResponseProject({
    required final List<Project> items,
    required final int page,
    required final int size,
    required final int total,
    final int? totalPages,
    final bool hasNext,
    final bool hasPrevious,
  }) = _$PageResponseProjectImpl;

  factory _PageResponseProject.fromJson(Map<String, dynamic> json) =
      _$PageResponseProjectImpl.fromJson;

  @override
  List<Project> get items;
  @override
  int get page;
  @override
  int get size;
  @override
  int get total;
  @override
  int? get totalPages;
  @override
  bool get hasNext;
  @override
  bool get hasPrevious;

  /// Create a copy of PageResponseProject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageResponseProjectImplCopyWith<_$PageResponseProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
