import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('СТАТИСТИКА И СТАБИЛЬНОСТЬ')),
      body: const Center(child: Text('Аналитика и графики')),
    );
  }
}
