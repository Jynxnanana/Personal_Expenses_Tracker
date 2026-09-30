import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'screens/add_expense_screen.dart';
import 'screens/home_screen.dart';
import 'screens/summary_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ExpenseMateApp());
}

class ExpenseMateApp extends StatefulWidget {
  const ExpenseMateApp({super.key});

  @override
  State<ExpenseMateApp> createState() => _ExpenseMateAppState();
}

class _ExpenseMateAppState extends State<ExpenseMateApp> {
  final List<Expense> _expenses = [];
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<void> _openExpenseForm([Expense? existing]) async {
    final expense = await _navigatorKey.currentState!.push<Expense>(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(initialExpense: existing),
      ),
    );
    if (expense != null && mounted) {
      setState(() {
        if (existing == null) {
          _expenses.insert(0, expense);
        } else {
          final index = _expenses.indexOf(existing);
          if (index != -1) _expenses[index] = expense;
        }
      });
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? '${expense.title} added to your expenses.'
                : '${expense.title} updated.',
          ),
          backgroundColor: ExpenseMateColors.ink,
        ),
      );
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Remove “${expense.title}” from this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    setState(() => _expenses.remove(expense));
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('${expense.title} deleted.')),
    );
  }

  void _openSummary() {
    _navigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          expenses: _expenses,
          onEditExpense: (expense) => _openExpenseForm(expense),
          onDeleteExpense: _deleteExpense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHCCI ExpenseMate',
      debugShowCheckedModeBanner: false,
      theme: ExpenseMateTheme.theme,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      home: HomeScreen(
        expenses: _expenses,
        onAddExpense: _openExpenseForm,
        onEditExpense: _openExpenseForm,
        onDeleteExpense: _deleteExpense,
        onViewSummary: _openSummary,
      ),
    );
  }
}
