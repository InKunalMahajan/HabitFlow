import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:habitflow/features/entries/entry_database.dart';
import 'package:habitflow/features/backup/habitflow_backup.dart';
import 'package:habitflow/features/entries/entry_store.dart';
import 'package:habitflow/features/reminders/reminder_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Directory temp;
  late String dbPath;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('habitflow-sqlite-test-');
    dbPath = '${temp.path}/habitflow.db';
  });

  tearDown(() async {
    await databaseFactory.deleteDatabase(dbPath);
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('fresh v3 database persists entries, history, goals and reminders', () async {
    var db = await EntryDatabase.open(databasePath: dbPath);
    await db.save([
      const FlowEntry(id: 1, title: 'Read', kind: EntryKind.task,
          completed: true, scheduledDay: '2026-11-20'),
      const FlowEntry(id: 2, title: 'Walk', kind: EntryKind.habit,
          completedDates: {'2026-11-13', '2026-11-14'}),
    ]);
    await db.saveGoals([
      {'id': 1, 'title': 'Books', 'target': 10, 'progress': 3},
    ]);
    await db.saveReminder(
      const ReminderSettings(habitId: 2, hour: 9, minute: 15),
    );
    await db.close();

    db = await EntryDatabase.open(databasePath: dbPath);
    final entries = await db.load();
    expect(entries, hasLength(2));
    expect(entries.first.completed, isTrue);
    expect(entries.first.scheduledDay, '2026-11-20');
    expect(entries.last.completedDates, {'2026-11-13', '2026-11-14'});
    expect((await db.loadGoals()).single['progress'], 3);
    expect((await db.loadReminders())[2]!.minute, 15);
    await db.close();
  });

  test('snapshot update retains valid habit reminder and removes deleted one', () async {
    final db = await EntryDatabase.open(databasePath: dbPath);
    const walk = FlowEntry(id: 1, title: 'Walk', kind: EntryKind.habit);
    const read = FlowEntry(id: 2, title: 'Read', kind: EntryKind.habit);
    await db.save([walk, read]);
    await db.saveReminder(
      const ReminderSettings(habitId: 1, hour: 8, minute: 0),
    );
    await db.saveReminder(
      const ReminderSettings(habitId: 2, hour: 10, minute: 30),
    );
    await db.save([
      walk.copyWith(title: 'Morning walk', completedDates: {'2026-11-14'}),
    ]);
    expect((await db.load()).single.title, 'Morning walk');
    expect((await db.load()).single.completedDates, {'2026-11-14'});
    expect((await db.loadReminders()).keys, {1});
    await db.close();
  });

  test('failed snapshot write rolls back all changes', () async {
    final db = await EntryDatabase.open(databasePath: dbPath);
    const original = FlowEntry(id: 1, title: 'Original', kind: EntryKind.habit,
        completedDates: {'2026-11-13'});
    await db.save([original]);
    await db.saveReminder(
      const ReminderSettings(habitId: 1, hour: 7, minute: 0),
    );
    await expectLater(
      db.save([
        const FlowEntry(id: 2, title: 'New', kind: EntryKind.task),
        const FlowEntry(id: 2, title: 'Duplicate', kind: EntryKind.task),
      ]),
      throwsA(isA<DatabaseException>()),
    );
    final restored = await db.load();
    expect(restored, hasLength(1));
    expect(restored.single.title, 'Original');
    expect(restored.single.completedDates, {'2026-11-13'});
    expect((await db.loadReminders()).keys, {1});
    await db.close();
  });

  test('v1 to v3 migration preserves entries and check-ins', () async {
    final legacy = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            "CREATE TABLE entries (id INTEGER PRIMARY KEY, title TEXT NOT NULL, "
            "kind TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0)",
          );
          await db.execute(
            "CREATE TABLE habit_completions (entry_id INTEGER NOT NULL, "
            "day TEXT NOT NULL, PRIMARY KEY (entry_id, day))",
          );
          await db.insert('entries',
              {'id': 7, 'title': 'Legacy walk', 'kind': 'habit', 'completed': 0});
          await db.insert('habit_completions',
              {'entry_id': 7, 'day': '2026-11-12'});
        },
      ),
    );
    await legacy.close();

    final db = await EntryDatabase.open(databasePath: dbPath);
    expect((await db.load()).single.completedDates, {'2026-11-12'});
    expect((await db.load()).single.scheduledDay, isNull);
    await db.saveReminder(
      const ReminderSettings(habitId: 7, hour: 8, minute: 45),
    );
    expect((await db.loadReminders())[7]!.minute, 45);
    await db.saveGoals([
      {'id': 1, 'title': 'Legacy goal', 'target': 5, 'progress': 1},
    ]);
    expect(await db.loadGoals(), hasLength(1));
    await db.close();
  });

  test('v2 to v3 migration retains goals and adds reminders', () async {
    final legacy = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(
            "CREATE TABLE entries (id INTEGER PRIMARY KEY, title TEXT NOT NULL, "
            "kind TEXT NOT NULL, completed INTEGER NOT NULL DEFAULT 0, "
            "scheduled_day TEXT)",
          );
          await db.execute(
            "CREATE TABLE habit_completions (entry_id INTEGER NOT NULL, "
            "day TEXT NOT NULL, PRIMARY KEY (entry_id, day))",
          );
          await db.execute(
            "CREATE TABLE goals (id INTEGER PRIMARY KEY, title TEXT NOT NULL, "
            "target INTEGER NOT NULL, progress INTEGER NOT NULL DEFAULT 0)",
          );
          await db.insert('entries',
              {'id': 4, 'title': 'Plan', 'kind': 'task',
               'completed': 0, 'scheduled_day': '2026-12-01'});
          await db.insert('goals',
              {'id': 3, 'title': 'Read', 'target': 10, 'progress': 2});
        },
      ),
    );
    await legacy.close();

    final db = await EntryDatabase.open(databasePath: dbPath);
    expect((await db.load()).single.scheduledDay, '2026-12-01');
    expect((await db.loadGoals()).single['progress'], 2);
    expect(await db.loadReminders(), isEmpty);
    await db.close();
  });

  test('invalid goal update rolls back previous goals', () async {
    final db = await EntryDatabase.open(databasePath: dbPath);
    await db.saveGoals([
      {'id': 1, 'title': 'Read', 'target': 5, 'progress': 2},
    ]);
    await expectLater(
      db.saveGoals([
        {'id': 2, 'title': 'Valid', 'target': 5, 'progress': 1},
        {'id': 3, 'title': 'Invalid', 'target': 0, 'progress': 0},
      ]),
      throwsA(isA<DatabaseException>()),
    );
    expect((await db.loadGoals()).single['title'], 'Read');
    await db.close();
  });
  test('atomic backup export and restore replaces all data together', () async {
    final db = await EntryDatabase.open(databasePath: dbPath);
    await db.save([
      const FlowEntry(id: 1, title: 'Old', kind: EntryKind.task),
    ]);
    final replacement = HabitFlowBackup(
      entries: [
        const FlowEntry(id: 5, title: 'Walk', kind: EntryKind.habit,
            completedDates: {'2026-11-14'}),
      ],
      goals: [
        {'id': 2, 'title': 'Steps', 'target': 20, 'progress': 4},
      ],
      reminders: {
        5: const ReminderSettings(habitId: 5, hour: 8, minute: 30),
      },
    );
    await db.restoreBackup(replacement);
    final exported = await db.exportBackup();
    final roundTrip = HabitFlowBackup.decode(exported.encode());
    expect(roundTrip.entries.single.title, 'Walk');
    expect(roundTrip.entries.single.completedDates, {'2026-11-14'});
    expect(roundTrip.goals.single['progress'], 4);
    expect(roundTrip.reminders[5]!.timeLabel, '08:30');
    await db.close();
  });

  test('invalid backup leaves all existing SQLite data unchanged', () async {
    final db = await EntryDatabase.open(databasePath: dbPath);
    await db.save([
      const FlowEntry(id: 1, title: 'Safe', kind: EntryKind.habit),
    ]);
    await db.saveReminder(
      const ReminderSettings(habitId: 1, hour: 7, minute: 0),
    );
    final invalid = HabitFlowBackup(
      entries: [
        const FlowEntry(id: 2, title: 'New', kind: EntryKind.task),
      ],
      goals: const [],
      reminders: {
        2: const ReminderSettings(habitId: 2, hour: 8, minute: 0),
      },
    );
    await expectLater(db.restoreBackup(invalid), throwsFormatException);
    expect((await db.load()).single.title, 'Safe');
    expect((await db.loadReminders()).keys, {1});
    await db.close();
  });

}
