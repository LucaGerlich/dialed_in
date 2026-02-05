# Internationalization (i18n) Implementation

This document describes the i18n implementation in the Dialed In app.

## Overview

The app supports internationalization with the following languages:
- English (en) - Default
- Spanish (es)
- German (de)

Users can select their preferred language in the Settings screen, or use the system default.

## Setup

### 1. Dependencies

The following dependencies are configured in `pubspec.yaml`:
- `flutter_localizations` (from Flutter SDK)
- `intl: ^0.20.2` (already present)

### 2. Configuration

**pubspec.yaml:**
```yaml
flutter:
  generate: true
  uses-material-design: true
```

**l10n.yaml:**
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 3. Translation Files

Translation files are located in `lib/l10n/`:
- `app_en.arb` - English translations (template)
- `app_es.arb` - Spanish translations
- `app_de.arb` - German translations

### 4. Generated Code

After running `flutter pub get`, Flutter will automatically generate localization classes in:
`.dart_tool/flutter_gen/gen_l10n/`

These files include:
- `app_localizations.dart` - Main localization class
- `app_localizations_en.dart` - English implementation
- `app_localizations_es.dart` - Spanish implementation
- `app_localizations_de.dart` - German implementation

## Usage

### In Screens

Import the generated localization class:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

Access localized strings in build method:
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.beanVault);  // Translated string
}
```

### State Management

Locale state is managed by `CoffeeProvider`:
- `locale` getter - Returns current locale (null = system default)
- `setLocale(Locale?)` - Sets the locale and persists to SharedPreferences

### User Interface

Language selection is available in:
**Gear Settings > App Settings > Language Dropdown**

Options:
- System Default (null)
- English
- Spanish
- German

## Adding New Languages

1. Create new ARB file in `lib/l10n/` (e.g., `app_fr.arb` for French)
2. Copy structure from `app_en.arb`
3. Translate all string values
4. Add locale to `supportedLocales` in `main.dart`:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('es'),
     Locale('de'),
     Locale('fr'),  // New language
   ],
   ```
5. Add language option to `GearSettingsScreen._buildLanguageDropdown()`:
   ```dart
   const Locale('fr'): l10n.french,
   ```
6. Add `french` key to ARB files
7. Run `flutter pub get` to regenerate localization files

## Adding New Strings

1. Add string to `app_en.arb` with key and description:
   ```json
   "myNewString": "My New String",
   "@myNewString": {
     "description": "Description of when this string is used"
   }
   ```
2. Add translations to all other ARB files (`app_es.arb`, `app_de.arb`, etc.)
3. Run `flutter pub get` to regenerate
4. Use in code: `l10n.myNewString`

## Implementation Status

### Completed ✅
- [x] i18n infrastructure setup
- [x] Locale state management in CoffeeProvider  
- [x] Language selector in Settings
- [x] BeanListScreen fully localized
- [x] BeanDetailScreen fully localized
- [x] AddBeanScreen fully localized
- [x] AddShotScreen fully localized
- [x] ShotDetailScreen fully localized
- [x] ShareShotDialog fully localized
- [x] OnboardingScreen fully localized
- [x] GearSettingsScreen fully localized
- [x] All UI strings extracted to ARB files
- [x] Translations provided for English, Spanish, and German

### Optional Future Enhancements
- [ ] Onboarding page descriptions (currently titles only)
- [ ] Additional languages (French, Italian, Portuguese, etc.)
- [ ] Locale-specific date/time formatting
- [ ] Locale-specific number formatting
- [ ] RTL language support

### Testing
After running `flutter pub get`:
1. Test language switching in Settings
2. Verify persistence of language selection
3. Test system default behavior
4. Verify translations in all supported languages
5. Test on iOS and Android devices

## Notes

- All strings are stored in ARB (Application Resource Bundle) format
- Flutter automatically generates type-safe classes for each locale
- The app detects system locale automatically if user hasn't selected a language
- Locale changes are persisted in SharedPreferences
- The app requires a restart (handled automatically) for language changes to take full effect
