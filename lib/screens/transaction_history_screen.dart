import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_widgets.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
    required this.onRepeat,
    required this.onBack,
  });

  final List<Expense> transactions;
  final Future<void> Function(Expense transaction) onEdit;
  final Future<void> Function(Expense transaction) onDelete;
  final Future<void> Function(Expense transaction) onRepeat;
  final VoidCallback onBack;

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  TransactionType? _type;
  String? _category;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _chooseDateRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (selected != null && mounted) setState(() => _dateRange = selected);
  }

  Future<void> _edit(Expense transaction) async {
    await widget.onEdit(transaction);
    if (mounted) setState(() {});
  }

  Future<void> _delete(Expense transaction) async {
    await widget.onDelete(transaction);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.transactions.where((transaction) {
      if (_type != null && transaction.type != _type) return false;
      if (_category != null && transaction.category != _category) return false;
      if (_dateRange != null) {
        final firstDay = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final dayAfterLast = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day + 1,
        );
        if (transaction.date.isBefore(firstDay) ||
            !transaction.date.isBefore(dayAfterLast)) {
          return false;
        }
      }
      if (query.isEmpty) return true;
      return transaction.title.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query) ||
          transaction.paymentMethod.toLowerCase().contains(query) ||
          transaction.notes.toLowerCase().contains(query) ||
          transaction.amount.toString().contains(query);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction history',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth < 400 ? 18.0 : 28.0;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: EdgeInsets.fromLTRB(side, 12, side, 32),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search name, category, payment, or amount',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<TransactionType?>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: null, label: Text('All')),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expenses'),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) =>
                        setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All categories'),
                            ),
                            for (final category in [
                              ...ExpenseCategory.all,
                              ...ExpenseCategory.income,
                            ])
                              DropdownMenuItem<String?>(
                                value: category.name,
                                child: Text(category.name),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _category = value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _chooseDateRange,
                        icon: const Icon(Icons.date_range_rounded),
                        label: Text(_dateRange == null ? 'Dates' : 'Selected'),
                      ),
                    ],
                  ),
                  if (_category != null || _dateRange != null) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _category = null;
                          _dateRange = null;
                        }),
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        label: const Text('Clear category/date filters'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SectionHeading(title: '${filtered.length} transactions'),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: filtered.isEmpty
                        ? const EmptyExpenses(
                            message: 'No transactions match these filters.',
                          )
                        : Column(
                            children: [
                              for (
                                var index = 0;
                                index < filtered.length;
                                index++
                              ) ...[
                                ExpenseRow(
                                  expense: filtered[index],
                                  onEdit: _edit,
                                  onDelete: _delete,
                                  onRepeat: widget.onRepeat,
                                ),
                                if (index != filtered.length - 1)
                                  const Divider(height: 1, indent: 59),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
