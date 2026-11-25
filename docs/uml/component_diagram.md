# Диаграмма слоёв и компонентов (Component / Layer Diagram)

## Описание
Диаграмма отображает архитектурные слои Clean Architecture в соответствии с правилом зависимостей (Dependency Rule): внешние слои зависят от внутренних, внутренний слой `domain` не имеет зависимостей от внешних фреймворков (Flutter, Drift, SQLite).

```mermaid
flowchart TB
    subgraph PresentationLayer ["Слой представления (Presentation Layer)"]
        UI_Screens["Screens:\nTodayScreen, HabitDetailScreen, HabitFormScreen, StatsScreen"]
        UI_Widgets["Widgets:\nHabitCard, HeatmapCalendar, StabilityRing, StreakTicker"]
        UI_State["State Management:\nRiverpod Notifiers & StateProviders"]
        UI_Screens --> UI_Widgets
        UI_Screens --> UI_State
    end

    subgraph DomainLayer ["Доменный слой (Domain Layer - Чистый Dart)"]
        UseCases["Use Cases:\nCalculateStreak, CalculateStability, ToggleCompletion, ManageHabit"]
        Entities["Entities & Value Objects:\nHabit, HabitCompletion, StreakInfo, StabilityMetrics"]
        RepoInterfaces["Repository Interfaces:\nHabitRepository, CompletionRepository"]
        UseCases --> Entities
        UseCases --> RepoInterfaces
    end

    subgraph DataLayer ["Слой данных (Data Layer)"]
        DriftDB["Drift SQLite Database:\nAppDatabase, HabitDao, CompletionDao"]
        RepoImpl["Repository Implementations:\nHabitRepositoryImpl, CompletionRepositoryImpl"]
        Mappers["Mappers:\nHabitTableData <-> Habit, CompletionTableData <-> HabitCompletion"]
        RepoImpl --> DriftDB
        RepoImpl --> Mappers
        RepoImpl ..|> RepoInterfaces
    end

    subgraph CoreLayer ["Базовый слой (Core Layer)"]
        Theme["Theme & Design System:\nAppColors, AppTypography, AppTheme"]
        Motion["Motion Tokens:\nMotionTokens, HapticFeedbackHelper"]
        Router["Routing:\nGoRouter"]
        ClockUtil["Time Utilities:\nClock, SystemClock"]
    end

    UI_State --> UseCases
    UI_Screens --> Router
    UI_Screens --> Theme
    UI_Widgets --> Motion
    UseCases --> ClockUtil
    DataLayer --> Entities
```

## Принципы изоляции зависимостей:
1. `Domain Layer` содержит бизнес-логику в чистом Dart и не импортирует `flutter`, `drift` или внешние пакеты ввода-вывода.
2. `Data Layer` реализует интерфейсы репозиториев, объявленные в `Domain Layer` (инверсия зависимостей).
3. `Presentation Layer` взаимодействует с бизнес-логикой исключительно через `Use Cases` и провайдеры `Riverpod`.
