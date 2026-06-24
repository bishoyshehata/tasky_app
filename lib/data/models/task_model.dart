class TaskModel {
  final String taskName;
  final String taskDescription;
  final bool isHighPriority;
  final String dateTime;

  TaskModel({
    required this.taskName,
    required this.taskDescription,
    required this.isHighPriority,
    required this.dateTime,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskName: json['taskName'],
      taskDescription: json['taskDescription'],
      isHighPriority: json['isHighPriority'],
      dateTime: json['dateTime'],
    );
  }

  // convert taskModel to json
  Map<String, dynamic> toJson() {
    return {
      'taskName': taskName,
      'taskDescription': taskDescription,
      'isHighPriority': isHighPriority,
      'dateTime': dateTime,
    };
  }
}
