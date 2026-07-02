// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Engez';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get motivationDefault => 'One task at a time. One step closer.';

  @override
  String get homeTagline1 => 'Small steps lead to';

  @override
  String get homeTagline2 => 'big achievements!';

  @override
  String get noTasksYet => 'No Tasks Yet';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get highPriorityTasks => 'High Priority';

  @override
  String get tabHome => 'Home';

  @override
  String get tabToDo => 'To Do';

  @override
  String get tabCompleted => 'Completed';

  @override
  String get tabProfile => 'Profile';

  @override
  String get todoTitle => 'To Do Tasks';

  @override
  String get noTodoTasks => 'No Tasks Yet';

  @override
  String get completedTitle => 'Completed Tasks';

  @override
  String get noCompletedTasks => 'No Completed Tasks Yet';

  @override
  String get archivedTitle => 'Archived Tasks';

  @override
  String get noArchivedTasks => 'No Archived Tasks';

  @override
  String get archiveBanner =>
      'Archived tasks are read-only and will be permanently deleted after 7 days.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileSectionLabel => 'Settings';

  @override
  String get menuUserDetails => 'User Details';

  @override
  String get menuArchivedTasks => 'Archived Tasks';

  @override
  String get menuBackupRestore => 'Backup & Restore';

  @override
  String get menuPrivacySecurity => 'Privacy & Security';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuDarkMode => 'Dark Mode';

  @override
  String get menuLogOut => 'Log Out';

  @override
  String get galleryOption => 'Choose from Gallery';

  @override
  String get cameraOption => 'Take from Camera';

  @override
  String get userDetailsTitle => 'User Details';

  @override
  String get userDetailsName => 'Full Name';

  @override
  String get userDetailsQuote => 'Motivation Quote';

  @override
  String get userDetailsSave => 'Save Changes';

  @override
  String get userDetailsNameHint => 'e.g. Sarah Khalid';

  @override
  String get userDetailsQuoteHint => 'e.g. You got this!';

  @override
  String get userDetailsNameValidation => 'Please enter your name';

  @override
  String get onboardingWelcome => 'Welcome To Engez';

  @override
  String get onboardingSubtitle => 'Your productivity journey starts here.';

  @override
  String get onboardingFullName => 'Full Name';

  @override
  String get onboardingNameHint => 'e.g. Sarah Khalid';

  @override
  String get onboardingGetStarted => 'Let\'s Get Started';

  @override
  String get onboardingRestoreBackup => 'Restore from Backup';

  @override
  String get onboardingRestoring => 'Restoring...';

  @override
  String get onboardingRestoreHint =>
      'Have a backup file? Restore everything in one tap.';

  @override
  String get onboardingValidateName => 'Please enter your full name';

  @override
  String get onboardingValidateNameLength => 'Please enter a valid full name';

  @override
  String get backupRestoreTitle => 'Backup & Restore';

  @override
  String get backupNow => 'Backup Now';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get backupPath => 'Backup Location';

  @override
  String get lastBackup => 'Last backup';

  @override
  String get never => 'Never';

  @override
  String get backupSuccessful => 'Backup saved successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreDialogTitle => 'Restore Backup';

  @override
  String restoreDialogContent(int count) {
    return 'Found $count task(s) in this backup.';
  }

  @override
  String restoreDialogCreated(String date) {
    return 'Created: $date';
  }

  @override
  String get restoreDialogWarning =>
      'All tasks will be restored and you\'ll go straight to the app.';

  @override
  String get cancel => 'Cancel';

  @override
  String get restore => 'Restore';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get addTaskTitle => 'New Task';

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get taskNameLabel => 'Task Name';

  @override
  String get taskNameHint => 'Task Name';

  @override
  String get taskDescLabel => 'Description';

  @override
  String get taskDescHint => 'Write your task description here ...';

  @override
  String get taskAddButton => 'Add Task';

  @override
  String get taskUpdateButton => 'Update Task';

  @override
  String get taskNameRequired => 'Task name is required';

  @override
  String get taskReminderPast => 'Reminder time cannot be in the past.';

  @override
  String get taskReminderLabel => 'Set Reminder';

  @override
  String get taskAlarmSound => 'Alarm Sound';

  @override
  String get taskSnoozeDuration => 'Snooze Duration';

  @override
  String get defaultNotification => 'Default Notification';

  @override
  String get confirmSelection => 'Confirm Selection';

  @override
  String get addCustomSound => 'Add Custom Sound from Files';

  @override
  String get alarmTitle => 'Time\'s Up!';

  @override
  String get alarmFor => 'Alarm for';

  @override
  String get alarmSnooze => 'Snooze';

  @override
  String get alarmStop => 'Stop';

  @override
  String get taskAdded => 'added';

  @override
  String get taskUpdated => 'updated';

  @override
  String get reminderIn => 'You will be reminded in';

  @override
  String get privacyTitle => 'Privacy & Security';

  @override
  String get privacyDataTitle => 'Your Data';

  @override
  String get privacyDataBody =>
      'Engez stores all your tasks and personal data locally on your device. No data is ever sent to external servers.';

  @override
  String get privacyBackupTitle => 'Backup Files';

  @override
  String get privacyBackupBody =>
      'Backup files are saved to your device storage (EngezBackups folder). They are not encrypted – avoid sharing them with untrusted parties.';

  @override
  String get privacyNotifTitle => 'Notifications & Alarms';

  @override
  String get privacyNotifBody =>
      'Engez uses local notifications to remind you about tasks. No network access is required for reminders.';

  @override
  String get privacyPermTitle => 'Permissions Used';

  @override
  String get privacyPermStorage =>
      'Storage – to save and restore backup files.';

  @override
  String get privacyPermNotif => 'Notifications – to deliver task reminders.';

  @override
  String get privacyPermCamera =>
      'Camera & Gallery – to update your profile picture.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String get privacyContactBody =>
      'For questions or concerns, please reach out to the developer.';

  @override
  String get privacyVersion => 'Engez v1.0.0';

  @override
  String get backupMerge => 'Merge with Current Tasks';

  @override
  String get backupMergeDesc => 'Adds backup tasks • keeps duplicates as-is';

  @override
  String get backupReplace => 'Replace Current Tasks';

  @override
  String get backupReplaceDesc => 'Deletes all existing tasks first';

  @override
  String get backupReplaceConfirmTitle => 'Replace Tasks?';

  @override
  String backupReplaceConfirmDesc(int count) {
    return 'This will permanently delete all your current tasks and replace them with the $count tasks from this backup.\n\nThis cannot be undone.';
  }

  @override
  String get backupReplaceBtn => 'Replace';

  @override
  String get backupTasksReplaced => 'Tasks replaced successfully!';

  @override
  String get backupTasksMerged => 'Tasks merged successfully!';

  @override
  String get backupAutoBanner => 'Saves to Internal Storage → EngezBackups';

  @override
  String get backupFreq => 'Backup Frequency';

  @override
  String backupFreqDays(int days) {
    return 'Every $days Days';
  }

  @override
  String get backupFreqDay => 'Every Day';

  @override
  String get backupSavedLocal => 'Saved to your internal storage';

  @override
  String get taskActionEdit => 'Edit';

  @override
  String get taskActionDelete => 'Delete';

  @override
  String get taskActionArchive => 'Archive';

  @override
  String get deleteTaskTitle => 'Delete Task';

  @override
  String deleteTaskDesc(String taskName) {
    return 'Delete \"$taskName\"? This action cannot be undone.';
  }

  @override
  String get deleteTaskConfirm => 'Delete';

  @override
  String get achievedTasksTitle => 'Achieved Tasks';

  @override
  String achievedTasksCount(int achieved, int total) {
    return '$achieved Out of $total Done';
  }

  @override
  String get backupStoragePermissionTitle => 'Allow File Access';

  @override
  String get backupStoragePermissionDesc =>
      'To save backups directly to Internal Storage → EngezBackups (visible in the Files app), Engez needs \"All Files Access\".\n\nTap Continue → find Engez → enable the toggle.';

  @override
  String get continueBtn => 'Continue';

  @override
  String get errorPickingFile => 'Error picking file';
}
