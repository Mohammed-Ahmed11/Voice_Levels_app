// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeGreeting => 'Hello, ';

  @override
  String get homeGreetingName => 'Little Star! ⭐';

  @override
  String get homeSubtitle => 'What do you want to do today?';

  @override
  String get homeTip => '💡 Set Max Level & Countdown in Options!';

  @override
  String get cardStartTitle => 'Start';

  @override
  String get cardStartSubtitle => 'Record something fun!';

  @override
  String get cardReportsTitle => 'Reports';

  @override
  String get cardReportsSubtitle => 'Listen & share!';

  @override
  String get cardProfilesTitle => 'Profiles';

  @override
  String get cardProfilesSubtitle => 'Patients / kids';

  @override
  String get cardOptionsTitle => 'Options';

  @override
  String get cardOptionsSubtitle => 'App settings';

  @override
  String get profilePickerTitle => '👶 Choose Profile';

  @override
  String get profilePickerSubtitle => 'Select who you will record for';

  @override
  String get profilePickerActivePrefix => 'Active: ';

  @override
  String get profilePickerNoPhone => 'No phone';

  @override
  String get profilePickerNewProfileBtn => '➕ New Profile';

  @override
  String get profilePickerCancelBtn => 'Cancel';

  @override
  String get snackbarCreateProfileFirst => 'Create a profile first 👶';

  @override
  String get fallbackLogoAppName => 'Speech Space';

  @override
  String get settingsTitle1 => 'App ';

  @override
  String get settingsTitle2 => 'Options';

  @override
  String get settingsSubtitle => 'Customize how the app works ⚙️';

  @override
  String get settingsSectionPermissions => 'Permissions';

  @override
  String get settingsSectionRecording => 'Recording';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsMicTitle => 'Microphone';

  @override
  String get settingsMicGranted => 'Granted';

  @override
  String get settingsMicNotGranted => 'Not Granted';

  @override
  String get settingsMicCheckBtn => 'Check';

  @override
  String get settingsQualityTitle => 'Recording Quality';

  @override
  String get settingsQualityHigh => 'High';

  @override
  String get settingsQualityMedium => 'Medium';

  @override
  String get settingsQualityLow => 'Low';

  @override
  String get settingsMaxLevelTitle => 'Max Level';

  @override
  String settingsMaxLevelSubtitle(int count) {
    return '$count levels';
  }

  @override
  String get settingsCountdownTitle => 'Countdown';

  @override
  String get settingsCountdownOff => 'Off';

  @override
  String settingsCountdownSeconds(int count) {
    return '$count seconds';
  }

  @override
  String get settingsLangEnglishTitle => 'English';

  @override
  String get settingsLangEnglishSubtitle => 'Switch to English';

  @override
  String get settingsLangArabicTitle => 'العربية';

  @override
  String get settingsLangArabicSubtitle => 'Switch to Arabic';

  @override
  String get settingsProfileTitle => 'Go to Profile';

  @override
  String get settingsProfileSubtitle => 'Parent & child info';

  @override
  String get settingsResetTitle => 'Reset App Data';

  @override
  String get settingsResetSubtitle => 'Delete profile, recordings & settings';

  @override
  String get settingsResetBtn => 'Reset';

  @override
  String get settingsResetDialogTitle => 'Reset App Data?';

  @override
  String get settingsResetDialogBody => 'This will delete your profile, recordings, and all settings.';

  @override
  String get settingsResetDialogCancel => 'Cancel';

  @override
  String get settingsResetDialogConfirm => 'Reset';

  @override
  String get settingsResetSuccess => 'App data reset!';

  @override
  String get profileTitle => 'Patients';

  @override
  String get profileSubtitle => 'Create a profile for each patient so recordings don’t get mixed.';

  @override
  String get profileParentSection => 'Parent Info';

  @override
  String get profileParentName => 'Parent Name';

  @override
  String get profileParentNameHint => 'e.g. Sarah';

  @override
  String get profilePhone => 'Phone Number';

  @override
  String get profilePhoneHint => 'e.g. +20 ...';

  @override
  String get profilePatientSection => 'Patient Info';

  @override
  String get profilePatientName => 'Patient Name';

  @override
  String get profilePatientNameHint => 'e.g. Lily';

  @override
  String get profileNotes => 'Notes';

  @override
  String get profileNotesHint => 'Any extra info...';

  @override
  String profileDeleteTitle(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get profileDeleteBody => 'This will delete this patient and their recordings.';

  @override
  String get profileDeleteCancel => 'Cancel';

  @override
  String get profileDeleteConfirm => 'Delete';

  @override
  String get profileSave => 'Save Changes';

  @override
  String get profileCreate => 'Create Patient';

  @override
  String get profileSaved => 'Saved!';

  @override
  String profileDefaultPatient(int number) {
    return 'Patient $number';
  }

  @override
  String get patient => 'Patient';

  @override
  String get reports => 'Reports';

  @override
  String get tapPatient => 'Tap a patient to view their recordings 🎵';

  @override
  String get recording => 'recording';

  @override
  String get recordings => 'recordings';

  @override
  String get sessions => 'sessions';

  @override
  String get peak => 'Peak';

  @override
  String get deleteRecording => 'Delete Recording?';

  @override
  String get deleteRecordingConfirm => 'This recording will be permanently deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noPatients => 'No patients yet!';

  @override
  String get addPatientHint => 'Add a patient profile first 👨‍👩‍👧';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get noRecordingsFor => 'No recordings for';

  @override
  String get startSessionHint => 'Start a session to see results here 🎙️';

  @override
  String get startRecording => 'Start Recording';

  @override
  String get mode => 'Mode';

  @override
  String get modeClassic => 'Classic';

  @override
  String get modeRounded => 'Rounded';

  @override
  String get modeThick => 'Thick Meter';

  @override
  String get modePlayful => 'Playful';

  @override
  String get navHome => 'Home';

  @override
  String get navRecords => 'Records';

  @override
  String get navOptions => 'Options';

  @override
  String get modeSelectTitle1 => 'Pick a ';

  @override
  String get modeSelectTitle2 => 'Mode!';

  @override
  String get modeSelectSubtitle => '4 unique looks to choose from';

  @override
  String get modeClassicDesc => 'Simple level meter';

  @override
  String get modeRoundedDesc => 'Smooth rounded meter';

  @override
  String get modeThickDesc => 'Bold & clear levels';

  @override
  String get modePlayfulDesc => 'Fun child-friendly UI';

  @override
  String get modeTagPopular => 'Popular';

  @override
  String get modeTagSmooth => 'Smooth';

  @override
  String get modeTagBold => 'Bold';

  @override
  String get modeTagFun => 'Fun';

  @override
  String get modeTapToUse => 'Tap to use';

  @override
  String get zoneQuiet => 'Quiet';

  @override
  String get zoneGood => 'Good';

  @override
  String get zoneLoud => 'Loud';

  @override
  String get zoneMax => 'Max!';

  @override
  String get zoneDotQuietPlayful => '🐢 Quiet';

  @override
  String get zoneDotGoodPlayful => '🐥 Good';

  @override
  String get zoneDotLoudPlayful => '🚀 Loud';

  @override
  String get zoneDotMaxPlayful => '🌟 Max!';

  @override
  String get labelQuiet1 => 'Quiet...';

  @override
  String get labelLouder1 => 'Getting louder!';

  @override
  String get labelGreat1 => 'Great job!';

  @override
  String get labelAmazing1 => 'AMAZING! 🎉';

  @override
  String get labelQuiet2 => 'Shhh... 🤫';

  @override
  String get labelLouder2 => 'Keep going!';

  @override
  String get labelLoud2 => 'So loud! 🎉';

  @override
  String get labelAmazing2 => 'AMAZING!! 🌟';

  @override
  String get labelQuiet4 => 'So quiet... 🤫';

  @override
  String get labelLouder4 => 'Little louder! 😊';

  @override
  String get labelGetting4 => 'Getting there! 🎵';

  @override
  String get labelKeep4 => 'Yes!! Keep going! 🔥';

  @override
  String get labelIncredible4 => 'INCREDIBLE!! 🎊🎉';

  @override
  String get meterBars => 'bars';
}
