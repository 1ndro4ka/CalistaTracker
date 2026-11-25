# Calista Tracker

> Минималистичный трекер привычек с монохромным интерфейсом, тонкими линиями и уникальной механикой **«Гибкой серии»** (Streak Freeze & Stability Index).

Проект индивидуальной производственной практики. Разработан на **Flutter** с соблюдением принципов **Clean Architecture**.

---

## 📱 Стек технологий

- **Фреймворк:** Flutter (stable) & Dart (null-safety)
- **Архитектура:** Clean Architecture (Feature-first: `data` / `domain` / `presentation`)
- **Состояние:** `flutter_riverpod`
- **Локальное хранилище:** `drift` (SQLite) + `sqlite3_flutter_libs`
- **Маршрутизация:** `go_router`
- **Уведомления:** `flutter_local_notifications` + `timezone`
- **Дизайн-система:** Monochromatic Minimalist Design System (`#0A0A0A` background, hairline borders, `JetBrains Mono`)
- **Тестирование:** `flutter_test`, `mocktail`
- **CI/CD:** GitHub Actions (автоматический анализ кода, запуск тестов, сборка Android APK и iOS IPA)

---

## 📂 Структура репозитория

```
.
├── .github/workflows/    # CI/CD пайплайны (проверка, тесты, сборки APK/IPA)
├── docs/                 # Проектная документация по ТЗ
│   ├── competitors/      # Анализ конкурентов, 15+ жалоб, выбор уникальной функции
│   ├── uml/              # UML-диаграммы (Use Case, Class, Component)
│   ├── adr/              # Architecture Decision Records (6 записей)
│   └── wireframes/       # Wireframes основных экранов
├── lib/
│   ├── core/             # Дизайн-система, тема, токены анимации, утилиты
│   └── features/         # Модули (habits, stats, reminders)
│       ├── data/         # Drift tables, DAO, repository implementations
│       ├── domain/       # Entities, repository interfaces, use cases
│       └── presentation/ # Экраны, виджеты, riverpod-провайдеры
└── test/                 # Юнит- и интеграционные тесты
```

---

## 🚀 Запуск и сборка

### Требования
- Flutter SDK 3.24+ (или новее)
- Android Studio / Android SDK (minSdkVersion 26)

### Установка зависимостей
```bash
flutter pub get
```

### Запуск статического анализа и тестов
```bash
flutter analyze
flutter test
```

### Запуск приложения на устройстве / эмуляторе
```bash
flutter run
```

### Сборка релизного APK
```bash
flutter build apk --release
```
Файл APK будет сформирован в `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📄 Документация
Подробная документация размещена в каталоге [`docs/`](docs/README.md).
