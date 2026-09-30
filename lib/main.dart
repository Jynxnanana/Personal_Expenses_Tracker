import 'package:flutter/material.dart';

import 'models/expense.dart';
import 'screens/add_expense_screen.dart';
import 'screens/home_screen.dart';
import 'screens/savings_goals_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/transaction_history_screen.dart';
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

  Future<void> _editMonthlyBudget() async {
    final controller = TextEditingController(
      text: _monthlyBudget.toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    final budget = await showDialog<double>(
      context: _navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Monthly budget'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Budget amount',
              prefixText: '\u20B1  ',
            ),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              return amount == null || !amount.isFinite || amount <= 0
                  ? 'Enter a budget above zero.'
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
            child: const Text('Save budget'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (budget != null && mounted) setState(() => _monthlyBudget = budget);
  }

  void _openHistory() {
    _navigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => TransactionHistoryScreen(
          transactions: _transactions,
          onEdit: (transaction) =>
              _openTransactionForm(transaction.type, transaction),
          onDelete: _deleteTransaction,
          onRepeat: _addRecurringOccurrence,
        ),
      ),
    );
  }

  void _openSummary() {
    _navigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          expenses: _transactions,
          monthlyBudget: _monthlyBudget,
          onEditExpense: (transaction) =>
              _openTransactionForm(transaction.type, transaction),
          onDeleteExpense: _deleteTransaction,
          onRepeatExpense: _addRecurringOccurrence,
        ),
      ),
    );
  }

  void _openSavingsGoals() {
    _navigatorKey.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => SavingsGoalsScreen(
          goals: _goals,
          onGoalsChanged: (goals) => setState(() => _goals = goals),
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
      darkTheme: ExpenseMateTheme.darkTheme,
      themeMode: _themeMode,
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _messengerKey,
      home: HomeScreen(
        expenses: _transactions,
        monthlyBudget: _monthlyBudget,
        onAddExpense: () => _openTransactionForm(TransactionType.expense),
        onAddIncome: () => _openTransactionForm(TransactionType.income),
        onEditExpense: (transaction) =>
            _openTransactionForm(transaction.type, transaction),
        onDeleteExpense: _deleteTransaction,
        onViewSummary: _openSummary,
        onOpenSettings: _openSettings,
        onOpenHistory: _openHistory,
        onOpenGoals: _openSavingsGoals,
        onEditBudget: _editMonthlyBudget,
        onRepeatExpense: _addRecurringOccurrence,
      ),
    );
  }
}
