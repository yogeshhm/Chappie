import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../models/call_log_model.dart';
import '../models/pitch_template_model.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class LeadProvider extends ChangeNotifier {
  final StorageService storageService;
  final SupabaseService supabaseService;

  List<LeadModel> _leads = [];
  List<CallLogModel> _callLogs = [];
  List<PitchTemplateModel> _pitchTemplates = [];

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _syncStatusMessage;

  // Filter States
  String _searchQuery = '';
  String _selectedCallStatus = 'All';
  String _selectedPriority = 'All';
  bool _filterOnlyWithPhone = false;
  bool _filterOnlyUnverified = false;
  bool _filterOnlyFollowUpsDue = false;

  LeadProvider({
    required this.storageService,
    required this.supabaseService,
  }) {
    _initializeData();
  }

  // Getters
  List<LeadModel> get allLeads => _leads;
  List<CallLogModel> get allCallLogs => _callLogs;
  List<PitchTemplateModel> get pitchTemplates => _pitchTemplates;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get syncStatusMessage => _syncStatusMessage;

  String get searchQuery => _searchQuery;
  String get selectedCallStatus => _selectedCallStatus;
  String get selectedPriority => _selectedPriority;
  bool get filterOnlyWithPhone => _filterOnlyWithPhone;
  bool get filterOnlyUnverified => _filterOnlyUnverified;
  bool get filterOnlyFollowUpsDue => _filterOnlyFollowUpsDue;

  void _initializeData() {
    _isLoading = true;
    notifyListeners();

    _leads = storageService.loadLeads();
    _callLogs = storageService.loadCallLogs();
    _pitchTemplates = storageService.loadPitchTemplates();

    _isLoading = false;
    notifyListeners();

    // Attempt auto-connect to Supabase if credentials exist
    final savedUrl = storageService.getSupabaseUrl();
    final savedKey = storageService.getSupabaseAnonKey();
    if (savedKey.isNotEmpty) {
      configureSupabase(savedUrl, savedKey, autoSync: true);
    }
  }

  // Filtered Leads calculation
  List<LeadModel> get filteredLeads {
    return _leads.where((lead) {
      // Search match
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = lead.businessName.toLowerCase().contains(query);
        final matchesServices = lead.services.toLowerCase().contains(query);
        final matchesLocation = lead.location.toLowerCase().contains(query);
        final matchesPhone = lead.phoneNumbers.contains(query);
        final matchesHandle = lead.instagramUsername.toLowerCase().contains(query);

        if (!matchesName &&
            !matchesServices &&
            !matchesLocation &&
            !matchesPhone &&
            !matchesHandle) {
          return false;
        }
      }

      // Status filter
      if (_selectedCallStatus != 'All' && lead.callStatus != _selectedCallStatus) {
        return false;
      }

      // Priority filter
      if (_selectedPriority != 'All' && lead.leadPriority != _selectedPriority) {
        return false;
      }

      // Only with phone
      if (_filterOnlyWithPhone && !lead.hasPhone) {
        return false;
      }

      // Only unverified nested data
      if (_filterOnlyUnverified && lead.isNestedDataVerified) {
        return false;
      }

      // Only follow-ups due
      if (_filterOnlyFollowUpsDue && !lead.isFollowUpDue) {
        return false;
      }

      return true;
    }).toList();
  }

  List<LeadModel> leadsByStatus(String status) {
    return _leads.where((l) => l.callStatus.toLowerCase() == status.toLowerCase()).toList();
  }

  List<CallLogModel> logsForLead(String leadId) {
    return _callLogs.where((log) => log.leadId == leadId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Metrics
  int get totalCount => _leads.length;
  int get calledCount => _leads.where((l) => l.callStatus != 'Not Called').length;
  int get interestedCount => _leads.where((l) => l.callStatus == 'Interested').length;
  int get highPriorityCount => _leads.where((l) => l.leadPriority == 'High').length;
  int get followUpsDueCount => _leads.where((l) => l.isFollowUpDue).length;
  int get unverifiedCount => _leads.where((l) => !l.isNestedDataVerified).length;

  double get conversionRate {
    if (calledCount == 0) return 0.0;
    return (interestedCount / calledCount) * 100;
  }

  // Filter modifiers
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCallStatusFilter(String status) {
    _selectedCallStatus = status;
    notifyListeners();
  }

  void setPriorityFilter(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void toggleOnlyWithPhone() {
    _filterOnlyWithPhone = !_filterOnlyWithPhone;
    notifyListeners();
  }

  void toggleOnlyUnverified() {
    _filterOnlyUnverified = !_filterOnlyUnverified;
    notifyListeners();
  }

  void toggleOnlyFollowUpsDue() {
    _filterOnlyFollowUpsDue = !_filterOnlyFollowUpsDue;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCallStatus = 'All';
    _selectedPriority = 'All';
    _filterOnlyWithPhone = false;
    _filterOnlyUnverified = false;
    _filterOnlyFollowUpsDue = false;
    notifyListeners();
  }

  // Lead Actions
  Future<void> updateLead(LeadModel updated) async {
    final index = _leads.indexWhere((l) => l.id == updated.id);
    if (index != -1) {
      _leads[index] = updated;
      await storageService.saveLeads(_leads);
      notifyListeners();

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updated);
      }
    }
  }

  Future<void> updateLeadStatus(String leadId, String newStatus) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final updated = _leads[index].copyWith(
        callStatus: newStatus,
        lastCallDate: DateTime.now(),
      );
      _leads[index] = updated;
      await storageService.saveLeads(_leads);
      notifyListeners();

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updated);
      }
    }
  }

  /// Automatically record that a call was placed to this lead without popping any dialogs
  Future<void> recordCallAttempt(String leadId) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final current = _leads[index];
      final updated = current.copyWith(
        lastCallDate: DateTime.now(),
        callStatus: current.callStatus == 'Not Called' ? 'Called - In Progress' : current.callStatus,
      );
      _leads[index] = updated;
      await storageService.saveLeads(_leads);
      notifyListeners();

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updated);
      }
    }
  }

  Future<void> toggleNestedDataVerified(String leadId) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final current = _leads[index];
      final updated = current.copyWith(
        isNestedDataVerified: !current.isNestedDataVerified,
      );
      _leads[index] = updated;
      await storageService.saveLeads(_leads);
      notifyListeners();

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updated);
      }
    }
  }

  Future<void> addLead(LeadModel lead) async {
    _leads.insert(0, lead);
    await storageService.saveLeads(_leads);
    notifyListeners();

    if (supabaseService.isConfigured) {
      await supabaseService.upsertLead(lead);
    }
  }

  Future<void> deleteLead(String leadId) async {
    _leads.removeWhere((l) => l.id == leadId);
    _callLogs.removeWhere((log) => log.leadId == leadId);
    await storageService.saveLeads(_leads);
    await storageService.saveCallLogs(_callLogs);
    notifyListeners();
  }

  /// Log an Outreach Call / Interaction
  Future<void> logCall({
    required String leadId,
    required String outcome,
    String notes = '',
    DateTime? nextFollowUpDate,
    int durationSeconds = 0,
    String pitchedOffering = 'Custom Web Development',
  }) async {
    final callLog = CallLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      leadId: leadId,
      outcome: outcome,
      notes: notes,
      nextFollowUpDate: nextFollowUpDate,
      durationSeconds: durationSeconds,
      pitchedOffering: pitchedOffering,
      createdAt: DateTime.now(),
    );

    _callLogs.insert(0, callLog);
    await storageService.saveCallLogs(_callLogs);

    // Map call outcome directly to lead status
    String newLeadStatus;
    if (outcome.contains('Interested')) {
      newLeadStatus = 'Interested';
    } else if (outcome.contains('Follow-up') || nextFollowUpDate != null) {
      newLeadStatus = 'Follow-up Scheduled';
    } else if (outcome.contains('No Answer')) {
      newLeadStatus = 'Called - No Answer';
    } else if (outcome.contains('Not Interested')) {
      newLeadStatus = 'Not Interested';
    } else if (outcome.contains('Won') || outcome.contains('Closed')) {
      newLeadStatus = 'Closed Won';
    } else if (outcome.contains('Invalid') || outcome.contains('Wrong Number')) {
      newLeadStatus = 'Invalid Number';
    } else {
      newLeadStatus = 'Connected';
    }

    final leadIndex = _leads.indexWhere((l) => l.id == leadId);
    if (leadIndex != -1) {
      final currentLead = _leads[leadIndex];
      final updatedLead = currentLead.copyWith(
        callStatus: newLeadStatus,
        lastCallDate: DateTime.now(),
        nextFollowUpDate: nextFollowUpDate ?? currentLead.nextFollowUpDate,
        notes: notes.isNotEmpty ? '${currentLead.notes}\n[${DateTime.now().toLocal()}]: $notes'.trim() : currentLead.notes,
      );
      _leads[leadIndex] = updatedLead;
      await storageService.saveLeads(_leads);

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updatedLead);
        await supabaseService.insertCallLog(callLog);
      }
    }

    notifyListeners();
  }

  // Pitch template update
  Future<void> updatePitchTemplate(PitchTemplateModel template) async {
    final index = _pitchTemplates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _pitchTemplates[index] = template;
    } else {
      _pitchTemplates.add(template);
    }
    await storageService.savePitchTemplates(_pitchTemplates);
    notifyListeners();
  }

  // Supabase Configuration & Sync
  Future<bool> configureSupabase(String url, String anonKey, {bool autoSync = false}) async {
    final success = await supabaseService.initialize(url, anonKey);
    if (success) {
      await storageService.setSupabaseUrl(url);
      await storageService.setSupabaseAnonKey(anonKey);
      if (autoSync) {
        await syncWithSupabase();
      }
    }
    notifyListeners();
    return success;
  }

  Future<void> syncWithSupabase() async {
    if (!supabaseService.isConfigured) return;

    _isSyncing = true;
    _syncStatusMessage = 'Syncing leads with Supabase...';
    notifyListeners();

    try {
      // 1. Push local leads to Supabase
      await supabaseService.batchUpsertLeads(_leads);

      // 2. Fetch latest leads from Supabase
      final remoteLeads = await supabaseService.fetchLeads();
      if (remoteLeads != null && remoteLeads.isNotEmpty) {
        _leads = remoteLeads;
        await storageService.saveLeads(_leads);
      }

      _syncStatusMessage = 'Sync complete! Cloud and local databases in sync.';
    } catch (e) {
      _syncStatusMessage = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> resetToInitialState() async {
    _isLoading = true;
    notifyListeners();

    await storageService.resetAll();
    _leads = storageService.loadLeads();
    _callLogs = storageService.loadCallLogs();
    _pitchTemplates = storageService.loadPitchTemplates();

    _isLoading = false;
    notifyListeners();
  }
}
