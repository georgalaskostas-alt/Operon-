import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'local_repository.dart';
import '../models/operator_timer.dart';

class TimerRepository {
  static const key = 'operon.timers.v1';
  static const _migrationKey = 'operon.timers.sqlite.migrated';
  final LocalRepository _repository;

  TimerRepository({LocalRepository? repository})
      : _repository = repository ?? LocalRepository();

  Future<Database> _database() => _repository.database();

  Future<List<OperatorTimer>> load() async {
    final db = await _database();
    final rows = await db.query('operator_timers', orderBy: 'updated_at DESC');
    if (rows.isNotEmpty) {
      return rows
          .map((row) => OperatorTimer.fromJson(
              Map<String, dynamic>.from(jsonDecode(row['json'] as String))))
          .toList();
    }
    return _migrateLegacy(db);
  }

  Future<List<OperatorTimer>> _migrateLegacy(Database db) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) ?? false) return [];

    final raw = prefs.getString(key);
    if (raw == null) {
      await prefs.setBool(_migrationKey, true);
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    final items = decoded
        .map((e) => OperatorTimer.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    await save(items);
    await prefs.setBool(_migrationKey, true);
    return items;
  }

  Future<void> save(List<OperatorTimer> items) async {
    final db = await _database();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      final ids = items.map((e) => e.id).toList();
      if (ids.isEmpty) {
        await txn.delete('operator_timers');
      } else {
        final placeholders = List.filled(ids.length, '?').join(',');
        await txn.delete(
          'operator_timers',
          where: 'id NOT IN ($placeholders)',
          whereArgs: ids,
        );
      }
      for (final item in items) {
        await txn.insert(
          'operator_timers',
          {
            'id': item.id,
            'json': jsonEncode(item.toJson()),
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> clear() async {
    final db = await _database();
    await db.delete('operator_timers');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await prefs.setBool(_migrationKey, true);
  }
}
