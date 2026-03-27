// lib/models/consumption_model.dart
//
// Fonksiyonel Programlama ilkesi: Immutable tuketim verisi modeli.
// @freezed anotasyonu sayesinde:
//   - Tum alanlar final (degistirilemez).
//   - copyWith() otomatik uretilir.
//   - fromJson / toJson json_serializable tarafindan uretilir.
//   - == ve hashCode deger esitligi (structural equality) saglar.
//
// Uretilen dosyayi olusturmak icin:
//   flutter pub run build_runner build --delete-conflicting-outputs

import 'package:freezed_annotation/freezed_annotation.dart';

part 'consumption_model.freezed.dart';
part 'consumption_model.g.dart';

// ─── Pure JSON dönüstürücüler ───────────────────────────────────────────────

/// Supabase bazen tam sayi (int) dondurur; bunu guvenle double'a cevirir.
double _parseDouble(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.parse(v);
  throw ArgumentError('Cannot convert $v (${v.runtimeType}) to double');
}

/// Supabase'den gelen timestamp string veya DateTime'i parse eder.
DateTime _parseDateTime(dynamic v) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.parse(v);
  throw ArgumentError('Cannot convert $v (${v.runtimeType}) to DateTime');
}

/// Tüketim türü — elektrik, su veya gaz
enum ConsumptionType {
  @JsonValue('electricity') electricity,
  @JsonValue('water')       water,
  @JsonValue('gas')         gas,
}

@freezed
class ConsumptionModel with _$ConsumptionModel {
  const factory ConsumptionModel({
    /// Kayit UUID'si
    required String id,

    /// Kullanici UUID'si (FK → users.id)
    @JsonKey(name: 'user_id') required String userId,

    /// Tuketim turu: electricity | water | gas
    required ConsumptionType type,

    /// Olcum degeri (kWh / litre / m3)
    /// @JsonKey(fromJson) ile int/double/String'i guvenle double'a cevirir.
    @JsonKey(fromJson: _parseDouble) required double value,

    /// Birim etiketi: 'kWh', 'L', 'm3'
    required String unit,

    /// Olcum zaman damgasi
    /// @JsonKey(fromJson) ile String veya DateTime'i guvenle parse eder.
    @JsonKey(name: 'recorded_at', fromJson: _parseDateTime)
    required DateTime recordedAt,

    /// Opsiyonel notlar
    String? notes,
  }) = _ConsumptionModel;

  /// JSON'dan immutable model uret
  factory ConsumptionModel.fromJson(Map<String, dynamic> json) =>
      _$ConsumptionModelFromJson(json);
}
