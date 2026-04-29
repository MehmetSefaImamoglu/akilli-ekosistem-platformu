// lib/core/utils/snackbar_helper.dart
//
// Hafta 10 — Merkezi SnackBar Yardımcı Sınıfı
//
// Uygulamanın her yerinden tek satırla çağrılabilen,
// tutarlı tasarımlı bildirim fonksiyonları.
//
// Kullanım:
//   SnackbarHelper.showSuccess(context, 'İşlem başarılı!');
//   SnackbarHelper.showError(context, 'Bir hata oluştu.');
//   SnackbarHelper.showAiBusy(context);          // 503 / yoğunluk hatası
//   SnackbarHelper.showInfo(context, 'Bilgi...');

import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
// SnackbarHelper — Pure static utility class
// Hiçbir state tutmaz, sadece ScaffoldMessenger üzerinden
// önceden tanımlanmış renk + ikon şablonlarını gösterir.
// ══════════════════════════════════════════════════════════════
abstract final class SnackbarHelper {

  // ── Başarı bildirimi (Yeşil) ──────────────────────────────────────────────
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message:    message,
      icon:       Icons.check_circle_rounded,
      background: const Color(0xFF166534),   // green-800
      foreground: const Color(0xFFDCFCE7),   // green-100
      duration:   duration,
    );
  }

  // ── Hata bildirimi (Kırmızı) ──────────────────────────────────────────────
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message:     message,
      icon:        Icons.error_rounded,
      background:  const Color(0xFF7F1D1D),  // red-900
      foreground:  const Color(0xFFFEE2E2),  // red-100
      duration:    duration,
      actionLabel: actionLabel,
      onAction:    onAction,
    );
  }

  // ── Uyarı bildirimi (Turuncu/Amber) ──────────────────────────────────────
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message:    message,
      icon:       Icons.warning_amber_rounded,
      background: const Color(0xFF78350F),   // amber-900
      foreground: const Color(0xFFFEF3C7),   // amber-100
      duration:   duration,
    );
  }

  // ── Bilgi bildirimi (Mavi) ────────────────────────────────────────────────
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message:    message,
      icon:       Icons.info_rounded,
      background: const Color(0xFF1E3A5F),   // blue-900
      foreground: const Color(0xFFDBEAFE),   // blue-100
      duration:   duration,
    );
  }

  // ── AI Sunucu Yoğunluk Hatası (503) ──────────────────────────────────────
  //
  // Gemini / Next.js proxy'den 503 veya "overloaded" hatası geldiğinde
  // çağrılır. "Tekrar Dene" butonu ile isteğe bağlı retry callback'i sunar.
  //
  // Kullanım:
  //   SnackbarHelper.showAiBusy(context, onRetry: () => notifier.analyze(anomaly));
  static void showAiBusy(
    BuildContext context, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 6),
  }) {
    _show(
      context,
      message: 'AI sunucuları şu an yoğun, lütfen birazdan tekrar deneyin.',
      icon:       Icons.cloud_off_rounded,
      background: const Color(0xFF4A1D96),   // violet-900
      foreground: const Color(0xFFEDE9FE),   // violet-100
      duration:   duration,
      actionLabel: onRetry != null ? 'Tekrar Dene' : null,
      onAction:    onRetry,
    );
  }

  // ── İç yardımcı: SnackBar oluşturucu ─────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String   message,
    required IconData icon,
    required Color    background,
    required Color    foreground,
    required Duration duration,
    String?        actionLabel,
    VoidCallback?  onAction,
  }) {
    // Önceki snackbar'ı kapat
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration:  duration,
        behavior:  SnackBarBehavior.floating,
        margin:    const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color:      foreground,
                  fontSize:   13.5,
                  fontWeight: FontWeight.w500,
                  height:     1.4,
                ),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
                label:     actionLabel,
                textColor: foreground,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
              )
            : null,
      ),
    );
  }
}
