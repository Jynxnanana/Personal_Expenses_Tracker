import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'screens/add_expense_screen.dart';
import 'screens/app_shell.dart';
import 'screens/settings_screen.dart';
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
  final List<Expense> _transactions = [];
  List<SavingsGoal> _goals = [];
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  ThemeMode _themeMode = ThemeMode.system;
  double _monthlyBudget = 10000;
  void _updateGoals(List<SavingsGoal> goals) {
    setState(() => _goals = goals);
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _openSettings() {
    _navigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          selectedTheme: _themeMode,
          onThemeChanged: _setThemeMode,
        ),
      ),
    );
  }

  Future<void> _openTransactionForm(
    TransactionType type, [
    Expense? existing,
  ]) async {
    final transaction = await _navigatorKey.currentState!.push<Expense>(
      MaterialPageRoute(
        builder: (_) =>
            AddExpenseScreen(initialExpense: existing, initialType: type),
      ),
    );
    if (transaction != null && mounted) {
      setState(() {
        if (existing == null) {
          _transactions.insert(0, transaction);
        } else {
          final index = _transactions.indexOf(existing);
          if (index != -1) _transactions[index] = transaction;
        }
      });
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? '${transaction.title} added.'
                : '${transaction.title} updated.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(Expense transaction) async {
    final shouldDelete = await showDialog<bool>(
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Remove "${transaction.title}" from this session?'),
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
    setState(() => _transactions.remove(transaction));
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('${transaction.title} deleted.')),
    );
  }

  Future<void> _addRecurringOccurrence(Expense transaction) async {
    setState(() {
      _transactions.insert(
        0,
        Expense(
          title: transaction.title,
          category: transaction.category,
          amount: transaction.amount,
          date: DateTime.now(),
          type: transaction.type,
          paymentMethod: transaction.paymentMethod,
          notes: transaction.notes,
          isRecurring: true,
        ),
      );
    });
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('${transaction.title} added for this month.')),
    );
  }

  void _saveMonthlyBudget(double budget) {
    setState(() => _monthlyBudget = budget);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHCCI ExpenseMate',
      debugShowCheckedModeBanner: false,
      theme: ExpenseMateTheme.theme,
      darkTheme: ExpenseMateTheme.darkTheme,
      themeMode: _themeMode,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      home: ExpenseMateShell(
        transactions: _transactions,
        goals: _goals,
        monthlyBudget: _monthlyBudget,
        onAddExpense: () => _openTransactionForm(TransactionType.expense),
        onAddIncome: () => _openTransactionForm(TransactionType.income),
        onEditTransaction: (transaction) =>
            _openTransactionForm(transaction.type, transaction),
        onDeleteTransaction: _deleteTransaction,
        onRepeatTransaction: _addRecurringOccurrence,
        onEditBudget: _saveMonthlyBudget,
        onGoalsChanged: _updateGoals,
        onOpenSettings: _openSettings,
      ),
    );
  }
}
