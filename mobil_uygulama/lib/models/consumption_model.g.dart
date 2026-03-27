// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsumptionModelImpl _$$ConsumptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsumptionModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: $enumDecode(_$ConsumptionTypeEnumMap, json['type']),
      value: _parseDouble(json['value']),
      unit: json['unit'] as String,
      recordedAt: _parseDateTime(json['recorded_at']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ConsumptionModelImplToJson(
        _$ConsumptionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$ConsumptionTypeEnumMap[instance.type]!,
      'value': instance.value,
      'unit': instance.unit,
      'recorded_at': instance.recordedAt.toIso8601String(),
      'notes': instance.notes,
    };

const _$ConsumptionTypeEnumMap = {
  ConsumptionType.electricity: 'electricity',
  ConsumptionType.water: 'water',
  ConsumptionType.gas: 'gas',
};
