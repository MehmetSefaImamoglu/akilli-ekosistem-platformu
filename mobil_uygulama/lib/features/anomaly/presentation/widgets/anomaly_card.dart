// lib/features/anomaly/presentation/widgets/anomaly_card.dart
//
// Hafta 6 — Paylaşımlı Anomali Kart Widget'ı
//
// DRY prensibi: dashboard_page.dart ve anomaly_list_page.dart
// aynı kart görünümünü bu widget üzerinden kullanır.
//
// Dışa aktarılan widget'lar:
//   - AnomalyCard          : tıklanabilir, severity-bazlı renkli kart
//   - AnomalySeverityBadge : şiddet rozeti (YÜKSEK, ORTA, ...)
//   - AnomalyCardSkeleton  : Shimmer efektsiz basit yükleniyor iskeleti

import 'package:flutter/material.dart';

import '../../../../models/anomaly_model.dart';

// ──────────────────────────────────────────────────────────────
// Renk yardımcı fonksiyonu — severity → (card, icon, border)
// ──────────────────────────────────────────────────────────────
(Color cardColor, Color iconColor, Color borderColor) _severityColors(
  AnomalySeverity severity,
) =>
    switch (severity) {
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

// ──────────────────────────────────────────────────────────────
// AnomalyCard
// ──────────────────────────────────────────────────────────────
/// Tek bir anomali kaydını gösterir.
///
/// [onTap] null ise kart pasif (dashboard'daki gibi).
/// [onTap] verilirse `chevron_right` ikonuyla tıklanabilir hale gelir.
/// [geminiExplanation] doluysa ⚡ AI rozetini gösterir.
class AnomalyCard extends StatelessWidget {
  const AnomalyCard({
    super.key,
    required this.anomaly,
    this.onTap,
  });

  final AnomalyModel anomaly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (cardColor, iconColor, borderColor) = _severityColors(anomaly.severity);

    // Tarih formatı: GG.AA SS:DD
    final dt = anomaly.detectedAt.toLocal();
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';

    final hasAi = anomaly.geminiExplanation != null &&
        anomaly.geminiExplanation!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Uyarı İkonu ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // ── Açıklama + Meta ───────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anomaly.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: iconColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: iconColor.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnomalySeverityBadge(severity: anomaly.severity),
                        if (hasAi) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 13,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Chevron (yalnızca tıklanabilirse) ────────
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: iconColor.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// AnomalySeverityBadge
// ──────────────────────────────────────────────────────────────
/// Şiddet seviyesini renkli rozet olarak gösterir.
class AnomalySeverityBadge extends StatelessWidget {
  const AnomalySeverityBadge({super.key, required this.severity});

  final AnomalySeverity severity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      AnomalySeverity.critical => ('KRİTİK', const Color(0xFFC62828)),
      AnomalySeverity.high     => ('YÜKSEK', const Color(0xFFE65100)),
      AnomalySeverity.medium   => ('ORTA',   const Color(0xFFF9A825)),
      AnomalySeverity.low      => ('DÜŞÜK',  const Color(0xFF558B2F)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// AnomalyCardSkeleton
// ──────────────────────────────────────────────────────────────
/// Anomali kartı yüklenirken gösterilen iskelet bileşeni.
/// Hem dashboard hem de anomaly_list_page kullanır.
class AnomalyCardSkeleton extends StatelessWidget {
  const AnomalyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 120,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
