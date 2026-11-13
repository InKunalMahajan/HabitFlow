import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'entry_store.dart';
import '../reminders/reminder_settings.dart';

/// Local SQLite storage. No network account or cloud synchronization.
class EntryDatabase {
  EntryDatabase._(this._db);

  final Database _db;

  static Future<EntryDatabase> open() async {
    final root = await getDatabasesPath();
    final db = await openDatabase(
      p.join(root, 'habitflow.db'),
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            kind TEXT NOT NULL CHECK (kind IN ('task', 'habit')),
            completed INTEGER NOT NULL DEFAULT 0,
            scheduled_day TEXT
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
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            target INTEGER NOT NULL CHECK (target > 0),
            progress INTEGER NOT NULL DEFAULT 0 CHECK (progress >= 0)
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_reminders (
            habit_id INTEGER PRIMARY KEY,
            hour INTEGER NOT NULL CHECK (hour BETWEEN 0 AND 23),
            minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 59),
            enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
            FOREIGN KEY (habit_id) REFERENCES entries(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE entries ADD COLUMN scheduled_day TEXT');
          await db.execute('''
            CREATE TABLE goals (
              id INTEGER PRIMARY KEY,
              title TEXT NOT NULL,
              target INTEGER NOT NULL CHECK (target > 0),
              progress INTEGER NOT NULL DEFAULT 0 CHECK (progress >= 0)
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE habit_reminders (
              habit_id INTEGER PRIMARY KEY,
              hour INTEGER NOT NULL CHECK (hour BETWEEN 0 AND 23),
              minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 59),
              enabled INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
              FOREIGN KEY (habit_id) REFERENCES entries(id) ON DELETE CASCADE
            )
          ''');
        }
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
        scheduledDay: row['scheduled_day'] as String?,
      );
    }).toList();
  }

  /// Atomically replaces the local snapshot, including completion history.
  Future<void> save(List<FlowEntry> entries) async {
    await _db.transaction((txn) async {
      final reminders = await txn.query('habit_reminders');
      await txn.delete('habit_completions');
      await txn.delete('entries');
      for (final entry in entries) {
        await txn.insert('entries', {
          'id': entry.id,
          'title': entry.title,
          'kind': entry.kind.name,
          'completed': entry.completed ? 1 : 0,
          'scheduled_day': entry.scheduledDay,
        });
        for (final day in entry.completedDates) {
          await txn.insert('habit_completions', {
            'entry_id': entry.id,
            'day': day,
          });
        }
      }
      final habitIds = entries.where((e) => e.kind == EntryKind.habit).map((e) => e.id).toSet();
      for (final reminder in reminders) {
        if (habitIds.contains(reminder['habit_id'])) {
          await txn.insert('habit_reminders', reminder);
        }
      }
    });
  }

  Future<List<Map<String, Object?>>> loadGoals() =>
      _db.query('goals', orderBy: 'id ASC');

  Future<void> saveGoals(List<Map<String, Object?>> goals) async {
    await _db.transaction((txn) async {
      await txn.delete('goals');
      for (final goal in goals) {
        await txn.insert('goals', goal);
      }
    });
  }

  Future<Map<int, ReminderSettings>> loadReminders() async {
    final rows = await _db.query('habit_reminders');
    final reminders = <int, ReminderSettings>{};
    for (final row in rows) {
      final setting = ReminderSettings.fromRow(row);
      if (setting != null) reminders[setting.habitId] = setting;
    }
    return reminders;
  }

  Future<void> saveReminder(ReminderSettings setting) async {
    await _db.insert(
      'habit_reminders', setting.toRow(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReminder(int habitId) async {
    await _db.delete('habit_reminders', where: 'habit_id = ?', whereArgs: [habitId]);
  }

  Future<void> close() => _db.close();
}
