import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/bootstrap/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Контейнер создаётся один раз: bootstrap и приложение используют одну и ту
  // же БД и один и тот же экземпляр планировщика уведомлений.
  final container = ProviderContainer();
  await AppBootstrap.run(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const CalistaApp()),
  );
}
