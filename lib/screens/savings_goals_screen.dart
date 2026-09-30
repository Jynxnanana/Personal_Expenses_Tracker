import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_widgets.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({
    super.key,
    required this.goals,
    required this.onGoalsChanged,
  });

  final List<SavingsGoal> goals;
  final ValueChanged<List<SavingsGoal>> onGoalsChanged;

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  late List<SavingsGoal> _goals;

  @override
  void initState() {
    super.initState();
    _goals = [...widget.goals];
  }

  void _updateGoals(List<SavingsGoal> goals) {
    setState(() => _goals = goals);
    widget.onGoalsChanged(goals);
  }

  Future<void> _addGoal(BuildContext context) async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final goal = await showDialog<SavingsGoal>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New savings goal'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Goal name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a goal name.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target amount',
                  prefixText: '\u20B1  ',
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  return amount == null || amount <= 0
                      ? 'Enter an amount above zero.'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                SavingsGoal(
                  title: nameController.text.trim(),
                  target: double.parse(targetController.text.trim()),
                ),
              );
            },
            child: const Text('Create goal'),
          ),
        ],
      ),
    );
    nameController.dispose();
    targetController.dispose();
    if (goal != null) _updateGoals([..._goals, goal]);
  }

  Future<void> _addContribution(BuildContext context, int index) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to ${_goals[index].title}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Contribution',
              prefixText: '\u20B1  ',
            ),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              return amount == null || !amount.isFinite || amount <= 0
                  ? 'Enter an amount above zero.'
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final value = double.parse(controller.text.trim());
              Navigator.pop(context, value);
            },
            child: const Text('Add savings'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null) return;
    final next = [..._goals];
    next[index] = next[index].copyWith(saved: next[index].saved + amount);
    _updateGoals(next);
  }

  void _deleteGoal(int index) {
    final next = [..._goals]..removeAt(index);
    _updateGoals(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Savings goals',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Add goal',
            onPressed: () => _addGoal(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth < 400 ? 18.0 : 28.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, 20, side, 32),
                children: [
                  Text(
                    'Save for what matters.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Track a target and add contributions as you go. Goals are kept for this session only.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (_goals.isEmpty)
                    SurfaceCard(
                      child: EmptyExpenses(
                        message: 'No savings goals yet. Tap + to create one.',
                      ),
                    )
                  else
                    for (var index = 0; index < _goals.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GoalCard(
                          goal: _goals[index],
                          onContribute: () => _addContribution(context, index),
                          onDelete: () => _deleteGoal(index),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _goals.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _addGoal(context),
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Create goal'),
            )
          : null,
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onContribute,
    required this.onDelete,
  });

  final SavingsGoal goal;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = (goal.saved / goal.target).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Delete goal',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          Text(
            '${formatPeso(goal.saved)} saved of ${formatPeso(goal.target)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(progress * 100).round()}% complete',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onContribute,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add savings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
