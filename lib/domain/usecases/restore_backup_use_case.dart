import 'package:engez/core/backup/backup_model.dart';
import 'package:engez/core/backup/backup_service.dart';

class RestoreBackupUseCase {
  final BackupService _service;
  const RestoreBackupUseCase(this._service);

  /// Opens file picker and returns a [BackupPreview] without modifying data.
  Future<BackupPreview?> preview() => _service.pickAndPreview();

  /// Applies the restore with the user-chosen strategy.
  Future<void> apply(BackupPreview preview, RestoreStrategy strategy) =>
      _service.applyRestore(preview, strategy);
}
