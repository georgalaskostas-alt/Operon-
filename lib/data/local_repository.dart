import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalRepository {
  static const _key='operon.snapshot.v1';
  Future<Map<String,dynamic>?> load() async {
    final prefs=await SharedPreferences.getInstance();
    final raw=prefs.getString(_key);
    if(raw==null)return null;
    final value=jsonDecode(raw);
    return value is Map<String,dynamic>?value:null;
  }
  Future<void> save(Map<String,dynamic> snapshot) async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString(_key,jsonEncode(snapshot));
  }
  Future<void> clear() async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
