import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/expense.dart';
import '../theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.initialExpense,
    this.initialType = TransactionType.expense,
  });

  final Expense? initialExpense;
  final TransactionType initialType;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _category;
  String _paymentMethod = 'Cash';
  DateTime _date = DateTime.now();
  late TransactionType _type;
  bool _isRecurring = false;

  bool get _isEditing => widget.initialExpense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _type = expense?.type ?? widget.initialType;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _category = expense.category;
      _date = expense.date;
      _paymentMethod = expense.paymentMethod;
      _notesController.text = expense.notes;
      _isRecurring = expense.isRecurring;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      helpText: 'Select the expense date',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme
              .copyWith(primary: ExpenseMateColors.forest),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    final expense = Expense(
      title: _titleController.text.trim(),
      category: _category!,
      amount: double.parse(_amountController.text.trim()),
      date: _date,
      type: _type,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim(),
      isRecurring: _isRecurring,
    );
    Navigator.of(context).pop(expense);
  }

  String _prettyDate(DateTime date) {
    const months = [
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
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit transaction'
              : _type == TransactionType.income
              ? 'Add income'
              : 'Add expense',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth < 400 ? 18.0 : 28.0;
          // A ListView gives the form a real viewport to scroll within. Keeping
          // the content as its first item also prevents short screens from
          // centering the form below the visible area.
          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 17, horizontal, 28),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildForm(context),
                      const SizedBox(height: 24),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _saveExpense,
                              icon: const Icon(Icons.check_rounded),
                              label: Text(
                                _isEditing
                                    ? 'Update transaction'
                                    : 'Save ${_type.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: ExpenseMateColors.forest,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditing
              ? 'Update the details'
              : _type == TransactionType.income
              ? 'Add to your income'
              : 'Where did it go?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 7),
        Text(
          _type == TransactionType.income
              ? 'Record allowance, salary, or other money received.'
              : 'Add a few details and keep your spending in view.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        SegmentedButton<TransactionType>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: TransactionType.expense,
              icon: Icon(Icons.north_east_rounded),
              label: Text('Expense'),
            ),
            ButtonSegment(
              value: TransactionType.income,
              icon: Icon(Icons.south_west_rounded),
              label: Text('Income'),
            ),
          ],
          selected: {_type},
          onSelectionChanged: (selection) => setState(() {
            _type = selection.first;
            _category = null;
            _isRecurring = false;
          }),
        ),
        const SizedBox(height: 26),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(
                _type == TransactionType.income ? 'Income name' : 'Description',
              ),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: 45,
                decoration: InputDecoration(
                  hintText: _type == TransactionType.income
                      ? 'e.g. Allowance'
                      : 'e.g. Lunch with friends',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name.';
                  }
                  if (value.trim().length < 2) {
                    return 'Use at least 2 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 19),
              _fieldLabel('Amount'),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '\u20B1  ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an amount.';
                  }
                  if (amount == null || !amount.isFinite) {
                    return 'Enter a valid amount.';
                  }
                  if (amount <= 0) return 'Amount must be greater than zero.';
                  return null;
                },
              ),
              const SizedBox(height: 19),
              _fieldLabel('Category'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Choose a category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final category in ExpenseCategory.forType(_type))
                    DropdownMenuItem(
                      value: category.name,
                      child: Row(
                        children: [
                          Icon(category.icon, size: 19, color: category.color),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Choose a category.' : null,
              ),
              const SizedBox(height: 19),
              _fieldLabel('Payment method'),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                  DropdownMenuItem(
                    value: 'Bank transfer',
                    child: Text('Bank transfer'),
                  ),
                  DropdownMenuItem(
                    value: 'Card',
                    child: Text('Debit / credit card'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _paymentMethod = value);
                },
              ),
              const SizedBox(height: 19),
              _fieldLabel('Date'),
              Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: _chooseDate,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 19,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _prettyDate(_date),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 19),
              _fieldLabel('Notes (optional)'),
              TextField(
                controller: _notesController,
                maxLines: 2,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintText: 'Add a note',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              if (_type == TransactionType.expense)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value),
                  title: const Text('Recurring monthly'),
                  subtitle: const Text('Mark regular bills and subscriptions.'),
                  secondary: const Icon(Icons.repeat_rounded),
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Your entries are kept in memory for this app session.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}
