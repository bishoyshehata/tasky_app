class TaskModel {
  final String taskName;
  final String taskDescription;
  final bool isHighPriority;
  final String dateTime;
  bool isDone;

  TaskModel({
    required this.taskName,
    required this.taskDescription,
    required this.isHighPriority,
    required this.dateTime,
    this.isDone = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskName: json['taskName'],
      taskDescription: json['taskDescription'],
      isHighPriority: json['isHighPriority'],
      dateTime: json['dateTime'],
      isDone: json['isDone'] ?? false,
    );
  }

  // convert taskModel to json
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'taskDescription': taskDescription,
      'isHighPriority': isHighPriority,
      'dateTime': dateTime,
      'isDone': isDone,
    };
  }
}
