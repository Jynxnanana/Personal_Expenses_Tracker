import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme.dart';
import '../widgets/expense_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.expenses,
    required this.monthlyBudget,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onEditExpense,
    required this.onDeleteExpense,
    required this.onRepeatExpense,
    required this.onNavigateToTab,
    required this.onOpenSettings,
    required this.onEditBudget,
  });

  final List<Expense> expenses;
  final double monthlyBudget;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final Future<void> Function(Expense expense) onEditExpense;
  final Future<void> Function(Expense expense) onDeleteExpense;
  final Future<void> Function(Expense expense) onRepeatExpense;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenSettings;
  final ValueChanged<double> onEditBudget;

  List<Expense> get _thisMonth => expenses.where((expense) {
    final now = DateTime.now();
    return expense.date.year == now.year && expense.date.month == now.month;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final monthTransactions = _thisMonth;
    final monthExpenses = monthTransactions
        .where((transaction) => !transaction.isIncome)
        .toList();
    final monthIncome = monthTransactions
        .where((transaction) => transaction.isIncome)
        .toList();
    final monthTotal = totalOf(monthExpenses);
    final allIncome = totalOf(
      expenses.where((transaction) => transaction.isIncome),
    );
    final allExpenses = totalOf(
      expenses.where((transaction) => !transaction.isIncome),
    );
    final recent = expenses.take(5).toList();
    final dayLabel = _dateLabel(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Row(
          children: [
            BrandMark(),
            SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CHCCI',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .4,
                  ),
                ),
                Text(
                  'ExpenseMate',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton.filledTonal(
              tooltip: 'View spending summary',
              onPressed: () => onNavigateToTab(2),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.bar_chart_rounded),
            ),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<TransactionType>(
        tooltip: 'Add transaction',
        onSelected: (type) =>
            type == TransactionType.income ? onAddIncome() : onAddExpense(),
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: TransactionType.expense,
            child: ListTile(
              leading: Icon(Icons.north_east_rounded),
              title: Text('Add expense'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: TransactionType.income,
            child: ListTile(
              leading: Icon(Icons.south_west_rounded),
              title: Text('Add income'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            color: ExpenseMateColors.forest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24114E40),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Add transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth;
          final horizontalPadding = contentWidth < 400 ? 18.0 : 28.0;
          final columns = contentWidth >= 850 ? 3 : 2;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  110,
                ),
                children: [
                  Text(
                    dayLabel.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your money, in view.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 19),
                  _MonthlySpendCard(
                    balance: allIncome - allExpenses,
                    income: allIncome,
                    expenses: allExpenses,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.calendar_view_week_rounded,
                          label: 'Income this month',
                          value: formatPeso(totalOf(monthIncome)),
                          tint: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.receipt_outlined,
                          label: 'Expenses this month',
                          value: formatPeso(monthTotal),
                          tint: Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _MonthlyBudgetCard(
                    spent: monthTotal,
                    budget: monthlyBudget,
                    onSave: onEditBudget,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => onNavigateToTab(3),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Savings goals'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SectionHeading(
                    title: 'Spending categories',
                    actionLabel: 'See summary',
                    onAction: () => onNavigateToTab(2),
                  ),
                  const SizedBox(height: 10),
                  _CategoryGrid(
                    expenses: monthExpenses,
                    columns: columns,
                    onTap: () => onNavigateToTab(2),
                  ),
                  const SizedBox(height: 28),
                  SectionHeading(
                    title: 'Recent transactions',
                    actionLabel: 'View all',
                    onAction: () => onNavigateToTab(1),
                  ),
                  const SizedBox(height: 9),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 4,
                    ),
                    child: recent.isEmpty
                        ? EmptyExpenses(
                            message: 'No transactions yet. Add income or an expense.',
                          )
                        : Column(
                            children: [
                              for (
                                var index = 0;
                                index < recent.length;
                                index++
                              ) ...[
                                ExpenseRow(
                                  expense: recent[index],
                                  onEdit: onEditExpense,
                                  onDelete: onDeleteExpense,
                                  onRepeat: onRepeatExpense,
                                ),
                                if (index != recent.length - 1)
                                  const Divider(height: 1, indent: 59),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 22),
                  _TipCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _dateLabel(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

class _MonthlySpendCard extends StatelessWidget {
  const _MonthlySpendCard({
    required this.balance,
    required this.income,
    required this.expenses,
  });

  final double balance;
  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ExpenseMateColors.forest, Color(0xFF17473C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24114E40),
            blurRadius: 24,
            offset: Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -35,
            width: 230,
            height: 190,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/savings_illustration.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: ExpenseMateColors.lime,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'CURRENT BALANCE  ·  THIS SESSION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD1E5D8),
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatPeso(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 37,
                      letterSpacing: -1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _HeroAmount(label: 'INCOME', amount: income),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _HeroAmount(label: 'EXPENSES', amount: expenses),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAmount extends StatelessWidget {
  const _HeroAmount({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD1E5D8),
          fontSize: 9,
          letterSpacing: .8,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          formatPeso(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _MonthlyBudgetCard extends StatefulWidget {
  const _MonthlyBudgetCard({
    required this.spent,
    required this.budget,
    required this.onSave,
  });

  final double spent;
  final double budget;
  final ValueChanged<double> onSave;

  @override
  State<_MonthlyBudgetCard> createState() => _MonthlyBudgetCardState();
}

class _MonthlyBudgetCardState extends State<_MonthlyBudgetCard> {
  late double _budget;

  @override
  void initState() {
    super.initState();
    _budget = widget.budget;
  }

  Future<void> _editBudget() async {
    var amountText = _budget.toStringAsFixed(2);
    String? errorText;
    final budget = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Monthly budget'),
          content: TextField(
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              amountText = value;
              if (errorText != null) {
                setDialogState(() => errorText = null);
              }
            },
            decoration: InputDecoration(
              labelText: 'Budget amount',
              prefixText: '\u20B1  ',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amountText.trim());
                if (value == null || !value.isFinite || value <= 0) {
                  setDialogState(
                    () => errorText = 'Enter an amount above zero.',
                  );
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Save budget'),
            ),
          ],
        ),
      ),
    );
    if (budget == null || !mounted) return;
    setState(() => _budget = budget);
    widget.onSave(budget);
  }

  @override
  Widget build(BuildContext context) {
    final spent = widget.spent;
    final remaining = (_budget - spent).clamp(0, double.infinity).toDouble();
    final progress = (spent / _budget).clamp(0.0, 1.0);
    final colors = Theme.of(context).colorScheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly budget',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _editBudget,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Set limit'),
              ),
            ],
          ),
          Text(
            '${formatPeso(spent)} of ${formatPeso(_budget)} used',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                spent > _budget ? colors.error : colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            spent > _budget
                ? '${formatPeso(spent - _budget)} over budget'
                : '${formatPeso(remaining)} remaining',
            style: TextStyle(
              color: spent > _budget ? colors.error : colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.expenses,
    required this.columns,
    required this.onTap,
  });

  final List<Expense> expenses;
  final int columns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rows = ExpenseCategory.all
        .map(
          (category) => (
            category: category,
            spent: totalOf(
              expenses.where((expense) => expense.category == category.name),
            ),
          ),
        )
        .where((row) => row.spent > 0)
        .toList();

    if (rows.isEmpty) {
      return SurfaceCard(
        child: EmptyExpenses(
          message: 'Add an expense to see your category totals.',
        ),
      );
    }

    return GridView.builder(
      itemCount: rows.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 11,
        crossAxisSpacing: 11,
        mainAxisExtent: 116,
      ),
      itemBuilder: (context, index) {
        final category = rows[index].category;
        final spent = rows[index].spent;
        final progress = (spent / category.monthlyBudget).clamp(0.0, 1.0);
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(19),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryIcon(category: category, size: 34),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatPeso(spent),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 21,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Small check-ins today make bigger money goals easier tomorrow.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                height: 1.45,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
