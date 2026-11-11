import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
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
            return AlertDialog(
              title: const Text('Add New Lead'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Business Name *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: serviceController,
                      decoration: const InputDecoration(labelText: 'Services / Industry *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number(s)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'City / Location'),
                    ),
                    const SizedBox(height: 8),
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
                ElevatedButton(
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
                  child: const Text('Save Lead'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();
    final filteredLeads = provider.filteredLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Falconate Leads Directory'),
        actions: [
          IconButton(
            tooltip: 'Add Prospect',
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: _showAddLeadDialog,
          ),
          IconButton(
            tooltip: 'Clear Filters',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: () {
              _searchController.clear();
              provider.clearFilters();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => provider.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search by business name, phone, city, services...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // Priority Filter
                FilterChip(
                  label: const Text('🔥 High Priority'),
                  selected: provider.selectedPriority == 'High',
                  onSelected: (selected) {
                    provider.setPriorityFilter(selected ? 'High' : 'All');
                  },
                ),
                const SizedBox(width: 8),

                // Has Phone Filter
                FilterChip(
                  label: const Text('📞 Has Phone'),
                  selected: provider.filterOnlyWithPhone,
                  onSelected: (_) => provider.toggleOnlyWithPhone(),
                ),
                const SizedBox(width: 8),

                // Status Not Called
                FilterChip(
                  label: const Text('⏳ Not Called'),
                  selected: provider.selectedCallStatus == 'Not Called',
                  onSelected: (selected) {
                    provider.setCallStatusFilter(selected ? 'Not Called' : 'All');
                  },
                ),
                const SizedBox(width: 8),

                // Status Interested
                FilterChip(
                  label: const Text('💬 Interested'),
                  selected: provider.selectedCallStatus == 'Interested',
                  onSelected: (selected) {
                    provider.setCallStatusFilter(selected ? 'Interested' : 'All');
                  },
                ),
                const SizedBox(width: 8),

                // Needs Nested Verification
                FilterChip(
                  label: const Text('⚠️ Needs Nested Check'),
                  selected: provider.filterOnlyUnverified,
                  onSelected: (_) => provider.toggleOnlyUnverified(),
                ),
                const SizedBox(width: 8),

                // Follow-ups Due
                FilterChip(
                  label: const Text('⏰ Due Today'),
                  selected: provider.filterOnlyFollowUpsDue,
                  onSelected: (_) => provider.toggleOnlyFollowUpsDue(),
                ),
              ],
            ),
          ),

          // Counter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Text(
                  'Showing ${filteredLeads.length} of ${provider.totalCount} Leads',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Spacer(),
                if (provider.selectedPriority != 'All' ||
                    provider.selectedCallStatus != 'All' ||
                    provider.filterOnlyWithPhone ||
                    provider.filterOnlyUnverified ||
                    provider.filterOnlyFollowUpsDue ||
                    provider.searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 24),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Reset filters', style: TextStyle(fontSize: 11)),
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
                          Icons.search_off,
                          size: 48,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No leads match your filter criteria',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            provider.clearFilters();
                          },
                          child: const Text('Clear all filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLeads.length,
                    padding: const EdgeInsets.only(bottom: 24),
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Lead',
        onPressed: _showAddLeadDialog,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
