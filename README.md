# CHCCI ExpenseMate

## Project description

CHCCI ExpenseMate is a Flutter personal finance tracker for the CSE101 final project. Users can record income and expenses, manage a monthly budget and savings goals, and review searchable transaction history and spending reports.

Expense records are edited in Dart `List` objects and saved locally as JSON when the app changes. Android uses an app-private file; Flutter Web uses browser local storage. The app uses no database and sends no records to a server.

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
- Transactions, monthly budget, savings goals, and appearance are saved locally and restored after reopening. No database or extra package is used.
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

For Flutter Web, use the same port each time so the browser reopens the same local storage:

```powershell
flutter run -d edge --web-port 54168
```

The Android APK is generated at `build/app/outputs/flutter-apk/app-release.apk` when an Android SDK is installed and configured.

## Download the Android APK

The [latest Android APK workflow](https://github.com/Jynxnanana/Personal_Expenses_Tracker/actions/workflows/build-android-apk.yml) creates a release APK when changes are pushed to `main`. Open the newest successful run and download the `CHCCI-ExpenseMate-Android-APK` artifact. Extract the ZIP and install the APK on your Android phone. GitHub keeps workflow artifacts for 14 days.

## Demo flow

Open Home, add an expense, and confirm that the totals update. Use the three-dot menu on an expense to edit or delete it. Open the chart icon to review the Summary.
