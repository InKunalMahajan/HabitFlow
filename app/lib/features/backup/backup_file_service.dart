import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'habitflow_backup.dart';

/// Mobile native file import and share-sheet export.
/// Never modifies SQLite; the caller must preview and confirm restore.
class BackupFileService {
  const BackupFileService();

  Future<bool> export(HabitFlowBackup backup) async {
    final temp = await getTemporaryDirectory();
    final file = File('${temp.path}/habitflow-backup.json');
    await file.writeAsString(backup.encode(), encoding: utf8, flush: true);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          text: 'HabitFlow backup — keep this file private.',
        ),
      );
      return result.status == ShareResultStatus.success;
    } finally {
      // The OS may copy/share the file asynchronously. Do not delete it here;
      // it resides in the app's OS-managed temporary directory.
    }
  }

  Future<HabitFlowBackup?> import() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: false,
    );
    if (selection == null) return null;
    final path = selection.files.single.path;
    if (path == null) {
      throw const FormatException('The selected file cannot be read.');
    }
    final file = File(path);
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) {
      throw const FormatException('Selected backup must be a regular file.');
    }
    if (stat.size > HabitFlowBackup.maxBytes) {
      throw const FormatException('Backup file is too large.');
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > HabitFlowBackup.maxBytes) {
      throw const FormatException('Backup file is too large.');
    }
    return HabitFlowBackup.decode(utf8.decode(bytes, allowMalformed: false));
  }
}
