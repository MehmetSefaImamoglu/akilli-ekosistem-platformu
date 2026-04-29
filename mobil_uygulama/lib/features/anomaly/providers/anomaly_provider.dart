// lib/features/anomaly/providers/anomaly_provider.dart
//
// Hafta 6 — Provider mimarisi
// Hafta 10 — 503 / AI yoğunluk hatası graceful handling eklendi
//
// Hafta 6 UI-anlık-güncelleme çözümü:
//   GeminiAnalysisState.lastExplanation ve lastAnalyzedId alanları,
//   API cevabı gelir gelmez (provider refetch tamamlanmayı beklemeden)
//   yeşil kartın anında gösterilmesini sağlar.
//
// Veri akışı:
//   1. analyze() → isLoading:true
//   2. GeminiService → Next.js → Gemini → açıklama
//   3. AnomalyRepository.updateGeminiExplanation() → Supabase
//   4. state = {lastAnalyzedId, lastExplanation} → UI ANINDA güncellenir ✅
//   5. ref.invalidate(anomalyListProvider) → liste arka planda yenilenir

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/gemini_service.dart';
import '../../../models/anomaly_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/anomaly_repository.dart';

// ─────────────────────────────────────────────────────
// 1. Repository provider
// ─────────────────────────────────────────────────────
final anomalyRepositoryProvider = Provider<AnomalyRepository>((ref) {
  return AnomalyRepository(Supabase.instance.client);
});

// ─────────────────────────────────────────────────────
// 2. GeminiService provider
// ─────────────────────────────────────────────────────
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// ─────────────────────────────────────────────────────
// 3. Anomali listesi — FutureProvider.family
//    Dashboard → anomalyListProvider(5)
//    Liste     → anomalyListProvider(50)
//    ref.invalidate(anomalyListProvider) tüm instance'ları yeniler.
// ─────────────────────────────────────────────────────
final anomalyListProvider =
    FutureProvider.family<List<AnomalyModel>, int>((ref, limit) async {
  final repo = ref.watch(anomalyRepositoryProvider);
  final uid = ref.watch(currentUserProvider)?.id;
  if (uid == null) return [];
  return repo.fetchRecentAnomalies(userId: uid, limit: limit);
});

// ─────────────────────────────────────────────────────
// 4. GeminiAnalysisState
// ─────────────────────────────────────────────────────
@immutable
class GeminiAnalysisState {
  const GeminiAnalysisState({
    this.isLoading = false,
    this.analyzingId,
    this.error,
    this.lastAnalyzedId,
    this.lastExplanation,
  });

  /// Analiz devam ediyor mu?
  final bool isLoading;

  /// Hangi anomali şu an analiz ediliyor?
  final String? analyzingId;

  /// Hata mesajı — null ise hata yok
  final String? error;

  /// ─── Anlık UI güncellemesi için ───────────────────
  /// Az önce analizi tamamlanan anomalinin ID'si.
  /// _AnomalyDetailSheet bu değeri izleyerek provider
  /// refetch tamamlanmadan önce yeşil kartı gösterir.
  final String? lastAnalyzedId;

  /// Az önce Gemini'den gelen tam açıklama metni.
  final String? lastExplanation;

  GeminiAnalysisState copyWith({
    bool? isLoading,
    String? analyzingId,
    String? error,
    String? lastAnalyzedId,
    String? lastExplanation,
  }) =>
      GeminiAnalysisState(
        isLoading:       isLoading       ?? this.isLoading,
        analyzingId:     analyzingId     ?? this.analyzingId,
        error:           error           ?? this.error,
        lastAnalyzedId:  lastAnalyzedId  ?? this.lastAnalyzedId,
        lastExplanation: lastExplanation ?? this.lastExplanation,
      );
}

// ─────────────────────────────────────────────────────
// 5. GeminiAnalysisNotifier
// ─────────────────────────────────────────────────────
class GeminiAnalysisNotifier
    extends AutoDisposeNotifier<GeminiAnalysisState> {
  @override
  GeminiAnalysisState build() => const GeminiAnalysisState();

  Future<void> analyze(AnomalyModel anomaly) async {
    if (state.isLoading) return;

    state = GeminiAnalysisState(isLoading: true, analyzingId: anomaly.id);

    try {
      final service = ref.read(geminiServiceProvider);
      final repo    = ref.read(anomalyRepositoryProvider);

      // Next.js → Gemini
      final explanation = await service.analyzeAnomaly(anomaly);

      if (explanation.isEmpty) {
        state = const GeminiAnalysisState(
          error:
              'AI açıklama üretemedi. Web sunucusunun (Next.js) '
              'çalıştığından ve GEMINI_API_KEY\'in tanımlı olduğundan emin olun.',
        );
        return;
      }

      // Supabase'e yaz (Flutter tarafı — Next.js zaten yazmış olsa da
      // güvenlik için Flutter da kanaldan bağımsız günceller)
      await repo.updateGeminiExplanation(
        anomalyId:   anomaly.id,
        explanation: explanation,
      );

      // ── ADIM 1: State'i hemen güncelle ──────────────────────────────
      // Bottom sheet bu state'i izlediği için provider refetch
      // tamamlanmadan yeşil kart ANINDA ekranda belirir.
      state = GeminiAnalysisState(
        lastAnalyzedId:  anomaly.id,
        lastExplanation: explanation,
      );

      // ── ADIM 2: Arka planda provider'ı yenile ───────────────────────
      // Dashboard (limit=5) ve liste (limit=50) her ikisi de güncellenir.
      ref.invalidate(anomalyListProvider);

    } on Exception catch (e) {
      final msg = e.toString().toLowerCase();

      // ── 503 / sunucu yoğunluk tespiti ────────────────────────────────────
      // Next.js proxy veya Gemini API'den 503, "overloaded", "unavailable",
      // "service unavailable" gibi ifadeler geldiğinde özel sentinel kullan.
      // UI katmanı (anomaly_list_page) bu sentinel'ı okuyarak
      // SnackbarHelper.showAiBusy() ile zarif bir bildirim gösterir.
      final isBusy = msg.contains('503') ||
          msg.contains('overload') ||
          msg.contains('unavailable') ||
          msg.contains('service') ||
          msg.contains('yoğun');

      if (isBusy) {
        // Sentinel: AI_BUSY  — UI bu değeri okuyarak showAiBusy() çağırır
        state = const GeminiAnalysisState(error: 'AI_BUSY');
      } else {
        state = GeminiAnalysisState(error: 'Analiz hatası: $e');
      }
    }
  }

  /// SnackBar gösterildikten sonra hata temizlenir.
  void clearError() => state = const GeminiAnalysisState();
}

final geminiAnalysisProvider =
    AutoDisposeNotifierProvider<GeminiAnalysisNotifier, GeminiAnalysisState>(
  GeminiAnalysisNotifier.new,
);
