import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnomalyListPage extends ConsumerWidget {
  const AnomalyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anomali Raporları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: filtre bottom sheet
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        // TODO: Supabase'den anomaly listesi çekilecek
        itemCount: 0,
        itemBuilder: (context, index) {
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Manuel anomali analizi tetikleme
        },
        icon: const Icon(Icons.auto_fix_high),
        label: const Text('AI Analiz'),
      ),
    );
  }
}
