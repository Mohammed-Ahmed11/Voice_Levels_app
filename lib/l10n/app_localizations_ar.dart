// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get homeGreeting => 'مرحباً، ';

  @override
  String get homeGreetingName => 'نجمنا الصغيرة! ⭐';

  @override
  String get homeSubtitle => 'ماذا تريد أن تفعل اليوم؟';

  @override
  String get homeTip => '💡 اضبط المستوى الأقصى والعد التنازلي في الخيارات!';

  @override
  String get cardStartTitle => 'ابدأ';

  @override
  String get cardStartSubtitle => 'سجّل شيئاً ممتعاً!';

  @override
  String get cardReportsTitle => 'التقارير';

  @override
  String get cardReportsSubtitle => 'استمع وشارك!';

  @override
  String get cardProfilesTitle => 'الملفات';

  @override
  String get cardProfilesSubtitle => 'المرضى / الأطفال';

  @override
  String get cardOptionsTitle => 'الخيارات';

  @override
  String get cardOptionsSubtitle => 'إعدادات التطبيق';

  @override
  String get profilePickerTitle => '👶 اختر ملفاً';

  @override
  String get profilePickerSubtitle => 'اختر لمن ستسجّل';

  @override
  String get profilePickerActivePrefix => 'النشط: ';

  @override
  String get profilePickerNoPhone => 'لا يوجد هاتف';

  @override
  String get profilePickerNewProfileBtn => '➕ ملف جديد';

  @override
  String get profilePickerCancelBtn => 'إلغاء';

  @override
  String get snackbarCreateProfileFirst => 'أنشئ ملفاً أولاً 👶';

  @override
  String get fallbackLogoAppName => 'Speech Space';

  @override
  String get settingsTitle1 => 'خيارات ';

  @override
  String get settingsTitle2 => 'التطبيق';

  @override
  String get settingsSubtitle => 'خصّص طريقة عمل التطبيق ⚙️';

  @override
  String get settingsSectionPermissions => 'الأذونات';

  @override
  String get settingsSectionRecording => 'التسجيل';

  @override
  String get settingsSectionLanguage => 'اللغة';

  @override
  String get settingsSectionData => 'البيانات';

  @override
  String get settingsMicTitle => 'الميكروفون';

  @override
  String get settingsMicGranted => 'مُفعَّل';

  @override
  String get settingsMicNotGranted => 'غير مُفعَّل';

  @override
  String get settingsMicCheckBtn => 'تحقق';

  @override
  String get settingsQualityTitle => 'جودة التسجيل';

  @override
  String get settingsQualityHigh => 'عالية';

  @override
  String get settingsQualityMedium => 'متوسطة';

  @override
  String get settingsQualityLow => 'منخفضة';

  @override
  String get settingsMaxLevelTitle => 'المستوى الأقصى';

  @override
  String settingsMaxLevelSubtitle(int count) {
    return '$count مستويات';
  }

  @override
  String get settingsCountdownTitle => 'العد التنازلي';

  @override
  String get settingsCountdownOff => 'إيقاف';

  @override
  String settingsCountdownSeconds(int count) {
    return '$count ثوانٍ';
  }

  @override
  String get settingsLangEnglishTitle => 'English';

  @override
  String get settingsLangEnglishSubtitle => 'التبديل للإنجليزية';

  @override
  String get settingsLangArabicTitle => 'العربية';

  @override
  String get settingsLangArabicSubtitle => 'التبديل للعربية';

  @override
  String get settingsProfileTitle => 'الملف الشخصي';

  @override
  String get settingsProfileSubtitle => 'معلومات الوالد والطفل';

  @override
  String get settingsResetTitle => 'إعادة ضبط التطبيق';

  @override
  String get settingsResetSubtitle => 'حذف الملف والتسجيلات والإعدادات';

  @override
  String get settingsResetBtn => 'إعادة ضبط';

  @override
  String get settingsResetDialogTitle => 'إعادة ضبط التطبيق؟';

  @override
  String get settingsResetDialogBody => 'سيتم حذف ملفك الشخصي والتسجيلات وجميع الإعدادات.';

  @override
  String get settingsResetDialogCancel => 'إلغاء';

  @override
  String get settingsResetDialogConfirm => 'إعادة ضبط';

  @override
  String get settingsResetSuccess => 'تمت إعادة ضبط التطبيق!';

  @override
  String get profileTitle => 'المرضى';

  @override
  String get profileSubtitle => 'أنشئ ملفًا لكل مريض حتى لا تختلط التسجيلات.';

  @override
  String get profileParentSection => 'بيانات ولي الأمر';

  @override
  String get profileParentName => 'اسم ولي الأمر';

  @override
  String get profileParentNameHint => 'مثال: سارة';

  @override
  String get profilePhone => 'رقم الهاتف';

  @override
  String get profilePhoneHint => 'مثال: +20 ...';

  @override
  String get profilePatientSection => 'بيانات المريض';

  @override
  String get profilePatientName => 'اسم المريض';

  @override
  String get profilePatientNameHint => 'مثال: ليلى';

  @override
  String get profileNotes => 'ملاحظات';

  @override
  String get profileNotesHint => 'أي معلومات إضافية...';

  @override
  String profileDeleteTitle(Object name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get profileDeleteBody => 'سيتم حذف هذا المريض وجميع تسجيلاته.';

  @override
  String get profileDeleteCancel => 'إلغاء';

  @override
  String get profileDeleteConfirm => 'حذف';

  @override
  String get profileSave => 'حفظ التعديلات';

  @override
  String get profileCreate => 'إنشاء مريض';

  @override
  String get profileSaved => 'تم الحفظ!';

  @override
  String profileDefaultPatient(int number) {
    return 'مريض $number';
  }

  @override
  String get patient => 'المريض';

  @override
  String get reports => 'التقارير';

  @override
  String get tapPatient => 'اضغط على المريض لعرض التسجيلات 🎵';

  @override
  String get recording => 'تسجيل';

  @override
  String get recordings => 'تسجيلات';

  @override
  String get sessions => 'جلسات';

  @override
  String get peak => 'أعلى مستوى';

  @override
  String get deleteRecording => 'حذف التسجيل؟';

  @override
  String get deleteRecordingConfirm => 'سيتم حذف هذا التسجيل نهائيًا';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get noPatients => 'لا يوجد مرضى بعد';

  @override
  String get addPatientHint => 'أضف ملف مريض أولاً 👨‍👩‍👧';

  @override
  String get addPatient => 'إضافة مريض';

  @override
  String get noRecordingsFor => 'لا توجد تسجيلات لـ';

  @override
  String get startSessionHint => 'ابدأ جلسة لعرض النتائج هنا 🎙️';

  @override
  String get startRecording => 'ابدأ التسجيل';

  @override
  String get mode => 'الوضع';

  @override
  String get modeClassic => 'كلاسيك';

  @override
  String get modeRounded => 'دائري';

  @override
  String get modeThick => 'سميك';

  @override
  String get modePlayful => 'مرح';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRecords => 'التسجيلات';

  @override
  String get navOptions => 'الخيارات';

  @override
  String get modeSelectTitle1 => 'اختر ';

  @override
  String get modeSelectTitle2 => 'الوضع!';

  @override
  String get modeSelectSubtitle => '4 أشكال مختلفة للاختيار';

  @override
  String get modeClassicDesc => 'مقياس مستوى بسيط';

  @override
  String get modeRoundedDesc => 'مقياس دائري ناعم';

  @override
  String get modeThickDesc => 'مستويات واضحة وعريضة';

  @override
  String get modePlayfulDesc => 'واجهة ممتعة للأطفال';

  @override
  String get modeTagPopular => 'الأشهر';

  @override
  String get modeTagSmooth => 'ناعم';

  @override
  String get modeTagBold => 'عريض';

  @override
  String get modeTagFun => 'ممتع';

  @override
  String get modeTapToUse => 'اضغط للاستخدام';

  @override
  String get zoneQuiet => 'هادئ';

  @override
  String get zoneGood => 'جيد';

  @override
  String get zoneLoud => 'عالٍ';

  @override
  String get zoneMax => 'الأقصى!';

  @override
  String get zoneDotQuietPlayful => '🐢 هادئ';

  @override
  String get zoneDotGoodPlayful => '🐥 جيد';

  @override
  String get zoneDotLoudPlayful => '🚀 عالٍ';

  @override
  String get zoneDotMaxPlayful => '🌟 الأقصى!';

  @override
  String get labelQuiet1 => 'هادئ...';

  @override
  String get labelLouder1 => 'يزداد الصوت!';

  @override
  String get labelGreat1 => 'أحسنت!';

  @override
  String get labelAmazing1 => 'رائع! 🎉';

  @override
  String get labelQuiet2 => 'بهدوء... 🤫';

  @override
  String get labelLouder2 => 'استمر!';

  @override
  String get labelLoud2 => 'عالٍ جداً! 🎉';

  @override
  String get labelAmazing2 => 'رائع!! 🌟';

  @override
  String get labelQuiet4 => 'هادئ جداً... 🤫';

  @override
  String get labelLouder4 => 'ارفع الصوت قليلاً! 😊';

  @override
  String get labelGetting4 => 'في الطريق! 🎵';

  @override
  String get labelKeep4 => 'نعم!! استمر! 🔥';

  @override
  String get labelIncredible4 => 'مذهل!! 🎊🎉';

  @override
  String get meterBars => 'أشرطة';
}
