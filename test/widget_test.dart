import 'package:chcci_expense_mate/main.dart';
import 'package:chcci_expense_mate/screens/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openExpenseForm(WidgetTester tester) async {
  await tester.tap(find.text('Add transaction'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add expense'));
  await tester.pumpAndSettle();
}

Future<void> scrollHomeUntilVisible(WidgetTester tester, Finder target) async {
  final homeList = find.byType(ListView).first;
  final screenHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  for (var attempt = 0; attempt < 8; attempt++) {
    final matches = target.evaluate().toList();
    if (matches.isNotEmpty) {
      final rect = tester.getRect(target.first);
      if (rect.top >= 0 && rect.bottom <= screenHeight) return;
    }
    await tester.drag(homeList, const Offset(0, -350));
    await tester.pumpAndSettle();
  }
}

Future<void> scrollFormUntilVisible(WidgetTester tester, Finder target) async {
  final formList = find.byType(ListView).last;
  for (var attempt = 0; attempt < 4; attempt++) {
    final rect = tester.getRect(target);
    final screenHeight = tester.view.physicalSize.height /
        tester.view.devicePixelRatio;
    if (rect.top >= 0 && rect.bottom <= screenHeight) return;
    await tester.drag(formList, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

Finder inHistory(Finder target) => find.descendant(
  of: find.byType(TransactionHistoryScreen),
  matching: target,
);

Future<void> scrollHistoryUntilVisible(
  WidgetTester tester,
  Finder target,
) async {
  final historyList = find.descendant(
    of: find.byType(TransactionHistoryScreen),
    matching: find.byType(ListView),
  );
  final scopedTarget = inHistory(target);
  final screenHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;
  for (var attempt = 0; attempt < 6; attempt++) {
    final matches = scopedTarget.evaluate().toList();
    if (matches.isNotEmpty) {
      final rect = tester.getRect(scopedTarget.first);
      if (rect.top >= 0 && rect.bottom <= screenHeight) return;
    }
    await tester.drag(historyList, const Offset(0, -300));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('home starts empty and presents the expense dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();

    expect(find.text('CHCCI'), findsOneWidget);
    expect(find.text('Your money, in view.'), findsOneWidget);
    await scrollHomeUntilVisible(tester, find.text('Spending categories'));
    expect(find.text('Spending categories'), findsOneWidget);
    await scrollHomeUntilVisible(tester, find.text('Recent transactions'));
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(
      find.text('No transactions yet. Add income or an expense.'),
      findsOneWidget,
    );
  });

  testWidgets('required fields show validation messages', (tester) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await openExpenseForm(tester);

    await scrollFormUntilVisible(tester, find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
    expect(find.text('Enter an amount.'), findsOneWidget);
    expect(find.text('Choose a category.'), findsOneWidget);
  });

  testWidgets('create, read, update, and delete expenses in this session', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await openExpenseForm(tester);

    final categoryField = find.byType(DropdownButtonFormField<String>).first;
    tester.state<FormFieldState<String>>(categoryField).didChange('Shopping');
    await tester.enterText(find.byType(TextFormField).at(0), 'School supplies');
    await tester.enterText(find.byType(TextFormField).at(1), '245.50');
    await scrollFormUntilVisible(tester, find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Transaction history'), findsOneWidget);
    await scrollHistoryUntilVisible(tester, find.text('School supplies'));
    expect(inHistory(find.text('School supplies')), findsOneWidget);

    await tester.tap(inHistory(find.byTooltip('Expense actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit transaction'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '300.25');
    await scrollFormUntilVisible(tester, find.text('Update transaction'));
    await tester.tap(find.text('Update transaction'));
    await tester.pumpAndSettle();

    await scrollHistoryUntilVisible(tester, find.text('School supplies'));
    expect(inHistory(find.text('School supplies')), findsOneWidget);
    await tester.tap(inHistory(find.byTooltip('Expense actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete transaction?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();

    expect(inHistory(find.text('School supplies')), findsNothing);
    expect(
      inHistory(find.text('No transactions match these filters.')),
      findsOneWidget,
    );
  });

  testWidgets('summary navigation shows the empty session report', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('View spending summary'));
    await tester.pumpAndSettle();

    expect(find.text('Spending summary'), findsOneWidget);
    expect(find.text('Monthly report'), findsOneWidget);
    expect(find.text('By category'), findsOneWidget);
    expect(find.textContaining('activity'), findsOneWidget);
    expect(find.text('No expenses recorded this month yet.'), findsOneWidget);
  });

  testWidgets('dashboard fits phone and wide screen widths', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    expect(find.text('Your money, in view.'), findsOneWidget);
    await scrollHomeUntilVisible(tester, find.text('Spending categories'));
    expect(find.text('Spending categories'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    expect(find.text('Your money, in view.'), findsOneWidget);
    await scrollHomeUntilVisible(tester, find.text('Spending categories'));
    expect(find.text('Spending categories'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('expense form remains usable on a short screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(714, 309));
    await tester.pumpWidget(const ExpenseMateApp());
    await tester.pumpAndSettle();
    await openExpenseForm(tester);

    expect(find.text('Add expense'), findsOneWidget);
    expect(find.text('Where did it go?'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
