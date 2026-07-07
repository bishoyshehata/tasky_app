// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أنجز';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get motivationDefault => 'خطوة واحدة في كل مرة، وستصل.';

  @override
  String get homeTagline1 => 'خطوات صغيرة تقود إلى';

  @override
  String get homeTagline2 => 'إنجازات كبيرة!';

  @override
  String get noTasksYet => 'لا توجد مهام بعد';

  @override
  String get addNewTask => 'إضافة مهمة';

  @override
  String get myTasks => 'مهامي';

  @override
  String get highPriorityTasks => 'أولوية عالية';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabToDo => 'قيد التنفيذ';

  @override
  String get tabCompleted => 'المنجزة';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get todoTitle => 'المهام قيد التنفيذ';

  @override
  String get noTodoTasks => 'لا توجد مهام بعد';

  @override
  String get completedTitle => 'المهام المنجزة';

  @override
  String get noCompletedTasks => 'لا توجد مهام منجزة بعد';

  @override
  String get archivedTitle => 'المهام المؤرشفة';

  @override
  String get noArchivedTasks => 'لا توجد مهام مؤرشفة';

  @override
  String get archiveBanner =>
      'المهام المؤرشفة للقراءة فقط وستُحذف نهائيًا بعد ٧ أيام.';

  @override
  String get profileTitle => 'ملفي الشخصي';

  @override
  String get profileSectionLabel => 'الإعدادات';

  @override
  String get menuUserDetails => 'بياناتي';

  @override
  String get menuArchivedTasks => 'المهام المؤرشفة';

  @override
  String get menuBackupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get menuPrivacySecurity => 'الخصوصية والأمان';

  @override
  String get menuLanguage => 'اللغة';

  @override
  String get menuDarkMode => 'الوضع الداكن';

  @override
  String get menuLogOut => 'تسجيل الخروج';

  @override
  String get galleryOption => 'اختر من المعرض';

  @override
  String get cameraOption => 'التقط صورة';

  @override
  String get userDetailsTitle => 'بياناتي';

  @override
  String get userDetailsName => 'الاسم الكامل';

  @override
  String get userDetailsQuote => 'اقتباس تحفيزي';

  @override
  String get userDetailsSave => 'حفظ التغييرات';

  @override
  String get userDetailsNameHint => 'مثال: سارة خالد';

  @override
  String get userDetailsQuoteHint => 'مثال: أنت قادر على ذلك!';

  @override
  String get userDetailsNameValidation => 'الرجاء إدخال اسمك';

  @override
  String get onboardingWelcome => 'أهلاً بك في أنجز';

  @override
  String get onboardingSubtitle => 'رحلتك نحو الإنتاجية تبدأ هنا.';

  @override
  String get onboardingFullName => 'الاسم الكامل';

  @override
  String get onboardingNameHint => 'مثال: سارة خالد';

  @override
  String get onboardingGetStarted => 'لنبدأ الآن';

  @override
  String get onboardingRestoreBackup => 'استعادة من نسخة احتياطية';

  @override
  String get onboardingRestoring => 'جارٍ الاستعادة...';

  @override
  String get onboardingRestoreHint =>
      'هل لديك ملف نسخة احتياطية؟ استعد كل شيء بنقرة واحدة.';

  @override
  String get onboardingValidateName => 'الرجاء إدخال اسمك الكامل';

  @override
  String get onboardingValidateNameLength => 'الرجاء إدخال اسم صحيح';

  @override
  String get backupRestoreTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get backupNow => 'نسخ احتياطي الآن';

  @override
  String get restoreFromFile => 'استعادة من ملف';

  @override
  String get autoBackup => 'النسخ التلقائي';

  @override
  String get backupPath => 'مسار النسخة الاحتياطية';

  @override
  String get lastBackup => 'آخر نسخة احتياطية';

  @override
  String get never => 'لم يتم بعد';

  @override
  String get backupSuccessful => 'تم حفظ النسخة الاحتياطية بنجاح';

  @override
  String get backupFailed => 'فشل النسخ الاحتياطي';

  @override
  String get restoreDialogTitle => 'استعادة النسخة الاحتياطية';

  @override
  String restoreDialogContent(int count) {
    return 'تم العثور على $count مهمة في هذه النسخة.';
  }

  @override
  String restoreDialogCreated(String date) {
    return 'تاريخ الإنشاء: $date';
  }

  @override
  String get restoreDialogWarning =>
      'سيتم استعادة جميع المهام وستنتقل مباشرةً إلى التطبيق.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get restore => 'استعادة';

  @override
  String get restoreFailed => 'فشلت الاستعادة';

  @override
  String get addTaskTitle => 'مهمة جديدة';

  @override
  String get editTaskTitle => 'تعديل المهمة';

  @override
  String get taskNameLabel => 'اسم المهمة';

  @override
  String get taskNameHint => 'اسم المهمة';

  @override
  String get taskDescLabel => 'الوصف';

  @override
  String get taskDescHint => 'اكتب وصف المهمة هنا...';

  @override
  String get taskAddButton => 'إضافة المهمة';

  @override
  String get taskUpdateButton => 'تحديث المهمة';

  @override
  String get taskNameRequired => 'اسم المهمة مطلوب';

  @override
  String get taskReminderPast => 'لا يمكن أن يكون وقت التذكير في الماضي.';

  @override
  String get taskReminderLabel => 'تعيين تذكير';

  @override
  String get taskAlarmSound => 'صوت المنبه';

  @override
  String get taskSnoozeDuration => 'مدة التأجيل';

  @override
  String get defaultNotification => 'الإشعار الافتراضي';

  @override
  String get confirmSelection => 'تأكيد الاختيار';

  @override
  String get addCustomSound => 'إضافة صوت مخصص من الملفات';

  @override
  String get alarmTitle => 'انتهى الوقت!';

  @override
  String get alarmFor => 'منبه لـ';

  @override
  String get alarmSnooze => 'تأجيل';

  @override
  String get alarmStop => 'إيقاف';

  @override
  String get taskAdded => 'تمت الإضافة';

  @override
  String get taskUpdated => 'تم التحديث';

  @override
  String get reminderIn => 'سيتم تذكيرك خلال';

  @override
  String get privacyTitle => 'الخصوصية والأمان';

  @override
  String get privacyDataTitle => 'بياناتك';

  @override
  String get privacyDataBody =>
      'تخزّن أنجز جميع مهامك وبياناتك الشخصية محليًا على جهازك. لا يُرسَل أي بيانات إلى خوادم خارجية.';

  @override
  String get privacyBackupTitle => 'ملفات النسخ الاحتياطي';

  @override
  String get privacyBackupBody =>
      'تُحفَظ النسخ الاحتياطية في مجلد EngezBackups على جهازك. الملفات غير مشفرة – تجنب مشاركتها مع أطراف غير موثوقة.';

  @override
  String get privacyNotifTitle => 'الإشعارات والتنبيهات';

  @override
  String get privacyNotifBody =>
      'تستخدم أنجز الإشعارات المحلية لتذكيرك بمهامك. لا يلزم أي وصول إلى الإنترنت لإرسال التذكيرات.';

  @override
  String get privacyPermTitle => 'الأذونات المستخدمة';

  @override
  String get privacyPermStorage =>
      'التخزين – لحفظ واستعادة ملفات النسخ الاحتياطي.';

  @override
  String get privacyPermNotif => 'الإشعارات – لإرسال تذكيرات المهام.';

  @override
  String get privacyPermCamera => 'الكاميرا والمعرض – لتحديث صورة ملفك الشخصي.';

  @override
  String get privacyContactTitle => 'تواصل معنا';

  @override
  String get privacyContactBody =>
      'لأي أسئلة أو استفسارات، يرجى التواصل مع المطور.';

  @override
  String get privacyVersion => 'أنجز v1.0.0';

  @override
  String get backupMerge => 'دمج مع المهام الحالية';

  @override
  String get backupMergeDesc =>
      'يضيف مهام النسخة الاحتياطية • يبقي النسخ المكررة';

  @override
  String get backupReplace => 'استبدال المهام الحالية';

  @override
  String get backupReplaceDesc => 'يحذف جميع المهام الموجودة أولاً';

  @override
  String get backupReplaceConfirmTitle => 'استبدال المهام؟';

  @override
  String backupReplaceConfirmDesc(int count) {
    return 'سيؤدي هذا إلى حذف جميع مهامك الحالية نهائيًا واستبدالها بـ $count مهمة من هذه النسخة.\n\nلا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get backupReplaceBtn => 'استبدال';

  @override
  String get backupTasksReplaced => 'تم استبدال المهام بنجاح!';

  @override
  String get backupTasksMerged => 'تم دمج المهام بنجاح!';

  @override
  String get backupAutoBanner =>
      'يُحفظ في وحدة التخزين الداخلية → EngezBackups';

  @override
  String get backupFreq => 'معدل النسخ الاحتياطي';

  @override
  String backupFreqDays(int days) {
    return 'كل $days أيام';
  }

  @override
  String get backupFreqDay => 'كل يوم';

  @override
  String get backupSavedLocal => 'تم الحفظ في وحدة التخزين الداخلية';

  @override
  String get taskActionEdit => 'تعديل';

  @override
  String get taskActionDelete => 'حذف';

  @override
  String get taskActionArchive => 'أرشفة';

  @override
  String get deleteTaskTitle => 'حذف المهمة';

  @override
  String deleteTaskDesc(String taskName) {
    return 'هل تريد حذف \"$taskName\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteTaskConfirm => 'حذف';

  @override
  String get achievedTasksTitle => 'المهام المنجزة';

  @override
  String achievedTasksCount(int achieved, int total) {
    return 'تم إنجاز $achieved من أصل $total';
  }

  @override
  String get backupStoragePermissionTitle => 'السماح بالوصول إلى الملفات';

  @override
  String get backupStoragePermissionDesc =>
      'لحفظ النسخ الاحتياطية مباشرة في وحدة التخزين الداخلية → EngezBackups (مرئية في تطبيق الملفات)، يحتاج تطبيق أنجز إلى \"الوصول إلى جميع الملفات\".\n\nاضغط على متابعة → ابحث عن أنجز → فعل خيار السماح.';

  @override
  String get continueBtn => 'متابعة';

  @override
  String get errorPickingFile => 'خطأ في اختيار الملف';

  @override
  String get micPermissionTitle => 'إذن الميكروفون مطلوب';

  @override
  String get micPermissionDesc =>
      'يتطلب الإدخال الصوتي الوصول إلى الميكروفون. يرجى السماح بإذن الميكروفون من إعدادات التطبيق، ثم العودة للمتابعة.';

  @override
  String get openSettings => 'فتح الإعدادات';
}
