import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ExpenseMateColors.forest,
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        size: size * .55,
        color: ExpenseMateColors.lime,
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: ExpenseMateColors.forest,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({super.key, required this.category, this.size = 46});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(size * .34),
      ),
      child: Icon(category.icon, color: category.color, size: size * .49),
    );
  }
}

class ExpenseRow extends StatelessWidget {
  const ExpenseRow({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    this.showDate = true,
  });

  final Expense expense;
  final Future<void> Function(Expense expense) onEdit;
  final Future<void> Function(Expense expense) onDelete;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.byName(expense.category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          CategoryIcon(category: category, size: 46),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ExpenseMateColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showDate
                      ? '${expense.category}  ·  ${_formatDate(expense.date)}'
                      : expense.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ExpenseMateColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '−${formatPeso(expense.amount)}',
            style: const TextStyle(
              color: ExpenseMateColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Expense actions',
            padding: EdgeInsets.zero,
            iconSize: 19,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            onSelected: (action) {
              if (action == 'edit') {
                onEdit(expense);
              } else {
                onDelete(expense);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, size: 20),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded, size: 20),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: const Color(0x140E2F24),
      color: ExpenseMateColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: ExpenseMateColors.line.withValues(alpha: .7)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class EmptyExpenses extends StatelessWidget {
  const EmptyExpenses({
    super.key,
    this.message = 'Your expenses will appear here.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 34,
            color: ExpenseMateColors.muted,
          ),
          const SizedBox(height: 10),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
