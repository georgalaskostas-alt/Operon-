import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LocalRepository{
 static const _legacyKey='operon.snapshot.v1';
 static const _dbName='operon.db';
 static const _schemaVersion=1;
 Database? _db;
 Future<Database> _database()async{if(_db!=null)return _db!;final root=await getDatabasesPath();_db=await openDatabase(p.join(root,_dbName),version:_schemaVersion,onConfigure:(db)async{await db.execute('PRAGMA foreign_keys = ON');},onCreate:(db,version)async{await db.execute('CREATE TABLE app_state (key TEXT PRIMARY KEY, json TEXT NOT NULL, updated_at TEXT NOT NULL)');await db.execute('CREATE TABLE audit_events (id TEXT PRIMARY KEY, type TEXT NOT NULL, summary TEXT NOT NULL, source TEXT NOT NULL, created_at TEXT NOT NULL, equipment_tag TEXT, shift_id TEXT, entity_id TEXT, json TEXT NOT NULL)');await db.execute('CREATE INDEX idx_audit_created ON audit_events(created_at DESC)');await db.execute('CREATE INDEX idx_audit_tag ON audit_events(equipment_tag,created_at DESC)');});return _db!;}
 Future<Map<String,dynamic>?> load()async{final db=await _database();final rows=await db.query('app_state',where:'key=?',whereArgs:['snapshot'],limit:1);if(rows.isNotEmpty){final value=jsonDecode(rows.first['json'] as String);return value is Map<String,dynamic>?value:null;}return _migrateLegacy(db);}
 Future<Map<String,dynamic>?> _migrateLegacy(Database db)async{final prefs=await SharedPreferences.getInstance(),raw=prefs.getString(_legacyKey);if(raw==null)return null;final decoded=jsonDecode(raw);if(decoded is! Map<String,dynamic>)return null;await save(decoded);await prefs.setBool('operon.sqlite.migrated',true);return decoded;}
 Future<void> save(Map<String,dynamic> snapshot)async{final db=await _database(),now=DateTime.now().toIso8601String();await db.transaction((txn)async{await txn.insert('app_state',{'key':'snapshot','json':jsonEncode(snapshot),'updated_at':now},conflictAlgorithm:ConflictAlgorithm.replace);final events=(snapshot['auditEvents'] as List?)??const[];for(final raw in events){final e=Map<String,dynamic>.from(raw as Map);final id=e['id']?.toString();if(id==null||id.isEmpty)continue;await txn.insert('audit_events',{'id':id,'type':e['type']??'','summary':e['summary']??'','source':e['source']??'app','created_at':e['createdAt']??now,'equipment_tag':e['equipmentTag'],'shift_id':e['shiftId'],'entity_id':e['entityId'],'json':jsonEncode(e)},conflictAlgorithm:ConflictAlgorithm.ignore);}});}
 Future<void> clear()async{final db=await _database();await db.transaction((txn)async{await txn.delete('audit_events');await txn.delete('app_state');});}
 Future<List<Map<String,dynamic>>> audit({String? tag,int limit=200})async{final db=await _database();final rows=await db.query('audit_events',where:tag==null?null:'equipment_tag=?',whereArgs:tag==null?null:[tag],orderBy:'created_at DESC',limit:limit);return rows.map((r)=>Map<String,dynamic>.from(jsonDecode(r['json'] as String) as Map)).toList();}
}
