import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lead_model.dart';
import '../models/call_log_model.dart';

class SupabaseService {
  bool _isInitialized = false;
  SupabaseClient? _client;

  bool get isConfigured => _isInitialized && _client != null;
  SupabaseClient? get client => _client;

  /// Initialize Supabase with the provided URL and anon key
  Future<bool> initialize(String url, String anonKey) async {
    if (url.trim().isEmpty || anonKey.trim().isEmpty) {
      _isInitialized = false;
      _client = null;
      return false;
    }

    try {
      if (Supabase.instance.isInitialized) {
        _client = Supabase.instance.client;
        _isInitialized = true;
        return true;
      }

      await Supabase.initialize(
        url: url.trim(),
        // ignore: deprecated_member_use
        anonKey: anonKey.trim(),
        debug: kDebugMode,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Supabase init error: $e');
      _isInitialized = false;
      _client = null;
      return false;
    }
  }

  /// Test connection by querying count of leads
  Future<({bool success, String message, int count})> testConnection() async {
    if (!isConfigured) {
      return (
        success: false,
        message: 'Supabase client is not initialized. Please provide a valid Anon Key.',
        count: 0
      );
    }

    try {
      final response = await _client!.from('leads').select('id');
      final list = response as List;
      return (
        success: true,
        message: 'Connected to Supabase successfully! Found ${list.length} leads in cloud database.',
        count: list.length
      );
    } catch (e) {
      return (
        success: false,
        message: 'Failed to query Supabase: $e\nTip: Make sure you ran `supabase_schema.sql` in Supabase SQL Editor.',
        count: 0
      );
    }
  }

  /// Fetch all leads from Supabase
  Future<List<LeadModel>?> fetchLeads() async {
    if (!isConfigured) return null;
    try {
      final response = await _client!.from('leads').select().order('created_at', ascending: true);
      final List<dynamic> data = response;
      return data.map((item) => LeadModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching leads from Supabase: $e');
      return null;
    }
  }

  /// Upsert a single lead to Supabase
  Future<bool> upsertLead(LeadModel lead) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('leads').upsert(lead.toMap());
      return true;
    } catch (e) {
      debugPrint('Error upserting lead to Supabase: $e');
      return false;
    }
  }

  /// Upsert a list of leads (batch sync)
  Future<bool> batchUpsertLeads(List<LeadModel> leads) async {
    if (!isConfigured || leads.isEmpty) return false;
    try {
      final payload = leads.map((l) => l.toMap()).toList();
      await _client!.from('leads').upsert(payload);
      return true;
    } catch (e) {
      debugPrint('Error batch syncing leads: $e');
      return false;
    }
  }

  /// Log an interaction / call in Supabase
  Future<bool> insertCallLog(CallLogModel log) async {
    if (!isConfigured) return false;
    try {
      await _client!.from('call_logs').insert(log.toMap());
      return true;
    } catch (e) {
      debugPrint('Error inserting call log in Supabase: $e');
      return false;
    }
  }

  /// Fetch call logs for a lead
  Future<List<CallLogModel>?> fetchCallLogs(String leadId) async {
    if (!isConfigured) return null;
    try {
      final response = await _client!
          .from('call_logs')
          .select()
          .eq('lead_id', leadId)
          .order('created_at', ascending: false);
      final List<dynamic> data = response;
      return data.map((item) => CallLogModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error fetching call logs: $e');
      return null;
    }
  }
}
