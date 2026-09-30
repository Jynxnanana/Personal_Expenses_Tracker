import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme.dart';
import '../widgets/expense_widgets.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({
    super.key,
    required this.expenses,
    required this.onEditExpense,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final Future<void> Function(Expense expense) onEditExpense;
  final Future<void> Function(Expense expense) onDeleteExpense;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Future<void> _editExpense(Expense expense) async {
    await widget.onEditExpense(expense);
    if (mounted) setState(() {});
  }

  Future<void> _deleteExpense(Expense expense) async {
    await widget.onDeleteExpense(expense);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthly = widget.expenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .toList();
    final total = totalOf(monthly);
    final groups = {
      for (final category in ExpenseCategory.all)
        category.name: totalOf(
          monthly.where((expense) => expense.category == category.name),
        ),
    }..removeWhere((key, value) => value == 0);
    final month = _monthName(now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spending summary',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 22),
            child: Center(
              child: Text(
                'THIS MONTH',
                style: TextStyle(
                  color: ExpenseMateColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;
          final side = constraints.maxWidth < 400 ? 18.0 : 28.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(side, 16, side, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryHero(
                      month: month,
                      total: total,
                      count: monthly.length,
                    ),
                    const SizedBox(height: 16),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _CategoryBreakdown(groups: groups)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _WeeklySpendingCard(expenses: monthly),
                          ),
                        ],
                      )
                    else ...[
                      _WeeklySpendingCard(expenses: monthly),
                      const SizedBox(height: 16),
                      _CategoryBreakdown(groups: groups),
                    ],
                    const SizedBox(height: 26),
                    SectionHeading(title: 'This month’s activity'),
                    const SizedBox(height: 10),
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 4,
                      ),
                      child: monthly.isEmpty
                          ? const EmptyExpenses(
                              message: 'No expenses recorded this month yet.',
                            )
                          : Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < monthly.length;
                                  index++
                                ) ...[
                                  ExpenseRow(
                                    expense: monthly[index],
                                    onEdit: _editExpense,
                                    onDelete: _deleteExpense,
                                  ),
                                  if (index != monthly.length - 1)
                                    const Divider(height: 1, indent: 59),
                                ],
                              ],
                            ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'CHCCI ExpenseMate  ·  Entries last until the app is closed',
                        style: TextStyle(
                          color: ExpenseMateColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _monthName(int month) => const [
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
  ][month - 1];
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.month,
    required this.total,
    required this.count,
  });

  final String month;
  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        color: ExpenseMateColors.forest,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: ExpenseMateColors.lime,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$month spending',
                style: const TextStyle(
                  color: Color(0xFFD1E5D8),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              total == 0 ? '₱0' : formatPeso(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -.8,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$count ${count == 1 ? 'expense' : 'expenses'} recorded',
            style: const TextStyle(color: Color(0xFFD1E5D8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WeeklySpendingCard extends StatelessWidget {
  const _WeeklySpendingCard({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - index)),
    );
    final values = days
        .map(
          (day) =>
              totalOf(expenses.where((expense) => _sameDay(expense.date, day))),
        )
        .toList();
    final peak = values.fold<double>(
      0,
      (maximum, value) => value > maximum ? value : maximum,
    );
    const weekdayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 days',
            style: TextStyle(
              color: ExpenseMateColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'A simple look at your daily spending',
            style: TextStyle(color: ExpenseMateColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < days.length; index++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (values[index] > 0)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatPeso(values[index]),
                                style: const TextStyle(
                                  color: ExpenseMateColors.muted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 11),
                          const SizedBox(height: 7),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: peak == 0
                                ? 4
                                : 8 + (values[index] / peak * 51),
                            decoration: BoxDecoration(
                              color: index == 6
                                  ? ExpenseMateColors.forest
                                  : const Color(0xFFCFE5D8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weekdayLetters[days[index].weekday - 1],
                            style: TextStyle(
                              color: index == 6
                                  ? ExpenseMateColors.forest
                                  : ExpenseMateColors.muted,
                              fontSize: 10,
                              fontWeight: index == 6
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.groups});

  final Map<String, double> groups;

  @override
  Widget build(BuildContext context) {
    final sorted = groups.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By category',
            style: TextStyle(
              color: ExpenseMateColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Monthly budget used',
            style: TextStyle(color: ExpenseMateColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            const EmptyExpenses(
              message: 'Category totals appear after you add an expense.',
            )
          else
            for (final entry in sorted)
              _CategorySummaryRow(
                category: ExpenseCategory.byName(entry.key),
                spent: entry.value,
              ),
        ],
      ),
    );
  }
}

class _CategorySummaryRow extends StatelessWidget {
  const _CategorySummaryRow({required this.category, required this.spent});

  final ExpenseCategory category;
  final double spent;

  @override
  Widget build(BuildContext context) {
    final progress = (spent / category.monthlyBudget).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              CategoryIcon(category: category, size: 35),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: ExpenseMateColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${formatPeso(spent)} of ${formatPeso(category.monthlyBudget)}',
                      style: const TextStyle(
                        color: ExpenseMateColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: ExpenseMateColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress,
              backgroundColor: const Color(0xFFEFF1EE),
              valueColor: AlwaysStoppedAnimation(category.color),
            ),
          ),
        ],
      ),
    );
  }
}
