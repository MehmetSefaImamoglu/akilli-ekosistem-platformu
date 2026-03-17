// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anomaly_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnomalyModelImpl _$$AnomalyModelImplFromJson(Map<String, dynamic> json) =>
    _$AnomalyModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      consumptionId: json['consumption_id'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$AnomalySeverityEnumMap, json['severity']),
      status: $enumDecodeNullable(_$AnomalyStatusEnumMap, json['status']) ??
          AnomalyStatus.open,
      detectedValue: (json['detected_value'] as num).toDouble(),
      expectedValue: (json['expected_value'] as num).toDouble(),
      geminiExplanation: json['gemini_explanation'] as String?,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
    );

Map<String, dynamic> _$$AnomalyModelImplToJson(_$AnomalyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'consumption_id': instance.consumptionId,
      'description': instance.description,
      'severity': _$AnomalySeverityEnumMap[instance.severity]!,
      'status': _$AnomalyStatusEnumMap[instance.status]!,
      'detected_value': instance.detectedValue,
      'expected_value': instance.expectedValue,
      'gemini_explanation': instance.geminiExplanation,
      'detected_at': instance.detectedAt.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
    };

const _$AnomalySeverityEnumMap = {
  AnomalySeverity.low: 'low',
  AnomalySeverity.medium: 'medium',
  AnomalySeverity.high: 'high',
  AnomalySeverity.critical: 'critical',
};

const _$AnomalyStatusEnumMap = {
  AnomalyStatus.open: 'open',
  AnomalyStatus.acknowledged: 'acknowledged',
  AnomalyStatus.resolved: 'resolved',
};
