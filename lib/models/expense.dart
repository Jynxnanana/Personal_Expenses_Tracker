import 'package:flutter/material.dart';

import '../theme.dart';

enum TransactionType { expense, income }

class Expense {
  const Expense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.type = TransactionType.expense,
    this.paymentMethod = 'Cash',
    this.notes = '',
    this.isRecurring = false,
  });

  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String paymentMethod;
  final String notes;
  final bool isRecurring;

  bool get isIncome => type == TransactionType.income;
}

class SavingsGoal {
  const SavingsGoal({
    required this.title,
    required this.target,
    this.saved = 0,
  });

  final String title;
  final double target;
  final double saved;

  SavingsGoal copyWith({double? saved}) =>
      SavingsGoal(title: title, target: target, saved: saved ?? this.saved);
}

class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.monthlyBudget = 0,
  });

  final String name;
  final IconData icon;
  final Color color;
  final double monthlyBudget;

  static const all = <ExpenseCategory>[
    ExpenseCategory(
      name: 'Food & dining',
      icon: Icons.restaurant_rounded,
      color: ExpenseMateColors.coral,
      monthlyBudget: 8000,
    ),
    ExpenseCategory(
      name: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: ExpenseMateColors.blue,
      monthlyBudget: 4500,
    ),
    ExpenseCategory(
      name: 'Groceries',
      icon: Icons.shopping_basket_rounded,
      color: ExpenseMateColors.forestLight,
      monthlyBudget: 9000,
    ),
    ExpenseCategory(
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: ExpenseMateColors.lilac,
      monthlyBudget: 6000,
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: ExpenseMateColors.yellow,
      monthlyBudget: 5000,
    ),
    ExpenseCategory(
      name: 'School',
      icon: Icons.school_rounded,
      color: Color(0xFF83A2D4),
      monthlyBudget: 5000,
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFD58AC8),
      monthlyBudget: 3500,
    ),
    ExpenseCategory(
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFE58297),
      monthlyBudget: 3500,
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.grid_view_rounded,
      color: Color(0xFF9AA49E),
      monthlyBudget: 4000,
    ),
  ];

  static const income = <ExpenseCategory>[
    ExpenseCategory(
      name: 'Allowance',
      icon: Icons.account_balance_wallet_rounded,
      color: ExpenseMateColors.forestLight,
    ),
    ExpenseCategory(
      name: 'Salary',
      icon: Icons.work_rounded,
      color: ExpenseMateColors.blue,
    ),
    ExpenseCategory(
      name: 'Side income',
      icon: Icons.trending_up_rounded,
      color: ExpenseMateColors.coral,
    ),
    ExpenseCategory(
      name: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: ExpenseMateColors.lilac,
    ),
    ExpenseCategory(
      name: 'Other income',
      icon: Icons.savings_rounded,
      color: ExpenseMateColors.yellow,
    ),
  ];

  static ExpenseCategory byName(String name) => [
    ...all,
    ...income,
  ].firstWhere((category) => category.name == name, orElse: () => all.last);

  static List<ExpenseCategory> forType(TransactionType type) =>
      type == TransactionType.income ? income : all;
}

String formatPeso(double amount) =>
    '\u20B1${amount.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '')}';

double totalOf(Iterable<Expense> expenses) =>
    expenses.fold(0, (total, expense) => total + expense.amount);
