// lib/features/consumption/data/consumption_repository.dart
//
// Fonksiyonel Programlama ilkesi:
//   - Saf fonksiyonlar: her metot girdi -> cikti, yan etki yok.
//   - Immutable model: ConsumptionModel (@freezed) donulur.
//   - Hata yonetimi: exception'lar ust katmana (provider) firlatilir.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/consumption_model.dart';

class ConsumptionRepository {
  ConsumptionRepository(this._supabase);

  final SupabaseClient _supabase;

  // ────────────────────────────────────────────────
  // INSERT — Yeni tuketim kaydi ekle
  // ────────────────────────────────────────────────
  Future<ConsumptionModel> insertConsumption({
    required String userId,
    required ConsumptionType type,
    required double value,
    required DateTime recordedAt,
    String? notes,
  }) async {
    // Birimi type'a gore belirle (pure function)
    final unit = _unitFor(type);

    final payload = {
      'user_id': userId,
      'type': type.name,          // 'electricity' | 'water' | 'gas'
      'value': value,
      'unit': unit,
      'recorded_at': recordedAt.toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _supabase
        .from('consumptions')
        .insert(payload)
        .select()          // INSERT sonrasi yeni satiri dondur
        .single();

    return ConsumptionModel.fromJson(response);
  }

  // ────────────────────────────────────────────────
  // SELECT — Son N gunun kayitlarini getir
  // ────────────────────────────────────────────────
  Future<List<ConsumptionModel>> fetchRecentConsumptions({
    required String userId,
    int days = 7,
  }) async {
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String();

    try {
      // Supabase Flutter SDK returns List<Map<String, dynamic>> directly;
      // no need to cast as List<dynamic>
      final response = await _supabase
          .from('consumptions')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', since)
          .order('recorded_at', ascending: true);

      return response
          .map((json) => ConsumptionModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      print('fetchRecentConsumptions ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ────────────────────────────────────────────────
  // SELECT — Ture gore toplam tuketim
  // ────────────────────────────────────────────────
  Future<Map<ConsumptionType, double>> fetchTotals({
    required String userId,
    int days = 30,
  }) async {
    try {
      final since = DateTime.now()
          .subtract(Duration(days: days))
          .toIso8601String();

      final response = await _supabase
          .from('consumptions')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', since)
          .order('recorded_at', ascending: true);

      final list = response
          .map((json) => ConsumptionModel.fromJson(json))
          .toList();

      // Fonksiyonel fold: mutable map yok, fold ile accumulate
      return list.fold<Map<ConsumptionType, double>>(
        {
          ConsumptionType.electricity: 0,
          ConsumptionType.water: 0,
          ConsumptionType.gas: 0,
        },
        (acc, item) => {
          ...acc,
          item.type: (acc[item.type] ?? 0) + item.value,
        },
      );
    } catch (e, stackTrace) {
      print('fetchTotals ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // ────────────────────────────────────────────────
  // Pure helper: tur → birim etiketi
  // ────────────────────────────────────────────────
  static String _unitFor(ConsumptionType type) => switch (type) {
        ConsumptionType.electricity => 'kWh',
        ConsumptionType.water => 'L',
        ConsumptionType.gas => 'm3',
      };
}
