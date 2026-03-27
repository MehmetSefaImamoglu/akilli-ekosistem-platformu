// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consumption_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConsumptionModel _$ConsumptionModelFromJson(Map<String, dynamic> json) {
  return _ConsumptionModel.fromJson(json);
}

/// @nodoc
mixin _$ConsumptionModel {
  /// Kayit UUID'si
  String get id => throw _privateConstructorUsedError;

  /// Kullanici UUID'si (FK → users.id)
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Tuketim turu: electricity | water | gas
  ConsumptionType get type => throw _privateConstructorUsedError;

  /// Olcum degeri (kWh / litre / m3)
  /// @JsonKey(fromJson) ile int/double/String'i guvenle double'a cevirir.
  @JsonKey(fromJson: _parseDouble)
  double get value => throw _privateConstructorUsedError;

  /// Birim etiketi: 'kWh', 'L', 'm3'
  String get unit => throw _privateConstructorUsedError;

  /// Olcum zaman damgasi
  /// @JsonKey(fromJson) ile String veya DateTime'i guvenle parse eder.
  @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
  DateTime get recordedAt => throw _privateConstructorUsedError;

  /// Opsiyonel notlar
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ConsumptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsumptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsumptionModelCopyWith<ConsumptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsumptionModelCopyWith<$Res> {
  factory $ConsumptionModelCopyWith(
          ConsumptionModel value, $Res Function(ConsumptionModel) then) =
      _$ConsumptionModelCopyWithImpl<$Res, ConsumptionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      ConsumptionType type,
      @JsonKey(fromJson: _parseDouble) double value,
      String unit,
      @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
      DateTime recordedAt,
      String? notes});
}

/// @nodoc
class _$ConsumptionModelCopyWithImpl<$Res, $Val extends ConsumptionModel>
    implements $ConsumptionModelCopyWith<$Res> {
  _$ConsumptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsumptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConsumptionType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsumptionModelImplCopyWith<$Res>
    implements $ConsumptionModelCopyWith<$Res> {
  factory _$$ConsumptionModelImplCopyWith(_$ConsumptionModelImpl value,
          $Res Function(_$ConsumptionModelImpl) then) =
      __$$ConsumptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      ConsumptionType type,
      @JsonKey(fromJson: _parseDouble) double value,
      String unit,
      @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
      DateTime recordedAt,
      String? notes});
}

/// @nodoc
class __$$ConsumptionModelImplCopyWithImpl<$Res>
    extends _$ConsumptionModelCopyWithImpl<$Res, _$ConsumptionModelImpl>
    implements _$$ConsumptionModelImplCopyWith<$Res> {
  __$$ConsumptionModelImplCopyWithImpl(_$ConsumptionModelImpl _value,
      $Res Function(_$ConsumptionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConsumptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? value = null,
    Object? unit = null,
    Object? recordedAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$ConsumptionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ConsumptionType,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      recordedAt: null == recordedAt
          ? _value.recordedAt
          : recordedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsumptionModelImpl implements _ConsumptionModel {
  const _$ConsumptionModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.type,
      @JsonKey(fromJson: _parseDouble) required this.value,
      required this.unit,
      @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
      required this.recordedAt,
      this.notes});

  factory _$ConsumptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsumptionModelImplFromJson(json);

  /// Kayit UUID'si
  @override
  final String id;

  /// Kullanici UUID'si (FK → users.id)
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  /// Tuketim turu: electricity | water | gas
  @override
  final ConsumptionType type;

  /// Olcum degeri (kWh / litre / m3)
  /// @JsonKey(fromJson) ile int/double/String'i guvenle double'a cevirir.
  @override
  @JsonKey(fromJson: _parseDouble)
  final double value;

  /// Birim etiketi: 'kWh', 'L', 'm3'
  @override
  final String unit;

  /// Olcum zaman damgasi
  /// @JsonKey(fromJson) ile String veya DateTime'i guvenle parse eder.
  @override
  @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
  final DateTime recordedAt;

  /// Opsiyonel notlar
  @override
  final String? notes;

  @override
  String toString() {
    return 'ConsumptionModel(id: $id, userId: $userId, type: $type, value: $value, unit: $unit, recordedAt: $recordedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsumptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, type, value, unit, recordedAt, notes);

  /// Create a copy of ConsumptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsumptionModelImplCopyWith<_$ConsumptionModelImpl> get copyWith =>
      __$$ConsumptionModelImplCopyWithImpl<_$ConsumptionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsumptionModelImplToJson(
      this,
    );
  }
}

abstract class _ConsumptionModel implements ConsumptionModel {
  const factory _ConsumptionModel(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      required final ConsumptionType type,
      @JsonKey(fromJson: _parseDouble) required final double value,
      required final String unit,
      @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
      required final DateTime recordedAt,
      final String? notes}) = _$ConsumptionModelImpl;

  factory _ConsumptionModel.fromJson(Map<String, dynamic> json) =
      _$ConsumptionModelImpl.fromJson;

  /// Kayit UUID'si
  @override
  String get id;

  /// Kullanici UUID'si (FK → users.id)
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Tuketim turu: electricity | water | gas
  @override
  ConsumptionType get type;

  /// Olcum degeri (kWh / litre / m3)
  /// @JsonKey(fromJson) ile int/double/String'i guvenle double'a cevirir.
  @override
  @JsonKey(fromJson: _parseDouble)
  double get value;

  /// Birim etiketi: 'kWh', 'L', 'm3'
  @override
  String get unit;

  /// Olcum zaman damgasi
  /// @JsonKey(fromJson) ile String veya DateTime'i guvenle parse eder.
  @override
  @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
  DateTime get recordedAt;

  /// Opsiyonel notlar
  @override
  String? get notes;

  /// Create a copy of ConsumptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsumptionModelImplCopyWith<_$ConsumptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
