import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_widgets.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({
    super.key,
    required this.goals,
    required this.onGoalsChanged,
    required this.onBack,
  });

  final List<SavingsGoal> goals;
  final ValueChanged<List<SavingsGoal>> onGoalsChanged;
  final VoidCallback onBack;

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
    final goal = await showDialog<SavingsGoal>(
      context: context,
      builder: (_) => const _NewSavingsGoalDialog(),
    );
    if (goal != null && mounted) _updateGoals([..._goals, goal]);
  }

  Future<void> _addContribution(BuildContext context, int index) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => _AddContributionDialog(goalTitle: _goals[index].title),
    );
    if (amount == null || !mounted || index >= _goals.length) return;
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
          onPressed: widget.onBack,
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

class _NewSavingsGoalDialog extends StatefulWidget {
  const _NewSavingsGoalDialog();

  @override
  State<_NewSavingsGoalDialog> createState() => _NewSavingsGoalDialogState();
}

class _NewSavingsGoalDialogState extends State<_NewSavingsGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _createGoal() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SavingsGoal(
        title: _nameController.text.trim(),
        target: double.parse(_targetController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New savings goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Goal name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a goal name.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Target amount',
                prefixText: '\u20B1  ',
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                return amount == null || !amount.isFinite || amount <= 0
                    ? 'Enter an amount above zero.'
                    : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _createGoal, child: const Text('Create goal')),
      ],
    );
  }
}

class _AddContributionDialog extends StatefulWidget {
  const _AddContributionDialog({required this.goalTitle});

  final String goalTitle;

  @override
  State<_AddContributionDialog> createState() => _AddContributionDialogState();
}

class _AddContributionDialogState extends State<_AddContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSavings() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(double.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to ${widget.goalTitle}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _addSavings, child: const Text('Add savings')),
      ],
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
