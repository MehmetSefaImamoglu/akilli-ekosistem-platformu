// lib/features/consumption/presentation/widgets/consumption_bar_chart.dart
//
// fl_chart BarChart - Son 7 gunun tuketim verisi.
//
// Fonksiyonel ilkeler:
//   - Veri donusumu (groupByDay) saf fonksiyon - state yok.
//   - Her tur icin renk ve ikon sabitleri (immutable).
//   - Loading / error / empty state ayri pure widget'lar.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../models/consumption_model.dart';
import '../../providers/consumption_provider.dart';

// Renk & ikon sabitleri (pure, degistirilemez)
const _typeColors = {
  ConsumptionType.electricity: Colors.amber,
  ConsumptionType.water: Colors.blue,
  ConsumptionType.gas: Colors.deepOrange,
};

const _typeLabels = {
  ConsumptionType.electricity: 'Elektrik',
  ConsumptionType.water: 'Su',
  ConsumptionType.gas: 'Gaz',
};

// Pure: List<ConsumptionModel> -> {dateStr: {type: total}}
Map<String, Map<ConsumptionType, double>> _groupByDay(
    List<ConsumptionModel> items) {
  return items.fold({}, (acc, item) {
    final day = DateFormat('MM/dd').format(item.recordedAt);
    final current = acc[day] ?? {};
    return {
      ...acc,
      day: {
        ...current,
        item.type: (current[item.type] ?? 0.0) + item.value,
      },
    };
  });
}

// Ana grafik widget'i (Consumer)
class ConsumptionBarChart extends ConsumerWidget {
  const ConsumptionBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(consumptionListProvider);
    final theme = Theme.of(context);

    return async.when(
      loading: () => _LoadingCard(theme: theme),
      error: (e, _) => _ErrorCard(message: e.toString(), theme: theme),
      data: (list) {
        if (list.isEmpty) return _EmptyCard(theme: theme);
        return _ChartCard(data: list, theme: theme);
      },
    );
  }
}

// Grafik karti
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.data, required this.theme});

  final List<ConsumptionModel> data;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDay(data);
    final days = grouped.keys.toList();

    // Bar gruplari: her gun icin 3 cubuk (elektrik, su, gaz)
    final barGroups = List<BarChartGroupData>.generate(days.length, (i) {
      final day = days[i];
      final dayData = grouped[day]!;

      return BarChartGroupData(
        x: i,
        groupVertically: false,
        barsSpace: 3,
        barRods: ConsumptionType.values.map((type) {
          final value = dayData[type] ?? 0.0;
          return BarChartRodData(
            toY: value,
            color: _typeColors[type],
            width: 9,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxValue(grouped),
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          );
        }).toList(),
      );
    });

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      height: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          // Aciklama (legend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ConsumptionType.values.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _typeColors[t],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _typeLabels[t]!,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Grafik
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: _maxValue(grouped) * 1.2,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            days[i],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.inverseSurface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final type = ConsumptionType.values[rodIndex];
                      final unit = switch (type) {
                        ConsumptionType.electricity => 'kWh',
                        ConsumptionType.water => 'L',
                        ConsumptionType.gas => 'm3',
                      };
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} $unit',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pure: tum gruptaki maksimum deger
  double _maxValue(Map<String, Map<ConsumptionType, double>> grouped) {
    double max = 1.0;
    for (final day in grouped.values) {
      for (final v in day.values) {
        if (v > max) max = v;
      }
    }
    return max;
  }
}

// State widget'lari (pure / yeniden kullanilabilir)
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.theme});
  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: theme.colorScheme.error, size: 32),
            const SizedBox(height: 8),
            Text('Veriler alinamadi',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hata detayi: $message',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Henuz kayit yok',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Asagidaki + butonundan tuketim ekleyin',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
