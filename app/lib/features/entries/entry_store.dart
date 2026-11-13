enum EntryKind { task, habit }

class FlowEntry {
  const FlowEntry({
    required this.id,
    required this.title,
    required this.kind,
    this.completed = false,
    this.completedDates = const {},
    this.scheduledDay,
  });

  final int id;
  final String title;
  final EntryKind kind;
  final bool completed;
  final Set<String> completedDates;
  final String? scheduledDay;

  FlowEntry copyWith({String? title, bool? completed, Set<String>? completedDates, String? scheduledDay, bool clearScheduledDay = false}) =>
      FlowEntry(
        id: id,
        title: title ?? this.title,
        kind: kind,
        completed: completed ?? this.completed,
        completedDates: completedDates ?? this.completedDates,
        scheduledDay: clearScheduledDay ? null : scheduledDay ?? this.scheduledDay,
      );
}

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class EntryStore {
  final List<FlowEntry> _items = [];
  int _nextId = 1;

  List<FlowEntry> get items => List.unmodifiable(_items);

  void restore(List<FlowEntry> entries) {
    _items
      ..clear()
      ..addAll(entries);
    _nextId = entries.fold<int>(0, (maxId, item) => item.id > maxId ? item.id : maxId) + 1;
  }

  FlowEntry add(String title, EntryKind kind, {String? scheduledDay}) {
    final normalized = title.trim();
    if (normalized.isEmpty || normalized.length > 120) {
      throw ArgumentError('Enter a name between 1 and 120 characters.');
    }
    final entry = FlowEntry(id: _nextId++, title: normalized, kind: kind, scheduledDay: scheduledDay);
    _items.add(entry);
    return entry;
  }

  bool rename(int id, String title) {
    final normalized = title.trim();
    if (normalized.isEmpty || normalized.length > 120) {
      throw ArgumentError('Enter a name between 1 and 120 characters.');
    }
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _items[index] = _items[index].copyWith(title: normalized);
    return true;
  }

  bool schedule(int id, String? day) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].kind != EntryKind.task) return false;
    _items[index] = _items[index].copyWith(
      scheduledDay: day, clearScheduledDay: day == null);
    return true;
  }

  bool remove(int id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    _items.removeAt(index);
    return true;
  }

  bool setCompleted(int id, bool completed, {DateTime? on}) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return false;
    final item = _items[index];
    if (item.kind == EntryKind.task) {
      _items[index] = item.copyWith(completed: completed);
    } else {
      final dates = {...item.completedDates};
      final key = dateKey(on ?? DateTime.now());
      if (completed) {
        dates.add(key);
      } else {
        dates.remove(key);
      }
      _items[index] = item.copyWith(completedDates: dates);
    }
    return true;
  }

  bool isCompleted(FlowEntry item, {DateTime? on}) =>
      item.kind == EntryKind.task
          ? item.completed
          : item.completedDates.contains(dateKey(on ?? DateTime.now()));
}
