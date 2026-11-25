# Диаграмма слоёв и компонентов (Component / Layer Diagram)

## Описание
Диаграмма отображает архитектурные слои Clean Architecture в соответствии с правилом зависимостей (Dependency Rule): внешние слои зависят от внутренних, внутренний слой `domain` не имеет зависимостей от внешних фреймворков (Flutter, Drift, SQLite).

```mermaid
flowchart TB
    subgraph PresentationLayer ["Слой представления (Presentation Layer)"]
        UI_Screens["Screens:\nTodayScreen, HabitDetailScreen, HabitFormScreen, StatsScreen"]
        UI_Widgets["Widgets:\nHabitCard, HeatmapCalendar, StabilityRing, SkeletonLoader"]
        UI_State["State Management:\nRiverpod Notifiers & Providers"]
        UI_Notifications["Reminder Provider:\nReminderScheduler"]
        UI_Screens --> UI_Widgets
        UI_Screens --> UI_State
        UI_Screens --> UI_Notifications
    end

    subgraph DomainLayer ["Доменный слой (Domain Layer - Чистый Dart)"]
        UseCases["Use Cases:\nCalculateStreak, CalculateStability,\nToggleCompletion, ManageHabit,\nApplyAutoFreeze"]
        Entities["Entities & Value Objects:\nHabit, HabitCompletion, StreakInfo,\nStabilityMetrics, FreezePolicy, ReminderTime"]
        RepoInterfaces["Interfaces:\nHabitRepository, CompletionRepository,\nReminderScheduler"]
        UseCases --> Entities
        UseCases --> RepoInterfaces
    end

    subgraph DataLayer ["Слой данных (Data Layer)"]
        DriftDB["Drift SQLite Database:\nAppDatabase, schemaVersion 2,\nindex (habit_id, date)"]
        RepoImpl["Repository Implementations:\nHabitRepositoryImpl, CompletionRepositoryImpl"]
        Mappers["Mappers:\nTableData <-> Entity"]
        Notifications["LocalReminderScheduler:\nflutter_local_notifications + timezone"]
        RepoImpl --> DriftDB
        RepoImpl --> Mappers
        RepoImpl ..|> RepoInterfaces
        Notifications ..|> RepoInterfaces
    end

    subgraph CoreLayer ["Базовый слой (Core Layer)"]
        Theme["Theme & Design System:\nAppColors, AppTypography, AppTheme"]
        Motion["Motion Tokens:\n150/300/500 ms, haptics"]
        Router["Routing:\nGoRouter + notification payload"]
        ClockUtil["Time Utilities:\nClock, SystemClock, FixedClock"]
        Bootstrap["Bootstrap:\nDB + auto-freeze + reminder sync"]
    end

    UI_State --> UseCases
    UI_Screens --> Router
    UI_Screens --> Theme
    UI_Widgets --> Motion
    UseCases --> ClockUtil
    DataLayer --> Entities
    Bootstrap --> UseCases
    Bootstrap --> Notifications
```

## Принципы изоляции зависимостей:
1. `Domain Layer` содержит бизнес-логику в чистом Dart и не импортирует `flutter`, `drift` или внешние пакеты ввода-вывода.
2. `Data Layer` реализует интерфейсы репозиториев, объявленные в `Domain Layer` (инверсия зависимостей).
3. `Presentation Layer` взаимодействует с бизнес-логикой исключительно через `Use Cases` и провайдеры `Riverpod`.
4. `Core Bootstrap` выполняет инициализацию до первого кадра, но не содержит бизнес-правил: только оркестрацию.
5. `ReminderScheduler` объявлен в `domain`, а реализация `LocalReminderScheduler` в `data`, поэтому UI не зависит от `flutter_local_notifications`.
