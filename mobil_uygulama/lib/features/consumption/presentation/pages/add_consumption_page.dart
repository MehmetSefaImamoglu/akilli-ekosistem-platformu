// lib/features/consumption/presentation/pages/add_consumption_page.dart
//
// Fonksiyonel ilkeler:
//   - Form state'i ConsumerStatefulWidget içinde izole edildi.
//   - Payload oluşturma saf (pure): _buildPayload() hiç side-effect yok.
//   - Supabase yan etkisi yalnızca _submit() içinde, try/catch ile izole.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../models/consumption_model.dart';
import '../../providers/consumption_provider.dart';

class AddConsumptionPage extends ConsumerStatefulWidget {
  const AddConsumptionPage({super.key});

  @override
  ConsumerState<AddConsumptionPage> createState() =>
      _AddConsumptionPageState();
}

class _AddConsumptionPageState extends ConsumerState<AddConsumptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  ConsumptionType _selectedType = ConsumptionType.electricity;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // ── Pure: tür → görüntüleme metni ───────────────────
  static String _labelFor(ConsumptionType t) => switch (t) {
        ConsumptionType.electricity => 'Elektrik',
        ConsumptionType.water => 'Su',
        ConsumptionType.gas => 'Gaz',
      };

  static String _unitFor(ConsumptionType t) => switch (t) {
        ConsumptionType.electricity => 'kWh',
        ConsumptionType.water => 'L',
        ConsumptionType.gas => 'm³',
      };

  static IconData _iconFor(ConsumptionType t) => switch (t) {
        ConsumptionType.electricity => Icons.bolt_rounded,
        ConsumptionType.water => Icons.water_drop_rounded,
        ConsumptionType.gas => Icons.local_fire_department_rounded,
      };

  static Color _colorFor(ConsumptionType t) => switch (t) {
        ConsumptionType.electricity => Colors.amber,
        ConsumptionType.water => Colors.blue,
        ConsumptionType.gas => Colors.orange,
      };

  // ── Tarih seçici ────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      locale: const Locale('tr'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Submit ──────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final value = double.tryParse(
      _valueController.text.replaceAll(',', '.'),
    );
    if (value == null || value <= 0) {
      _showSnack('Lütfen geçerli bir sayı girin.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(consumptionListProvider.notifier).addConsumption(
            type: _selectedType,
            value: value,
            recordedAt: _selectedDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        _showSnack('Tüketim başarıyla kaydedildi ✅');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorFor(_selectedType);
    final unit = _unitFor(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüketim Ekle'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tür Seçimi ─────────────────────────────────
              Text(
                'Tüketim Türü',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                children: ConsumptionType.values.map((type) {
                  final selected = type == _selectedType;
                  final c = _colorFor(type);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = type),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? c.withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color:
                                    selected ? c : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Icon(_iconFor(type),
                                    color: selected ? c : theme.colorScheme.onSurfaceVariant,
                                    size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  _labelFor(type),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: selected
                                        ? c
                                        : theme.colorScheme.onSurfaceVariant,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Miktar ─────────────────────────────────────
              TextFormField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Miktar',
                  hintText: 'Örn: 50',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(_iconFor(_selectedType), color: color),
                  suffixText: unit,
                  suffixStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Miktar giriniz';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Geçerli bir sayı girin';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Tarih ──────────────────────────────────────
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarih',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    DateFormat('dd MMMM yyyy', 'tr').format(_selectedDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Notlar ─────────────────────────────────────
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar (opsiyonel)',
                  hintText: 'Örn: Ay sonu faturam arttı...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 42),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Gönder Butonu ──────────────────────────────
              FilledButton.icon(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isLoading ? 'Kaydediliyor...' : 'Kaydet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
