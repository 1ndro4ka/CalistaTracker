import 'package:flutter/material.dart';

class HabitFormScreen extends StatelessWidget {
  final String? habitId;

  const HabitFormScreen({super.key, this.habitId});

  @override
  Widget build(BuildContext context) {
    final isEditing = habitId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'РЕДАКТИРОВАТЬ' : 'НОВАЯ ПРИВЫЧКА'),
      ),
      body: const Center(child: Text('Форма привычки')),
    );
  }
}
