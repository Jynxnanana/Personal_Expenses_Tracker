import 'package:flutter/material.dart';

import '../theme.dart';

class Expense {
  const Expense({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  final String title;
  final String category;
  final double amount;
  final DateTime date;
}

class ExpenseCategory {
  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.monthlyBudget,
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

  static ExpenseCategory byName(String name) => all.firstWhere(
    (category) => category.name == name,
    orElse: () => all.last,
  );
}

String formatPeso(double amount) =>
    '₱${amount.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '')}';

double totalOf(Iterable<Expense> expenses) =>
    expenses.fold(0, (total, expense) => total + expense.amount);
