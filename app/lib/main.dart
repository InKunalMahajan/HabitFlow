import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'features/backup/habitflow_backup.dart';
import 'core/theme/app_theme.dart';
import 'features/entries/entry_store.dart';
import 'features/entries/entry_database.dart';
import 'features/insights/insight_summary.dart';
import 'features/insights/habit_streak.dart';
import 'features/reminders/reminder_settings.dart';
import 'features/reminders/reminder_schedule.dart';
import 'features/reminders/habit_notification_service.dart';
import 'features/reminders/reminder_reconciliation.dart';
import 'features/reminders/notification_sync_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final database = await EntryDatabase.open();
    final entries = await database.load();
    final goals = await database.loadGoals();
    final reminders = await database.loadReminders();
    runApp(HabitFlowApp(database: database, initialEntries: entries, initialGoals: goals, initialReminders: reminders));
  } catch (error) {
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text(
      'Could not open local storage. Your data was not changed.\n$error',
      textAlign: TextAlign.center,
    )))));
  }
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key, this.database, this.initialEntries, this.initialGoals, this.initialReminders});

  final EntryDatabase? database;
  final List<FlowEntry>? initialEntries;
  final List<Map<String, Object?>>? initialGoals;
  final Map<int, ReminderSettings>? initialReminders;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HabitFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: HabitFlowShell(database: database, initialEntries: initialEntries, initialGoals: initialGoals, initialReminders: initialReminders),
      );
}

class HabitFlowShell extends StatefulWidget {
  const HabitFlowShell({super.key, this.database, this.initialEntries, this.initialGoals, this.initialReminders});

  final EntryDatabase? database;
  final List<FlowEntry>? initialEntries;
  final List<Map<String, Object?>>? initialGoals;
  final Map<int, ReminderSettings>? initialReminders;

  @override
  State<HabitFlowShell> createState() => _HabitFlowShellState();
}

class _HabitFlowShellState extends State<HabitFlowShell> {
  final EntryStore _store = EntryStore()
    ..add('Review today’s priorities', EntryKind.task)
    ..add('Plan tomorrow', EntryKind.task);
  final List<Map<String, Object?>> _goals = [];
  final Map<int, ReminderSettings> _reminders = {};
  Future<void> _saveQueue = Future<void>.value();
  String? _saveError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEntries != null) {
      _store.restore(widget.initialEntries!);
    }
    _goals.addAll(widget.initialGoals ?? []);
    _reminders.addAll(widget.initialReminders ?? {});
    if (widget.database != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDeviceReminders());
    }
  }

  Future<void> _checkNotificationStatus() async {
    String message;
    try {
      final service = HabitNotificationService.instance;
      if (!service.supported) {
        message = 'Notifications are available only on iPhone and Android.';
      } else {
        final allowed = await service.notificationsAllowed();
        message = allowed
            ? 'Notifications are allowed in device settings.'
            : 'Notifications are not allowed. Enable them in your phone settings.';
      }
    } catch (_) {
      message = 'Could not read notification permission. Check phone settings.';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _refreshHabitNotification(int habitId, String title) async {
    final reminder = _reminders[habitId];
    if (reminder == null) return;
    try {
      final service = HabitNotificationService.instance;
      if (await service.notificationsAllowed()) {
        await service.scheduleDaily(reminder, title);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saveError =
            'Habit saved, but its phone reminder could not be updated.');
      }
    }
  }

  Future<void> _restoreDeviceReminders() async {
    if (!mounted) return;
    try {
      final service = HabitNotificationService.instance;
      await service.initialize();
      final plan = ReminderReconciliation.plan(_store.items, _reminders);
      for (final id in plan.orphanedHabitIds) {
        await service.cancel(id);
        if (widget.database != null) {
          await widget.database!.deleteReminder(id);
        }
        _reminders.remove(id);
      }
      final allowed = await service.notificationsAllowed();
      final sync = NotificationSyncPlan.build(
        entries: _store.items,
        saved: plan.active,
        pendingIds: await service.pendingReminderIds(),
        permissionGranted: allowed,
      );
      for (final id in sync.toCancel) {
        await service.cancel(id);
      }
      for (final entry in _store.items.where((e) => e.kind == EntryKind.habit)) {
        final reminder = sync.toSchedule[entry.id];
        if (reminder != null) {
          await service.scheduleDaily(reminder, entry.title);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = 'Some device reminders could not be restored.');
      }
    }
  }

  void _persist() {
    final db = widget.database;
    if (db == null) { return; }
    final snapshot = List<FlowEntry>.of(_store.items);
    _saveQueue = _saveQueue.catchError((Object _) {}).then((_) async {
      try {
        await db.save(snapshot);
        if (mounted && _saveError != null) { setState(() => _saveError = null); }
      } catch (error) {
        if (mounted) { setState(() => _saveError = 'Could not save changes. Please retry.'); }
      }
    });
  }

  void _persistGoals() {
    final db = widget.database;
    if (db == null) { return; }
    final snapshot = _goals.map((goal) => Map<String, Object?>.of(goal)).toList();
    _saveQueue = _saveQueue.catchError((Object _) {}).then((_) async {
      try {
        await db.saveGoals(snapshot);
      } catch (_) {
        if (mounted) { setState(() => _saveError = 'Could not save goals. Please retry.'); }
      }
    });
  }


  Future<void> _openBackupDialog() async {
    final db = widget.database;
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backups require local storage.')),
      );
      return;
    }
    await _saveQueue;
    if (!mounted) return;
    final input = TextEditingController();
    HabitFlowBackup? preview;
    String? error;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, updateDialog) => AlertDialog(
            title: const Text('Backup and restore'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Copy a JSON backup to a safe location. '
                        'To restore, paste backup JSON and preview it first.'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await _saveQueue;
                          final backup = await db.exportBackup();
                          await Clipboard.setData(ClipboardData(text: backup.encode()));
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('Backup copied. Save it securely outside the app.')),
                            );
                          }
                        } catch (_) {
                          updateDialog(() => error = 'Could not export backup.');
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy backup JSON'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: input,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Paste backup JSON',
                        hintText: 'Paste your saved HabitFlow backup',
                      ),
                      onChanged: (_) => updateDialog(() {
                        preview = null;
                        error = null;
                      }),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        try {
                          final candidate = HabitFlowBackup.decode(input.text);
                          updateDialog(() {
                            preview = candidate;
                            error = null;
                          });
                        } catch (_) {
                          updateDialog(() {
                            preview = null;
                            error = 'Invalid or unsupported backup. No data changed.';
                          });
                        }
                      },
                      child: const Text('Preview backup'),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 8),
                      Text('Backup contains ${preview!.entries.length} items, '
                          '${preview!.goals.length} goals, and '
                          '${preview!.reminders.length} reminders.'),
                      const Text('Restoring will REPLACE all current tasks, '
                          'habits, goals and reminder preferences.'),
                      FilledButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: dialogContext,
                            builder: (confirmationContext) => AlertDialog(
                              title: const Text('Replace all local data?'),
                              content: const Text('This replaces your current '
                                  'HabitFlow data. This action cannot be undone. '
                                  'Save a separate backup first.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(confirmationContext, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(confirmationContext, true),
                                  child: const Text('Replace my data'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          try {
                            await _saveQueue;
                            await db.restoreBackup(preview!);
                            final entries = await db.load();
                            final goals = await db.loadGoals();
                            final reminders = await db.loadReminders();
                            if (!mounted) return;
                            setState(() {
                              _store.restore(entries);
                              _goals..clear()..addAll(goals);
                              _reminders..clear()..addAll(reminders);
                              _saveError = null;
                            });
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            await _restoreDeviceReminders();
                          } catch (_) {
                            updateDialog(() => error =
                                'Restore failed. Database changes were rolled back.');
                          }
                        },
                        child: const Text('Restore backup'),
                      ),
                    ],
                    if (error != null)
                      Semantics(liveRegion: true, child: Text(error!)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    } finally {
      input.dispose();
    }
  }

  int _selected = 0;
  static const _titles = ['Today', 'Planner', 'Goals', 'Insights'];
  static const _icons = [
    Icons.today_outlined,
    Icons.calendar_month_outlined,
    Icons.flag_outlined,
    Icons.insights_outlined,
  ];

  Future<void> _editEntry({FlowEntry? entry}) async {
    final controller = TextEditingController(text: entry?.title ?? '');
    var kind = entry?.kind ?? EntryKind.task;
    DateTime? scheduled = entry?.scheduledDay == null ? null : DateTime.tryParse(entry!.scheduledDay!);
    String? error;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, updateSheet) => Padding(
            padding: EdgeInsets.fromLTRB(
              24, 8, 24, MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(entry == null ? 'Quick add' : 'Edit item',
                        style: Theme.of(sheetContext).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    if (entry == null)
                      SegmentedButton<EntryKind>(
                        segments: const [
                          ButtonSegment(value: EntryKind.task, label: Text('Task')),
                          ButtonSegment(value: EntryKind.habit, label: Text('Habit')),
                        ],
                        selected: {kind},
                        onSelectionChanged: (value) =>
                            updateSheet(() => kind = value.first),
                      ),
                    if (kind == EntryKind.task) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: scheduled ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) { updateSheet(() => scheduled = picked); }
                        },
                        icon: const Icon(Icons.event),
                        label: Text(scheduled == null ? 'Schedule date' : 'Scheduled: ${dateKey(scheduled!)}'),
                      ),
                      if (scheduled != null)
                        TextButton(onPressed: () => updateSheet(() => scheduled = null),
                            child: const Text('Clear date')),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('entry-name'),
                      controller: controller,
                      autofocus: true,
                      maxLength: 120,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: entry == null ? 'Name' : 'Edit name',
                        hintText: 'What would you like to do?',
                        errorText: error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) {
                          updateSheet(() => error = 'Enter a name.');
                          return;
                        }
                        setState(() {
                          if (entry == null) {
                            _store.add(name, kind, scheduledDay: scheduled == null ? null : dateKey(scheduled!));
                          } else {
                            _store.rename(entry.id, name);
                            if (entry.kind == EntryKind.task) {
                              _store.schedule(entry.id, scheduled == null ? null : dateKey(scheduled!));
                            }
                          }
                          _selected = 0;
                        });
                        _persist();
                        if (entry != null &&
                            entry.kind == EntryKind.habit &&
                            _reminders.containsKey(entry.id)) {
                          _refreshHabitNotification(entry.id, name);
                        }
                        Navigator.pop(sheetContext);
                      },
                      icon: Icon(entry == null ? Icons.add : Icons.save_outlined),
                      label: Text(entry == null ? 'Add item' : 'Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } finally {
      // Delay disposal until the bottom sheet's exit animation completes.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      controller.dispose();
    }
  }

  Future<void> _deleteEntry(FlowEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Delete "${entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final hadReminder = _reminders.containsKey(entry.id);
      setState(() {
        _store.remove(entry.id);
        _reminders.remove(entry.id);
      });
      _persist();
      if (entry.kind == EntryKind.habit && hadReminder) {
        try {
          await HabitNotificationService.instance.cancel(entry.id);
        } catch (_) {
          if (mounted) {
            setState(() => _saveError =
                'Habit deleted, but its phone reminder could not be cancelled.');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;
    final expanded = width >= 840;
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(14);
    final compact = width < 380 || textScale > 21;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitFlow'),
        actions: [
          if (widget.database != null)
            IconButton(
              tooltip: 'Backup and restore',
              icon: const Icon(Icons.backup_outlined),
              onPressed: _openBackupDialog,
            ),
          IconButton(
            tooltip: 'About this preview',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'HabitFlow',
              children: [
                Text(widget.database == null
                    ? 'Preview mode: items are saved for this session only.'
                    : 'Tasks, habits, and goals are stored locally on this device.'),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: expanded,
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  setState(() => _selected = index),
              labelType: expanded
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: List.generate(
                _titles.length,
                (index) => NavigationRailDestination(
                  icon: Icon(_icons[index]),
                  selectedIcon: Icon(_icons[index], color: scheme.primary),
                  label: Text(_titles[index]),
                ),
              ),
            ),
          Expanded(
            child: switch (_selected) {
              0 => _todayPage(context),
              1 => _plannerPage(context),
              2 => _goalsPage(context),
              _ => _insightsPage(context),
            },
          ),
        ],
      ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  setState(() => _selected = index),
              labelBehavior: compact ? NavigationDestinationLabelBehavior.onlyShowSelected : NavigationDestinationLabelBehavior.alwaysShow,
              destinations: List.generate(
                _titles.length,
                (index) => NavigationDestination(
                  icon: Icon(_icons[index]),
                  label: _titles[index],
                ),
              ),
            ),
      floatingActionButton: _selected == 0 || _selected == 1
          ? FloatingActionButton.extended(
        tooltip: 'Add a task or habit',
        onPressed: _editEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ) : null,
    );
  }

  Widget _todayPage(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = _store.items.where((e) => e.kind == EntryKind.task).toList();
    final habits = _store.items.where((e) => e.kind == EntryKind.habit).toList();
    final done = tasks.where((e) => e.completed).length;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
          children: [
            Semantics(header: true, child: Text('Today', style: theme.textTheme.headlineMedium)),
            const SizedBox(height: 8),
            const Text('Your day, one step at a time.'),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily progress', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('$done of ${tasks.length} tasks complete',
                        key: const Key('progress-label')),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Daily progress',
                      value: '$done of ${tasks.length} tasks complete',
                      child: LinearProgressIndicator(
                        value: tasks.isEmpty ? 0 : done / tasks.length,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_saveError != null) ...[
              Semantics(liveRegion: true, child: Text(_saveError!, style: TextStyle(color: theme.colorScheme.error))),
              TextButton(onPressed: _persist, child: const Text('Retry saving')),
            ],
            const SizedBox(height: 20),
            Semantics(header: true, child: Text('Tasks', style: theme.textTheme.titleLarge)),
            const SizedBox(height: 8),
            if (tasks.isEmpty) const Text('No tasks yet. Tap Add to create one.'),
            ...tasks.map((item) => _entryTile(item)),
            const SizedBox(height: 20),
            Semantics(header: true, child: Text('Habits', style: theme.textTheme.titleLarge)),
            const SizedBox(height: 8),
            if (habits.isEmpty)
              const Text('No habits yet. Tap Add and choose Habit.'),
            ...habits.map((item) => _entryTile(item)),
            const SizedBox(height: 16),
            const Text(
              'Tasks and habits are stored locally on this device when storage '
              'is available. There is no cloud backup or sync.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(FlowEntry item) => Card(
        key: ValueKey('entry-${item.id}'),
        child: Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                value: _store.isCompleted(item),
                title: Text(item.title),
                subtitle: Text(item.kind == EntryKind.habit
                    ? 'Daily habit'
                    : item.scheduledDay == null ? 'No scheduled date' : 'Scheduled: ${item.scheduledDay}'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) {
                  setState(() => _store.setCompleted(item.id, checked == true));
                  _persist();
                },
              ),
            ),
            IconButton(
              tooltip: 'Edit ${item.title}',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editEntry(entry: item),
            ),
            IconButton(
              tooltip: 'Delete ${item.title}',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteEntry(item),
            ),
          ],
        ),
      );


  Widget _plannerPage(BuildContext context) {
    final tasks = _store.items.where((e) => e.kind == EntryKind.task).toList()
      ..sort((a, b) => (a.scheduledDay ?? '9999').compareTo(b.scheduledDay ?? '9999'));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
      children: [
        Semantics(header: true, child: Text('Planner', style: Theme.of(context).textTheme.headlineMedium)),
        const SizedBox(height: 8),
        const Text('Schedule tasks by day. Edit a task to choose its date.'),
        const SizedBox(height: 16),
        if (tasks.isEmpty) const Text('No tasks to plan yet.'),
        ...tasks.map((item) => _entryTile(item)),
      ],
    );
  }

  Future<void> _addGoal() async {
    final controller = TextEditingController();
    final targetController = TextEditingController(text: '10');
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('New goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller,
                decoration: const InputDecoration(labelText: 'Goal name', hintText: 'Example: Read 10 books'),
                maxLength: 120),
              TextField(controller: targetController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Target count')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
            FilledButton(onPressed: () {
              final title = controller.text.trim();
              final target = int.tryParse(targetController.text.trim());
              if (title.isEmpty || target == null || target < 1 || target > 1000000) { return; }
              final nextId = _goals.fold<int>(0, (maxId, g) =>
                (g['id'] as int) > maxId ? g['id'] as int : maxId) + 1;
              setState(() => _goals.add({
                'id': nextId, 'title': title, 'target': target, 'progress': 0,
              }));
              _persistGoals();
              Navigator.pop(dialogContext);
            }, child: const Text('Create goal')),
          ],
        ),
      );
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      controller.dispose();
      targetController.dispose();
    }
  }

  Widget _goalsPage(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
    children: [
      Semantics(header: true, child: Text('Goals', style: Theme.of(context).textTheme.headlineMedium)),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _addGoal,
        icon: const Icon(Icons.add),
        label: const Text('Create goal'),
      ),
      const SizedBox(height: 16),
      if (_goals.isEmpty) const Text('No goals yet. Create your first goal.'),
      ..._goals.map((goal) {
        final id = goal['id'] as int;
        final title = goal['title'] as String;
        final target = goal['target'] as int;
        final progress = goal['progress'] as int;
        return Card(
          key: ValueKey('goal-$id'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('$progress of $target complete'),
                Semantics(
                  label: 'Goal progress for $title',
                  value: '$progress of $target complete',
                  child: LinearProgressIndicator(value: (progress / target).clamp(0.0, 1.0)),
                ),
                Row(children: [
                  IconButton(
                    tooltip: 'Decrease $title',
                    onPressed: progress <= 0 ? null : () {
                      setState(() => goal['progress'] = progress - 1);
                      _persistGoals();
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Increase $title',
                    onPressed: progress >= target ? null : () {
                      setState(() => goal['progress'] = progress + 1);
                      _persistGoals();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Delete goal $title',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete goal?'),
                          content: Text('Delete "$title"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true && mounted) {
                        setState(() => _goals.removeWhere((g) => g['id'] == id));
                        _persistGoals();
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    ],
  );

  Widget _insightsPage(BuildContext context) {
    final summary = InsightSummary.calculate(
      entries: _store.items,
      goals: _goals,
      now: DateTime.now(),
    );
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
          children: [
            Semantics(
              header: true,
              child: Text('Insights', style: theme.textTheme.headlineMedium),
            ),
            const SizedBox(height: 8),
            const Text('Your progress, based on data saved on this device.'),
            const SizedBox(height: 16),
            _insightCard(
              context,
              'Tasks',
              '${summary.tasksCompleted} of ${summary.taskTotal} completed',
              summary.taskRate,
              Icons.check_circle_outline,
            ),
            _insightCard(
              context,
              'Habits today',
              '${summary.habitsDoneToday} of ${summary.habitTotal} completed',
              summary.habitRateToday,
              Icons.repeat,
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: const Text('Habit activity — last 7 days'),
                subtitle: Text('${summary.habitCompletionsLast7Days} check-ins'),
              ),
            ),
            _insightCard(
              context,
              'Goals',
              '${summary.goalsCompleted} of ${summary.goalTotal} reached',
              summary.goalRate,
              Icons.flag_outlined,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _checkNotificationStatus,
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Check notification permission'),
            ),
            const SizedBox(height: 8),
            const Text('Daily notifications require permission and device setup. Times are approximate on Android.'),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text('Habit streaks', style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            if (!_store.items.any((e) => e.kind == EntryKind.habit))
              const Text('Add a habit to start tracking your streaks.'),
            ..._store.items
                .where((e) => e.kind == EntryKind.habit)
                .map((habit) => _habitStreakCard(context, habit)),
            const SizedBox(height: 12),
            const Text(
              'A current streak includes consecutive days ending today or yesterday. '
              'Missing today does not break yesterday’s streak until tomorrow. '
              'The seven-day view runs from six days ago through today.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Task completion is the current total, not a daily history. '
              'Habit activity counts check-ins from today and the previous six days. '
              'Goal progress shows goals that reached their target. '
              'No data is uploaded.',
            ),
          ],
        ),
      ),
    );
  }

  String _formatNextReminder(ReminderSettings setting) {
    final next = ReminderSchedule.nextOccurrence(setting, DateTime.now());
    return '${dateKey(next)} ${setting.timeLabel}';
  }

  Future<void> _setHabitReminder(FlowEntry habit) async {
    final previous = _reminders[habit.id];
    final picked = await showTimePicker(
      context: context,
      initialTime: previous == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: previous.hour, minute: previous.minute),
      helpText: 'Daily reminder time',
    );
    if (picked == null || !mounted) return;
    final setting = ReminderSettings(
      habitId: habit.id,
      hour: picked.hour,
      minute: picked.minute,
    );
    final db = widget.database;
    if (db != null) {
      try {
        await _saveQueue;
        await db.saveReminder(setting);
      } catch (_) {
        if (mounted) {
          setState(() => _saveError = 'Could not save reminder time.');
        }
        return;
      }
    }
    if (mounted) setState(() => _reminders[habit.id] = setting);
    try {
      final allowed = await HabitNotificationService.instance.requestPermission();
      if (allowed) {
        await HabitNotificationService.instance.scheduleDaily(setting, habit.title);
      } else if (mounted) {
        setState(() => _saveError = 'Reminder time saved, but notifications are not permitted.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = 'Reminder time saved, but phone notification setup failed.');
      }
    }
  }

  Future<void> _removeHabitReminder(FlowEntry habit) async {
    final db = widget.database;
    if (db != null) {
      try {
        await _saveQueue;
        await db.deleteReminder(habit.id);
      } catch (_) {
        if (mounted) {
          setState(() => _saveError = 'Could not remove reminder time.');
        }
        return;
      }
    }
    if (mounted) setState(() => _reminders.remove(habit.id));
    try {
      await HabitNotificationService.instance.cancel(habit.id);
    } catch (_) {
      if (mounted) {
        setState(() => _saveError = 'Reminder cleared, but device notification cancellation failed.');
      }
    }
  }

  Future<void> _editHabitHistory(FlowEntry habit) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Choose a habit history date',
    );
    if (selected == null || !mounted) return;
    final completed = habit.completedDates.contains(dateKey(selected));
    final change = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(habit.title),
        content: Text(
          '${dateKey(selected)} is currently ${completed ? 'completed' : 'not completed'}. '
          'Would you like to mark it ${completed ? 'not completed' : 'completed'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, !completed),
            child: Text(completed ? 'Remove check-in' : 'Mark complete'),
          ),
        ],
      ),
    );
    if (change == null || !mounted) return;
    setState(() => _store.setCompleted(habit.id, change, on: selected));
    _persist();
  }

  Widget _habitStreakCard(BuildContext context, FlowEntry habit) {
    final streak = HabitStreak.fromDates(habit.completedDates, DateTime.now());
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    return Card(
      key: ValueKey('streak-${habit.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Current: ${streak.current} days · Longest: ${streak.longest} days'),
            const SizedBox(height: 8),
            Text(
              _reminders[habit.id] == null
                  ? 'No reminder time set'
                  : 'Daily reminder time: ${_reminders[habit.id]!.timeLabel}',
            ),
            if (_reminders[habit.id] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next reminder time: ${_formatNextReminder(_reminders[habit.id]!)}',
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _setHabitReminder(habit),
                  icon: const Icon(Icons.schedule_outlined),
                  label: const Text('Set reminder time'),
                ),
                if (_reminders.containsKey(habit.id))
                  TextButton(
                    onPressed: () => _removeHabitReminder(habit),
                    child: const Text('Clear reminder'),
                  ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => _editHabitHistory(habit),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Edit history'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final day = first.add(Duration(days: index));
                final done = streak.last7Days[index];
                return Semantics(
                  label: '${dateKey(day)}: ${done ? 'completed' : 'not completed'}',
                  child: Chip(
                    avatar: Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                    ),
                    label: Text('${day.day}/${day.month}'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard(
    BuildContext context,
    String title,
    String detail,
    double progress,
    IconData icon,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 8),
          Text(detail),
          const SizedBox(height: 12),
          Semantics(
            label: '$title progress',
            value: detail,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    ),
  );
}
