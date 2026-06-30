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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Engez'**
  String get appName;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greetingEvening;

  /// No description provided for @motivationDefault.
  ///
  /// In en, this message translates to:
  /// **'One task at a time. One step closer.'**
  String get motivationDefault;

  /// No description provided for @homeTagline1.
  ///
  /// In en, this message translates to:
  /// **'Small steps lead to'**
  String get homeTagline1;

  /// No description provided for @homeTagline2.
  ///
  /// In en, this message translates to:
  /// **'big achievements!'**
  String get homeTagline2;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No Tasks Yet'**
  String get noTasksYet;

  /// No description provided for @addNewTask.
  ///
  /// In en, this message translates to:
  /// **'Add New Task'**
  String get addNewTask;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @highPriorityTasks.
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get highPriorityTasks;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabToDo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get tabToDo;

  /// No description provided for @tabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tabCompleted;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @todoTitle.
  ///
  /// In en, this message translates to:
  /// **'To Do Tasks'**
  String get todoTitle;

  /// No description provided for @noTodoTasks.
  ///
  /// In en, this message translates to:
  /// **'No Tasks Yet'**
  String get noTodoTasks;

  /// No description provided for @completedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTitle;

  /// No description provided for @noCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'No Completed Tasks Yet'**
  String get noCompletedTasks;

  /// No description provided for @archivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived Tasks'**
  String get archivedTitle;

  /// No description provided for @noArchivedTasks.
  ///
  /// In en, this message translates to:
  /// **'No Archived Tasks'**
  String get noArchivedTasks;

  /// No description provided for @archiveBanner.
  ///
  /// In en, this message translates to:
  /// **'Archived tasks are read-only and will be permanently deleted after 7 days.'**
  String get archiveBanner;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSectionLabel;

  /// No description provided for @menuUserDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get menuUserDetails;

  /// No description provided for @menuArchivedTasks.
  ///
  /// In en, this message translates to:
  /// **'Archived Tasks'**
  String get menuArchivedTasks;

  /// No description provided for @menuBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get menuBackupRestore;

  /// No description provided for @menuPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get menuPrivacySecurity;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menuDarkMode;

  /// No description provided for @menuLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get menuLogOut;

  /// No description provided for @galleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get galleryOption;

  /// No description provided for @cameraOption.
  ///
  /// In en, this message translates to:
  /// **'Take from Camera'**
  String get cameraOption;

  /// No description provided for @userDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetailsTitle;

  /// No description provided for @userDetailsName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get userDetailsName;

  /// No description provided for @userDetailsQuote.
  ///
  /// In en, this message translates to:
  /// **'Motivation Quote'**
  String get userDetailsQuote;

  /// No description provided for @userDetailsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get userDetailsSave;

  /// No description provided for @userDetailsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sarah Khalid'**
  String get userDetailsNameHint;

  /// No description provided for @userDetailsQuoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. You got this!'**
  String get userDetailsQuoteHint;

  /// No description provided for @userDetailsNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get userDetailsNameValidation;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome To Engez'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your productivity journey starts here.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get onboardingFullName;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sarah Khalid'**
  String get onboardingNameHint;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get onboardingRestoreBackup;

  /// No description provided for @onboardingRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get onboardingRestoring;

  /// No description provided for @onboardingRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Have a backup file? Restore everything in one tap.'**
  String get onboardingRestoreHint;

  /// No description provided for @onboardingValidateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get onboardingValidateName;

  /// No description provided for @onboardingValidateNameLength.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid full name'**
  String get onboardingValidateNameLength;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestoreTitle;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get backupNow;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get restoreFromFile;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Auto Backup'**
  String get autoBackup;

  /// No description provided for @backupPath.
  ///
  /// In en, this message translates to:
  /// **'Backup Location'**
  String get backupPath;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @backupSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Backup saved successfully'**
  String get backupSuccessful;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @restoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreDialogTitle;

  /// No description provided for @restoreDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Found {count} task(s) in this backup.'**
  String restoreDialogContent(int count);

  /// No description provided for @restoreDialogCreated.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String restoreDialogCreated(String date);

  /// No description provided for @restoreDialogWarning.
  ///
  /// In en, this message translates to:
  /// **'All tasks will be restored and you\'ll go straight to the app.'**
  String get restoreDialogWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @addTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get addTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskTitle;

  /// No description provided for @taskNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskNameLabel;

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'Task Name'**
  String get taskNameHint;

  /// No description provided for @taskDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescLabel;

  /// No description provided for @taskDescHint.
  ///
  /// In en, this message translates to:
  /// **'Write your task description here ...'**
  String get taskDescHint;

  /// No description provided for @taskAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get taskAddButton;

  /// No description provided for @taskUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Task'**
  String get taskUpdateButton;

  /// No description provided for @taskNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Task name is required'**
  String get taskNameRequired;

  /// No description provided for @taskReminderPast.
  ///
  /// In en, this message translates to:
  /// **'Reminder time cannot be in the past.'**
  String get taskReminderPast;

  /// No description provided for @taskReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get taskReminderLabel;

  /// No description provided for @taskAlarmSound.
  ///
  /// In en, this message translates to:
  /// **'Alarm Sound'**
  String get taskAlarmSound;

  /// No description provided for @taskSnoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Snooze Duration'**
  String get taskSnoozeDuration;

  /// No description provided for @defaultNotification.
  ///
  /// In en, this message translates to:
  /// **'Default Notification'**
  String get defaultNotification;

  /// No description provided for @confirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm Selection'**
  String get confirmSelection;

  /// No description provided for @addCustomSound.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Sound from Files'**
  String get addCustomSound;

  /// No description provided for @alarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get alarmTitle;

  /// No description provided for @alarmFor.
  ///
  /// In en, this message translates to:
  /// **'Alarm for'**
  String get alarmFor;

  /// No description provided for @alarmSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get alarmSnooze;

  /// No description provided for @alarmStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get alarmStop;

  /// No description provided for @taskAdded.
  ///
  /// In en, this message translates to:
  /// **'added'**
  String get taskAdded;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'updated'**
  String get taskUpdated;

  /// No description provided for @reminderIn.
  ///
  /// In en, this message translates to:
  /// **'You will be reminded in'**
  String get reminderIn;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyTitle;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Engez stores all your tasks and personal data locally on your device. No data is ever sent to external servers.'**
  String get privacyDataBody;

  /// No description provided for @privacyBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup Files'**
  String get privacyBackupTitle;

  /// No description provided for @privacyBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Backup files are saved to your device storage (TaskyBackups folder). They are not encrypted – avoid sharing them with untrusted parties.'**
  String get privacyBackupBody;

  /// No description provided for @privacyNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Alarms'**
  String get privacyNotifTitle;

  /// No description provided for @privacyNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Engez uses local notifications to remind you about tasks. No network access is required for reminders.'**
  String get privacyNotifBody;

  /// No description provided for @privacyPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions Used'**
  String get privacyPermTitle;

  /// No description provided for @privacyPermStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage – to save and restore backup files.'**
  String get privacyPermStorage;

  /// No description provided for @privacyPermNotif.
  ///
  /// In en, this message translates to:
  /// **'Notifications – to deliver task reminders.'**
  String get privacyPermNotif;

  /// No description provided for @privacyPermCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera & Gallery – to update your profile picture.'**
  String get privacyPermCamera;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'For questions or concerns, please reach out to the developer.'**
  String get privacyContactBody;

  /// No description provided for @privacyVersion.
  ///
  /// In en, this message translates to:
  /// **'Engez v1.0.0'**
  String get privacyVersion;

  /// No description provided for @backupMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge with Current Tasks'**
  String get backupMerge;

  /// No description provided for @backupMergeDesc.
  ///
  /// In en, this message translates to:
  /// **'Adds backup tasks • keeps duplicates as-is'**
  String get backupMergeDesc;

  /// No description provided for @backupReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace Current Tasks'**
  String get backupReplace;

  /// No description provided for @backupReplaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes all existing tasks first'**
  String get backupReplaceDesc;

  /// No description provided for @backupReplaceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace Tasks?'**
  String get backupReplaceConfirmTitle;

  /// No description provided for @backupReplaceConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your current tasks and replace them with the {count} tasks from this backup.\n\nThis cannot be undone.'**
  String backupReplaceConfirmDesc(int count);

  /// No description provided for @backupReplaceBtn.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get backupReplaceBtn;

  /// No description provided for @backupTasksReplaced.
  ///
  /// In en, this message translates to:
  /// **'Tasks replaced successfully!'**
  String get backupTasksReplaced;

  /// No description provided for @backupTasksMerged.
  ///
  /// In en, this message translates to:
  /// **'Tasks merged successfully!'**
  String get backupTasksMerged;

  /// No description provided for @backupAutoBanner.
  ///
  /// In en, this message translates to:
  /// **'Saves to Internal Storage → TaskyBackups'**
  String get backupAutoBanner;

  /// No description provided for @backupFreq.
  ///
  /// In en, this message translates to:
  /// **'Backup Frequency'**
  String get backupFreq;

  /// No description provided for @backupFreqDays.
  ///
  /// In en, this message translates to:
  /// **'Every {days} Days'**
  String backupFreqDays(int days);

  /// No description provided for @backupFreqDay.
  ///
  /// In en, this message translates to:
  /// **'Every Day'**
  String get backupFreqDay;

  /// No description provided for @backupSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Saved to your internal storage'**
  String get backupSavedLocal;

  /// No description provided for @taskActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get taskActionEdit;

  /// No description provided for @taskActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get taskActionDelete;

  /// No description provided for @taskActionArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get taskActionArchive;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskDesc.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{taskName}\"? This action cannot be undone.'**
  String deleteTaskDesc(String taskName);

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTaskConfirm;

  /// No description provided for @achievedTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Achieved Tasks'**
  String get achievedTasksTitle;

  /// No description provided for @achievedTasksCount.
  ///
  /// In en, this message translates to:
  /// **'{achieved} Out of {total} Done'**
  String achievedTasksCount(int achieved, int total);

  /// No description provided for @backupStoragePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow File Access'**
  String get backupStoragePermissionTitle;

  /// No description provided for @backupStoragePermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'To save backups directly to Internal Storage → TaskyBackups (visible in the Files app), Engez needs \"All Files Access\".\n\nTap Continue → find Engez → enable the toggle.'**
  String get backupStoragePermissionDesc;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @errorPickingFile.
  ///
  /// In en, this message translates to:
  /// **'Error picking file'**
  String get errorPickingFile;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
