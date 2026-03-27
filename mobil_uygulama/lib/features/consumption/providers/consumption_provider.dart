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

import '../../../models/consumption_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
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
      await _repo.insertConsumption(
        userId: uid,
        type: type,
        value: value,
        recordedAt: recordedAt,
        notes: notes,
      );
      // Insert sonrasi listeyi yenile (saf veri akisi)
      return _repo.fetchRecentConsumptions(userId: uid, days: 7);
    });

    // Sadece totals provider'i yenile (consumptionListProvider'i buradan
    // invalidate etmek circular dependency hatasi verir — state zaten
    // AsyncValue.guard ile yukarida guncellendi).
    ref.invalidate(consumptionTotalsProvider);
  }

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
