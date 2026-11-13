import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const HabitFlowApp());

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HabitFlowShell(),
    );
  }
}

/// Phase 03 shell. Sample content is in memory and resets on restart.
class HabitFlowShell extends StatefulWidget {
  const HabitFlowShell({super.key});

  @override
  State<HabitFlowShell> createState() => _HabitFlowShellState();
}

class _HabitFlowShellState extends State<HabitFlowShell> {
  int _selected = 0;
  final List<String> _tasks = ['Review today’s priorities', 'Plan tomorrow'];
  final Set<String> _completed = {};
  static const _titles = ['Today', 'Planner', 'Goals', 'Insights'];
  static const _icons = [
    Icons.today_outlined,
    Icons.calendar_month_outlined,
    Icons.flag_outlined,
    Icons.insights_outlined,
  ];

  Future<void> _quickAdd() async {
    final controller = TextEditingController();
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 8, 24, MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Quick add task',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task name',
                    hintText: 'What would you like to do?',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) return;
                    setState(() {
                      _tasks.add(value);
                      _selected = 0;
                    });
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task added for this session')),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add task'),
                ),
              ],
            ),
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 600;
    final expanded = width >= 840;
    final scheme = Theme.of(context).colorScheme;
    final content = _selected == 0
        ? _todayPage(context)
        : _placeholderPage(context, _titles[_selected]);

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
                const Text('Phase 03 preview: sample data is not saved yet.'),
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
              onDestinationSelected: (index) => setState(() => _selected = index),
              labelType: expanded ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              destinations: List.generate(
                _titles.length,
                (index) => NavigationRailDestination(
                  icon: Icon(_icons[index]),
                  selectedIcon: Icon(_icons[index], color: scheme.primary),
                  label: Text(_titles[index]),
                ),
              ),
            ),
          Expanded(child: content),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: (index) => setState(() => _selected = index),
              destinations: List.generate(
                _titles.length,
                (index) => NavigationDestination(
                  icon: Icon(_icons[index]),
                  label: _titles[index],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add a task',
        onPressed: _quickAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _todayPage(BuildContext context) {
    final theme = Theme.of(context);
    final done = _completed.length;
    final total = _tasks.length;
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
                    Text('$done of $total tasks complete',
                        key: const Key('progress-label')),
                    const SizedBox(height: 12),
                    Semantics(
                      label: 'Daily progress',
                      value: '$done of $total tasks complete',
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
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
            ..._tasks.map((task) => Card(
                  key: ValueKey('task-$task'),
                  child: CheckboxListTile(
                    value: _completed.contains(task),
                    title: Text(task),
                    subtitle: const Text('Saved for this session only'),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _completed.add(task);
                      } else {
                        _completed.remove(task);
                      }
                    }),
                  ),
                )),
            const SizedBox(height: 12),
            const Text(
              'Preview only: tasks and progress reset when the app restarts. '
              'Offline storage and reminders are planned for later phases.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderPage(BuildContext context, String title) {
    return Center(
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
}
