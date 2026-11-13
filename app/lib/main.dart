import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/entries/entry_store.dart';

void main() => runApp(const HabitFlowApp());

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'HabitFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HabitFlowShell(),
      );
}

class HabitFlowShell extends StatefulWidget {
  const HabitFlowShell({super.key});

  @override
  State<HabitFlowShell> createState() => _HabitFlowShellState();
}

class _HabitFlowShellState extends State<HabitFlowShell> {
  final EntryStore _store = EntryStore()
    ..add('Review today’s priorities', EntryKind.task)
    ..add('Plan tomorrow', EntryKind.task);
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
                            _store.add(name, kind);
                          } else {
                            _store.rename(entry.id, name);
                          }
                          _selected = 0;
                        });
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
      setState(() => _store.remove(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;
    final expanded = width >= 840;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitFlow'),
        actions: [
          IconButton(
            tooltip: 'About this preview',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'HabitFlow',
              children: [
                const Text('Phase 03D: items are saved for this session only.'),
              ],
            ),
          ),
        ],
      ),
      body: Row(
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
            child: _selected == 0
                ? _todayPage(context)
                : _placeholderPage(context, _titles[_selected]),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) =>
                  setState(() => _selected = index),
              destinations: List.generate(
                _titles.length,
                (index) => NavigationDestination(
                  icon: Icon(_icons[index]),
                  label: _titles[index],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add a task or habit',
        onPressed: _editEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
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
            Text('Today', style: theme.textTheme.headlineMedium),
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
            const SizedBox(height: 20),
            Text('Tasks', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (tasks.isEmpty) const Text('No tasks yet. Tap Add to create one.'),
            ...tasks.map((item) => _entryTile(item)),
            const SizedBox(height: 20),
            Text('Habits', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (habits.isEmpty)
              const Text('No habits yet. Tap Add and choose Habit.'),
            ...habits.map((item) => _entryTile(item)),
            const SizedBox(height: 16),
            const Text(
              'Preview only: tasks, habits and progress reset when the app '
              'restarts. Offline storage is planned for Phase 03E.',
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
                    ? 'Daily habit · session only'
                    : 'Saved for this session only'),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) => setState(
                  () => _store.setCompleted(item.id, checked == true),
                ),
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

  Widget _placeholderPage(BuildContext context, String title) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined,
                  size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('This feature is planned for a future phase.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
