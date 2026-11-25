/// Native SQLite factories and the shared database/settings/photo directory.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

/// Retain the established database directory on the original native platforms.
Future<String> nativeDataDirectory() async {
  if (Platform.isWindows) {
    final String? path = await PathProviderWindows()
        .getApplicationSupportPath();
    if (path == null) {
      throw StateError('Windows application support directory is unavailable.');
    }
    final Directory directory = Directory(path);
    await directory.create(recursive: true);
    return directory.path;
  }
  return getDatabasesPath();
}

Future<({DatabaseFactory factory, String path})> platformDatabase() async {
  final String basePath = await nativeDataDirectory();
  if (Platform.isWindows) {
    sqfliteFfiInit();
  }
  final DatabaseFactory factory = Platform.isWindows
      ? databaseFactoryFfi
      : databaseFactory;
  return (factory: factory, path: p.join(basePath, 'pet_health_tracker.db'));
}

/// Directory holding `settings.json` and `pet_photos/`.
String platformDataDirectory(String databasePath) => p.dirname(databasePath);
