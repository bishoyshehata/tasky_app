import 'backup_model.dart';

enum ValidationStatus {
  ok,
  missingKeys,
  unknownVersion,
  invalidJson,
  emptyTasks,
}

class ValidationResult {
  final ValidationStatus status;
  final String? message;

  const ValidationResult.ok() : status = ValidationStatus.ok, message = null;
  const ValidationResult({required this.status, this.message});

  bool get isValid => status == ValidationStatus.ok;
}

class BackupValidator {
  static const _requiredKeys = ['version', 'tasks'];

  static ValidationResult validate(Map<String, dynamic> json) {
    // Check required keys
    for (final key in _requiredKeys) {
      if (!json.containsKey(key)) {
        return ValidationResult(
          status: ValidationStatus.missingKeys,
          message: 'Missing required field: "$key"',
        );
      }
    }

    // Check version compatibility
    final version = json['version'];
    if (version is! int || version < 1 || version > BackupModel.currentVersion) {
      return ValidationResult(
        status: ValidationStatus.unknownVersion,
        message: 'Unsupported backup version: $version',
      );
    }

    // Verify tasks is a list
    if (json['tasks'] is! List) {
      return ValidationResult(
        status: ValidationStatus.invalidJson,
        message: '"tasks" field must be a list',
      );
    }

    return const ValidationResult.ok();
  }
}
