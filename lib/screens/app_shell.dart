import 'package:flutter/material.dart';

import '../models/expense.dart';
import 'home_screen.dart';
import 'savings_goals_screen.dart';
import 'summary_screen.dart';
import 'transaction_history_screen.dart';

class ExpenseMateShell extends StatefulWidget {
  const ExpenseMateShell({
    super.key,
    required this.transactions,
    required this.goals,
    required this.monthlyBudget,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onEditTransaction,
    required this.onDeleteTransaction,
    required this.onRepeatTransaction,
    required this.onEditBudget,
    required this.onGoalsChanged,
    required this.onOpenSettings,
  });

  final List<Expense> transactions;
  final List<SavingsGoal> goals;
  final double monthlyBudget;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final Future<void> Function(Expense transaction) onEditTransaction;
  final Future<void> Function(Expense transaction) onDeleteTransaction;
  final Future<void> Function(Expense transaction) onRepeatTransaction;
  final ValueChanged<double> onEditBudget;
  final ValueChanged<List<SavingsGoal>> onGoalsChanged;
  final VoidCallback onOpenSettings;

  @override
  State<ExpenseMateShell> createState() => _ExpenseMateShellState();
}

class _ExpenseMateShellState extends State<ExpenseMateShell> {
  int _selectedTab = 0;
  double? _budgetOverride;

  double get _monthlyBudget => _budgetOverride ?? widget.monthlyBudget;

  void _selectTab(int index) {
    if (index == _selectedTab) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedTab = index);
  }

  void _updateBudget(double budget) {
    setState(() => _budgetOverride = budget);
    widget.onEditBudget(budget);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        expenses: widget.transactions,
        monthlyBudget: _monthlyBudget,
        onAddExpense: widget.onAddExpense,
        onAddIncome: widget.onAddIncome,
        onEditExpense: widget.onEditTransaction,
        onDeleteExpense: widget.onDeleteTransaction,
        onRepeatExpense: widget.onRepeatTransaction,
        onNavigateToTab: _selectTab,
        onOpenSettings: widget.onOpenSettings,
        onEditBudget: _updateBudget,
      ),
      TransactionHistoryScreen(
        transactions: widget.transactions,
        onEdit: widget.onEditTransaction,
        onDelete: widget.onDeleteTransaction,
        onRepeat: widget.onRepeatTransaction,
        onBack: () => _selectTab(0),
      ),
      SummaryScreen(
        expenses: widget.transactions,
        monthlyBudget: _monthlyBudget,
        onEditExpense: widget.onEditTransaction,
        onDeleteExpense: widget.onDeleteTransaction,
        onRepeatExpense: widget.onRepeatTransaction,
        onBack: () => _selectTab(0),
      ),
      SavingsGoalsScreen(
        goals: widget.goals,
        onGoalsChanged: widget.onGoalsChanged,
        onBack: () => _selectTab(0),
      ),
    ];

    return PopScope<Object?>(
      canPop: _selectedTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedTab != 0) _selectTab(0);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            for (var index = 0; index < pages.length; index++)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: index != _selectedTab,
                  child: ExcludeSemantics(
                    excluding: index != _selectedTab,
                    child: AnimatedOpacity(
                      opacity: index == _selectedTab ? 1 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: AnimatedSlide(
                        offset: index == _selectedTab
                            ? Offset.zero
                            : const Offset(0, .025),
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: TickerMode(
                          enabled: index == _selectedTab,
                          child: pages[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag_rounded),
              label: 'Goals',
            ),
          ],
        ),
      ),
    );
  }
}
