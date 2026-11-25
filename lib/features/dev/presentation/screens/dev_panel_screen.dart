import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/clock_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../habits/presentation/providers/habits_provider.dart';
import '../providers/dev_panel_provider.dart';

/// Скрытая панель для проверки сценариев без ожидания реальных дней.
///
/// Открывается долгим нажатием на заголовок экрана «Сегодня» и намеренно
/// доступна во всех сборках, чтобы сценарий можно было показать на защите.
class DevPanelScreen extends ConsumerStatefulWidget {
  const DevPanelScreen({super.key});

  @override
  ConsumerState<DevPanelScreen> createState() => _DevPanelScreenState();
}

class _DevPanelScreenState extends ConsumerState<DevPanelScreen> {
  final _secondsController = TextEditingController(text: '10');
  String? _selectedHabitId;
  bool _busy = false;

  @override
  void dispose() {
    _secondsController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Text(message, style: AppTypography.bodySmall),
        ),
      );
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() => _busy = true);
    try {
      _toast(await action());
    } catch (error) {
      _toast('ОШИБКА: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(devPanelControllerProvider);
    final clock = ref.watch(clockProvider);
    final now = clock.currentTime;
    final habits = ref.watch(habitsProvider).value ?? const [];
    final selectedId =
        _selectedHabitId ?? (habits.isEmpty ? null : habits.first.habit.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('СЕКРЕТНАЯ ПАНЕЛЬ', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'ДАННЫЕ',
            children: [
              const _Hint(
                'Фиксированные демо-привычки с историей за 17 дней. '
                'Повторное нажатие ничего не дублирует.',
              ),
              _Action(
                label: 'СОЗДАТЬ ДЕМО-ПРИВЫЧКИ',
                icon: Icons.dataset_outlined,
                enabled: !_busy,
                onPressed: () => _run(() async {
                  final created = await controller.seedDemoData();
                  return created == 0
                      ? 'Демо-привычки уже есть в базе'
                      : 'Создано демо-привычек: $created';
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Section(
            title: 'СИМУЛЯЦИЯ ПРОПУСКОВ',
            children: [
              const _Hint(
                'Удаляет отметки за последние дни и сразу запускает '
                'автозаморозку. Третий пропуск в месяце разорвёт серию.',
              ),
              if (habits.isEmpty)
                const _Hint('Сначала создайте демо-привычки или привычку в UI.')
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  decoration: const InputDecoration(
                    labelText: 'ПРИВЫЧКА',
                    labelStyle: AppTypography.caption,
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: AppColors.surfaceElevated,
                  style: AppTypography.bodySmall,
                  items: [
                    for (final item in habits)
                      DropdownMenuItem<String>(
                        value: item.habit.id,
                        child: Text(item.habit.title),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedHabitId = value),
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  for (final days in [1, 2, 3])
                    _Chip(
                      label: '−$days ${_dayWord(days)}',
                      enabled: !_busy && selectedId != null,
                      onPressed: () => _run(() async {
                        final freezes = await controller.simulateMissedDays(
                          selectedId!,
                          days,
                        );
                        return 'Пропусков: $days • новых заморозок: $freezes';
                      }),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Section(
            title: 'ПУТЕШЕСТВИЕ ВО ВРЕМЕНИ',
            children: [
              _Hint(
                'Виртуальное сегодня: ${AppDateFormatter.formatToday(now)}. '
                'Меняет расчёты серий, заморозок и квоты. '
                'Системные будильники ОС не сдвигаются.',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(
                    label: '−1 ДЕНЬ',
                    enabled: !_busy,
                    onPressed: () => _run(() async {
                      await controller.shiftDays(-1);
                      return 'Дата: ${AppDateFormatter.formatToday(ref.read(clockProvider).now())}';
                    }),
                  ),
                  _Chip(
                    label: '+1 ДЕНЬ',
                    enabled: !_busy,
                    onPressed: () => _run(() async {
                      await controller.shiftDays(1);
                      return 'Дата: ${AppDateFormatter.formatToday(ref.read(clockProvider).now())}';
                    }),
                  ),
                  _Chip(
                    label: 'ВЫБРАТЬ ДАТУ',
                    enabled: !_busy,
                    onPressed: _pickDate,
                  ),
                  _Chip(
                    label: 'СИСТЕМНАЯ ДАТА',
                    enabled: !_busy,
                    onPressed: () => _run(() async {
                      await controller.resetDate();
                      return 'Сброшено на ${AppDateFormatter.formatToday(ref.read(clockProvider).now())}';
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Section(
            title: 'УВЕДОМЛЕНИЯ',
            children: [
              const _Hint(
                'На Android/iOS запросит разрешение и покажет уведомление. '
                'Таймер планирует его через выбранное число секунд.',
              ),
              _Action(
                label: 'ПОКАЗАТЬ СЕЙЧАС',
                icon: Icons.notifications_active_outlined,
                enabled: !_busy,
                onPressed: () => _run(() async {
                  await controller.showNotificationNow();
                  return 'Тестовое уведомление отправлено';
                }),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _secondsController,
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodySmall,
                      decoration: const InputDecoration(
                        labelText: 'СЕКУНД',
                        labelStyle: AppTypography.caption,
                        filled: true,
                        fillColor: AppColors.surfaceMuted,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Action(
                      label: 'ЗАПЛАНИРОВАТЬ',
                      icon: Icons.schedule_outlined,
                      enabled: !_busy,
                      onPressed: () => _run(() async {
                        final seconds = int.tryParse(_secondsController.text);
                        final safe = (seconds ?? 10).clamp(1, 3600);
                        await controller.scheduleNotification(
                          Duration(seconds: safe),
                        );
                        return 'Уведомление через $safe с';
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Action(
                label: 'ОТМЕНИТЬ ЗАПЛАНИРОВАННОЕ',
                icon: Icons.notifications_off_outlined,
                enabled: !_busy,
                onPressed: () => _run(() async {
                  await controller.cancelNotification();
                  return 'Запланированное тестовое уведомление снято';
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final clock = ref.read(clockProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: clock.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    await _run(() async {
      await ref.read(devPanelControllerProvider).setDate(picked);
      return 'Дата: ${AppDateFormatter.formatToday(ref.read(clockProvider).now())}';
    });
  }

  String _dayWord(int days) {
    if (days == 1) return 'день';
    if (days < 5) return 'дня';
    return 'дней';
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// $title',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypography.bodySmall),
    );
  }
}

class _Action extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _Action({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 16),
      label: Text(label, style: AppTypography.bodySmall),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderHighlight, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _Chip({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: AppTypography.caption),
      backgroundColor: AppColors.surfaceMuted,
      side: const BorderSide(color: AppColors.borderHighlight, width: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      onPressed: enabled ? onPressed : null,
    );
  }
}
