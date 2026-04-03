// lib/features/dashboard/presentation/pages/dashboard_page.dart
//
// Hafta 4: Gercek veri entegrasyonu
//   - consumptionTotalsProvider ile ozet kartlar
//   - ConsumptionBarChart ile fl_chart entegrasyonu
//   - FAB -> /add-consumption sayfasi
// Hafta 5: Anomali tespiti
//   - anomalyListProvider ile Son Anomaliler bölümü

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../anomaly/providers/anomaly_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../consumption/presentation/widgets/consumption_bar_chart.dart';
import '../../../consumption/providers/consumption_provider.dart';
import '../../../../models/anomaly_model.dart';
import '../../../../models/consumption_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final displayName =
        user?.userMetadata?['full_name'] as String? ?? user?.email ?? 'Kullanici';

    // 30 gunluk toplam tuketimler (elektrik, su, gaz)
    final totalsAsync = ref.watch(consumptionTotalsProvider);
    // Son 5 anomali
    final anomalyAsync = ref.watch(anomalyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoSync - Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Bildirimler',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cikis Yap',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cikis Yap'),
                  content: const Text('Oturumu kapatmak istiyor musun?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Iptal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Cikis Yap'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      // -- FAB -> Tuketim Ekle --
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-consumption'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tuketim Ekle'),
        tooltip: 'Yeni tuketim kaydi ekle',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consumptionListProvider);
          ref.invalidate(consumptionTotalsProvider);
          ref.invalidate(anomalyListProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // -- Hos Geldin --
                  Text(
                    'Merhaba, $displayName 👋',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Son 30 gunun tuketim ozeti asagida.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),

                  // -- Ozet Kartlar (totalsAsync) --
                  totalsAsync.when(
                    loading: () => Row(
                      children: List.generate(
                        3,
                        (_) => const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: _SkeletonCard(),
                          ),
                        ),
                      ),
                    ),
                    error: (e, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Ozet hata: $e',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ),
                    data: (totals) => Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Elektrik',
                            value: _fmt(totals[ConsumptionType.electricity]),
                            unit: 'kWh',
                            icon: Icons.bolt_rounded,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Su',
                            value: _fmt(totals[ConsumptionType.water]),
                            unit: 'L',
                            icon: Icons.water_drop_rounded,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Gaz',
                            value: _fmt(totals[ConsumptionType.gas]),
                            unit: 'm3',
                            icon: Icons.local_fire_department_rounded,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // -- Grafik --
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son 7 Gun - Tuketim Grafigi',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        tooltip: 'Yenile',
                        onPressed: () {
                          ref.invalidate(consumptionListProvider);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // fl_chart BarChart widgeti
                  const ConsumptionBarChart(),
                  const SizedBox(height: 24),

                  // -- Son Anomaliler --
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Son Anomaliler',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.go('/anomalies'),
                        child: const Text('Tumunu gor'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  anomalyAsync.when(
                    loading: () => Column(
                      children: List.generate(
                        2,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: _AnomalyCardSkeleton(),
                        ),
                      ),
                    ),
                    error: (e, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: theme.colorScheme.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Anomaliler yuklenemedi: $e',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (anomalies) => anomalies.isEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                    size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Henuz anomali tespit edilmedi',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: anomalies
                                .map((a) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: _AnomalyCard(anomaly: a),
                                    ))
                                .toList(),
                          ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pure formatter: null veya 0 -> '-', aksi halde ondalikli
  static String _fmt(double? v) {
    if (v == null || v == 0) return '-';
    return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }
}

// Ozet Kart Widget
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(unit,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// Skeleton (yukleniyor) Kart
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 28, width: 28,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 8),
            Container(height: 10, width: 40,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 4),
            Container(height: 22, width: 56,
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Anomali Uyarı Kartı
// severity: high → kırmızı, medium → turuncu, low → sarı
// ──────────────────────────────────────────────────────────────
class _AnomalyCard extends StatelessWidget {
  final AnomalyModel anomaly;
  const _AnomalyCard({required this.anomaly});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Şiddete göre renk paleti
    final (cardColor, iconColor, borderColor) = switch (anomaly.severity) {
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

    // Tarih formatlama (GG.AA SS:DD)
    final dt = anomaly.detectedAt.toLocal();
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';

    return Container(
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
            // İkon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Açıklama + tarih
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
                      Icon(Icons.access_time_rounded,
                          size: 13,
                          color: iconColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _SeverityBadge(severity: anomaly.severity),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Şiddet rozeti
class _SeverityBadge extends StatelessWidget {
  final AnomalySeverity severity;
  const _SeverityBadge({required this.severity});

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

// Anomali yükleniyor iskeleti
class _AnomalyCardSkeleton extends StatelessWidget {
  const _AnomalyCardSkeleton();

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
            width: 38, height: 38,
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
                  height: 12, width: double.infinity,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10, width: 120,
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
