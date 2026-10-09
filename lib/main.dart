import 'dart:async';

import 'package:flutter/material.dart';

import 'data/local_store.dart';
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
  bool _isReady = false;
  Future<void> _saveQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    unawaited(_restoreData());
  }

  Future<void> _restoreData() async {
    final saved = await loadSavedData();
    if (saved != null) {
      final transactions = saved['transactions'];
      if (transactions is List) {
        for (final value in transactions) {
          try {
            if (value is Map) {
              _transactions.add(
                Expense.fromJson(Map<String, Object?>.from(value)),
              );
            }
          } on Object {
            continue;
          }
        }
      }
      final goals = saved['goals'];
      if (goals is List) {
        _goals = [
          for (final value in goals)
            if (value is Map) tryParseGoal(Map<String, Object?>.from(value)),
        ].whereType<SavingsGoal>().toList();
      }
      final budget = saved['monthlyBudget'];
      if (budget is num && budget.isFinite && budget > 0) {
        _monthlyBudget = budget.toDouble();
      }
      _themeMode = switch (saved['themeMode']) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    }
    if (mounted) setState(() => _isReady = true);
  }

  Future<void> _persistData() {
    final snapshot = <String, Object?>{
      'transactions': _transactions
          .map((transaction) => transaction.toJson())
          .toList(),
      'goals': _goals.map((goal) => goal.toJson()).toList(),
      'monthlyBudget': _monthlyBudget,
      'themeMode': _themeMode.name,
    };
    _saveQueue = _saveQueue
        .catchError((Object _) {})
        .then((_) => saveData(snapshot));
    return _saveQueue;
  }

  void _updateGoals(List<SavingsGoal> goals) {
    setState(() => _goals = goals);
    unawaited(_persistData());
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    unawaited(_persistData());
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
      await _persistData();
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
    await _persistData();
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
    await _persistData();
    _messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text('${transaction.title} added for this month.')),
    );
  }

  void _saveMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    unawaited(_persistData());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return MaterialApp(
        title: 'CHCCI ExpenseMate',
        debugShowCheckedModeBanner: false,
        theme: ExpenseMateTheme.theme,
        darkTheme: ExpenseMateTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
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

SavingsGoal? tryParseGoal(Map<String, Object?> json) {
  try {
    return SavingsGoal.fromJson(json);
  } on Object {
    return null;
  }
}
