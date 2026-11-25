import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../reminders/presentation/providers/reminder_providers.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_schedule.dart';
import '../providers/database_provider.dart';
import '../providers/habits_provider.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  final String? habitId;

  const HabitFormScreen({super.key, this.habitId});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  bool _isEveryDay = true;
  final Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7};
  bool _enableReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  int _monthlyFreezes = 2;
  bool _isLoading = true;
  Habit? _existingHabit;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.habitId != null) {
      final repo = ref.read(habitRepositoryProvider);
      final habit = await repo.getHabitById(widget.habitId!);
      if (habit != null) {
        _existingHabit = habit;
        _titleController.text = habit.title;
        _descController.text = habit.description;
        _isEveryDay = habit.schedule.type == ScheduleType.everyDay;
        _selectedDays.clear();
        _selectedDays.addAll(habit.schedule.daysOfWeek);
        _monthlyFreezes = habit.monthlyFreezesAllowed;

        if (habit.reminderTime != null) {
          _enableReminder = true;
          final parts = habit.reminderTime!.split(':');
          if (parts.length == 2) {
            _reminderTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 21,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    await AppFeedback.selection();
    if (!mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      await AppFeedback.error();
      return;
    }

    final id =
        _existingHabit?.id ?? 'h_${DateTime.now().millisecondsSinceEpoch}';
    final schedule = _isEveryDay
        ? const HabitSchedule.everyDay()
        : HabitSchedule.specificDays(_selectedDays.toList()..sort());

    final reminderStr = _enableReminder
        ? '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'
        : null;

    final habit = Habit(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      schedule: schedule,
      createdAt: _existingHabit?.createdAt ?? DateTime.now(),
      reminderTime: reminderStr,
      monthlyFreezesAllowed: _monthlyFreezes,
    );

    await ref.read(habitsProvider.notifier).saveHabit(habit);
    await AppFeedback.selection();

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    final isEdit = _existingHabit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'РЕДАКТИРОВАТЬ' : 'НОВАЯ ПРИВЫЧКА'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'СОХРАНИТЬ',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title input
            const Text('НАЗВАНИЕ', style: AppTypography.caption),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Например: Чтение 20 страниц',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.textPrimary,
                    width: 1.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 1.0,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Введите название привычки';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Description input
            const Text('ОПИСАНИЕ (ОПЦИОНАЛЬНО)', style: AppTypography.caption),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              style: AppTypography.bodyMedium,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Контекст или цель',
                hintStyle: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.textPrimary,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Schedule Section
            const Text('РАСПИСАНИЕ', style: AppTypography.caption),
            const SizedBox(height: 8),
            Row(
              children: [
                _ScheduleOption(
                  label: 'Каждый день',
                  isSelected: _isEveryDay,
                  onTap: () {
                    AppFeedback.selection();
                    setState(() {
                      _isEveryDay = true;
                      _selectedDays.addAll([1, 2, 3, 4, 5, 6, 7]);
                    });
                  },
                ),
                const SizedBox(width: 8),
                _ScheduleOption(
                  label: 'Дни недели',
                  isSelected: !_isEveryDay,
                  onTap: () {
                    AppFeedback.selection();
                    setState(() => _isEveryDay = false);
                  },
                ),
              ],
            ),
            if (!_isEveryDay) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DayChip(
                    dayNum: 1,
                    label: 'ПН',
                    selected: _selectedDays.contains(1),
                    onToggle: () => _toggleDay(1),
                  ),
                  _DayChip(
                    dayNum: 2,
                    label: 'ВТ',
                    selected: _selectedDays.contains(2),
                    onToggle: () => _toggleDay(2),
                  ),
                  _DayChip(
                    dayNum: 3,
                    label: 'СР',
                    selected: _selectedDays.contains(3),
                    onToggle: () => _toggleDay(3),
                  ),
                  _DayChip(
                    dayNum: 4,
                    label: 'ЧТ',
                    selected: _selectedDays.contains(4),
                    onToggle: () => _toggleDay(4),
                  ),
                  _DayChip(
                    dayNum: 5,
                    label: 'ПТ',
                    selected: _selectedDays.contains(5),
                    onToggle: () => _toggleDay(5),
                  ),
                  _DayChip(
                    dayNum: 6,
                    label: 'СБ',
                    selected: _selectedDays.contains(6),
                    onToggle: () => _toggleDay(6),
                  ),
                  _DayChip(
                    dayNum: 7,
                    label: 'ВС',
                    selected: _selectedDays.contains(7),
                    onToggle: () => _toggleDay(7),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Reminder section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ЛОКАЛЬНОЕ НАПОМИНАНИЕ',
                          style: AppTypography.titleMedium,
                        ),
                        if (_enableReminder)
                          Text(
                            'Время: ${_reminderTime.format(context)}',
                            style: AppTypography.caption,
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableReminder,
                    activeThumbColor: AppColors.textPrimary,
                    onChanged: (val) async {
                      final messenger = ScaffoldMessenger.of(context);
                      await AppFeedback.selection();
                      setState(() => _enableReminder = val);
                      if (!val) return;

                      // Разрешение запрашивается в момент первого включения
                      // напоминания, а не при старте приложения.
                      final granted = await ref
                          .read(reminderSchedulerProvider)
                          .requestPermissions();
                      if (!granted && mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.surfaceElevated,
                            content: Text(
                              'Уведомления запрещены в настройках системы. '
                              'Напоминание сохранится, но не будет показано.',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        );
                      }
                      if (mounted) await _pickTime();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Unique feature config: Freezes
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('❄', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'ГИБКАЯ СЕРИЯ (ЗАМОРОЗКИ)',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'При случайном пропуске дня серия не сгорает, а автоматически использует заморозку из месячной квоты.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Лимит на месяц:',
                        style: AppTypography.bodyMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: _monthlyFreezes > 1
                                ? () {
                                    AppFeedback.selection();
                                    setState(() => _monthlyFreezes--);
                                  }
                                : null,
                          ),
                          Text(
                            '$_monthlyFreezes',
                            style: AppTypography.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: _monthlyFreezes < 5
                                ? () {
                                    AppFeedback.selection();
                                    setState(() => _monthlyFreezes++);
                                  }
                                : null,
                          ),
                        ],
                      ),
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

  void _toggleDay(int day) {
    AppFeedback.selection();
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }
}

class _ScheduleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScheduleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
              width: 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.background
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int dayNum;
  final String label;
  final bool selected;
  final VoidCallback onToggle;

  const _DayChip({
    required this.dayNum,
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: 0.8,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.background : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
