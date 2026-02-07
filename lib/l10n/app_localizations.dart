import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Dialed In'**
  String get appTitle;

  /// Title for the bean list screen
  ///
  /// In en, this message translates to:
  /// **'Bean Vault'**
  String get beanVault;

  /// Title for gear settings screen
  ///
  /// In en, this message translates to:
  /// **'Gear Settings'**
  String get gearSettings;

  /// Tooltip for sort menu
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Empty state message when no beans exist
  ///
  /// In en, this message translates to:
  /// **'No beans found'**
  String get noBeansFound;

  /// Filter option to show all beans
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter option for light roast
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get filterLight;

  /// Filter option for medium roast
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get filterMedium;

  /// Filter option for dark roast
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get filterDark;

  /// Sort by default order
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get sortDefault;

  /// Tooltip for view mode toggle
  ///
  /// In en, this message translates to:
  /// **'View mode'**
  String get viewMode;

  /// Detailed view mode option
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get viewDetailed;

  /// Compact view mode option
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get viewCompact;

  /// Sort option by ranking
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get sortRanking;

  /// Label for bean origin
  ///
  /// In en, this message translates to:
  /// **'ORIGIN'**
  String get origin;

  /// Label for roast date
  ///
  /// In en, this message translates to:
  /// **'ROAST DATE'**
  String get roastDate;

  /// Label for bean resting period
  ///
  /// In en, this message translates to:
  /// **'RESTING'**
  String get resting;

  /// Title for delete bean confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Bean?'**
  String get deleteBeanTitle;

  /// Message for delete bean confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This will delete the bean and all its shots.'**
  String get deleteBeanMessage;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title for edit bean screen
  ///
  /// In en, this message translates to:
  /// **'Edit Bean'**
  String get editBean;

  /// Title for add bean screen and FAB label
  ///
  /// In en, this message translates to:
  /// **'Add Bean'**
  String get addBean;

  /// Label for bean name field
  ///
  /// In en, this message translates to:
  /// **'BEAN NAME'**
  String get beanName;

  /// Label for bean ranking field
  ///
  /// In en, this message translates to:
  /// **'RANKING'**
  String get ranking;

  /// Label for roast level field
  ///
  /// In en, this message translates to:
  /// **'ROAST LEVEL'**
  String get roastLevel;

  /// Label for bean process field
  ///
  /// In en, this message translates to:
  /// **'PROCESS'**
  String get process;

  /// Label for bean composition field
  ///
  /// In en, this message translates to:
  /// **'BEAN COMPOSITION'**
  String get beanComposition;

  /// Label for notes field
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get notes;

  /// Label for flavor profile section
  ///
  /// In en, this message translates to:
  /// **'FLAVOR PROFILE'**
  String get flavorProfile;

  /// Label for flavor tags field
  ///
  /// In en, this message translates to:
  /// **'FLAVOR TAGS'**
  String get flavorTags;

  /// Hint text for bean name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Ethiopia Yirgacheffe'**
  String get beanNameHint;

  /// Hint text for origin field
  ///
  /// In en, this message translates to:
  /// **'e.g. Ethiopia'**
  String get originHint;

  /// Hint text for date picker
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Hint text for process field
  ///
  /// In en, this message translates to:
  /// **'e.g. Washed, Natural'**
  String get processHint;

  /// Hint text for notes field
  ///
  /// In en, this message translates to:
  /// **'Tasting notes, etc.'**
  String get notesHint;

  /// Hint text for flavor tag input
  ///
  /// In en, this message translates to:
  /// **'Add a tag (e.g. Blueberry)'**
  String get flavorTagHint;

  /// Arabica bean type
  ///
  /// In en, this message translates to:
  /// **'Arabica'**
  String get arabica;

  /// Robusta bean type
  ///
  /// In en, this message translates to:
  /// **'Robusta'**
  String get robusta;

  /// Flavor profile attribute
  ///
  /// In en, this message translates to:
  /// **'Acidity'**
  String get acidity;

  /// Flavor profile attribute
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// Flavor profile attribute
  ///
  /// In en, this message translates to:
  /// **'Sweetness'**
  String get sweetness;

  /// Flavor profile attribute
  ///
  /// In en, this message translates to:
  /// **'Bitterness'**
  String get bitterness;

  /// Flavor profile attribute
  ///
  /// In en, this message translates to:
  /// **'Aftertaste'**
  String get aftertaste;

  /// Button to add a new bean
  ///
  /// In en, this message translates to:
  /// **'ADD BEAN'**
  String get addBeanButton;

  /// Button to update an existing bean
  ///
  /// In en, this message translates to:
  /// **'UPDATE BEAN'**
  String get updateBeanButton;

  /// Title for add shot screen and FAB label
  ///
  /// In en, this message translates to:
  /// **'Add Shot'**
  String get addShot;

  /// Title for edit shot screen
  ///
  /// In en, this message translates to:
  /// **'Edit Shot'**
  String get editShot;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Validation message for incomplete forms
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get fillAllFields;

  /// Label for bean section
  ///
  /// In en, this message translates to:
  /// **'BEAN'**
  String get bean;

  /// Label for brew ratio section
  ///
  /// In en, this message translates to:
  /// **'BREW RATIO'**
  String get brewRatio;

  /// Label for extraction parameters section
  ///
  /// In en, this message translates to:
  /// **'EXTRACTION PARAMETERS'**
  String get extractionParameters;

  /// Label for gear section
  ///
  /// In en, this message translates to:
  /// **'GEAR'**
  String get gear;

  /// Label for taste profile section
  ///
  /// In en, this message translates to:
  /// **'TASTE PROFILE'**
  String get tasteProfile;

  /// Label for grind size
  ///
  /// In en, this message translates to:
  /// **'GRIND SIZE'**
  String get grindSize;

  /// Label for brew time
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get time;

  /// Label for coffee dose input
  ///
  /// In en, this message translates to:
  /// **'DOSE IN'**
  String get doseIn;

  /// Label for coffee dose output
  ///
  /// In en, this message translates to:
  /// **'DOSE OUT'**
  String get doseOut;

  /// Label for brew pressure
  ///
  /// In en, this message translates to:
  /// **'PRESSURE'**
  String get pressure;

  /// Label for brew temperature
  ///
  /// In en, this message translates to:
  /// **'TEMP'**
  String get temp;

  /// Label for pre-infusion time
  ///
  /// In en, this message translates to:
  /// **'PRE-INFUSION'**
  String get preInfusion;

  /// RPM field label
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpm;

  /// Label for coffee machine
  ///
  /// In en, this message translates to:
  /// **'MACHINE'**
  String get machine;

  /// Label for grinder
  ///
  /// In en, this message translates to:
  /// **'GRINDER'**
  String get grinder;

  /// Label for water type
  ///
  /// In en, this message translates to:
  /// **'WATER'**
  String get water;

  /// Taste profile descriptor
  ///
  /// In en, this message translates to:
  /// **'STRONG'**
  String get strong;

  /// Taste profile descriptor
  ///
  /// In en, this message translates to:
  /// **'WEAK'**
  String get weak;

  /// Taste profile descriptor
  ///
  /// In en, this message translates to:
  /// **'SOUR'**
  String get sour;

  /// Taste profile descriptor
  ///
  /// In en, this message translates to:
  /// **'BITTER'**
  String get bitter;

  /// Title for delete shot confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Shot?'**
  String get deleteShotTitle;

  /// Message for delete shot confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this shot record?'**
  String get deleteShotMessage;

  /// Label prefix for roast date
  ///
  /// In en, this message translates to:
  /// **'ROASTED:'**
  String get roasted;

  /// Section header for app settings
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Option to use system language
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Section header for coffee machines
  ///
  /// In en, this message translates to:
  /// **'Coffee Machines'**
  String get coffeeMachines;

  /// Section header for grinders
  ///
  /// In en, this message translates to:
  /// **'Grinders'**
  String get grinders;

  /// Section header for grind settings
  ///
  /// In en, this message translates to:
  /// **'Grind Settings'**
  String get grindSettings;

  /// Section header for data management
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Section header for help
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Section header for about
  ///
  /// In en, this message translates to:
  /// **'About Dialed In'**
  String get aboutDialedIn;

  /// Option to use system theme
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Merge button label for data import
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// Replace button label for data import
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// Button to add custom flavor attribute
  ///
  /// In en, this message translates to:
  /// **'Add Custom Attribute'**
  String get addCustomAttribute;

  /// Export data button
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Import data button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Add machine dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Machine'**
  String get addMachine;

  /// Add grinder dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Grinder'**
  String get addGrinder;

  /// Button to view app tutorial
  ///
  /// In en, this message translates to:
  /// **'View App Tutorial'**
  String get viewAppTutorial;

  /// Description for tutorial button
  ///
  /// In en, this message translates to:
  /// **'Learn how to use Dialed In'**
  String get learnHowToUse;

  /// Error message when data export fails
  ///
  /// In en, this message translates to:
  /// **'Error exporting data:'**
  String get errorExportingData;

  /// Error message when data import fails
  ///
  /// In en, this message translates to:
  /// **'Error importing data:'**
  String get errorImportingData;

  /// Button to save shot image
  ///
  /// In en, this message translates to:
  /// **'Save Image'**
  String get saveImage;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Success message when image is saved
  ///
  /// In en, this message translates to:
  /// **'Saved to Photos!'**
  String get savedToPhotos;

  /// Success message when copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to Clipboard! Open Instagram Story and Paste.'**
  String get copiedToClipboard;

  /// Onboarding welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dialed In'**
  String get welcomeToDialedIn;

  /// Onboarding section title
  ///
  /// In en, this message translates to:
  /// **'Bean Vault'**
  String get onboardingBeanVault;

  /// Onboarding section title
  ///
  /// In en, this message translates to:
  /// **'Shot Tracking'**
  String get onboardingShotTracking;

  /// Onboarding section title
  ///
  /// In en, this message translates to:
  /// **'Gear Settings'**
  String get onboardingGearSettings;

  /// Button to complete onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Welcome page description
  ///
  /// In en, this message translates to:
  /// **'Your personal coffee companion for tracking beans, brewing shots, and perfecting your espresso.'**
  String get onboardingWelcomeDescription;

  /// Welcome page detail 1
  ///
  /// In en, this message translates to:
  /// **'Track your coffee bean collection'**
  String get onboardingWelcomeDetail1;

  /// Welcome page detail 2
  ///
  /// In en, this message translates to:
  /// **'Log every shot you pull'**
  String get onboardingWelcomeDetail2;

  /// Welcome page detail 3
  ///
  /// In en, this message translates to:
  /// **'Analyze your brewing patterns'**
  String get onboardingWelcomeDetail3;

  /// Welcome page detail 4
  ///
  /// In en, this message translates to:
  /// **'Find your perfect grind size'**
  String get onboardingWelcomeDetail4;

  /// Bean vault page description
  ///
  /// In en, this message translates to:
  /// **'Store and organize your coffee bean collection with detailed information.'**
  String get onboardingBeanVaultDescription;

  /// Bean vault detail 1
  ///
  /// In en, this message translates to:
  /// **'Add beans with origin, roast level, and process'**
  String get onboardingBeanVaultDetail1;

  /// Bean vault detail 2
  ///
  /// In en, this message translates to:
  /// **'Set roast dates to track freshness'**
  String get onboardingBeanVaultDetail2;

  /// Bean vault detail 3
  ///
  /// In en, this message translates to:
  /// **'Define flavor profiles (acidity, body, sweetness)'**
  String get onboardingBeanVaultDetail3;

  /// Bean vault detail 4
  ///
  /// In en, this message translates to:
  /// **'Add custom flavor tags like \"Blueberry\" or \"Chocolate\"'**
  String get onboardingBeanVaultDetail4;

  /// Bean vault detail 5
  ///
  /// In en, this message translates to:
  /// **'Filter beans by roast level (Light, Medium, Dark)'**
  String get onboardingBeanVaultDetail5;

  /// Shot tracking page description
  ///
  /// In en, this message translates to:
  /// **'Log every shot you pull to dial in the perfect extraction.'**
  String get onboardingShotTrackingDescription;

  /// Shot tracking detail 1
  ///
  /// In en, this message translates to:
  /// **'Record grind size, dose in, and dose out'**
  String get onboardingShotTrackingDetail1;

  /// Shot tracking detail 2
  ///
  /// In en, this message translates to:
  /// **'Use the built-in timer for extraction time'**
  String get onboardingShotTrackingDetail2;

  /// Shot tracking detail 3
  ///
  /// In en, this message translates to:
  /// **'Track machine settings (pressure, temperature)'**
  String get onboardingShotTrackingDetail3;

  /// Shot tracking detail 4
  ///
  /// In en, this message translates to:
  /// **'Map flavor on a Sour-Bitter / Weak-Strong grid'**
  String get onboardingShotTrackingDetail4;

  /// Shot tracking detail 5
  ///
  /// In en, this message translates to:
  /// **'View grind size trends over time with charts'**
  String get onboardingShotTrackingDetail5;

  /// Gear settings page description
  ///
  /// In en, this message translates to:
  /// **'Configure your coffee equipment for accurate tracking.'**
  String get onboardingGearSettingsDescription;

  /// Gear settings detail 1
  ///
  /// In en, this message translates to:
  /// **'Add your espresso machines with default settings'**
  String get onboardingGearSettingsDetail1;

  /// Gear settings detail 2
  ///
  /// In en, this message translates to:
  /// **'Add your grinders with default RPM'**
  String get onboardingGearSettingsDetail2;

  /// Gear settings detail 3
  ///
  /// In en, this message translates to:
  /// **'Customize grind size scale (min, max, step)'**
  String get onboardingGearSettingsDetail3;

  /// Gear settings detail 4
  ///
  /// In en, this message translates to:
  /// **'Choose between Light and Dark themes'**
  String get onboardingGearSettingsDetail4;

  /// Gear settings detail 5
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally on your device'**
  String get onboardingGearSettingsDetail5;

  /// Configure gear page title
  ///
  /// In en, this message translates to:
  /// **'Configure Your Gear'**
  String get onboardingConfigureGearTitle;

  /// Configure gear page description
  ///
  /// In en, this message translates to:
  /// **'Set up your equipment now or skip to configure later in settings.'**
  String get onboardingConfigureGearDescription;

  /// Get started page description
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to start your coffee journey!'**
  String get onboardingGetStartedDescription;

  /// Get started step 1
  ///
  /// In en, this message translates to:
  /// **'1. Tap + on Bean Vault to add your first bean'**
  String get onboardingGetStartedStep1;

  /// Get started step 2
  ///
  /// In en, this message translates to:
  /// **'2. Select a bean to view details'**
  String get onboardingGetStartedStep2;

  /// Get started step 3
  ///
  /// In en, this message translates to:
  /// **'3. Tap + on bean details to log a shot'**
  String get onboardingGetStartedStep3;

  /// Get started step 4
  ///
  /// In en, this message translates to:
  /// **'4. Use the dial to set your grind size'**
  String get onboardingGetStartedStep4;

  /// Get started step 5
  ///
  /// In en, this message translates to:
  /// **'5. Track and improve your brewing over time'**
  String get onboardingGetStartedStep5;

  /// Empty state message for configuration sections
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get noItemsAdded;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Pressure field label
  ///
  /// In en, this message translates to:
  /// **'Pressure (bar)'**
  String get pressureBar;

  /// Temperature field label
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureCelsius;

  /// Pre-infusion field label
  ///
  /// In en, this message translates to:
  /// **'Pre-infusion (s)'**
  String get preInfusionSeconds;

  /// Minimum value label
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// Maximum value label
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// Step value label
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// Placeholder when no notes are present
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// Label for arabica percentage
  ///
  /// In en, this message translates to:
  /// **'% Arabica'**
  String get percentArabica;

  /// Label for robusta percentage
  ///
  /// In en, this message translates to:
  /// **'% Robusta'**
  String get percentRobusta;

  /// Label when bean is pure robusta
  ///
  /// In en, this message translates to:
  /// **'100% Robusta'**
  String get hundredPercentRobusta;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Days unit of time (lowercase)
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Days unit of time (uppercase)
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get daysUppercase;

  /// Label for total number of brews
  ///
  /// In en, this message translates to:
  /// **'BREWS'**
  String get totalBrews;

  /// Label for average dose in
  ///
  /// In en, this message translates to:
  /// **'AVG IN'**
  String get avgDoseIn;

  /// Label for average dose out
  ///
  /// In en, this message translates to:
  /// **'AVG OUT'**
  String get avgDoseOut;

  /// Short label for dose in
  ///
  /// In en, this message translates to:
  /// **'IN'**
  String get doseInShort;

  /// Short label for dose out
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get doseOutShort;

  /// Chart title for grind size trends
  ///
  /// In en, this message translates to:
  /// **'GRIND SIZE OVER TIME'**
  String get grindSizeOverTime;

  /// Title for discard changes dialog
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChangesTitle;

  /// Message for discard changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to go back?'**
  String get discardChangesMessage;

  /// Discard button label
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Label for bean image section
  ///
  /// In en, this message translates to:
  /// **'PHOTO'**
  String get beanImage;

  /// Placeholder text for image picker
  ///
  /// In en, this message translates to:
  /// **'Tap to add a photo'**
  String get tapToAddPhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
