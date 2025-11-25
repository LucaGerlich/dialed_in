# Dialed In

## Project Overview

**Dialed In** is a Flutter-based application designed for specialty coffee enthusiasts. It allows users to track their coffee beans, record roast details, and log brew history ("shots"). The app helps users "dial in" their espresso by tracking grind sizes and tasting notes over time.

### Key Technologies

*   **Framework:** Flutter (Dart)
*   **State Management:** `provider`
*   **Persistence:** `shared_preferences` (Local storage)
*   **UI/UX:** Material 3 Design, Google Fonts (`robotoMono`), Custom Dark Theme
*   **Visualization:** `fl_chart` for plotting grind size trends
*   **Utilities:** `uuid` for unique IDs, `intl` for formatting

### Architecture

The project follows a standard Flutter directory structure with a separation of concerns:

*   `lib/main.dart`: The application entry point. Sets up the global `CoffeeProvider`, `MaterialApp`, and the custom dark theme.
*   `lib/models/`: Contains data models (e.g., `Bean`, `Shot`, `CoffeeMachine`, `Grinder`).
*   `lib/providers/`: Contains the state management logic. `CoffeeProvider` handles data loading, saving, and state updates for beans and gear settings.
*   `lib/screens/`: UI screens for different features (e.g., `BeanListScreen`, `AddShotScreen`, `GearSettingsScreen`).
*   `lib/widgets/`: Reusable UI components (e.g., `BeanCard`, `AnalogDial`).

## Building and Running

### Prerequisites

*   Flutter SDK installed.
*   A running emulator or connected physical device (iOS, Android, macOS, etc.).

### Commands

*   **Install Dependencies:**
    ```bash
    flutter pub get
    ```

*   **Run the Application:**
    ```bash
    flutter run
    ```

*   **Run Tests:**
    ```bash
    flutter test
    ```

*   **Build for Release (Android):**
    ```bash
    flutter build apk --release
    ```

## Development Conventions

*   **Linting:** The project utilizes `flutter_lints` as defined in `analysis_options.yaml`. Run `flutter analyze` to check for code quality issues.
*   **State Management:** `ChangeNotifier` pattern via the `provider` package. The `CoffeeProvider` is the single source of truth for app state.
*   **Persistence:** Data is serialized to JSON and stored in `SharedPreferences`.
*   **Styling:** The app enforces a specific dark theme with `scaffoldBackgroundColor: const Color(0xFF000000)` and technical orange accents (`0xFFFF9F0A`).
*   **Typography:** `GoogleFonts.robotoMono` is used throughout the app for a technical/industrial aesthetic.
