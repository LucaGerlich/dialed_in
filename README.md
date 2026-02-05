# Dialed In

Dialed In is a Flutter application for specialty coffee enthusiasts who want to capture roast details, track brews, and explore how grind size behaves over time. The experience centers on a bean vault where every roast can be tagged, rated, and paired with shot history coming from favorite machines and grinders. I'm still working on it, but it's fun to use! iOS version will follow soon.

## Features

- **Bean Vault:** Browse and filter beans (Light / Medium / Dark) with notes, origin, roast date, and process tags.
- **Smart Insights:** Inspect individual beans to see roast metadata, resting days, aggregate shot stats, and grind-size trends.
- **Visual Shot Sharing:** Generate and share beautiful sticker-style images of your shot stats (Grind, Time, Ratio, Taste) directly to Instagram Stories, Photos, or other apps.
- **Enhanced Shot Analytics:** View shots with a new Bento-grid layout, featuring brew ratios, resting days, and a visual taste profile plotter (Sour/Bitter vs Strong/Weak).
- **Detailed Extraction Metrics:** Track advanced parameters like pressure, temperature, pre-infusion time, and RPM alongside standard metrics (Dose/Yield, Grind, Time).
- **Gear Tracking:** Configure your setup (grinders, machines) to link every shot to the equipment used.
- **Maintenance Tracking:** Set reminders to clean, decalcify, or check your machine and grinder based on shot count, days, or estimated water usage. Never miss maintenance again!

## Roadmap 🚀

-   **Cloud Sync & Backup:** Securely back up your roast history and sync across devices.
-   **Smart Scale Integration:** Bluetooth support for real-time flow profiling and auto-logging from smart scales (e.g., Acaia, Felicita).
-   **Data Export:** Download your brew logs as CSV/JSON for external analysis.
-   **Water Profiles:** Track detailed water recipes (GH/KH, mineral composition) to isolate variables.
-   **Recipe Sharing:** Share full bean and recipe deep-links with other Dialed In users.
-   **Localization:** Multi-language support to reach a global community of coffee lovers.

## Getting Started

### Prerequisites

- Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) and ensure `flutter doctor` is clean for at least one target platform (iOS, Android, Linux, macOS, web, or Windows).
- Use a terminal with access to the Flutter tooling and a device/emulator or browser for the target platform.

### Build & Run

```bash
flutter pub get

flutter run

flutter build apk --release
```

### Tests

```bash
flutter test
```

The suite exercises the core models and providers that back the bean vault experience.

## Reporting Issues

Please file bugs, feature requests, or build problems on the public issue tracker at https://github.com/LucaGerlich/dialed_in/issues. Provide steps to reproduce, the platform you ran on, and any relevant logs/screenshots.

## License

This project is licensed under the MIT License; see the [LICENSE](LICENSE) file for details.
