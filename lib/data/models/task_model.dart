class TaskModel {
  /// Stable unique identifier used as the notification ID key.
  final String id;
  final String taskName;
  final String taskDescription;
  final bool isHighPriority;
  final String dateTime;
  bool isDone;
  final DateTime? reminderDate;
  final bool reminderEnabled;
  final String alarmSound;
  final int snoozeDuration;

  TaskModel({
    String? id,
    required this.taskName,
    required this.taskDescription,
    required this.isHighPriority,
    required this.dateTime,
    this.isDone = false,
    this.reminderDate,
    this.reminderEnabled = false,
    this.alarmSound = 'default',
    this.snoozeDuration = 10,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      taskName: json['taskName'] as String,
      taskDescription: json['taskDescription'] as String,
      isHighPriority: json['isHighPriority'] as bool,
      dateTime: json['dateTime'] as String,
      isDone: json['isDone'] as bool? ?? false,
      reminderDate: json['reminderDate'] != null
          ? DateTime.parse(json['reminderDate'] as String)
          : null,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      alarmSound: json['alarmSound'] as String? ?? 'default',
      snoozeDuration: json['snoozeDuration'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'isHighPriority': isHighPriority,
      'dateTime': dateTime,
      'isDone': isDone,
      'reminderDate': reminderDate?.toIso8601String(),
      'reminderEnabled': reminderEnabled,
      'alarmSound': alarmSound,
      'snoozeDuration': snoozeDuration,
    };
  }

  TaskModel copyWith({
    String? taskName,
    String? taskDescription,
    bool? isHighPriority,
    String? dateTime,
    bool? isDone,
    DateTime? reminderDate,
    bool? reminderEnabled,
    String? alarmSound,
    int? snoozeDuration,
  }) {
    return TaskModel(
      id: id,
      taskName: taskName ?? this.taskName,
      taskDescription: taskDescription ?? this.taskDescription,
      isHighPriority: isHighPriority ?? this.isHighPriority,
      dateTime: dateTime ?? this.dateTime,
      isDone: isDone ?? this.isDone,
      reminderDate: reminderDate ?? this.reminderDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      alarmSound: alarmSound ?? this.alarmSound,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }
}
