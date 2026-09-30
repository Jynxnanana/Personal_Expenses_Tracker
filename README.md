# CHCCI ExpenseMate

## Project description

CHCCI ExpenseMate is a Flutter personal finance tracker for the CSE101 final project. Users can record income and expenses, manage a monthly budget and savings goals, and review searchable transaction history and spending reports.

Expense records are held in a Dart `List` in memory only. The app starts empty, uses no database, and clears all entries when it closes.

## Features

- Record income and expenses with amount, category, date, payment method, and optional notes.
- Review current balance, income, expenses, and monthly budget progress on the dashboard.
- Search and filter transaction history by type, category, date, and text.
- Edit or delete transactions.
- View monthly income, spending, savings, highest and lowest categories, a pie chart, and a seven-day spending chart.
- Create savings goals and record contributions.
- Mark regular expenses as recurring and manually add a monthly occurrence.
- Navigate between the dashboard, transaction form, history, summary, savings goals, and settings.
- Responsive phone and wide-screen layouts; System, Light, and Dark appearance options.
- All records stay in runtime memory and clear when the app closes. No database or extra package is used.
- Philippine peso amounts and locally bundled artwork.

## Screenshots

Capture the Home, Add Transaction, Summary, and wide-screen views from the running app for the final screenshot set.

## Run and build

```powershell
flutter pub get
flutter run
flutter test
flutter build apk --release
```

The Android APK is generated at `build/app/outputs/flutter-apk/app-release.apk` when an Android SDK is installed and configured.

## Demo flow

Open Home, add an expense, and confirm that the totals update. Use the three-dot menu on an expense to edit or delete it. Open the chart icon to review the Summary.
