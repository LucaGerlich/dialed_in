# Dialed In — Native Swift/SwiftUI Rewrite Plan

## Overview

"Dialed In" is an espresso tracking app. Users manage a collection of coffee beans, log brewing sessions (shots) with detailed extraction parameters, track equipment maintenance, and analyze their brewing patterns over time. All data is local, on-device only.

**Target:** iOS 18+ with SwiftUI, leveraging iOS 26 Liquid Glass design where available.

---

## 1. Data Models

All models need `Codable` conformance and `Identifiable` (UUID-based IDs).

### Bean (primary entity)
```
id: UUID
name: String
notes: String (default: "")
preferredGrindSize: Double (default: 10.0)
shots: [Shot] (default: []) — one-to-many relationship
origin: String (default: "")
roastLevel: String — one of: "Light", "Medium", "Dark"
process: String (default: "")
flavourTags: [String] (default: [])
roastDate: Date? (nullable)
acidity: Double (default: 5.0, range: 0.0–10.0)
body: Double (default: 5.0, range: 0.0–10.0)
sweetness: Double (default: 5.0, range: 0.0–10.0)
bitterness: Double (default: 5.0, range: 0.0–10.0)
aftertaste: Double (default: 5.0, range: 0.0–10.0)
customFlavorValues: [String: Double] (default: [:])
arabicaPercentage: Double (default: 100.0)
robustaPercentage: Double (default: 0.0)
ranking: Int (0 = unranked, 1–5 = star rating)
imagePath: String? (nullable, path to image file in app documents)
```

### Shot
```
id: UUID
grindSize: Double
doseIn: Double (grams)
doseOut: Double (grams)
duration: Int (seconds)
timestamp: Date
grinderRpm: Double? (nullable)
pressure: Double? (nullable)
temperature: Double? (nullable)
preInfusionTime: Int? (nullable)
machineId: String? (nullable, references CoffeeMachine.id)
grinderId: String? (nullable, references Grinder.id)
water: String? (nullable, free text)
flavourX: Double? (nullable, range: -1 Sour to +1 Bitter)
flavourY: Double? (nullable, range: -1 Weak to +1 Strong)
```

### CoffeeMachine
```
id: UUID
name: String
defaultPressure: Double? (nullable)
defaultTemperature: Double? (nullable)
defaultPreInfusionTime: Int? (nullable)
```

### Grinder
```
id: UUID
name: String
defaultRpm: Double? (nullable)
```

### MaintenanceTask
```
id: UUID
name: String
type: MaintenanceType (enum: clean, decalcify, checkMachine, checkGrinder)
intervalType: MaintenanceIntervalType (enum: shots, days, waterLiters)
intervalValue: Int
lastCompleted: Date? (nullable)
isEnabled: Bool (default: true)
```

### Enums
```
MaintenanceType: clean, decalcify, checkMachine, checkGrinder
MaintenanceIntervalType: shots, days, waterLiters
```

---

## 2. Persistence

The Flutter app uses SharedPreferences (JSON serialization). For the Swift rewrite:

**Recommended: SwiftData** (iOS 17+) or **Core Data** for structured storage.

Alternatively, for simplicity matching the original: **UserDefaults + Codable JSON** (the dataset is small — typically <100 beans, <1000 shots).

### Storage keys (if using UserDefaults approach)
- `beans` — JSON array of all beans (each bean contains its shots array)
- `machines` — JSON array of CoffeeMachine
- `grinders` — JSON array of Grinder
- `maintenanceTasks` — JSON array of MaintenanceTask
- `grindMin` — Double
- `grindMax` — Double
- `grindStep` — Double (default: 0.5)
- `useClicksMode` — Bool
- `grindLabel` — String
- `themeMode` — String ("system", "light", "dark")
- `locale` — String (language code, e.g. "en", "de", "es")
- `hasCompletedOnboarding` — Bool
- `customFlavorAttributes` — JSON array of String (max 3)
- `beanListCompactView` — Bool

### Data export/import
- Export: serialize all data + settings to a single JSON file with version number and timestamp
- Import: support merge (add non-duplicate items) and replace (wipe and overwrite) modes
- File is saved to/loaded from the app's documents directory

---

## 3. Architecture

**Pattern:** MVVM with SwiftUI

- **Models:** Codable structs (see above)
- **ViewModels:** ObservableObject classes, published via @EnvironmentObject
- **Views:** SwiftUI views

### Main ViewModel (equivalent to CoffeeProvider)

A single `CoffeeStore` (ObservableObject) manages all state:

**Published properties:**
- `beans: [Bean]`
- `machines: [CoffeeMachine]`
- `grinders: [Grinder]`
- `maintenanceTasks: [MaintenanceTask]`
- `grindMin: Double`, `grindMax: Double`, `grindStep: Double`
- `useClicksMode: Bool`, `grindLabel: String`
- `themeMode: ThemeMode`
- `locale: String?`
- `hasCompletedOnboarding: Bool`
- `customFlavorAttributes: [String]`

**CRUD methods:**
- Beans: `addBean()`, `updateBean()`, `deleteBean(id:)`
- Shots: `addShot(beanId:, shot:, updatePreferredGrind:)`, `updateShot(beanId:, shot:)`
- Machines: `addMachine()`, `deleteMachine(id:)`
- Grinders: `addGrinder()`, `deleteGrinder(id:)`
- Maintenance: `addTask()`, `updateTask()`, `deleteTask(id:)`, `completeTask(id:)` (sets lastCompleted = now)
- Settings: `updateGrindSettings()`, `setThemeMode()`, `setLocale()`
- Custom flavors: `addCustomFlavorAttribute(name:)` (max 3), `removeCustomFlavorAttribute(name:)`
- Onboarding: `completeOnboarding()`, `resetOnboarding()`
- Export/Import: `exportDataToJson() -> String`, `importDataFromJson(String, replace: Bool)`

**Computed analytics:**
- `getTotalShotCount() -> Int` — sum of shots across all beans
- `getTotalWaterUsage() -> Double` — total shots × 0.06 liters

**Important behavior:**
- When adding a shot, sort the bean's shots by timestamp descending (newest first)
- Every mutation triggers a save to persistence
- Shots are nested inside their parent Bean, not stored separately

---

## 4. Screens & Navigation

### Navigation Structure

```
App Entry
├── OnboardingView (shown once, 6 pages)
└── MainTabView (2 tabs)
    ├── Tab 0: "Bean Vault" (SF Symbol: cup.and.saucer / cup.and.saucer.fill)
    │   └── BeanListView
    │       ├── → BeanDetailView (NavigationLink/push)
    │       │   ├── → AddShotView (push)
    │       │   ├── → ShotDetailView (push)
    │       │   │   ├── → ShareShotSheet (sheet)
    │       │   │   └── → AddShotView (edit mode, push)
    │       │   └── → AddBeanView (edit mode, push)
    │       ├── → AddBeanView (push, from FAB)
    │       └── → GearSettingsView (push, from toolbar)
    └── Tab 1: "Maintenance" (SF Symbol: wrench / wrench.fill)
        └── MaintenanceListView
            └── → AddTaskDialog (sheet/alert)
```

### Screen Details

#### 1. OnboardingView
- 6-page horizontal PageView with dots indicator
- Pages: Welcome, Bean Vault intro, Shot Tracking intro, Gear Settings intro, Configure Gear (inline add machines/grinders), Get Started
- Skip button on all pages, Next/Back navigation
- Configure Gear page has inline machine/grinder add forms
- "Get Started" completes onboarding and navigates to main app

#### 2. MainTabView
- 2-tab bottom navigation
- Tab bar icons: `cup.and.saucer` / `wrench` (SF Symbols)
- Toolbar actions change per tab:
  - Bean Vault tab: view toggle (swap icon), sort menu, settings gear
  - Maintenance tab: no toolbar actions
- Floating action button per tab:
  - Bean Vault: "Add Bean" glass-style button
  - Maintenance: "+" glass-style button

#### 3. BeanListView (Tab 0 body)
- Horizontal scrolling filter chips: All, Light, Medium, Dark (filters by roastLevel)
- Sort options: Default order, Ranking (descending)
- View toggle: List view (full-width cards) or Grid view (2-column compact cards)
- Each card shows: image (or coffee cup placeholder), bean name, origin, roast level, notes preview, star rating badge, brew count
- Animated list items (staggered fade+slide on appear)
- Empty state: animated coffee icon + "No beans found" text

#### 4. BeanDetailView
- Toolbar: back, edit (pencil), delete (trash) — liquid glass style
- Header image (full width, extends behind translucent nav bar, with bottom gradient fade). Falls back to top padding when no image.
- Two tabs: Details and Shots
- **Details tab:**
  - Stats row: total brews, avg dose in (g), avg dose out (g)
  - Bean info: origin, roast date (with "resting X days" calculation), roast level, process
  - Bean composition bar (Arabica % / Robusta %)
  - Flavor profile: sliders or bars for acidity, body, sweetness, bitterness, aftertaste + custom attributes
  - Flavor tags as chips
  - Notes section
  - Line chart: grind size over time (x = shot timestamps, y = grind sizes) using data from bean's shots
- **Shots tab:**
  - List of shots sorted newest first
  - Each row shows: grind size, dose in→out, duration, timestamp
  - Empty state: "No shots yet — tap + to log your first shot"
- FAB: "Add Shot" glass-style button

#### 5. AddBeanView (also used for editing)
- If editing, pre-populate all fields from existing bean
- Fields:
  - Image picker (tap to select from photo library, with remove option)
  - Bean name (text field, required)
  - Star ranking (0–5 tap selector)
  - Origin (text field)
  - Roast date (date picker)
  - Roast level (chip selector: Light / Medium / Dark)
  - Process (text field, e.g. "Washed", "Natural")
  - Bean composition: two linked sliders — Arabica % and Robusta % (must sum to 100)
  - Notes (multiline text field)
  - Flavor profile: 5 default sliders (Acidity, Body, Sweetness, Bitterness, Aftertaste) + up to 3 custom attribute sliders (range 0.0–10.0)
  - Flavor tags: text input + add button, displayed as removable chips
- Save button in toolbar (checkmark icon)
- Unsaved changes detection with discard confirmation dialog
- Block swipe-back when unsaved changes exist
- Image handling: pick from gallery, compress to 1024×1024 at 85% JPEG quality, save to app documents directory

#### 6. AddShotView (also used for editing)
- Key UI element: **Analog grind size dial** — a vertical ruler-style control the user drags to set grind size. Provides haptic feedback at step boundaries. The scale is configurable (min/max/step from settings). This is a custom control.
- Fields:
  - Grind size (via analog dial, respects grindMin/grindMax/grindStep settings)
  - Dose in (grams, text field)
  - Dose out (grams, text field)
  - Duration: either auto timer (start/pause button, MM:SS.T display) OR manual entry via time picker (minutes, seconds, tenths)
  - Machine dropdown (from saved machines list, optional)
  - Grinder dropdown (from saved grinders list, optional)
  - Advanced fields (collapsible): RPM, pressure (bar), temperature (°C), pre-infusion time (seconds), water type
  - Flavor grid: 2D touch target where X axis = Sour↔Bitter, Y axis = Weak↔Strong. User taps/drags to place a point. Values stored as flavourX (-1 to +1) and flavourY (-1 to +1)
- Default grind size: inherits from bean's preferredGrindSize or last shot's grindSize
- Save action: if `updatePreferredGrind` option is on, updates bean's preferredGrindSize
- Layout: analog dial on one side, form fields in a DraggableScrollableSheet overlay

#### 7. ShotDetailView
- Toolbar: back, share, edit, delete — liquid glass style
- Stats grid showing: grind size, duration (MM:SS.T), dose in (g), dose out (g), brew ratio (1:X.X)
- Optional fields shown if present: pressure, temperature, pre-infusion, RPM, machine name, grinder name, water
- Flavor grid visualization (read-only 2D plot with the shot's flavor point)
- Bean context (which bean this shot belongs to)
- Timestamp display
- Delete with confirmation dialog

#### 8. ShareShotView (sheet/dialog)
- Renders a styled "shot sticker" image showing: bean name, origin, grind/time/dose stats, machine/grinder info, timestamp
- Share options:
  - Share to any app (UIActivityViewController)
  - Save to Photos (PHPhotoLibrary)
  - Copy to clipboard (for Instagram Stories paste)
- Requires rendering a SwiftUI view to UIImage for sharing

#### 9. GearSettingsView (pushed from bean list toolbar)
- Sections:
  - **App Settings:** Theme picker (System/Light/Dark), Language picker (System/English/Spanish/German)
  - **Coffee Machines:** List of saved machines with swipe-to-delete. Add button opens dialog with fields: name, default pressure, default temperature, default pre-infusion time
  - **Grinders:** List of saved grinders with swipe-to-delete. Add button opens dialog with fields: name, default RPM
  - **Grind Settings:** Min value, Max value, Step value (text fields). Toggle for "Clicks mode" (tracks as notches instead of numeric). Custom label field (e.g. "Clicks" vs "Grind Size")
  - **Flavor Profile:** List of custom flavor attributes (max 3) with add/remove. Built-in attributes (Acidity, Body, Sweetness, Bitterness, Aftertaste) cannot be removed
  - **Data Management:** Export button (creates JSON file), Import button (file picker to select JSON, then choose Merge or Replace)
  - **Help:** "View App Tutorial" button (restarts onboarding)
  - **About:** App version info

#### 10. MaintenanceListView (Tab 1 body)
- List of maintenance task cards, each showing:
  - Icon based on type (cleaning_services, water_drop, coffee_maker, settings)
  - Task name
  - Interval description (e.g. "Every 100 shots")
  - Progress bar (0.0–1.0, clamped)
  - Progress text (e.g. "45 / 100 shots")
  - "OVERDUE" badge when progress >= 1.0 (red)
  - Last completed date
- Tap card → dialog showing full details + "Mark Complete" / "Delete" / "Close" buttons
- Empty state: "No maintenance tasks — Add a task to get started"
- FAB: "+" glass-style button → Add task dialog

**Maintenance progress calculation:**
- For shots-based: count shots across all beans since lastCompleted date. If never completed, count total shots. Progress = count / intervalValue.
- For days-based: days since lastCompleted. If never completed, progress = 0. Progress = daysSince / intervalValue.
- For waterLiters-based: count shots since lastCompleted × 0.06L per shot. Progress = waterSince / intervalValue.

---

## 5. Theming

### Light Theme
- Primary: #253ABD (blue)
- Background: system light grey
- Font: RobotoMono (variable weight) — must be bundled as a custom font

### Dark Theme
- Primary: #FF9F0A (orange)
- Background: system black
- Font: RobotoMono (variable weight)

### System Theme
- Follows device setting

The RobotoMono font is used throughout the entire app for all text. Bundle the variable font file: `RobotoMono-VariableFont_wght.ttf`.

---

## 6. Localization

3 languages with ~135 unique string keys (some keys are duplicated in the ARB file):

**Languages:** English (en), Spanish (es), German (de)

Use Xcode String Catalogs (.xcstrings) or Localizable.strings.

### All localization keys and English values:

```
appTitle = "Dialed In"
beanVault = "Bean Vault"
gearSettings = "Gear Settings"
sortBy = "Sort by"
noBeansFound = "No beans found"
filterAll = "All"
filterLight = "Light"
filterMedium = "Medium"
filterDark = "Dark"
sortDefault = "Default"
viewMode = "View mode"
viewDetailed = "Detailed"
viewCompact = "Compact"
sortRanking = "Ranking"
origin = "ORIGIN"
roastDate = "ROAST DATE"
resting = "RESTING"
deleteBeanTitle = "Delete Bean?"
deleteBeanMessage = "This will delete the bean and all its shots."
cancel = "Cancel"
delete = "Delete"
editBean = "Edit Bean"
addBean = "Add Bean"
beanName = "BEAN NAME"
ranking = "RANKING"
roastLevel = "ROAST LEVEL"
process = "PROCESS"
beanComposition = "BEAN COMPOSITION"
notes = "NOTES"
flavorProfile = "FLAVOR PROFILE"
flavorTags = "FLAVOR TAGS"
beanNameHint = "e.g. Ethiopia Yirgacheffe"
originHint = "e.g. Ethiopia"
selectDate = "Select Date"
processHint = "e.g. Washed, Natural"
notesHint = "Tasting notes, etc."
flavorTagHint = "Add a tag (e.g. Blueberry)"
arabica = "Arabica"
robusta = "Robusta"
acidity = "Acidity"
body = "Body"
sweetness = "Sweetness"
bitterness = "Bitterness"
aftertaste = "Aftertaste"
addBeanButton = "ADD BEAN"
updateBeanButton = "UPDATE BEAN"
addShot = "Add Shot"
editShot = "Edit Shot"
done = "Done"
fillAllFields = "Please fill in all fields"
bean = "BEAN"
brewRatio = "BREW RATIO"
extractionParameters = "EXTRACTION PARAMETERS"
gear = "GEAR"
tasteProfile = "TASTE PROFILE"
grindSize = "GRIND SIZE"
time = "TIME"
doseIn = "DOSE IN"
doseOut = "DOSE OUT"
pressure = "PRESSURE"
temp = "TEMP"
preInfusion = "PRE-INFUSION"
rpm = "RPM"
machine = "MACHINE"
grinder = "GRINDER"
water = "WATER"
strong = "STRONG"
weak = "WEAK"
sour = "SOUR"
bitter = "BITTER"
deleteShotTitle = "Delete Shot?"
deleteShotMessage = "Are you sure you want to delete this shot record?"
roasted = "ROASTED:"
appSettings = "App Settings"
language = "Language"
systemDefault = "System Default"
english = "English"
spanish = "Spanish"
german = "German"
coffeeMachines = "Coffee Machines"
grinders = "Grinders"
grindSettings = "Grind Settings"
dataManagement = "Data Management"
help = "Help"
aboutDialedIn = "About Dialed In"
systemTheme = "System Theme"
lightTheme = "Light Theme"
darkTheme = "Dark Theme"
add = "Add"
merge = "Merge"
replace = "Replace"
addCustomAttribute = "Add Custom Attribute"
export = "Export"
import = "Import"
addMachine = "Add Machine"
addGrinder = "Add Grinder"
viewAppTutorial = "View App Tutorial"
learnHowToUse = "Learn how to use Dialed In"
errorExportingData = "Error exporting data:"
errorImportingData = "Error importing data:"
saveImage = "Save Image"
share = "Share"
savedToPhotos = "Saved to Photos!"
copiedToClipboard = "Copied to Clipboard! Open Instagram Story and Paste."
welcomeToDialedIn = "Welcome to Dialed In"
onboardingBeanVault = "Bean Vault"
onboardingShotTracking = "Shot Tracking"
onboardingGearSettings = "Gear Settings"
getStarted = "Get Started"
onboardingWelcomeDescription = "Your personal coffee companion for tracking beans, brewing shots, and perfecting your espresso."
onboardingWelcomeDetail1 = "Track your coffee bean collection"
onboardingWelcomeDetail2 = "Log every shot you pull"
onboardingWelcomeDetail3 = "Analyze your brewing patterns"
onboardingWelcomeDetail4 = "Find your perfect grind size"
onboardingBeanVaultDescription = "Store and organize your coffee bean collection with detailed information."
onboardingBeanVaultDetail1 = "Add beans with origin, roast level, and process"
onboardingBeanVaultDetail2 = "Set roast dates to track freshness"
onboardingBeanVaultDetail3 = "Define flavor profiles (acidity, body, sweetness)"
onboardingBeanVaultDetail4 = "Add custom flavor tags like \"Blueberry\" or \"Chocolate\""
onboardingBeanVaultDetail5 = "Filter beans by roast level (Light, Medium, Dark)"
onboardingShotTrackingDescription = "Log every shot you pull to dial in the perfect extraction."
onboardingShotTrackingDetail1 = "Record grind size, dose in, and dose out"
onboardingShotTrackingDetail2 = "Use the built-in timer for extraction time"
onboardingShotTrackingDetail3 = "Track machine settings (pressure, temperature)"
onboardingShotTrackingDetail4 = "Map flavor on a Sour-Bitter / Weak-Strong grid"
onboardingShotTrackingDetail5 = "View grind size trends over time with charts"
onboardingGearSettingsDescription = "Configure your coffee equipment for accurate tracking."
onboardingGearSettingsDetail1 = "Add your espresso machines with default settings"
onboardingGearSettingsDetail2 = "Add your grinders with default RPM"
onboardingGearSettingsDetail3 = "Customize grind size scale (min, max, step)"
onboardingGearSettingsDetail4 = "Choose between Light and Dark themes"
onboardingGearSettingsDetail5 = "Your data is stored locally on your device"
onboardingConfigureGearTitle = "Configure Your Gear"
onboardingConfigureGearDescription = "Set up your equipment now or skip to configure later in settings."
onboardingGetStartedDescription = "You're ready to start your coffee journey!"
onboardingGetStartedStep1 = "1. Tap + on Bean Vault to add your first bean"
onboardingGetStartedStep2 = "2. Select a bean to view details"
onboardingGetStartedStep3 = "3. Tap + on bean details to log a shot"
onboardingGetStartedStep4 = "4. Use the dial to set your grind size"
onboardingGetStartedStep5 = "5. Track and improve your brewing over time"
noItemsAdded = "No items added yet"
name = "Name"
pressureBar = "Pressure (bar)"
temperatureCelsius = "Temperature (°C)"
preInfusionSeconds = "Pre-infusion (s)"
min = "Min"
max = "Max"
step = "Step"
noNotes = "No notes"
percentArabica = "% Arabica"
percentRobusta = "% Robusta"
hundredPercentRobusta = "100% Robusta"
next = "Next"
back = "Back"
skip = "Skip"
days = "days"
daysUppercase = "DAYS"
totalBrews = "BREWS"
avgDoseIn = "AVG IN"
avgDoseOut = "AVG OUT"
doseInShort = "IN"
doseOutShort = "OUT"
grindSizeOverTime = "GRIND SIZE OVER TIME"
discardChangesTitle = "Discard Changes?"
discardChangesMessage = "You have unsaved changes. Are you sure you want to go back?"
discard = "Discard"
beanImage = "PHOTO"
tapToAddPhoto = "Tap to add a photo"
tabDetails = "Details"
tabShots = "Shots"
noShotsYet = "No shots yet"
noShotsDescription = "Tap + to log your first shot"
```

---

## 7. Custom UI Components to Build

### Analog Grind Size Dial
- Vertical ruler-style drag control
- Shows tick marks at each step interval
- Current value displayed prominently
- Haptic feedback (UIImpactFeedbackGenerator) when crossing step boundaries
- Configurable: min, max, step values from grind settings
- Optional "clicks mode" label
- Dynamic sensitivity based on drag speed

### Flavor Grid (2D Touch Target)
- Square area with labeled axes: X = Sour↔Bitter, Y = Weak↔Strong
- Crosshair lines at center
- User taps or drags to place a colored dot
- Returns (x, y) as Double values in range -1.0 to +1.0
- Used in AddShotView (editable) and ShotDetailView (read-only)

### Star Rating Selector
- 5 stars, tap to select (0 = no rating, 1–5 = filled stars)
- Used in AddBeanView and displayed on BeanCard

### Shot Sticker (for sharing)
- Styled card rendered to image for social sharing
- Shows: bean name, origin, grind size, time, dose in/out, machine, grinder, timestamp
- Monospace font styling, dark background

### Animated Coffee Icon
- Custom animated dripping coffee drop icon for empty states
- SVG or custom drawing with animation

---

## 8. iOS Framework Dependencies

| Need | Swift/iOS Solution |
|------|-------------------|
| State management | @Observable / ObservableObject + @EnvironmentObject |
| Persistence | SwiftData or UserDefaults + Codable |
| Charts | Swift Charts framework (iOS 16+) |
| Image picking | PHPickerViewController or PhotosUI (PhotosPicker) |
| File picking | UIDocumentPickerViewController or .fileImporter() |
| Photo library save | PHPhotoLibrary |
| Clipboard | UIPasteboard |
| Sharing | UIActivityViewController or ShareLink |
| Haptic feedback | UIImpactFeedbackGenerator |
| Localization | String Catalogs (.xcstrings) |
| Date formatting | DateFormatter / .formatted() |
| UUID generation | Foundation.UUID |
| JSON encoding | JSONEncoder / JSONDecoder |
| File system | FileManager (documents directory) |
| Image compression | UIImage.jpegData(compressionQuality: 0.85) |

No third-party packages should be needed.

---

## 9. Implementation Order

### Phase 1: Foundation
1. Create Xcode project with SwiftUI lifecycle
2. Define all model structs (Codable, Identifiable)
3. Build CoffeeStore (ObservableObject) with persistence layer
4. Bundle RobotoMono font, configure theme colors
5. Set up localization with String Catalogs (en, es, de)

### Phase 2: Core Navigation
6. Build MainTabView with 2 tabs
7. Build OnboardingView (6 pages)
8. App entry point: show onboarding or main tabs based on hasCompletedOnboarding

### Phase 3: Bean Management
9. BeanListView with filter chips, sort, view toggle (list/grid)
10. BeanCard and BeanCardCompact views
11. AddBeanView with all fields, image picker, unsaved changes detection
12. BeanDetailView with Details and Shots tabs
13. Line chart for grind size over time (Swift Charts)

### Phase 4: Shot Tracking
14. Build the Analog Grind Size Dial custom control
15. Build the Flavor Grid (2D touch target) custom control
16. AddShotView with dial, timer, form fields, flavor grid
17. ShotDetailView with stats display and read-only flavor grid
18. ShareShotView with sticker rendering and share options

### Phase 5: Equipment & Settings
19. GearSettingsView with all sections
20. Machine and Grinder CRUD dialogs
21. Grind settings configuration
22. Custom flavor attributes management
23. Data export/import functionality
24. Theme and language switching

### Phase 6: Maintenance
25. MaintenanceListView with task cards and progress bars
26. Add/complete/delete maintenance tasks
27. Progress calculation logic (shots-based, days-based, water-based)

### Phase 7: Polish
28. Empty state animations
29. List item staggered animations
30. Haptic feedback throughout
31. iOS 26 Liquid Glass toolbar and tab bar styling
32. Test data migration from Flutter app (import JSON export)

---

## 10. Data Migration Path

The Flutter app's export function creates a JSON file with this structure:
```json
{
  "version": 1,
  "exportDate": "2026-03-13T...",
  "beans": [...],
  "machines": [...],
  "grinders": [...],
  "maintenanceTasks": [...],
  "settings": {
    "grindMin": 0.0,
    "grindMax": 50.0,
    "grindStep": 0.5,
    "useClicksMode": false,
    "grindLabel": "Grind Size",
    "themeMode": "system",
    "locale": "en",
    "customFlavorAttributes": []
  }
}
```

The Swift app should be able to import this exact format so users can migrate their data from the Flutter version. Implement a JSON decoder that matches this structure.
