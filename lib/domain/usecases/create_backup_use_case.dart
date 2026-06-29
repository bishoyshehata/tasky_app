import 'package:tasky/core/backup/backup_service.dart';

class CreateBackupUseCase {
  final BackupService _service;
  const CreateBackupUseCase(this._service);

  Future<void> execute() => _service.exportAndShare();
}
