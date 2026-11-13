import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/entries/entry_store.dart';

void main() {
  test('task CRUD preserves stable IDs and completion', () {
    final store = EntryStore();
    final first = store.add(' Read ', EntryKind.task);
    final second = store.add('Read', EntryKind.task);
    expect(first.id, isNot(second.id));
    expect(first.title, 'Read');
    expect(store.setCompleted(first.id, true), isTrue);
    expect(store.isCompleted(store.items.first), isTrue);
    expect(store.rename(first.id, 'Write'), isTrue);
    expect(store.items.first.completed, isTrue);
    expect(store.remove(first.id), isTrue);
    expect(store.items.single.id, second.id);
  });

  test('habit completion is per day', () {
    final store = EntryStore();
    final habit = store.add('Exercise', EntryKind.habit);
    final monday = DateTime(2026, 11, 16);
    final tuesday = DateTime(2026, 11, 17);
    store.setCompleted(habit.id, true, on: monday);
    expect(store.isCompleted(store.items.single, on: monday), isTrue);
    expect(store.isCompleted(store.items.single, on: tuesday), isFalse);
    store.setCompleted(habit.id, false, on: monday);
    expect(store.isCompleted(store.items.single, on: monday), isFalse);
  });

  test('empty and oversized names are rejected', () {
    final store = EntryStore();
    expect(() => store.add('   ', EntryKind.task), throwsArgumentError);
    expect(() => store.add('x' * 121, EntryKind.habit), throwsArgumentError);
    final entry = store.add('Valid', EntryKind.task);
    expect(() => store.rename(entry.id, ''), throwsArgumentError);
    expect(store.items.single.title, 'Valid');
  });
}
