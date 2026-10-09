import 'dart:convert';
import 'dart:io';

const _fileName = 'expensemate_data.json';

File get _dataFile {
  if (Platform.isAndroid) {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      return File('$home/files/$_fileName');
    }
    return File(
      '/data/user/0/ph.edu.chcci.chcci_expense_mate/files/$_fileName',
    );
  }
  return File('${Directory.current.path}/$_fileName');
}

Future<Map<String, Object?>?> loadSavedData() async {
  try {
    final file = _dataFile;
    if (!await file.exists()) return null;
    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map<String, Object?> ? decoded : null;
  } on Object {
    return null;
  }
}

Future<void> saveData(Map<String, Object?> data) async {
  try {
    final file = _dataFile;
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data), flush: true);
  } on Object {
    // Keep the app usable if local storage is unavailable.
  }
}
