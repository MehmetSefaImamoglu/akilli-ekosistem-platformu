// lib/features/consumption/providers/consumption_provider.dart
//
// Riverpod katmanı — ConsumptionRepository üzerinde reactive state.
//
// Provider mimarisi:
//   consumptionRepositoryProvider  → Repository singleton
//   consumptionListProvider        → AsyncNotifier: fetch + add
//   consumptionTotalsProvider      → AsyncProvider: türe göre toplam
//
// Fonksiyonel ilkeler:
//   - State immutable: her güncellemede yeni liste döner.
//   - Side effect izolasyonu: Supabase sadece Repository içinde.
//   - Hata mesajları Türkçe, exception fırlatma yerine AsyncError.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/anomaly_model.dart';
import '../../../models/consumption_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/anomaly/data/anomaly_repository.dart';
import '../../../features/anomaly/providers/anomaly_provider.dart';
import '../data/consumption_repository.dart';

// ─────────────────────────────────────────────────────
// 1. Repository provider (singleton)
// ─────────────────────────────────────────────────────
final consumptionRepositoryProvider = Provider<ConsumptionRepository>((ref) {
  return ConsumptionRepository(Supabase.instance.client);
});

// ─────────────────────────────────────────────────────
// 2. Consumption list — AsyncNotifier
// ─────────────────────────────────────────────────────

class ConsumptionNotifier
    extends AsyncNotifier<List<ConsumptionModel>> {
  ConsumptionRepository get _repo =>
      ref.read(consumptionRepositoryProvider);

  String? get _userId =>
      ref.read(currentUserProvider)?.id;

  @override
  Future<List<ConsumptionModel>> build() async {
    final uid = _userId;
    if (uid == null) return [];
    return _repo.fetchRecentConsumptions(userId: uid, days: 7);
  }

  // ── Yeni kayıt ekle ────────────────────────────────
  Future<void> addConsumption({
    required ConsumptionType type,
    required double value,
    required DateTime recordedAt,
    String? notes,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('Oturum açılmamış.');

    // Optimistic update yok — loading state göster
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 1. Tüketimi kaydet ve oluşturulan kaydı al (id dahil)
      final saved = await _repo.insertConsumption(
        userId: uid,
        type: type,
        value: value,
        recordedAt: recordedAt,
        notes: notes,
      );

      // 2. Kural tabanlı anomali tespiti ─────────────────
      // Eşik değerler: elektrik > 200 kWh, su > 100 L, gaz > 50 m³
      final threshold = _thresholdFor(type);
      if (value > threshold) {
        final typeName = _typeLabel(type);
        final description =
            'Dikkat: Normalin üzerinde $typeName tüketimi tespit edildi!'
            ' Deger: ${value.toStringAsFixed(1)}';

        final anomalyRepo =
            ref.read(anomalyRepositoryProvider);

        await anomalyRepo.insertAnomaly(
          userId: uid,
          consumptionId: saved.id,
          description: description,
          detectedValue: value,
          expectedValue: threshold.toDouble(),
          severity: AnomalySeverity.high,
        );

        // 3. Anomali listesini yenile (dashboard güncellenir)
        ref.invalidate(anomalyListProvider);
      }

      // 4. Güncel tüketim listesini döndür
      return _repo.fetchRecentConsumptions(userId: uid, days: 7);
    });

    ref.invalidate(consumptionTotalsProvider);
  }

  /// Türe göre eşik değer — saf fonksiyon
  static double _thresholdFor(ConsumptionType type) => switch (type) {
        ConsumptionType.electricity => 200,
        ConsumptionType.water => 100,
        ConsumptionType.gas => 50,
      };

  /// Türün Türkçe karşılığı — saf fonksiyon
  static String _typeLabel(ConsumptionType type) => switch (type) {
        ConsumptionType.electricity => 'Elektrik',
        ConsumptionType.water => 'Su',
        ConsumptionType.gas => 'Gaz',
      };


  // ── Manuel yenile ──────────────────────────────────
  Future<void> refresh() async {
    final uid = _userId;
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.fetchRecentConsumptions(userId: uid, days: 7),
    );
  }
}

final consumptionListProvider =
    AsyncNotifierProvider<ConsumptionNotifier, List<ConsumptionModel>>(
  ConsumptionNotifier.new,
);

// ─────────────────────────────────────────────────────
// 3. Totals provider (30 günlük özet)
//    Derived provider — consumptionListProvider'dan türetilmez,
//    çünkü 30 günü bağımsız sorgular.
// ─────────────────────────────────────────────────────
final consumptionTotalsProvider =
    FutureProvider<Map<ConsumptionType, double>>((ref) async {
  final repo = ref.watch(consumptionRepositoryProvider);
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return {};
  return repo.fetchTotals(userId: uid, days: 30);
});
