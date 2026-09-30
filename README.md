# CHCCI ExpenseMate

## Project description

CHCCI ExpenseMate is a Flutter personal expense tracker for the CSE101 final project. Users can add, view, edit, and delete daily expenses, then review current-month and weekly totals.

Expense records are held in a Dart `List` in memory only. The app starts empty, uses no database, and clears all entries when it closes.

## Features

- Empty first launch with live monthly and weekly spending totals.
- Create expenses with a name, positive amount, category, and date.
- Read all current-month expenses in Home and Summary.
- Edit existing expense details.
- Delete an expense after confirmation.
- Category totals, category budgets, and a seven-day spending chart.
- Navigation and responsive phone and wide-screen layouts.
- Philippine peso amounts and locally bundled artwork.

## Screenshots

The empty-start Home screenshot is in `screenshots/home.png`. Capture the New Expense, Summary, and wide-screen views from the running app for the final screenshot set.

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
