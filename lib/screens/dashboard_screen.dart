import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../widgets/call_log_dialog.dart';
import 'lead_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToLeads;
  final VoidCallback onNavigateToKanban;

  const DashboardScreen({
    super.key,
    required this.onNavigateToLeads,
    required this.onNavigateToKanban,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();

    final total = provider.totalCount;
    final called = provider.calledCount;
    final interested = provider.interestedCount;
    final highPriority = provider.highPriorityCount;
    final followUpsDue = provider.followUpsDueCount;
    final unverified = provider.unverifiedCount;
    final conversionRate = provider.conversionRate;

    final followUpLeads = provider.allLeads.where((l) => l.isFollowUpDue).toList();
    final highPriorityLeads = provider.allLeads.where((l) => l.isHighPriority && l.callStatus == 'Not Called').toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FalconCRM',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                Text(
                  'falconate.com • Web & App Outreach Engine',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (provider.isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              tooltip: 'Sync with Supabase Cloud',
              icon: const Icon(Icons.cloud_sync_outlined),
              onPressed: () async {
                await provider.syncWithSupabase();
                if (context.mounted && provider.syncStatusMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.syncStatusMessage!),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await provider.syncWithSupabase(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caution Banner regarding AI verification
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Lead Sheet Loaded (14 Verified Companies)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Company names are verified. Nested data (websites/handles) can be verified directly in the app. $unverified nested items pending manual confirmation.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Stats Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 1.6 : 1.4,
                    children: [
                      _buildKpiCard(
                        title: 'Total Prospects',
                        value: '$total',
                        subtitle: '14 initial qualified leads',
                        icon: Icons.people_outline,
                        color: const Color(0xFF2563EB),
                        isDark: isDark,
                      ),
                      _buildKpiCard(
                        title: 'High Priority',
                        value: '$highPriority',
                        subtitle: 'Best website opportunities',
                        icon: Icons.star_border,
                        color: const Color(0xFFEF4444),
                        isDark: isDark,
                      ),
                      _buildKpiCard(
                        title: 'Outreach Calls',
                        value: '$called / $total',
                        subtitle: '${((called / (total == 0 ? 1 : total)) * 100).toInt()}% contacted',
                        icon: Icons.phone_in_talk,
                        color: const Color(0xFF0EA5E9),
                        isDark: isDark,
                      ),
                      _buildKpiCard(
                        title: 'Interested (Hot)',
                        value: '$interested',
                        subtitle: '${conversionRate.toStringAsFixed(1)}% conversion rate',
                        icon: Icons.local_fire_department,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Quick Action Bar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNavigateToLeads,
                      icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
                      label: const Text(
                        'View Lead Directory',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onNavigateToKanban,
                      icon: const Icon(Icons.view_kanban_outlined),
                      label: const Text(
                        'Kanban Pipeline',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Follow-ups Due Section
              if (followUpLeads.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.alarm, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Follow-ups Due Today ($followUpsDue)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...followUpLeads.map((lead) => _buildActionCard(context, lead, isDark)),
                const SizedBox(height: 20),
              ],

              // Next High Priority Calling Queue
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'High Priority Calling Queue (${highPriorityLeads.length} Uncalled)',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (highPriorityLeads.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '🎉 All high priority leads have been called!',
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ),
                )
              else
                ...highPriorityLeads.take(4).map((lead) => _buildActionCard(context, lead, isDark)),

              const SizedBox(height: 24),

              // Falconate Pitch Angles Guide
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 8),
                          Text(
                            'Falconate Sales Outreach Playbook',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildPlaybookItem(
                        icon: '1',
                        title: 'Leads with No Website (e.g. Namma Mane, Mane Mithra, Dhyan)',
                        description:
                            'Pitch turnkey high-converting landing page & online booking portal. Emphasize converting their large Instagram following into direct inquiries.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildPlaybookItem(
                        icon: '2',
                        title: 'Leads with Active Website (e.g. FalconNest Constructions)',
                        description:
                            'Do not pitch a new site! Pitch mobile responsiveness, Google SEO ranking, speed optimization, or a dedicated Flutter mobile client portal.',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildPlaybookItem(
                        icon: '3',
                        title: 'Caution Items (Shrinidhi FMCG & Deep Solar)',
                        description:
                            'Avoid mentioning external HVAC or unverified websites. Ask directly about their current digital ordering workflow during the call.',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, dynamic lead, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LeadDetailScreen(leadId: lead.id)),
          );
        },
        title: Text(
          lead.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          lead.services,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lead.hasPhone)
              IconButton(
                tooltip: 'Call Now',
                icon: const Icon(Icons.call, color: Color(0xFF2563EB)),
                onPressed: () async {
                  await OutreachService.makePhoneCall(lead.primaryPhone!);
                  if (context.mounted) {
                    CallLogDialog.show(context, lead);
                  }
                },
              ),
            IconButton(
              tooltip: 'Log Call',
              icon: const Icon(Icons.edit_note),
              onPressed: () => CallLogDialog.show(context, lead),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybookItem({
    required String icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            icon,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
