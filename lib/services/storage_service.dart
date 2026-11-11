import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lead_model.dart';
import '../models/call_log_model.dart';
import '../models/pitch_template_model.dart';
import '../data/initial_leads.dart';

class StorageService {
  static const String _keyLeads = 'falcon_leads_v1';
  static const String _keyLogs = 'falcon_call_logs_v1';
  static const String _keyTemplates = 'falcon_templates_v1';
  static const String _keySupabaseUrl = 'falcon_supabase_url';
  static const String _keySupabaseAnonKey = 'falcon_supabase_anon_key';

  static const String defaultSupabaseUrl = 'https://avoioogdnbyivinkamup.supabase.co';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Leads ---
  List<LeadModel> loadLeads() {
    final raw = _prefs.getString(_keyLeads);
    if (raw == null || raw.isEmpty) {
      // Seed with initial leads from the provided sheet
      saveLeads(initialFalconateLeads);
      return List.from(initialFalconateLeads);
    }
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((item) => LeadModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return List.from(initialFalconateLeads);
    }
  }

  Future<void> saveLeads(List<LeadModel> leads) async {
    final raw = json.encode(leads.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyLeads, raw);
  }

  // --- Call Logs ---
  List<CallLogModel> loadCallLogs() {
    final raw = _prefs.getString(_keyLogs);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((item) => CallLogModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCallLogs(List<CallLogModel> logs) async {
    final raw = json.encode(logs.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyLogs, raw);
  }

  // --- Pitch Templates ---
  List<PitchTemplateModel> loadPitchTemplates() {
    final raw = _prefs.getString(_keyTemplates);
    if (raw == null || raw.isEmpty) {
      savePitchTemplates(initialFalconatePitchTemplates);
      return List.from(initialFalconatePitchTemplates);
    }
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((item) => PitchTemplateModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return List.from(initialFalconatePitchTemplates);
    }
  }

  Future<void> savePitchTemplates(List<PitchTemplateModel> templates) async {
    final raw = json.encode(templates.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyTemplates, raw);
  }

  // --- Supabase Config ---
  String getSupabaseUrl() {
    return _prefs.getString(_keySupabaseUrl) ?? defaultSupabaseUrl;
  }

  Future<void> setSupabaseUrl(String url) async {
    await _prefs.setString(_keySupabaseUrl, url.trim());
  }

  String getSupabaseAnonKey() {
    return _prefs.getString(_keySupabaseAnonKey) ?? '';
  }

  Future<void> setSupabaseAnonKey(String key) async {
    await _prefs.setString(_keySupabaseAnonKey, key.trim());
  }

  // --- Reset to Clean Initial State ---
  Future<void> resetAll() async {
    await _prefs.remove(_keyLeads);
    await _prefs.remove(_keyLogs);
    await _prefs.remove(_keyTemplates);
    await saveLeads(initialFalconateLeads);
    await savePitchTemplates(initialFalconatePitchTemplates);
  }
}
