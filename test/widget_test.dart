import 'package:chcci_expense_mate/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home starts empty and presents the expense dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();

    expect(find.text('CHCCI'), findsOneWidget);
    expect(find.text('Your money, in view.'), findsOneWidget);
    expect(find.text('Spending categories'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -720));
    await tester.pumpAndSettle();
    expect(find.text('Your expenses'), findsOneWidget);
    expect(
      find.text('No expenses yet. Add one to get started.'),
      findsOneWidget,
    );
  });

  testWidgets('required fields show validation messages', (tester) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an expense name.'), findsOneWidget);
    expect(find.text('Enter an amount.'), findsOneWidget);
    expect(find.text('Choose an expense category.'), findsOneWidget);
  });

  testWidgets('create, read, update, and delete expenses in this session', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    final categoryField = find.byType(DropdownButtonFormField<String>);
    tester.state<FormFieldState<String>>(categoryField).didChange('Shopping');
    await tester.enterText(find.byType(TextFormField).at(0), 'School supplies');
    await tester.enterText(find.byType(TextFormField).at(1), '245.50');
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -720));
    await tester.pumpAndSettle();
    expect(find.text('School supplies'), findsOneWidget);
    expect(find.text('−₱245.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Expense actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit expense'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '300.25');
    await tester.tap(find.text('Update expense'));
    await tester.pumpAndSettle();
    expect(find.text('School supplies'), findsOneWidget);
    expect(find.text('−₱300.25'), findsOneWidget);

    await tester.tap(find.byTooltip('Expense actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete expense?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('School supplies'), findsNothing);
    expect(
      find.text('No expenses yet. Add one to get started.'),
      findsOneWidget,
    );
  });

  testWidgets('summary navigation reflects the empty session', (tester) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('View spending summary'));
    await tester.pumpAndSettle();

    expect(find.text('Spending summary'), findsOneWidget);
    expect(find.text('₱0'), findsOneWidget);
    expect(find.text('By category'), findsOneWidget);
    expect(find.text('This month’s activity'), findsOneWidget);
    expect(find.text('No expenses recorded this month yet.'), findsOneWidget);
  });

  testWidgets('dashboard fits phone and wide screen widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    expect(find.text('Spending categories'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    expect(find.text('Spending categories'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('add expense form remains visible on a short screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(714, 309));
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();

    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Where did it go?'), findsOneWidget);
    expect(find.text('Expense name'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
