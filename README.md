<img src="docs/assets/logo.png" width="140" alt="Calista Tracker logo" />

# Calista Tracker

> Минималистичный офлайн-трекер привычек с монохромным интерфейсом и уникальной механикой **«Гибкая серия»**: автоматические заморозки пропущенных дней + честный индекс стабильности за 30 дней.

Проект индивидуальной производственной практики. Flutter, Clean Architecture, Drift (SQLite), Riverpod, GoRouter, локальные уведомления. Полностью автономен: без аккаунтов, серверов и облачной синхронизации.

---

## Содержание

- [Ключевая идея](#ключевая-идея)
- [Возможности](#возможности)
- [Стек](#стек)
- [Архитектура](#архитектура)
- [Структура проекта](#структура-проекта)
- [Быстрый старт](#быстрый-старт)
- [Тесты и качество](#тесты-и-качество)
- [CI/CD и сборки](#cicd-и-сборки)
- [Локальные напоминания](#локальные-напоминания)
- [Документация](#документация)
- [Ограничения](#ограничения)
- [Демонстрация](#демонстрация)

---

## Ключевая идея

Классический streak-трекер наказывает за один случайный пропуск: «день 47 → день 0». Это главная причина демотивации и удаления приложений (подробнее — [`docs/competitors/`](docs/competitors/)).

Calista Tracker заменяет бинарную логику на **«Гибкую серию»**:

| Механика | Правило |
|---|---|
| **Заморозка** | Пропущенный запланированный день автоматически закрывается заморозкой `❄` из бесплатной месячной квоты (по умолчанию 2 дня, настраивается 1–5). |
| **Серия** | Замороженный день не рвёт непрерывность, но и не увеличивает счётчик выполненных дней. |
| **Стабильность** | `Stability Index = выполненные дни ÷ запланированные дни × 100%` за скользящие 30 дней. Заморозки не завышают показатель. |
| **Честность** | При исчерпанной квоте следующий пропуск действительно рвёт серию. Квота возобновляется 1-го числа месяца. |
| **Контроль** | Нажатие на `❄`-ячейку превращает заморозку в реальное выполнение задним числом. |

Пример: 4 выполненных дня + 1 пропуск при квоте 2 → серия 4 дня, использовано 1/2 заморозок, индекс стабильности не растёт.

---

## Возможности

- Создание, редактирование, удаление и архивирование привычек.
- Расписание: каждый день или выбранные дни недели.
- Отметка выполнения на сегодня и задним числом (heatmap-календарь).
- Текущая и рекордная серия, остаток заморозок, 30-дневная стабильность.
- Автоматическая материализация заморозок при запуске и обновлении данных.
- Экран статистики: средний индекс, спасённые серии, лучшая серия, разбивка по привычкам.
- Локальные напоминания на Android/iOS с восстановлением после перезагрузки.
- Переход на карточку привычки по нажатию на уведомление (тёплый и холодный старт).
- Монохромная дизайн-система, JetBrains Mono, анимации 150/300/500 мс, haptic-отклик.
- Переходы между экранами, ступенчатое появление карточек, анимация чекбокса и заморозок, заполнение шкал, смена месяца, «бегущая волна» skeleton. Анимации отключаются системной настройкой «уменьшить движение».
- Состояния загрузки (skeleton), пустые состояния, ошибки валидации.
- **Секретная панель тестирования**: долгое нажатие на заголовок «CALISTA TRACKER» → `/dev`. Доступна во всех сборках.

Шрифт JetBrains Mono включён в `assets/fonts`, лицензия OFL — `assets/fonts/OFL.txt`.

### Секретная панель

Долгое нажатие на заголовок экрана «Сегодня» открывает панель `/dev` (доступна и в release-сборке). В ней можно:

- создать фиксированный набор демо-привычек с историей за 17 дней (идемпотентно);
- удалить отметки за 1/2/3 последних дня и сразу прогнать автозаморозку;
- подменить «сегодня» (сдвиг на ±1 день, выбор даты, возврат к системной дате);
- показать тестовое уведомление немедленно или по таймеру в секундах и отменить его.

Подмена даты влияет только на расчёты внутри приложения (серии, заморозки, квоту), не на системные будильники ОС. Реализация: `lib/features/dev/`.

---

## Стек

| Слой | Технологии |
|---|---|
| Язык / UI | Flutter 3.47+, Dart 3.13+ |
| Архитектура | Clean Architecture + Feature-first |
| Состояние | `flutter_riverpod` 3.x |
| Навигация | `go_router` |
| Хранилище | `drift` + SQLite, `sqlite3_flutter_libs`, `path_provider` |
| Уведомления | `flutter_local_notifications`, `timezone`, `flutter_timezone` |
| Анимации | `flutter_animate`, собственные motion-токены |
| Тестирование | `flutter_test`, `mocktail`, Drift in-memory SQLite |
| CI/CD | GitHub Actions: analyze, test, release APK, unsigned IPA |

Обоснование выбора стека — [`docs/adr/`](docs/adr/):
`0001` архитектура, `0002` Flutter, `0003` Drift, `0004` уникальная функция,
`0005` Riverpod, `0006` уведомления и iOS-сборка.

---

## Архитектура

```text
lib/
├── core/
│   ├── bootstrap/      # инициализация БД, заморозок и уведомлений до runApp
│   ├── constants/      # константы приложения и канала уведомлений
│   ├── motion/         # MotionTokens + HapticFeedback
│   ├── router/         # GoRouter
│   ├── theme/          # Monochromatic Minimal Design System
│   └── utils/          # Clock (SystemClock / FixedClock), форматтеры дат
├── features/
│   ├── habits/
│   │   ├── domain/     # Habit, HabitSchedule, HabitCompletion, StreakInfo,
│   │   │               # StabilityMetrics, FreezePolicy, use cases, интерфейсы
│   │   ├── data/       # Drift-таблицы, БД, мапперы, реализации репозиториев
│   │   └── presentation# экраны, виджеты, Riverpod-провайдеры
│   ├── stats/          # агрегированная статистика
│   └── reminders/
│       ├── domain/     # ReminderTime, контракт ReminderScheduler
│       ├── data/       # LocalReminderScheduler (Android/iOS)
│       └── presentation# провайдер планировщика
└── main.dart           # ProviderContainer → AppBootstrap → CalistaApp
```

Правило зависимостей: `presentation → domain ← data`. Домен не импортирует Flutter,
Drift или плагины. Время абстрагировано через `Clock`, поэтому граничные случаи
тестируются детерминированно.

UML-диаграммы: [`docs/uml/`](docs/uml/).

---

## Структура проекта

```text
.
├── .github/workflows/
│   ├── ci.yml                 # format + analyze + test
│   ├── build-android.yml      # release APK
│   └── build-ios.yml          # Runner.app → Payload → .ipa (Sideloadly)
├── android/                   # Android-конфигурация, permissions, receivers
├── ios/                       # iOS-конфигурация, AppDelegate для уведомлений
├── docs/
│   ├── competitors/           # 5+ конкурентов, 15+ болей, value proposition
│   ├── uml/                   # Use Case, Class, Component/Layers
│   ├── adr/                   # 6 Architecture Decision Records
│   ├── wireframes/            # макеты экранов
│   ├── demo/                  # сценарий демонстрации на 1 минуту
│   ├── testing/               # чек-лист реального Android-устройства
│   └── presentation/          # структура защиты и Q&A
├── lib/
└── test/
```

---

## Быстрый старт

### Требования
- Flutter SDK **3.47+** (Dart 3.13+).
- Android SDK, JDK 17, Android-устройство/эмулятор с Android 8+ (для точных будильников — 12+).
- Для iOS-сборки — macOS + Xcode (локально) либо GitHub Actions.

### Установка и запуск
```bash
flutter pub get

# Генерация Drift-кода (при изменении таблиц/аннотаций)
flutter pub run build_runner build

# Запуск
flutter run

# Release APK
flutter build apk --release
```

> Android-сборка использует `compileSdk = 37` и core library desugaring —
> этого требуют `androidx.core` 1.19+ и `flutter_local_notifications`.
> JDK 17 обязателен.

### Анализ и тесты
```bash
flutter analyze
flutter test
```

---

## Тесты и качество

**48 тестов**, все зелёные; `flutter analyze` — 0 issues.

| Группа | Что проверяет |
|---|---|
| `calculate_streak_test.dart` (12) | непрерывные серии, 1–2–3 пропуска, месячная квота, выходные, граница года, отметка задним числом, «сегодня ещё идёт» |
| `calculate_stability_test.dart` (5) | формула 30 дней, заморозки, окно до создания привычки, выборочные дни |
| `auto_freeze_test.dart` (10) | `FreezePolicy`, материализация заморозок, идемпотентность, квота, остановка на разрыве, архив, смена месяца |
| `manage_habit_test.dart` (6) | валидация, trim, архив, каскадное удаление, toggle, превращение заморозки в выполнение |
| `repository_impl_test.dart` (5) | Drift in-memory: CRUD, диапазон дат, индекс схемы |
| `reminder_time_test.dart` (4) | парсинг/сериализация `HH:mm`, некорректные значения |
| `widget_test.dart` (2) | пустое состояние приложения, карточка привычки |

Ключевые технические решения:
- `Clock`/`FixedClock` — детерминированные тесты без `sleep`.
- `HabitCompletion.isFrozen` — единая модель выполнения и заморозки.
- Идемпотентные ID заморозок — повторный запуск не создаёт дублей.
- Drift in-memory — интеграционные тесты без файловой системы.

---

## CI/CD и сборки

| Workflow | Триггер | Результат |
|---|---|---|
| `ci.yml` | push/PR в `main`/`master` | `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test` |
| `build-android.yml` | тег `v*` или вручную | `app-release.apk` в артефактах |
| `build-ios.yml` | тег `v*` или вручную | `CalistaTracker.ipa` (`Payload/Runner.app`) для Sideloadly |

iOS собирается на `macos-latest` без подписи:
```bash
flutter build ios --release --no-codesign
mkdir -p build/ios/ipa/Payload
cp -R build/ios/iphoneos/Runner.app build/ios/ipa/Payload/
cd build/ios/ipa && zip -r CalistaTracker.ipa Payload
```
Установка на iPhone — через Sideloadly с бесплатным Apple ID (переподпись раз в 7 дней).

> Release APK сейчас подписывается debug-ключом, как в стандартном шаблоне Flutter.
> Для публикации в магазине нужно добавить keystore и `signingConfigs.release`.

---

## Локальные напоминания

- **Android 13+**: запрос `POST_NOTIFICATIONS` при первом включении напоминания.
- **Android 12+**: `SCHEDULE_EXACT_ALARM` + `requestExactAlarmsPermission()`;
  при отказе — автоматический fallback на `inexactAllowWhileIdle`.
- **iOS**: `UNUserNotificationCenter` + `requestPermissions(alert/badge/sound)`.
- **Расписание**: `zonedSchedule` с `DateTimeComponents.time` для ежедневных
  привычек и `dayOfWeekAndTime` для выбранных дней (отдельный ID на день недели).
- **Перезагрузка**: `ScheduledNotificationBootReceiver` в `AndroidManifest.xml`
  (`BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`) + `syncAll` при запуске.
- **Навигация**: payload `habitId` → `GoRouter.push('/habits/:id')`;
  холодный старт обрабатывается через `getNotificationAppLaunchDetails`.
- **Desktop/web**: планировщик работает как no-op, приложение остаётся запускаемым.

ADR: [`docs/adr/0006-notifications-and-ios-build.md`](docs/adr/0006-notifications-and-ios-build.md).

---

## Документация

| Раздел | Содержание |
|---|---|
| [`docs/competitors/`](docs/competitors/) | 5+ приложений, таблица функций, 15+ сгруппированных болей, value proposition |
| [`docs/uml/`](docs/uml/) | Use Case, Class Diagram, Component/Layers Diagram (Mermaid) |
| [`docs/adr/`](docs/adr/) | 6 архитектурных решений с альтернативами и последствиями |
| [`docs/wireframes/`](docs/wireframes/) | ASCII-макеты ключевых экранов |
| [`docs/demo/one-minute-demo.md`](docs/demo/one-minute-demo.md) | сценарий демонстрации «Гибкой серии» на 1 минуту |
| [`docs/testing/device-checklist.md`](docs/testing/device-checklist.md) | чек-лист тестирования на реальном Android |
| [`docs/presentation/defense-outline.md`](docs/presentation/defense-outline.md) | структура защиты 5–7 минут |
| [`docs/presentation/qa-cheatsheet.md`](docs/presentation/qa-cheatsheet.md) | 30 вопросов руководителя и ответы |

---

## Ограничения

- Нет облачной синхронизации и аккаунтов — данные живут только на устройстве.
- Нет импорта/экспорта (в планах — CSV и шифрованный бэкап).
- iOS-артефакт без подписи; для установки нужен Sideloadly и переподпись раз в 7 дней.
- На desktop и web локальные напоминания отключены.
- Release APK использует debug-подпись; для магазина нужен собственный keystore.
- Виджеты home screen и интеграции со здоровьем не входят в текущий объём.

---

## Демонстрация

Короткий сценарий: [`docs/demo/one-minute-demo.md`](docs/demo/one-minute-demo.md).

1. Открыть «Сегодня» → карточка с сохранённой серией и `❄ 1/2`.
2. Открыть детали → календарь с замороженной ячейкой.
3. Нажать на `❄` → день становится выполненным.
4. Открыть «Статистику» → 30-дневный индекс и спасённые серии.
5. Дождаться уведомления → тап открывает карточку привычки.

---

<p align="center">
  <sub>Calista Tracker · Flutter · Clean Architecture · 2026</sub>
</p>
