import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'entry_store.dart';

/// Local SQLite storage. No network account or cloud synchronization.
class EntryDatabase {
  EntryDatabase._(this._db);

  final Database _db;

  static Future<EntryDatabase> open() async {
    final root = await getDatabasesPath();
    final db = await openDatabase(
      p.join(root, 'habitflow.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            kind TEXT NOT NULL CHECK (kind IN ('task', 'habit')),
            completed INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_completions (
            entry_id INTEGER NOT NULL,
            day TEXT NOT NULL,
            PRIMARY KEY (entry_id, day),
            FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
          )
        ''');
      },
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
    return EntryDatabase._(db);
  }

  Future<List<FlowEntry>> load() async {
    final rows = await _db.query('entries', orderBy: 'id ASC');
    final dates = await _db.query('habit_completions');
    final byId = <int, Set<String>>{};
    for (final row in dates) {
      (byId.putIfAbsent(row['entry_id'] as int, () => <String>{}))
          .add(row['day'] as String);
    }
    return rows.map((row) {
      final id = row['id'] as int;
      return FlowEntry(
        id: id,
        title: row['title'] as String,
        kind: row['kind'] == 'habit' ? EntryKind.habit : EntryKind.task,
        completed: row['completed'] == 1,
        completedDates: byId[id] ?? <String>{},
      );
    }).toList();
  }

  /// Atomically replaces the local snapshot, including completion history.
  Future<void> save(List<FlowEntry> entries) async {
    await _db.transaction((txn) async {
      await txn.delete('habit_completions');
      await txn.delete('entries');
      for (final entry in entries) {
        await txn.insert('entries', {
          'id': entry.id,
          'title': entry.title,
          'kind': entry.kind.name,
          'completed': entry.completed ? 1 : 0,
        });
        for (final day in entry.completedDates) {
          await txn.insert('habit_completions', {
            'entry_id': entry.id,
            'day': day,
          });
        }
      }
    });
  }

  Future<void> close() => _db.close();
}
