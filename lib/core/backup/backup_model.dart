import 'dart:convert';
import 'package:engez/data/models/task_model.dart';
import 'package:engez/data/models/user_model.dart';

class BackupModel {
  static const int currentVersion = 1;

  final int version;
  final String appVersion;
  final DateTime createdAt;
  final List<TaskModel> tasks;
  final UserModel? user;

  const BackupModel({
    required this.version,
    required this.appVersion,
    required this.createdAt,
    required this.tasks,
    this.user,
  });

  factory BackupModel.create({required List<TaskModel> tasks, UserModel? user}) {
    return BackupModel(
      version: currentVersion,
      appVersion: '1.0.0',
      createdAt: DateTime.now().toUtc(),
      tasks: tasks,
      user: user,
    );
  }

  factory BackupModel.fromJson(Map<String, dynamic> json) {
    final tasksList = (json['tasks'] as List<dynamic>? ?? [])
        .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
        .toList();

    return BackupModel(
      version: json['version'] as int? ?? 1,
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      tasks: tasksList,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'appVersion': appVersion,
      'createdAt': createdAt.toIso8601String(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Summary info shown to user before restoring
class BackupPreview {
  final int taskCount;
  final DateTime createdAt;
  final int version;
  final BackupModel model;

  const BackupPreview({
    required this.taskCount,
    required this.createdAt,
    required this.version,
    required this.model,
  });
}

enum RestoreStrategy { replace, merge }
