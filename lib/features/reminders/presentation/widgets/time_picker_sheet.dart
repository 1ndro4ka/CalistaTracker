import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Крупный колесный выбор времени: час и минуты читаются легко,
/// между соседними значениями достаточно расстояния.
class TimePickerSheet extends StatefulWidget {
  final TimeOfDay initial;

  const TimePickerSheet({super.key, required this.initial});

  static Future<TimeOfDay?> show(BuildContext context, TimeOfDay initial) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (_) => TimePickerSheet(initial: initial),
    );
  }

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  late FixedExtentScrollController _hours;
  late FixedExtentScrollController _minutes;
  late int _hour;
  late int _minute;

  static const double _itemExtent = 72;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _hours = FixedExtentScrollController(initialItem: _hour);
    _minutes = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ОТМЕНА',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Text('ВРЕМЯ НАПОМИНАНИЯ', style: AppTypography.caption),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      TimeOfDay(hour: _hour, minute: _minute),
                    ),
                    child: const Text(
                      'ОК',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: _itemExtent + 8,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.borderHighlight,
                          width: 0.8,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _hours,
                            itemExtent: _itemExtent,
                            squeeze: 1.15,
                            useMagnifier: true,
                            magnification: 1.12,
                            backgroundColor: Colors.transparent,
                            selectionOverlay:
                                const CupertinoPickerDefaultSelectionOverlay(
                                  background: Color(0x00000000),
                                ),
                            onSelectedItemChanged: (index) {
                              setState(() => _hour = index);
                            },
                            children: [
                              for (var hour = 0; hour < 24; hour++)
                                Center(
                                  child: Text(
                                    hour.toString().padLeft(2, '0'),
                                    style: AppTypography.statValue.copyWith(
                                      fontSize: 34,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            ':',
                            style: AppTypography.statValue.copyWith(
                              fontSize: 30,
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: _minutes,
                            itemExtent: _itemExtent,
                            squeeze: 1.15,
                            useMagnifier: true,
                            magnification: 1.12,
                            backgroundColor: Colors.transparent,
                            selectionOverlay:
                                const CupertinoPickerDefaultSelectionOverlay(
                                  background: Color(0x00000000),
                                ),
                            onSelectedItemChanged: (index) {
                              setState(() => _minute = index);
                            },
                            children: [
                              for (var minute = 0; minute < 60; minute++)
                                Center(
                                  child: Text(
                                    minute.toString().padLeft(2, '0'),
                                    style: AppTypography.statValue.copyWith(
                                      fontSize: 34,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'Прокрутите, чтобы выбрать час и минуты',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
