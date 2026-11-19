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
  int get outreachCount => _leads.where((l) => l.callStatus == 'Outreach').length;
  int get interestedCount => _leads.where((l) => l.callStatus == 'Interested').length;
  int get demoCount => _leads.where((l) => l.callStatus == 'Demo').length;
  int get dealCount => _leads.where((l) => l.callStatus == 'Deal').length;
  int get junkCount => _leads.where((l) => l.callStatus == 'Junk').length;
  int get lostCount => _leads.where((l) => l.callStatus == 'Lost').length;
  int get calledCount => _leads.where((l) => l.callStatus != 'Outreach').length;
  int get highPriorityCount => _leads.where((l) => l.leadPriority == 'High').length;
  int get followUpsDueCount => _leads.where((l) => l.isFollowUpDue).length;
  int get unverifiedCount => _leads.where((l) => !l.isNestedDataVerified).length;

  double get conversionRate {
    if (calledCount == 0) return 0.0;
    return (dealCount / (totalCount == 0 ? 1 : totalCount)) * 100;
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

  Future<void> updateLeadStatus(String leadId, String newStatus, {String? lostReason}) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final current = _leads[index];
      final normStatus = LeadModel.normalizeStatus(newStatus);
      final updated = current.copyWith(
        callStatus: normStatus,
        lostReason: normStatus == 'Lost' ? (lostReason ?? current.lostReason) : '',
        lastCallDate: DateTime.now(),
        updatedBy: 'Yogesh',
      );
      _leads[index] = updated;
      await storageService.saveLeads(_leads);

      // Cadence user logging: Record activity log
      final log = CallLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: leadId,
        outcome: normStatus,
        notes: normStatus == 'Lost' && (lostReason != null && lostReason.isNotEmpty)
            ? 'Lost: $lostReason (logged by Yogesh)'
            : 'Status updated to $normStatus (by Yogesh)',
        loggedBy: 'Yogesh',
      );
      _callLogs.insert(0, log);
      await storageService.saveCallLogs(_callLogs);

      notifyListeners();

      if (supabaseService.isConfigured) {
        await supabaseService.upsertLead(updated);
      }
    }
  }

  /// Automatically record that a call was placed to this lead without popping any dialogs or altering status
  Future<void> recordCallAttempt(String leadId) async {
    final index = _leads.indexWhere((l) => l.id == leadId);
    if (index != -1) {
      final current = _leads[index];
      final updated = current.copyWith(
        lastCallDate: DateTime.now(),
        updatedBy: 'Yogesh',
      );
      _leads[index] = updated;
      await storageService.saveLeads(_leads);

      // Cadence user logging: Record call attempt
      final log = CallLogModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        leadId: leadId,
        outcome: current.callStatus,
        notes: 'Outreach call placed by Yogesh',
        loggedBy: 'Yogesh',
      );
      _callLogs.insert(0, log);
      await storageService.saveCallLogs(_callLogs);

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
        updatedBy: 'Yogesh',
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
    final loggedLead = lead.copyWith(
      createdBy: 'Yogesh',
      updatedBy: 'Yogesh',
    );
    _leads.insert(0, loggedLead);
    await storageService.saveLeads(_leads);
    notifyListeners();

    if (supabaseService.isConfigured) {
      await supabaseService.upsertLead(loggedLead);
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
    String lostReason = '',
    DateTime? nextFollowUpDate,
    int durationSeconds = 0,
    String pitchedOffering = 'Custom Web Development',
  }) async {
    final normStatus = LeadModel.normalizeStatus(outcome);
    final callLog = CallLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      leadId: leadId,
      outcome: normStatus,
      notes: normStatus == 'Lost' && lostReason.isNotEmpty
          ? 'Lost: $lostReason. Notes: $notes'.trim()
          : notes,
      nextFollowUpDate: nextFollowUpDate,
      durationSeconds: durationSeconds,
      pitchedOffering: pitchedOffering,
      createdAt: DateTime.now(),
      loggedBy: 'Yogesh',
    );

    _callLogs.insert(0, callLog);
    await storageService.saveCallLogs(_callLogs);

    final leadIndex = _leads.indexWhere((l) => l.id == leadId);
    if (leadIndex != -1) {
      final currentLead = _leads[leadIndex];
      final finalLostReason = normStatus == 'Lost'
          ? (lostReason.isNotEmpty
              ? lostReason
              : (currentLead.lostReason.isNotEmpty ? currentLead.lostReason : notes))
          : '';
      final updatedLead = currentLead.copyWith(
        callStatus: normStatus,
        lostReason: finalLostReason,
        lastCallDate: DateTime.now(),
        nextFollowUpDate: nextFollowUpDate ?? currentLead.nextFollowUpDate,
        notes: notes.isNotEmpty
            ? '${currentLead.notes}\n[${DateTime.now().toLocal()} by Yogesh]: $notes'.trim()
            : currentLead.notes,
        updatedBy: 'Yogesh',
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
