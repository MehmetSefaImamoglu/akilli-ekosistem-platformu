// lib/features/anomaly/providers/anomaly_provider.dart
//
// Riverpod katmanı — AnomalyRepository üzerinde reactive state.
//
// Provider mimarisi:
//   anomalyRepositoryProvider → Repository singleton
//   anomalyListProvider       → FutureProvider: kullanıcıya ait son anomaliler
//
// Fonksiyonel ilkeler:
//   - State immutable: List<AnomalyModel> değişmez, yeni liste döner.
//   - Side effect izolasyonu: Supabase sadece Repository içinde.
//   - Hata mesajları Türkçe, exception fırlatma yerine AsyncError.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/anomaly_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/anomaly_repository.dart';

// ─────────────────────────────────────────────────────
// 1. Repository provider (singleton)
// ─────────────────────────────────────────────────────
final anomalyRepositoryProvider = Provider<AnomalyRepository>((ref) {
  return AnomalyRepository(Supabase.instance.client);
});

// ─────────────────────────────────────────────────────
// 2. Son anomali listesi — FutureProvider
//    Dashboard'da "Son Anomaliler" bölümünü besler.
//    ref.invalidate(anomalyListProvider) ile yenilenebilir.
// ─────────────────────────────────────────────────────
final anomalyListProvider = FutureProvider<List<AnomalyModel>>((ref) async {
  final repo = ref.watch(anomalyRepositoryProvider);
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return [];
  return repo.fetchRecentAnomalies(userId: uid, limit: 5);
});
