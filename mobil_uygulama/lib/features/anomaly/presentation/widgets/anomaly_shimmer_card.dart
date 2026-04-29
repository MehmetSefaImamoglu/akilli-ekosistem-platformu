// lib/features/anomaly/presentation/widgets/anomaly_shimmer_card.dart
//
// Hafta 10 — Shimmer İskelet Yükleme Kartı
//
// Gemini'den uzun AI analizi beklenirken veya liste ilk yüklenirken
// sıradan CircularProgressIndicator yerine modern, yanıp sönen
// iskelet tasarımı (skeleton screen) gösterir.
//
// Kullanım:
//   ListView.builder(
//     itemCount: 4,
//     itemBuilder: (_, __) => const AnomalyShimmerCard(),
//   )

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ══════════════════════════════════════════════════════════════
// AnomalyShimmerCard  — Anomali kartı iskelet yükleme efekti
// ══════════════════════════════════════════════════════════════
class AnomalyShimmerCard extends StatelessWidget {
  const AnomalyShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Koyu temada slate benzeri, açık temada gri tonlar
    final baseColor      = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor:      baseColor,
      highlightColor: highlightColor,
      period:         const Duration(milliseconds: 1200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        baseColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Başlık satırı: badge + büyük metin ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Şiddet badge placeholder
                _ShimmerBox(width: 60, height: 22, radius: 20),
                const SizedBox(width: 10),
                // Başlık metin placeholder
                Expanded(child: _ShimmerBox(height: 16, radius: 4)),
              ],
            ),

            const SizedBox(height: 14),

            // ── Alt satır 1: kısa metin ──────────────────────────────────
            _ShimmerBox(width: 180, height: 12, radius: 4),
            const SizedBox(height: 8),

            // ── Alt satır 2: daha kısa metin ────────────────────────────
            _ShimmerBox(width: 130, height: 12, radius: 4),
            const SizedBox(height: 14),

            // ── AI analiz bölümü placeholder (geniş blok) ────────────────
            _ShimmerBox(height: 48, radius: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GeminiShimmerBlock  — Sadece AI analiz alanı için Shimmer
//
// Bottom Sheet içinde Gemini yanıtı beklenirken spinner yerine
// bu widget kullanılır. Gerçek yeşil kartın boyutuna yakın
// bir iskelet oluşturarak layout kaymasını (CLS) önler.
// ══════════════════════════════════════════════════════════════
class GeminiShimmerBlock extends StatelessWidget {
  const GeminiShimmerBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark         = Theme.of(context).brightness == Brightness.dark;
    final baseColor      = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor:      baseColor,
      highlightColor: highlightColor,
      period:         const Duration(milliseconds: 1000),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        baseColor,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: baseColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık satırı
            Row(
              children: [
                _ShimmerBox(width: 16, height: 16, radius: 8),
                const SizedBox(width: 8),
                _ShimmerBox(width: 100, height: 14, radius: 4),
              ],
            ),
            const SizedBox(height: 12),
            // Metin satırları — farklı genişlikte 4 satır
            _ShimmerBox(height: 12, radius: 4),
            const SizedBox(height: 8),
            _ShimmerBox(height: 12, radius: 4),
            const SizedBox(height: 8),
            _ShimmerBox(width: 220, height: 12, radius: 4),
            const SizedBox(height: 8),
            _ShimmerBox(width: 180, height: 12, radius: 4),
            const SizedBox(height: 8),
            _ShimmerBox(height: 12, radius: 4),
          ],
        ),
      ),
    );
  }
}

// ── Yardımcı: beyaz kutu placeholder ─────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    this.width,
    required this.height,
    this.radius = 4,
  });

  final double? width;
  final double  height;
  final double  radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        // Shimmer.fromColors kendi rengi üzerine boyar;
        // burada Colors.white olması zorunludur.
        color:        Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
