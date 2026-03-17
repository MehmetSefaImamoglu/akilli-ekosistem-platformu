// lib/models/consumption_model.dart
//
// Fonksiyonel Programlama ilkesi: Immutable tüketim verisi modeli.
// @freezed anotasyonu sayesinde:
//   - Tüm alanlar final (değiştirilemez).
//   - copyWith() otomatik üretilir — yeni state fonksiyonel olarak türetilir.
//   - fromJson / toJson json_serializable tarafından üretilir.
//   - == ve hashCode değer eşitliği (structural equality) sağlar.
//
// Üretilen dosyayı oluşturmak için:
//   flutter pub run build_runner build --delete-conflicting-outputs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumption_model.freezed.dart';
part 'consumption_model.g.dart';

/// Tüketim türü — elektrik, su veya gaz
enum ConsumptionType {
  @JsonValue('electricity') electricity,
  @JsonValue('water')       water,
  @JsonValue('gas')         gas,
}

@freezed
class ConsumptionModel with _$ConsumptionModel {
  const factory ConsumptionModel({
    /// Kayıt UUID'si
    required String id,

    /// Kullanıcı UUID'si (FK → users.id)
    @JsonKey(name: 'user_id') required String userId,

    /// Tüketim türü: electricity | water | gas
    required ConsumptionType type,

    /// Ölçüm değeri (kWh / litre / m³)
    required double value,

    /// Birim etiketi: 'kWh', 'litre', 'm³'
    required String unit,

    /// Ölçüm zaman damgası
    @JsonKey(name: 'recorded_at') required DateTime recordedAt,

    /// Opsiyonel notlar
    String? notes,
  }) = _ConsumptionModel;

  /// JSON'dan immutable model üret
  factory ConsumptionModel.fromJson(Map<String, dynamic> json) =>
      _$ConsumptionModelFromJson(json);
}
