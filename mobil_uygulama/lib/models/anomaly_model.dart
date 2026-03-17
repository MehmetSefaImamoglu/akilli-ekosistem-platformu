// lib/models/anomaly_model.dart
//
// Fonksiyonel Programlama ilkesi: Immutable anomali tespit modeli.
// @freezed anotasyonu sayesinde:
//   - Tüm alanlar final (değiştirilemez).
//   - copyWith() otomatik üretilir — yeni state fonksiyonel olarak türetilir.
//   - fromJson / toJson json_serializable tarafından üretilir.
//   - == ve hashCode değer eşitliği (structural equality) sağlar.
//
// Üretilen dosyayı oluşturmak için:
//   flutter pub run build_runner build --delete-conflicting-outputs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'anomaly_model.freezed.dart';
part 'anomaly_model.g.dart';

/// Anomali şiddeti
enum AnomalySeverity {
  @JsonValue('low')      low,
  @JsonValue('medium')   medium,
  @JsonValue('high')     high,
  @JsonValue('critical') critical,
}

/// Anomali durumu
enum AnomalyStatus {
  @JsonValue('open')         open,
  @JsonValue('acknowledged') acknowledged,
  @JsonValue('resolved')     resolved,
}

@freezed
class AnomalyModel with _$AnomalyModel {
  const AnomalyModel._(); // Özel metotlar için gerekli private constructor

  const factory AnomalyModel({
    /// Anomali UUID'si
    required String id,

    /// Kullanıcı UUID'si (FK → users.id)
    @JsonKey(name: 'user_id') required String userId,

    /// İlişkili tüketim kaydı UUID'si (FK → consumptions.id)
    @JsonKey(name: 'consumption_id') required String consumptionId,

    /// Anomali açıklaması
    required String description,

    /// Şiddet seviyesi: low | medium | high | critical
    required AnomalySeverity severity,

    /// Mevcut durum: open | acknowledged | resolved
    @Default(AnomalyStatus.open) AnomalyStatus status,

    /// Tespit edilen gerçek değer
    @JsonKey(name: 'detected_value') required double detectedValue,

    /// Beklenen değer (baseline)
    @JsonKey(name: 'expected_value') required double expectedValue,

    /// Gemini AI tarafından üretilen doğal dil açıklaması
    @JsonKey(name: 'gemini_explanation') String? geminiExplanation,

    /// Anomali tespit zaman damgası
    @JsonKey(name: 'detected_at') required DateTime detectedAt,

    /// Çözüm zaman damgası (opsiyonel)
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
  }) = _AnomalyModel;

  /// JSON'dan immutable model üret
  factory AnomalyModel.fromJson(Map<String, dynamic> json) =>
      _$AnomalyModelFromJson(json);

  // ── Saf fonksiyonlar (side-effect yok) ──────────────────────────────────

  /// Anomali çözülmüş mü?
  bool get isResolved => status == AnomalyStatus.resolved;

  /// Kritik seviyede mi?
  bool get isCritical => severity == AnomalySeverity.critical;

  /// Sapma yüzdesi (detected - expected) / expected * 100
  double get deviationPercent =>
      expectedValue == 0 ? 0 : ((detectedValue - expectedValue) / expectedValue) * 100;
}
