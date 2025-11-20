# Dialed In

Dialed In is a Flutter application for specialty coffee enthusiasts who want to capture roast details, track brews, and explore how grind size behaves over time. The experience centers on a bean vault where every roast can be tagged, rated, and paired with shot history coming from favorite machines and grinders. Im still working on it, but it's fun to use! IOS version will follow soon.

## Features

- Browse and filter beans (Light / Medium / Dark) with notes, origin, roast date, and process tags.
- Inspect individual beans to see roast metadata, resting days, aggregate shot stats, and grind-size trends.
- Log shots per bean to capture dose/yield, grind size, and equipment details; every brew shows a timestamp, grind size, and linked machine/grinder entry.
- Add or edit beans via a modern form that keeps track of roast level, process, roast date, and tasting notes.
- Configure related gear from the settings screen (grinders, machines) used by the shot history views.

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

The project targets Material 3 with a dark theme and ships with web and desktop support, so you can iterate on mobile and desktop targets with the same codebase.

### Tests

```bash
flutter test
```

The suite exercises the core models and providers that back the bean vault experience.

## Reporting Issues

Please file bugs, feature requests, or build problems on the public issue tracker at https://github.com/LucaGerlich/dialed_in/issues. Provide steps to reproduce, the platform you ran on, and any relevant logs/screenshots.

## License

This project is licensed under the MIT License; see the [LICENSE](LICENSE) file for details.
