import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
import '../widgets/call_log_dialog.dart';
import 'lead_detail_screen.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  final List<Map<String, dynamic>> _pipelineColumns = const [
    {
      'title': 'Uncontacted Queue',
      'statuses': ['Not Called'],
      'color': Color(0xFF64748B),
      'icon': Icons.hourglass_top_rounded,
    },
    {
      'title': 'Outreach / In Progress',
      'statuses': ['Called - No Answer', 'Connected', 'Pitch Sent', 'Called - In Progress'],
      'color': Color(0xFF06B6D4),
      'icon': Icons.send_rounded,
    },
    {
      'title': 'Interested (Hot 🔥)',
      'statuses': ['Interested'],
      'color': Color(0xFF10B981),
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'title': 'Follow-up Due',
      'statuses': ['Follow-up Scheduled'],
      'color': Color(0xFFF59E0B),
      'icon': Icons.calendar_month_rounded,
    },
    {
      'title': 'Closed Won 🎉',
      'statuses': ['Closed Won'],
      'color': Color(0xFF059669),
      'icon': Icons.verified_rounded,
    },
    {
      'title': 'Cold / Inactive',
      'statuses': ['Not Interested', 'Invalid Number'],
      'color': Color(0xFFF43F5E),
      'icon': Icons.archive_outlined,
    },
  ];

  void _showMoveStageDialog(BuildContext context, LeadModel lead) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'Move Stage: ${lead.businessName}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStageOption(ctx, lead, 'Not Called', Icons.hourglass_top_rounded, const Color(0xFF64748B)),
              _buildStageOption(ctx, lead, 'Called - In Progress', Icons.phone_forwarded_rounded, const Color(0xFF06B6D4)),
              _buildStageOption(ctx, lead, 'Called - No Answer', Icons.phone_missed_rounded, const Color(0xFF8B5CF6)),
              _buildStageOption(ctx, lead, 'Pitch Sent', Icons.send_rounded, const Color(0xFF0EA5E9)),
              _buildStageOption(ctx, lead, 'Interested', Icons.local_fire_department_rounded, const Color(0xFF10B981)),
              _buildStageOption(ctx, lead, 'Follow-up Scheduled', Icons.calendar_month_rounded, const Color(0xFFF59E0B)),
              _buildStageOption(ctx, lead, 'Closed Won', Icons.verified_rounded, const Color(0xFF059669)),
              _buildStageOption(ctx, lead, 'Not Interested', Icons.thumb_down_rounded, const Color(0xFFF43F5E)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStageOption(
      BuildContext context, LeadModel lead, String status, IconData icon, Color color) {
    final isCurrent = lead.callStatus == status;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        status,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          color: isCurrent ? color : null,
          fontSize: 13.5,
        ),
      ),
      trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18) : null,
      onTap: () {
        context.read<LeadProvider>().updateLeadStatus(lead.id, status);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();
    final leads = provider.allLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pipeline Board',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${leads.length} Active Leads',
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        itemCount: _pipelineColumns.length,
        controller: PageController(viewportFraction: 0.88),
        itemBuilder: (context, columnIndex) {
          final column = _pipelineColumns[columnIndex];
          final colTitle = column['title'] as String;
          final validStatuses = (column['statuses'] as List<String>).map((s) => s.toLowerCase()).toSet();
          final colColor = column['color'] as Color;
          final colIcon = column['icon'] as IconData;

          final colLeads = leads
              .where((l) => validStatuses.contains(l.callStatus.toLowerCase()))
              .toList();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Column Header with Accent Border
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colColor.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    border: Border(
                      bottom: BorderSide(color: colColor.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(colIcon, color: colColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          colTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: colColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: colColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${colLeads.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lead cards in this pipeline column
                Expanded(
                  child: colLeads.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 36,
                                color: isDark ? const Color(0xFF334155) : Colors.black12,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No leads in this stage',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: colLeads.length,
                          itemBuilder: (context, i) {
                            final lead = colLeads[i];
                            return _buildKanbanCard(context, lead, isDark);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanbanCard(BuildContext context, LeadModel lead, bool isDark) {
    final priorityColor = AppTheme.getPriorityColor(lead.leadPriority);
    final avatarGradient = AppTheme.getAvatarGradient(lead.businessName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C2D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: lead.isHighPriority
              ? priorityColor.withValues(alpha: 0.35)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LeadDetailScreen(leadId: lead.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: avatarGradient,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        lead.businessName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        lead.leadPriority.toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.drive_file_move_outline, size: 17),
                      tooltip: 'Advance / Move Stage',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showMoveStageDialog(context, lead),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lead.businessName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  lead.services,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lead.hasCaution) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Has caution note',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 18),
                Row(
                  children: [
                    if (lead.hasPhone) ...[
                      InkWell(
                        onTap: () async {
                          await OutreachService.makePhoneCall(lead.primaryPhone!);
                          if (context.mounted) {
                            context.read<LeadProvider>().recordCallAttempt(lead.id);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.call_rounded, size: 13, color: Color(0xFF3B82F6)),
                            const SizedBox(width: 4),
                            Text(
                              lead.primaryPhone!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ] else ...[
                      const Text('No phone', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Spacer(),
                    ],
                    InkWell(
                      onTap: () => CallLogDialog.show(context, lead),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 14, color: Color(0xFF3B82F6)),
                            SizedBox(width: 3),
                            Text(
                              'Log',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
