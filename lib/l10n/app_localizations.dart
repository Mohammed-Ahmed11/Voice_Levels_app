import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, '**
  String get homeGreeting;

  /// No description provided for @homeGreetingName.
  ///
  /// In en, this message translates to:
  /// **'Little Star! ⭐'**
  String get homeGreetingName;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do today?'**
  String get homeSubtitle;

  /// No description provided for @homeTip.
  ///
  /// In en, this message translates to:
  /// **'💡 Set Max Level & Countdown in Options!'**
  String get homeTip;

  /// No description provided for @cardStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get cardStartTitle;

  /// No description provided for @cardStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record something fun!'**
  String get cardStartSubtitle;

  /// No description provided for @cardReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get cardReportsTitle;

  /// No description provided for @cardReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Listen & share!'**
  String get cardReportsSubtitle;

  /// No description provided for @cardProfilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get cardProfilesTitle;

  /// No description provided for @cardProfilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Patients / kids'**
  String get cardProfilesSubtitle;

  /// No description provided for @cardOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get cardOptionsTitle;

  /// No description provided for @cardOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get cardOptionsSubtitle;

  /// No description provided for @profilePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'👶 Choose Profile'**
  String get profilePickerTitle;

  /// No description provided for @profilePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select who you will record for'**
  String get profilePickerSubtitle;

  /// No description provided for @profilePickerActivePrefix.
  ///
  /// In en, this message translates to:
  /// **'Active: '**
  String get profilePickerActivePrefix;

  /// No description provided for @profilePickerNoPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get profilePickerNoPhone;

  /// No description provided for @profilePickerNewProfileBtn.
  ///
  /// In en, this message translates to:
  /// **'➕ New Profile'**
  String get profilePickerNewProfileBtn;

  /// No description provided for @profilePickerCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profilePickerCancelBtn;

  /// No description provided for @snackbarCreateProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a profile first 👶'**
  String get snackbarCreateProfileFirst;

  /// No description provided for @fallbackLogoAppName.
  ///
  /// In en, this message translates to:
  /// **'Speech Space'**
  String get fallbackLogoAppName;

  /// No description provided for @settingsTitle1.
  ///
  /// In en, this message translates to:
  /// **'App '**
  String get settingsTitle1;

  /// No description provided for @settingsTitle2.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get settingsTitle2;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize how the app works ⚙️'**
  String get settingsSubtitle;

  /// No description provided for @settingsSectionPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsSectionPermissions;

  /// No description provided for @settingsSectionRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get settingsSectionRecording;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsMicTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get settingsMicTitle;

  /// No description provided for @settingsMicGranted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get settingsMicGranted;

  /// No description provided for @settingsMicNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Not Granted'**
  String get settingsMicNotGranted;

  /// No description provided for @settingsMicCheckBtn.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get settingsMicCheckBtn;

  /// No description provided for @settingsQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording Quality'**
  String get settingsQualityTitle;

  /// No description provided for @settingsQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get settingsQualityHigh;

  /// No description provided for @settingsQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsQualityMedium;

  /// No description provided for @settingsQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settingsQualityLow;

  /// No description provided for @settingsMaxLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Level'**
  String get settingsMaxLevelTitle;

  /// No description provided for @settingsMaxLevelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} levels'**
  String settingsMaxLevelSubtitle(int count);

  /// No description provided for @settingsCountdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get settingsCountdownTitle;

  /// No description provided for @settingsCountdownOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsCountdownOff;

  /// No description provided for @settingsCountdownSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String settingsCountdownSeconds(int count);

  /// No description provided for @settingsLangEnglishTitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLangEnglishTitle;

  /// No description provided for @settingsLangEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get settingsLangEnglishSubtitle;

  /// No description provided for @settingsLangArabicTitle.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLangArabicTitle;

  /// No description provided for @settingsLangArabicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get settingsLangArabicSubtitle;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile'**
  String get settingsProfileTitle;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parent & child info'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete profile, recordings & settings'**
  String get settingsResetSubtitle;

  /// No description provided for @settingsResetBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetBtn;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete your profile, recordings, and all settings.'**
  String get settingsResetDialogBody;

  /// No description provided for @settingsResetDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsResetDialogCancel;

  /// No description provided for @settingsResetDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetDialogConfirm;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App data reset!'**
  String get settingsResetSuccess;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a profile for each patient so recordings don’t get mixed.'**
  String get profileSubtitle;

  /// No description provided for @profileParentSection.
  ///
  /// In en, this message translates to:
  /// **'Parent Info'**
  String get profileParentSection;

  /// No description provided for @profileParentName.
  ///
  /// In en, this message translates to:
  /// **'Parent Name'**
  String get profileParentName;

  /// No description provided for @profileParentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sarah'**
  String get profileParentNameHint;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhone;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +20 ...'**
  String get profilePhoneHint;

  /// No description provided for @profilePatientSection.
  ///
  /// In en, this message translates to:
  /// **'Patient Info'**
  String get profilePatientSection;

  /// No description provided for @profilePatientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get profilePatientName;

  /// No description provided for @profilePatientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lily'**
  String get profilePatientNameHint;

  /// No description provided for @profileNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get profileNotes;

  /// No description provided for @profileNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Any extra info...'**
  String get profileNotesHint;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String profileDeleteTitle(Object name);

  /// No description provided for @profileDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete this patient and their recordings.'**
  String get profileDeleteBody;

  /// No description provided for @profileDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteCancel;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteConfirm;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSave;

  /// No description provided for @profileCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Patient'**
  String get profileCreate;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get profileSaved;

  /// No description provided for @profileDefaultPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient {number}'**
  String profileDefaultPatient(int number);

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @tapPatient.
  ///
  /// In en, this message translates to:
  /// **'Tap a patient to view their recordings 🎵'**
  String get tapPatient;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'recording'**
  String get recording;

  /// No description provided for @recordings.
  ///
  /// In en, this message translates to:
  /// **'recordings'**
  String get recordings;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessions;

  /// No description provided for @peak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get peak;

  /// No description provided for @deleteRecording.
  ///
  /// In en, this message translates to:
  /// **'Delete Recording?'**
  String get deleteRecording;

  /// No description provided for @deleteRecordingConfirm.
  ///
  /// In en, this message translates to:
  /// **'This recording will be permanently deleted.'**
  String get deleteRecordingConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients yet!'**
  String get noPatients;

  /// No description provided for @addPatientHint.
  ///
  /// In en, this message translates to:
  /// **'Add a patient profile first 👨‍👩‍👧'**
  String get addPatientHint;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @noRecordingsFor.
  ///
  /// In en, this message translates to:
  /// **'No recordings for'**
  String get noRecordingsFor;

  /// No description provided for @startSessionHint.
  ///
  /// In en, this message translates to:
  /// **'Start a session to see results here 🎙️'**
  String get startSessionHint;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassic;

  /// No description provided for @modeRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get modeRounded;

  /// No description provided for @modeThick.
  ///
  /// In en, this message translates to:
  /// **'Thick Meter'**
  String get modeThick;

  /// No description provided for @modePlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get modePlayful;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get navOptions;

  /// No description provided for @modeSelectTitle1.
  ///
  /// In en, this message translates to:
  /// **'Pick a '**
  String get modeSelectTitle1;

  /// No description provided for @modeSelectTitle2.
  ///
  /// In en, this message translates to:
  /// **'Mode!'**
  String get modeSelectTitle2;

  /// No description provided for @modeSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4 unique looks to choose from'**
  String get modeSelectSubtitle;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple level meter'**
  String get modeClassicDesc;

  /// No description provided for @modeRoundedDesc.
  ///
  /// In en, this message translates to:
  /// **'Smooth rounded meter'**
  String get modeRoundedDesc;

  /// No description provided for @modeThickDesc.
  ///
  /// In en, this message translates to:
  /// **'Bold & clear levels'**
  String get modeThickDesc;

  /// No description provided for @modePlayfulDesc.
  ///
  /// In en, this message translates to:
  /// **'Fun child-friendly UI'**
  String get modePlayfulDesc;

  /// No description provided for @modeTagPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get modeTagPopular;

  /// No description provided for @modeTagSmooth.
  ///
  /// In en, this message translates to:
  /// **'Smooth'**
  String get modeTagSmooth;

  /// No description provided for @modeTagBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get modeTagBold;

  /// No description provided for @modeTagFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get modeTagFun;

  /// No description provided for @modeTapToUse.
  ///
  /// In en, this message translates to:
  /// **'Tap to use'**
  String get modeTapToUse;

  /// No description provided for @zoneQuiet.
  ///
  /// In en, this message translates to:
  /// **'Quiet'**
  String get zoneQuiet;

  /// No description provided for @zoneGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get zoneGood;

  /// No description provided for @zoneLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud'**
  String get zoneLoud;

  /// No description provided for @zoneMax.
  ///
  /// In en, this message translates to:
  /// **'Max!'**
  String get zoneMax;

  /// No description provided for @zoneDotQuietPlayful.
  ///
  /// In en, this message translates to:
  /// **'🐢 Quiet'**
  String get zoneDotQuietPlayful;

  /// No description provided for @zoneDotGoodPlayful.
  ///
  /// In en, this message translates to:
  /// **'🐥 Good'**
  String get zoneDotGoodPlayful;

  /// No description provided for @zoneDotLoudPlayful.
  ///
  /// In en, this message translates to:
  /// **'🚀 Loud'**
  String get zoneDotLoudPlayful;

  /// No description provided for @zoneDotMaxPlayful.
  ///
  /// In en, this message translates to:
  /// **'🌟 Max!'**
  String get zoneDotMaxPlayful;

  /// No description provided for @labelQuiet1.
  ///
  /// In en, this message translates to:
  /// **'Quiet...'**
  String get labelQuiet1;

  /// No description provided for @labelLouder1.
  ///
  /// In en, this message translates to:
  /// **'Getting louder!'**
  String get labelLouder1;

  /// No description provided for @labelGreat1.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get labelGreat1;

  /// No description provided for @labelAmazing1.
  ///
  /// In en, this message translates to:
  /// **'AMAZING! 🎉'**
  String get labelAmazing1;

  /// No description provided for @labelQuiet2.
  ///
  /// In en, this message translates to:
  /// **'Shhh... 🤫'**
  String get labelQuiet2;

  /// No description provided for @labelLouder2.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get labelLouder2;

  /// No description provided for @labelLoud2.
  ///
  /// In en, this message translates to:
  /// **'So loud! 🎉'**
  String get labelLoud2;

  /// No description provided for @labelAmazing2.
  ///
  /// In en, this message translates to:
  /// **'AMAZING!! 🌟'**
  String get labelAmazing2;

  /// No description provided for @labelQuiet4.
  ///
  /// In en, this message translates to:
  /// **'So quiet... 🤫'**
  String get labelQuiet4;

  /// No description provided for @labelLouder4.
  ///
  /// In en, this message translates to:
  /// **'Little louder! 😊'**
  String get labelLouder4;

  /// No description provided for @labelGetting4.
  ///
  /// In en, this message translates to:
  /// **'Getting there! 🎵'**
  String get labelGetting4;

  /// No description provided for @labelKeep4.
  ///
  /// In en, this message translates to:
  /// **'Yes!! Keep going! 🔥'**
  String get labelKeep4;

  /// No description provided for @labelIncredible4.
  ///
  /// In en, this message translates to:
  /// **'INCREDIBLE!! 🎊🎉'**
  String get labelIncredible4;

  /// No description provided for @meterBars.
  ///
  /// In en, this message translates to:
  /// **'bars'**
  String get meterBars;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
