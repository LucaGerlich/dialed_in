# Localization Status

## Completed
All major UI screens have been updated to use AppLocalizations:

### Fully Localized Screens
- ✅ bean_list_screen.dart
- ✅ bean_detail_screen.dart  
- ✅ add_bean_screen.dart
- ✅ add_shot_screen.dart
- ✅ shot_detail_screen.dart
- ✅ share_shot_dialog.dart
- ✅ gear_settings_screen.dart
- ✅ onboarding_screen.dart

## Known Limitations (ARB keys not available)

### 1. Onboarding Content
The onboarding screen titles are localized, but descriptions and bullet points remain in English because the ARB files only define keys for:
- `welcomeToDialedIn` (title)
- `onboardingBeanVault` (title)
- `onboardingShotTracking` (title)
- `onboardingGearSettings` (title)
- `getStarted` (button)

Full description/detail content is not in the ARB files.

### 2. Navigation Button Text
- "Next" button in onboarding is hardcoded (no `next` key in ARB)
- "Skip" button in onboarding is hardcoded (no `skip` key in ARB)
- "Back" button in onboarding is hardcoded (no `back` key in ARB)

### 3. Time/Date Formatting
- "DAYS" suffix in shot_detail_screen.dart is hardcoded
- "days" text in bean_detail_screen.dart is hardcoded

### 4. Compact Labels
In add_shot_screen.dart, compact input fields use `.split(' ').last` to extract:
- "IN" from "DOSE IN" 
- "OUT" from "DOSE OUT"

This is fragile but necessary since no separate keys exist for the abbreviated forms.

### 5. Bean Detail Stats
The following stat labels don't have ARB keys:
- "BREWS" (total brew count)
- "AVG IN" (average dose in)
- "AVG OUT" (average dose out)

These remain hardcoded as there are no corresponding keys in the ARB files.

### 6. Shot Detail "GRIND SIZE OVER TIME"
The chart title uses just `l10n.grindSize` which is "GRIND SIZE", not the full "GRIND SIZE OVER TIME" text.

## Recommendations for Future Improvements

To achieve 100% localization, the following keys should be added to ARB files:

```json
"next": "Next",
"back": "Back", 
"skip": "Skip",
"days": "days",
"totalBrews": "BREWS",
"avgDoseIn": "AVG IN",
"avgDoseOut": "AVG OUT",
"doseInShort": "IN",
"doseOutShort": "OUT",
"grindSizeOverTime": "GRIND SIZE OVER TIME",
```

Plus full onboarding content keys for descriptions and detail lists.
