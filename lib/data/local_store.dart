import 'local_store_stub.dart'
    if (dart.library.io) 'local_store_io.dart'
    if (dart.library.html) 'local_store_web.dart'
    as platform;

Future<Map<String, Object?>?> loadSavedData() => platform.loadSavedData();

Future<void> saveData(Map<String, Object?> data) => platform.saveData(data);
