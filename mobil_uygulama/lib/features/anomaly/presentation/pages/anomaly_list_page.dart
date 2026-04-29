// lib/features/anomaly/presentation/pages/anomaly_list_page.dart
//
// Hafta 6 — Tam Anomali Listesi Sayfası + AI Analiz Entegrasyonu
//
// UI anlık güncelleme çözümü:
//   _AnomalyDetailSheet iki kaynaktan okur:
//   1. geminiState.lastExplanation  → API cevabı gelir gelmez ANINDA gösterir
//   2. anomaly.geminiExplanation    → Provider refetch sonrası DB'den gelir
//   Hangisi önce gelirse onu kullanır — asla boş kalmaz.
//
//   AsyncValue.value kullanımı:
//   whenOrNull yerine .value ile provider invalidate sırasında da
//   önceki veri korunur; flicker (beyaz flash) olmaz.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/snackbar_helper.dart';
import '../../../../models/anomaly_model.dart';
import '../../providers/anomaly_provider.dart';
import '../widgets/anomaly_card.dart';
import '../widgets/anomaly_shimmer_card.dart';

// ══════════════════════════════════════════════════════════════
// AnomalyListPage
// ══════════════════════════════════════════════════════════════
class AnomalyListPage extends ConsumerWidget {
  const AnomalyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anomalyAsync = ref.watch(anomalyListProvider(50));
    final geminiState  = ref.watch(geminiAnalysisProvider);

    // Hata → SnackBar, asla kırmızı çökme ekranı
    // Hafta 10: AI_BUSY sentinel → showAiBusy(), diğer hatalar → showError()
    ref.listen<GeminiAnalysisState>(geminiAnalysisProvider, (_, next) {
      if (next.error != null && !next.isLoading) {
        if (next.error == 'AI_BUSY') {
          // 503 / Gemini sunucu yoğunluğu — zarfıf mor bildirim
          SnackbarHelper.showAiBusy(
            context,
            onRetry: () {
              // Analiz edilmemiş ilk anomaliyi tekrar tetikle
              final anomalies = ref.read(anomalyListProvider(50)).value;
              final first     = anomalies
                  ?.where((a) => a.geminiExplanation == null)
                  .firstOrNull;
              if (first != null) {
                ref.read(geminiAnalysisProvider.notifier).analyze(first);
              }
            },
          );
        } else {
          // Genel hata — kırmızı bildirim
          SnackbarHelper.showError(
            context,
            next.error!,
            actionLabel: 'Tamam',
            onAction:    () =>
                ref.read(geminiAnalysisProvider.notifier).clearError(),
          );
        }
        ref.read(geminiAnalysisProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anomali Raporları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
            onPressed: () => ref.invalidate(anomalyListProvider(50)),
          ),
        ],
      ),

      // ── FAB: Analiz edilmemiş ilk anomaliyi tetikle ──────────
      floatingActionButton: anomalyAsync.whenOrNull(
        data: (anomalies) {
          final unanalyzed =
              anomalies.where((a) => a.geminiExplanation == null).toList();
          if (unanalyzed.isEmpty) return null;

          return FloatingActionButton.extended(
            onPressed: geminiState.isLoading
                ? null
                : () => ref
                    .read(geminiAnalysisProvider.notifier)
                    .analyze(unanalyzed.first),
            icon: geminiState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_fix_high_rounded),
            label: Text(
              geminiState.isLoading ? 'Analiz ediliyor...' : 'AI Analiz',
            ),
          );
        },
      ),

      // ── Body ────────────────────────────────────────────────
      body: anomalyAsync.when(
        loading: () => _buildSkeleton(),
        error:   (e, _) => _buildError(context, ref, e),
        data:    (anomalies) => anomalies.isEmpty
            ? _buildEmpty(context)
            : _buildList(context, ref, anomalies, geminiState),
      ),
    );
  }

  // ── Liste ──────────────────────────────────────────────────
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<AnomalyModel> anomalies,
    GeminiAnalysisState geminiState,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: anomalies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final anomaly = anomalies[index];
        final isBeingAnalyzed =
            geminiState.isLoading && geminiState.analyzingId == anomaly.id;

        return Stack(
          children: [
            AnomalyCard(
              anomaly: anomaly,
              onTap: () => _showDetailSheet(context, ref, anomaly.id),
            ),
            if (isBeingAnalyzed)
              // Hafta 10: CircularProgressIndicator yerine GeminiShimmerBlock
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const GeminiShimmerBlock(),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Skeleton — Hafta 10: AnomalyShimmerCard kullanılıyor ──────────────────
  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const AnomalyShimmerCard(),
    );
  }

  // ── Hata durumu ────────────────────────────────────────────
  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Anomaliler yüklenemedi',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(anomalyListProvider(50)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Boş durum ──────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              'Henüz anomali kaydı yok',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'AI anomali tespit motoru eşik değerlerini izlemeye devam ediyor.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Sheet açıcı ─────────────────────────────────────
  void _showDetailSheet(BuildContext context, WidgetRef ref, String anomalyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AnomalyDetailSheet(anomalyId: anomalyId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AnomalyDetailSheet
//
// ConsumerWidget olduğu için hem anomalyListProvider(50) hem de
// geminiAnalysisProvider'ı izler.
//
// Anlık güncelleme mantığı:
//   freshExplanation = geminiState.lastExplanation  (API'den yeni geldi)
//                   ?? anomaly.geminiExplanation    (DB'den okundu)
//   Hangisi doluysa onu kullanır; provider refetch beklenmez.
// ══════════════════════════════════════════════════════════════
class _AnomalyDetailSheet extends ConsumerWidget {
  const _AnomalyDetailSheet({required this.anomalyId});

  final String anomalyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme       = Theme.of(context);
    final geminiState = ref.watch(geminiAnalysisProvider);
    final listAsync   = ref.watch(anomalyListProvider(50));

    // AsyncValue.value kullan → provider invalidate/loading sırasında önceki
    // veriyi korur; flicker ve null flash olmaz.
    final anomaly = listAsync.value
        ?.where((a) => a.id == anomalyId)
        .firstOrNull;

    if (anomaly == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final (_, iconColor, _) = _severityColors(anomaly.severity);
    final dt            = anomaly.detectedAt.toLocal();
    final dateFormatted = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(dt);

    // ── Anlık güncelleme: state → DB, hangisi doluysa ───────
    final freshExplanation =
        (geminiState.lastAnalyzedId == anomalyId &&
                geminiState.lastExplanation != null &&
                geminiState.lastExplanation!.isNotEmpty)
            ? geminiState.lastExplanation!
            : (anomaly.geminiExplanation ?? '');

    final hasAi              = freshExplanation.isNotEmpty;
    final isBeingAnalyzed    =
        geminiState.isLoading && geminiState.analyzingId == anomalyId;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize:     0.4,
      maxChildSize:     0.92,
      expand:           false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Drag handle ──────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Başlık ───────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnomalySeverityBadge(severity: anomaly.severity),
                        const SizedBox(height: 6),
                        Text(
                          anomaly.description,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // ── Tüketim Detayları ────────────────────────────
              Text(
                'Tüketim Detayları',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon:  Icons.trending_up_rounded,
                color: theme.colorScheme.error,
                label: 'Tespit Edilen Değer',
                value: anomaly.detectedValue.toStringAsFixed(1),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon:  Icons.horizontal_rule_rounded,
                color: theme.colorScheme.primary,
                label: 'Beklenen Değer (Eşik)',
                value: anomaly.expectedValue.toStringAsFixed(1),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon:  Icons.percent_rounded,
                color: theme.colorScheme.error,
                label: 'Sapma Oranı',
                value: '%${anomaly.deviationPercent.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon:  Icons.access_time_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                label: 'Tespit Tarihi',
                value: dateFormatted,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon:  Icons.info_outline_rounded,
                color: _statusColor(anomaly.status, theme),
                label: 'Durum',
                value: _statusLabel(anomaly.status),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // ── AI Analiz Bölümü ─────────────────────────────
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 18, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Gemini AI Analizi',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── 3 durum — if / else if / else ────────────────

              if (hasAi)
                // Durum 1: Açıklama var → yeşil kart
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık satırı
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 15, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'AI Açıklaması',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Metin: min 150px / max 400px — maxLines: null = asla kısıtlama yok
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 150,
                          maxHeight: 400,
                        ),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Text(
                            freshExplanation,
                            maxLines: null,      // ← HİÇBİR KISITLAMA YOK
                            softWrap: true,
                            overflow: TextOverflow.clip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:  Colors.green.shade900,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              else if (isBeingAnalyzed)
                // Durum 2: Analiz sürüyor → spinner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Gemini analiz ediyor, lütfen bekleyin...',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )

              else
                // Durum 3: Analiz edilmemiş → buton
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: geminiState.isLoading
                        ? null
                        : () => ref
                            .read(geminiAnalysisProvider.notifier)
                            .analyze(anomaly),
                    icon:  const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Bu Anomaliyi AI ile Analiz Et'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

            ],
          ),
        );
      },
    );
  }

  // ── Yardımcılar ────────────────────────────────────────────
  (Color, Color, Color) _severityColors(AnomalySeverity s) =>
      switch (s) {
        AnomalySeverity.critical => (
            const Color(0xFFFFEBEE),
            const Color(0xFFC62828),
            const Color(0xFFEF9A9A),
          ),
        AnomalySeverity.high => (
            const Color(0xFFFFF3E0),
            const Color(0xFFE65100),
            const Color(0xFFFFCC80),
          ),
        AnomalySeverity.medium => (
            const Color(0xFFFFFDE7),
            const Color(0xFFF9A825),
            const Color(0xFFFFF176),
          ),
        AnomalySeverity.low => (
            const Color(0xFFF1F8E9),
            const Color(0xFF558B2F),
            const Color(0xFFAED581),
          ),
      };

  Color _statusColor(AnomalyStatus s, ThemeData t) =>
      switch (s) {
        AnomalyStatus.open         => t.colorScheme.error,
        AnomalyStatus.acknowledged => Colors.orange,
        AnomalyStatus.resolved     => Colors.green,
      };

  String _statusLabel(AnomalyStatus s) =>
      switch (s) {
        AnomalyStatus.open         => 'Açık',
        AnomalyStatus.acknowledged => 'İnceleniyor',
        AnomalyStatus.resolved     => 'Çözüldü',
      };
}

// ──────────────────────────────────────────────────────────────
// _DetailRow — Label + Value ikilisi
// ──────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
