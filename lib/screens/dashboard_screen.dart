import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
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
    final outreach = provider.outreachCount;
    final interested = provider.interestedCount;
    final demo = provider.demoCount;
    final deal = provider.dealCount;
    final lost = provider.lostCount;
    final junk = provider.junkCount;
    final followUpsDue = provider.followUpsDueCount;

    final followUpLeads = provider.allLeads.where((l) => l.isFollowUpDue).toList();
    final highPriorityLeads = provider.allLeads
        .where((l) => l.isHighPriority && l.callStatus == 'Outreach')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cadence',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'falconate.com • Yogesh',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Supabase Live Sync Indicator Pill (borderless)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (provider.supabaseService.isConfigured
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B))
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: provider.supabaseService.isConfigured
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  provider.supabaseService.isConfigured ? 'CLOUD SYNCED' : 'LOCAL CACHE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: provider.supabaseService.isConfigured
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sync Leads with Supabase Cloud',
            icon: provider.isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () async => await provider.syncWithSupabase(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await provider.syncWithSupabase(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Sheet Status Banner (borderless)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF3B82F6), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pipeline & Outreach Dashboard',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All leads tracked across Outreach, Interested, Demo, Deal, Junk, and Lost.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // KPI Bento Grid (borderless 6-card pipeline tracking)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: isWide ? 1.8 : 1.35,
                    children: [
                      _buildBentoKpiCard(
                        title: 'All Leads',
                        value: '$total',
                        subtitle: 'Directory total',
                        icon: Icons.folder_shared_rounded,
                        color: const Color(0xFF3B82F6),
                        isDark: isDark,
                      ),
                      _buildBentoKpiCard(
                        title: 'Outreach',
                        value: '$outreach',
                        subtitle: 'Ready for outreach',
                        icon: Icons.phone_forwarded_rounded,
                        color: const Color(0xFF06B6D4),
                        isDark: isDark,
                      ),
                      _buildBentoKpiCard(
                        title: 'Interested',
                        value: '$interested',
                        subtitle: 'Engaged prospects',
                        icon: Icons.thumb_up_alt_rounded,
                        color: const Color(0xFF10B981),
                        isDark: isDark,
                      ),
                      _buildBentoKpiCard(
                        title: 'Demo Scheduled',
                        value: '$demo',
                        subtitle: 'Product pitched',
                        icon: Icons.co_present_rounded,
                        color: const Color(0xFF8B5CF6),
                        isDark: isDark,
                      ),
                      _buildBentoKpiCard(
                        title: 'Deals Won',
                        value: '$deal',
                        subtitle: 'Closed contracts',
                        icon: Icons.military_tech_rounded,
                        color: const Color(0xFFF59E0B),
                        isDark: isDark,
                      ),
                      _buildBentoKpiCard(
                        title: 'Lost Leads',
                        value: '$lost',
                        subtitle: '$junk junk leads',
                        icon: Icons.trending_down_rounded,
                        color: const Color(0xFFEF4444),
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Command Action Row (completely borderless)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onNavigateToLeads,
                        icon: const Icon(Icons.people_alt_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          'Open Leads Directory',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: onNavigateToKanban,
                        icon: Icon(
                          Icons.view_kanban_rounded,
                          size: 18,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        label: Text(
                          'Kanban Pipeline',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Follow-ups Due Today ($followUpsDue)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...followUpLeads.map((lead) => _buildTactileQueueCard(context, lead, isDark)),
                const SizedBox(height: 20),
              ],

              // High Priority Queue
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF43F5E), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'High Priority Outreach Queue (${highPriorityLeads.length} Uncalled)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (highPriorityLeads.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131B2E) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '🎉 All high priority prospects have been contacted!',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                ...highPriorityLeads.take(4).map((lead) => _buildTactileQueueCard(context, lead, isDark)),

              const SizedBox(height: 24),

              // Falconate Sales Playbook Card (borderless)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Falconate Sales Outreach Playbook',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildPlaybookRow(
                      number: '01',
                      title: 'No Matching Website (Namma Mane, Mane Mithra, Dhyan)',
                      desc: 'Pitch custom mobile-first website & automated customer booking portal to convert their large Instagram following.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPlaybookRow(
                      number: '02',
                      title: 'Existing Website Verified (FalconNest Constructions)',
                      desc: 'Do NOT pitch a new website! Pitch mobile responsiveness audit, speed optimization, and custom client mobile app.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildPlaybookRow(
                      number: '03',
                      title: 'Unverified / Caution (Shrinidhi FMCG & Deep Solar)',
                      desc: 'Avoid referencing unverified HVAC/solar websites. Directly ask about their current digital ordering process on the call.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTactileQueueCard(BuildContext context, dynamic lead, bool isDark) {
    final avatarGradient = AppTheme.getAvatarGradient(lead.businessName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LeadDetailScreen(leadId: lead.id)),
          );
        },
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: avatarGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            lead.businessName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        title: Text(
          lead.businessName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
        subtitle: Text(
          lead.services,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lead.hasPhone)
              IconButton(
                tooltip: 'Direct Call Dialpad',
                icon: const Icon(Icons.call_rounded, color: Color(0xFF2563EB), size: 19),
                onPressed: () async {
                  await OutreachService.makePhoneCall(lead.primaryPhone!);
                  if (context.mounted) {
                    context.read<LeadProvider>().recordCallAttempt(lead.id);
                  }
                },
              ),
            IconButton(
              tooltip: 'Log Call Outcome',
              icon: const Icon(Icons.edit_note_rounded, size: 21),
              onPressed: () => CallLogDialog.show(context, lead),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybookRow({
    required String number,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w800,
              fontSize: 11,
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
