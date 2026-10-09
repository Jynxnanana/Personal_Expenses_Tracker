// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:convert';

const _storageKey = 'chcci_expense_mate_data_v1';

Future<Map<String, Object?>?> loadSavedData() async {
  try {
    final saved = html.window.localStorage[_storageKey];
    if (saved == null) return null;
    final decoded = jsonDecode(saved);
    return decoded is Map<String, Object?> ? decoded : null;
  } on Object {
    return null;
  }
}

Future<void> saveData(Map<String, Object?> data) async {
  try {
    html.window.localStorage[_storageKey] = jsonEncode(data);
  } on Object {
    // Keep the app usable if browser storage is unavailable.
  }
}
