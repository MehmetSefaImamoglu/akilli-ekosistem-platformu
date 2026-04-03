// lib/features/anomaly/data/anomaly_repository.dart
//
// Fonksiyonel Programlama ilkesi:
//   - Saf fonksiyonlar: her metot girdi → çıktı, yan etki yok.
//   - Immutable model: AnomalyModel (@freezed) döndürülür.
//   - INSERT işlemi consumption kaydının ID'sini alır,
//     anomali kaydını oluşturur ve geri döndürür.
//   - Hata yönetimi: exception'lar üst katmana (provider) fırlatılır.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/anomaly_model.dart';

class AnomalyRepository {
  AnomalyRepository(this._supabase);

  final SupabaseClient _supabase;

  // ────────────────────────────────────────────────
  // INSERT — Kural tabanlı anomali kaydı ekle
  // ────────────────────────────────────────────────
  /// Anomaliyi `anomalies` tablosuna yazar ve kayıtlı modeli döndürür.
  /// [consumptionId] : yeni eklenen tüketim kaydının UUID'si
  /// [userId]         : oturumu açık kullanıcınn UUID'si
  /// [description]    : kullanıcıya gösterilecek Türkçe uyarı metni
  /// [detectedValue]  : kullanıcının girdiği değer
  /// [expectedValue]  : eşik değer (kural tabanlı baseline)
  /// [severity]       : şiddet seviyesi (varsayılan: high)
  Future<AnomalyModel> insertAnomaly({
    required String userId,
    required String consumptionId,
    required String description,
    required double detectedValue,
    required double expectedValue,
    AnomalySeverity severity = AnomalySeverity.high,
  }) async {
    final payload = {
      'user_id': userId,
      'consumption_id': consumptionId,
      'description': description,
      'severity': severity.name,
      'status': AnomalyStatus.open.name,
      'detected_value': detectedValue,
      'expected_value': expectedValue,
      'detected_at': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await _supabase
        .from('anomalies')
        .insert(payload)
        .select()
        .single();

    return AnomalyModel.fromJson(response);
  }

  // ────────────────────────────────────────────────
  // SELECT — Kullanıcının son N anomalisini getir
  // ────────────────────────────────────────────────
  /// [limit] kadar en yeni anomaliyi azalan sıraya göre döndürür.
  Future<List<AnomalyModel>> fetchRecentAnomalies({
    required String userId,
    int limit = 5,
  }) async {
    final response = await _supabase
        .from('anomalies')
        .select()
        .eq('user_id', userId)
        .order('detected_at', ascending: false)
        .limit(limit);

    return response
        .map((json) => AnomalyModel.fromJson(json))
        .toList();
  }
}
