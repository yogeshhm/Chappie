import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/lead_card.dart';
import 'lead_detail_screen.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLeadDialog() {
    final nameController = TextEditingController();
    final serviceController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    final igController = TextEditingController();
    String priority = 'High';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(ctx);
            final isDark = theme.brightness == Brightness.dark;

            return AlertDialog(
              backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add New Prospect', style: TextStyle(fontWeight: FontWeight.w700)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Business Name *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: serviceController,
                      decoration: const InputDecoration(labelText: 'Services / Industry *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number(s)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'City / Location'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: igController,
                      decoration: const InputDecoration(labelText: 'Instagram Handle'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Lead Priority'),
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High Priority')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium Priority')),
                        DropdownMenuItem(value: 'Low', child: Text('Low Priority')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => priority = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final newLead = LeadModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        businessName: name,
                        services: serviceController.text.trim(),
                        phoneNumbers: phoneController.text.trim(),
                        location: locationController.text.trim(),
                        instagramUsername: igController.text.trim(),
                        leadPriority: priority,
                        callStatus: 'Not Called',
                        isCompanyVerified: true,
                        isNestedDataVerified: false,
                      );

                      context.read<LeadProvider>().addLead(newLead);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Save Prospect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
    bool isDark = true,
  }) {
    final effectiveColor = activeColor ?? const Color(0xFF3B82F6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.15)
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.6)
                : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: effectiveColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : effectiveColor)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();
    final filteredLeads = provider.filteredLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lead Directory',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Prospect',
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
            onPressed: _showAddLeadDialog,
          ),
          IconButton(
            tooltip: 'Reset Filters',
            icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Sleek Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => provider.setSearchQuery(value),
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Search leads by business name, services, phone, city...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Horizontal Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterPill(
                  label: 'High Priority',
                  isSelected: provider.selectedPriority == 'High',
                  onTap: () => provider.setPriorityFilter(
                    provider.selectedPriority == 'High' ? 'All' : 'High',
                  ),
                  activeColor: const Color(0xFFF43F5E),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Has Phone',
                  isSelected: provider.filterOnlyWithPhone,
                  onTap: () => provider.toggleOnlyWithPhone(),
                  activeColor: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Not Called',
                  isSelected: provider.selectedCallStatus == 'Not Called',
                  onTap: () => provider.setCallStatusFilter(
                    provider.selectedCallStatus == 'Not Called' ? 'All' : 'Not Called',
                  ),
                  activeColor: const Color(0xFF64748B),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Interested (Hot)',
                  isSelected: provider.selectedCallStatus == 'Interested',
                  onTap: () => provider.setCallStatusFilter(
                    provider.selectedCallStatus == 'Interested' ? 'All' : 'Interested',
                  ),
                  activeColor: const Color(0xFF10B981),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Audit Nested Data',
                  isSelected: provider.filterOnlyUnverified,
                  onTap: () => provider.toggleOnlyUnverified(),
                  activeColor: const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterPill(
                  label: 'Due Follow-ups',
                  isSelected: provider.filterOnlyFollowUpsDue,
                  onTap: () => provider.toggleOnlyFollowUpsDue(),
                  activeColor: const Color(0xFFF43F5E),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Count Subheader
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(
              children: [
                Text(
                  '${filteredLeads.length} of ${provider.totalCount} PROSPECTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                const Spacer(),
                if (provider.selectedPriority != 'All' ||
                    provider.selectedCallStatus != 'All' ||
                    provider.filterOnlyWithPhone ||
                    provider.filterOnlyUnverified ||
                    provider.filterOnlyFollowUpsDue ||
                    provider.searchQuery.isNotEmpty)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Leads List
          Expanded(
            child: filteredLeads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: isDark ? const Color(0xFF334155) : Colors.black12,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No prospects match your active filters',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.clearFilters();
                          },
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLeads.length,
                    padding: const EdgeInsets.only(top: 4, bottom: 32),
                    itemBuilder: (context, index) {
                      final lead = filteredLeads[index];
                      return LeadCard(
                        lead: lead,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LeadDetailScreen(leadId: lead.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: 'Add Prospect',
          onPressed: _showAddLeadDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
