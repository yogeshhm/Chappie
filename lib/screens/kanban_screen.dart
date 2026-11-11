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
      'title': 'Not Called',
      'statuses': ['Not Called'],
      'color': Color(0xFF64748B),
      'icon': Icons.hourglass_top,
    },
    {
      'title': 'Outreach / Sent',
      'statuses': ['Called - No Answer', 'Connected', 'Pitch Sent'],
      'color': Color(0xFF0EA5E9),
      'icon': Icons.send,
    },
    {
      'title': 'Interested (Hot 🔥)',
      'statuses': ['Interested'],
      'color': Color(0xFF10B981),
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'Follow-up Due',
      'statuses': ['Follow-up Scheduled'],
      'color': Color(0xFFF59E0B),
      'icon': Icons.calendar_month,
    },
    {
      'title': 'Closed Won 🎉',
      'statuses': ['Closed Won'],
      'color': Color(0xFF059669),
      'icon': Icons.verified,
    },
    {
      'title': 'Cold / Inactive',
      'statuses': ['Not Interested', 'Invalid Number'],
      'color': Color(0xFFEF4444),
      'icon': Icons.archive_outlined,
    },
  ];

  void _showMoveStageDialog(BuildContext context, LeadModel lead) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Move Stage: ${lead.businessName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStageOption(ctx, lead, 'Not Called', Icons.hourglass_top, const Color(0xFF64748B)),
              _buildStageOption(ctx, lead, 'Called - No Answer', Icons.phone_missed, const Color(0xFF8B5CF6)),
              _buildStageOption(ctx, lead, 'Pitch Sent', Icons.send, const Color(0xFF0EA5E9)),
              _buildStageOption(ctx, lead, 'Interested', Icons.local_fire_department, const Color(0xFF10B981)),
              _buildStageOption(ctx, lead, 'Follow-up Scheduled', Icons.calendar_month, const Color(0xFFF59E0B)),
              _buildStageOption(ctx, lead, 'Closed Won', Icons.verified, const Color(0xFF059669)),
              _buildStageOption(ctx, lead, 'Not Interested', Icons.thumb_down, const Color(0xFFEF4444)),
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
      leading: Icon(icon, color: color),
      title: Text(
        status,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          color: isCurrent ? color : null,
        ),
      ),
      trailing: isCurrent ? const Icon(Icons.check, color: Color(0xFF10B981)) : null,
      onTap: () {
        context.read<LeadProvider>().updateLeadStatus(lead.id, status);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();
    final leads = provider.allLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Falconate Relationship Pipeline'),
        actions: [
          IconButton(
            tooltip: 'Log Call',
            icon: const Icon(Icons.add_call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tap on any card to call or move stages.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Column Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(colIcon, color: colColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          colTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${colLeads.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
                          child: Text(
                            'No leads in this stage',
                            style: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                              fontSize: 13,
                            ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    lead.leadPriority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.drive_file_move_outline, size: 18),
                  tooltip: 'Move to another stage',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMoveStageDialog(context, lead),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeadDetailScreen(leadId: lead.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lead.businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lead.services,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (lead.hasCaution) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning, size: 12, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Has caution note',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 16),
            Row(
              children: [
                if (lead.hasPhone) ...[
                  InkWell(
                    onTap: () async {
                      await OutreachService.makePhoneCall(lead.primaryPhone!);
                      if (context.mounted) {
                        CallLogDialog.show(context, lead);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.call, size: 13, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          lead.primaryPhone!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit_note, size: 13, color: Color(0xFF2563EB)),
                        SizedBox(width: 3),
                        Text(
                          'Log',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
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
    );
  }
}
