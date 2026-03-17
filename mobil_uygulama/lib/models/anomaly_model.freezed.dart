// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anomaly_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnomalyModel _$AnomalyModelFromJson(Map<String, dynamic> json) {
  return _AnomalyModel.fromJson(json);
}

/// @nodoc
mixin _$AnomalyModel {
  /// Anomali UUID'si
  String get id => throw _privateConstructorUsedError;

  /// Kullanıcı UUID'si (FK → users.id)
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// İlişkili tüketim kaydı UUID'si (FK → consumptions.id)
  @JsonKey(name: 'consumption_id')
  String get consumptionId => throw _privateConstructorUsedError;

  /// Anomali açıklaması
  String get description => throw _privateConstructorUsedError;

  /// Şiddet seviyesi: low | medium | high | critical
  AnomalySeverity get severity => throw _privateConstructorUsedError;

  /// Mevcut durum: open | acknowledged | resolved
  AnomalyStatus get status => throw _privateConstructorUsedError;

  /// Tespit edilen gerçek değer
  @JsonKey(name: 'detected_value')
  double get detectedValue => throw _privateConstructorUsedError;

  /// Beklenen değer (baseline)
  @JsonKey(name: 'expected_value')
  double get expectedValue => throw _privateConstructorUsedError;

  /// Gemini AI tarafından üretilen doğal dil açıklaması
  @JsonKey(name: 'gemini_explanation')
  String? get geminiExplanation => throw _privateConstructorUsedError;

  /// Anomali tespit zaman damgası
  @JsonKey(name: 'detected_at')
  DateTime get detectedAt => throw _privateConstructorUsedError;

  /// Çözüm zaman damgası (opsiyonel)
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this AnomalyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnomalyModelCopyWith<AnomalyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnomalyModelCopyWith<$Res> {
  factory $AnomalyModelCopyWith(
          AnomalyModel value, $Res Function(AnomalyModel) then) =
      _$AnomalyModelCopyWithImpl<$Res, AnomalyModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'consumption_id') String consumptionId,
      String description,
      AnomalySeverity severity,
      AnomalyStatus status,
      @JsonKey(name: 'detected_value') double detectedValue,
      @JsonKey(name: 'expected_value') double expectedValue,
      @JsonKey(name: 'gemini_explanation') String? geminiExplanation,
      @JsonKey(name: 'detected_at') DateTime detectedAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt});
}

/// @nodoc
class _$AnomalyModelCopyWithImpl<$Res, $Val extends AnomalyModel>
    implements $AnomalyModelCopyWith<$Res> {
  _$AnomalyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? consumptionId = null,
    Object? description = null,
    Object? severity = null,
    Object? status = null,
    Object? detectedValue = null,
    Object? expectedValue = null,
    Object? geminiExplanation = freezed,
    Object? detectedAt = null,
    Object? resolvedAt = freezed,
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
      consumptionId: null == consumptionId
          ? _value.consumptionId
          : consumptionId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AnomalyStatus,
      detectedValue: null == detectedValue
          ? _value.detectedValue
          : detectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      expectedValue: null == expectedValue
          ? _value.expectedValue
          : expectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      geminiExplanation: freezed == geminiExplanation
          ? _value.geminiExplanation
          : geminiExplanation // ignore: cast_nullable_to_non_nullable
              as String?,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnomalyModelImplCopyWith<$Res>
    implements $AnomalyModelCopyWith<$Res> {
  factory _$$AnomalyModelImplCopyWith(
          _$AnomalyModelImpl value, $Res Function(_$AnomalyModelImpl) then) =
      __$$AnomalyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'consumption_id') String consumptionId,
      String description,
      AnomalySeverity severity,
      AnomalyStatus status,
      @JsonKey(name: 'detected_value') double detectedValue,
      @JsonKey(name: 'expected_value') double expectedValue,
      @JsonKey(name: 'gemini_explanation') String? geminiExplanation,
      @JsonKey(name: 'detected_at') DateTime detectedAt,
      @JsonKey(name: 'resolved_at') DateTime? resolvedAt});
}

/// @nodoc
class __$$AnomalyModelImplCopyWithImpl<$Res>
    extends _$AnomalyModelCopyWithImpl<$Res, _$AnomalyModelImpl>
    implements _$$AnomalyModelImplCopyWith<$Res> {
  __$$AnomalyModelImplCopyWithImpl(
      _$AnomalyModelImpl _value, $Res Function(_$AnomalyModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? consumptionId = null,
    Object? description = null,
    Object? severity = null,
    Object? status = null,
    Object? detectedValue = null,
    Object? expectedValue = null,
    Object? geminiExplanation = freezed,
    Object? detectedAt = null,
    Object? resolvedAt = freezed,
  }) {
    return _then(_$AnomalyModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      consumptionId: null == consumptionId
          ? _value.consumptionId
          : consumptionId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as AnomalyStatus,
      detectedValue: null == detectedValue
          ? _value.detectedValue
          : detectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      expectedValue: null == expectedValue
          ? _value.expectedValue
          : expectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      geminiExplanation: freezed == geminiExplanation
          ? _value.geminiExplanation
          : geminiExplanation // ignore: cast_nullable_to_non_nullable
              as String?,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnomalyModelImpl extends _AnomalyModel {
  const _$AnomalyModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'consumption_id') required this.consumptionId,
      required this.description,
      required this.severity,
      this.status = AnomalyStatus.open,
      @JsonKey(name: 'detected_value') required this.detectedValue,
      @JsonKey(name: 'expected_value') required this.expectedValue,
      @JsonKey(name: 'gemini_explanation') this.geminiExplanation,
      @JsonKey(name: 'detected_at') required this.detectedAt,
      @JsonKey(name: 'resolved_at') this.resolvedAt})
      : super._();

  factory _$AnomalyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnomalyModelImplFromJson(json);

  /// Anomali UUID'si
  @override
  final String id;

  /// Kullanıcı UUID'si (FK → users.id)
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  /// İlişkili tüketim kaydı UUID'si (FK → consumptions.id)
  @override
  @JsonKey(name: 'consumption_id')
  final String consumptionId;

  /// Anomali açıklaması
  @override
  final String description;

  /// Şiddet seviyesi: low | medium | high | critical
  @override
  final AnomalySeverity severity;

  /// Mevcut durum: open | acknowledged | resolved
  @override
  @JsonKey()
  final AnomalyStatus status;

  /// Tespit edilen gerçek değer
  @override
  @JsonKey(name: 'detected_value')
  final double detectedValue;

  /// Beklenen değer (baseline)
  @override
  @JsonKey(name: 'expected_value')
  final double expectedValue;

  /// Gemini AI tarafından üretilen doğal dil açıklaması
  @override
  @JsonKey(name: 'gemini_explanation')
  final String? geminiExplanation;

  /// Anomali tespit zaman damgası
  @override
  @JsonKey(name: 'detected_at')
  final DateTime detectedAt;

  /// Çözüm zaman damgası (opsiyonel)
  @override
  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'AnomalyModel(id: $id, userId: $userId, consumptionId: $consumptionId, description: $description, severity: $severity, status: $status, detectedValue: $detectedValue, expectedValue: $expectedValue, geminiExplanation: $geminiExplanation, detectedAt: $detectedAt, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnomalyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.consumptionId, consumptionId) ||
                other.consumptionId == consumptionId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.detectedValue, detectedValue) ||
                other.detectedValue == detectedValue) &&
            (identical(other.expectedValue, expectedValue) ||
                other.expectedValue == expectedValue) &&
            (identical(other.geminiExplanation, geminiExplanation) ||
                other.geminiExplanation == geminiExplanation) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      consumptionId,
      description,
      severity,
      status,
      detectedValue,
      expectedValue,
      geminiExplanation,
      detectedAt,
      resolvedAt);

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnomalyModelImplCopyWith<_$AnomalyModelImpl> get copyWith =>
      __$$AnomalyModelImplCopyWithImpl<_$AnomalyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnomalyModelImplToJson(
      this,
    );
  }
}

abstract class _AnomalyModel extends AnomalyModel {
  const factory _AnomalyModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'consumption_id') required final String consumptionId,
          required final String description,
          required final AnomalySeverity severity,
          final AnomalyStatus status,
          @JsonKey(name: 'detected_value') required final double detectedValue,
          @JsonKey(name: 'expected_value') required final double expectedValue,
          @JsonKey(name: 'gemini_explanation') final String? geminiExplanation,
          @JsonKey(name: 'detected_at') required final DateTime detectedAt,
          @JsonKey(name: 'resolved_at') final DateTime? resolvedAt}) =
      _$AnomalyModelImpl;
  const _AnomalyModel._() : super._();

  factory _AnomalyModel.fromJson(Map<String, dynamic> json) =
      _$AnomalyModelImpl.fromJson;

  /// Anomali UUID'si
  @override
  String get id;

  /// Kullanıcı UUID'si (FK → users.id)
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// İlişkili tüketim kaydı UUID'si (FK → consumptions.id)
  @override
  @JsonKey(name: 'consumption_id')
  String get consumptionId;

  /// Anomali açıklaması
  @override
  String get description;

  /// Şiddet seviyesi: low | medium | high | critical
  @override
  AnomalySeverity get severity;

  /// Mevcut durum: open | acknowledged | resolved
  @override
  AnomalyStatus get status;

  /// Tespit edilen gerçek değer
  @override
  @JsonKey(name: 'detected_value')
  double get detectedValue;

  /// Beklenen değer (baseline)
  @override
  @JsonKey(name: 'expected_value')
  double get expectedValue;

  /// Gemini AI tarafından üretilen doğal dil açıklaması
  @override
  @JsonKey(name: 'gemini_explanation')
  String? get geminiExplanation;

  /// Anomali tespit zaman damgası
  @override
  @JsonKey(name: 'detected_at')
  DateTime get detectedAt;

  /// Çözüm zaman damgası (opsiyonel)
  @override
  @JsonKey(name: 'resolved_at')
  DateTime? get resolvedAt;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnomalyModelImplCopyWith<_$AnomalyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
