import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lost_reason_sheet.dart';
import 'lead_detail_screen.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  final List<Map<String, dynamic>> _pipelineColumns = const [
    {
      'title': 'Outreach',
      'statuses': ['Outreach'],
      'color': Color(0xFF3B82F6),
      'icon': Icons.send_rounded,
    },
    {
      'title': 'Interested',
      'statuses': ['Interested'],
      'color': Color(0xFF10B981),
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'title': 'Demo',
      'statuses': ['Demo'],
      'color': Color(0xFF8B5CF6),
      'icon': Icons.smart_display_rounded,
    },
    {
      'title': 'Deal',
      'statuses': ['Deal'],
      'color': Color(0xFF059669),
      'icon': Icons.verified_rounded,
    },
    {
      'title': 'Junk',
      'statuses': ['Junk'],
      'color': Color(0xFF64748B),
      'icon': Icons.block_flipped,
    },
    {
      'title': 'Lost',
      'statuses': ['Lost'],
      'color': Color(0xFFEF4444),
      'icon': Icons.archive_outlined,
    },
  ];

  void _showMoveStageDialog(BuildContext context, LeadModel lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131B2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move Stage: ${lead.businessName}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildStageOption(context, ctx, lead, 'Outreach', Icons.send_rounded, const Color(0xFF3B82F6)),
              _buildStageOption(context, ctx, lead, 'Interested', Icons.local_fire_department_rounded, const Color(0xFF10B981)),
              _buildStageOption(context, ctx, lead, 'Demo', Icons.smart_display_rounded, const Color(0xFF8B5CF6)),
              _buildStageOption(context, ctx, lead, 'Deal', Icons.verified_rounded, const Color(0xFF059669)),
              _buildStageOption(context, ctx, lead, 'Junk', Icons.block_flipped, const Color(0xFF64748B)),
              _buildStageOption(context, ctx, lead, 'Lost', Icons.archive_outlined, const Color(0xFFEF4444)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStageOption(
      BuildContext rootCtx, BuildContext bottomSheetCtx, LeadModel lead, String status, IconData icon, Color color) {
    final isCurrent = lead.callStatus.toLowerCase() == status.toLowerCase();
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        status,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          color: isCurrent ? color : null,
          fontSize: 14,
        ),
      ),
      trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18) : null,
      onTap: () {
        Navigator.pop(bottomSheetCtx);
        if (status == 'Lost') {
          LostReasonSheet.show(rootCtx, lead);
        } else {
          rootCtx.read<LeadProvider>().updateLeadStatus(lead.id, status);
        }
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
          'Cadence Pipeline',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${leads.length} LEADS • YOGESH',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _pipelineColumns.length,
        itemBuilder: (context, colIndex) {
          final col = _pipelineColumns[colIndex];
          final colTitle = col['title'] as String;
          final colStatuses = col['statuses'] as List<String>;
          final colColor = col['color'] as Color;
          final colIcon = col['icon'] as IconData;

          final colLeads = leads.where((l) {
            return colStatuses.any((s) => s.toLowerCase() == l.callStatus.toLowerCase());
          }).toList();

          return Container(
            width: 290,
            margin: const EdgeInsets.only(right: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Row(
                    children: [
                      Icon(colIcon, size: 16, color: colColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          colTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: colColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: colColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${colLeads.length}',
                          style: TextStyle(
                            color: colColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lead cards in this pipeline column (NO borders)
                Expanded(
                  child: colLeads.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 36,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No leads in $colTitle',
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162035) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.15),
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
                const SizedBox(height: 6),
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
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // If lost, show reason callout
                if (lead.isLost && lead.lostReason.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lost: ${lead.lostReason}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Direct action footer
                Row(
                  children: [
                    if (lead.hasPhone) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          await OutreachService.makePhoneCall(lead.primaryPhone!);
                          if (context.mounted) {
                            context.read<LeadProvider>().recordCallAttempt(lead.id);
                          }
                        },
                        icon: const Icon(Icons.call, size: 12, color: Colors.white),
                        label: const Text('Call', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: 'WhatsApp',
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF25D366)),
                        onPressed: () => OutreachService.openWhatsApp(lead.primaryPhone!),
                        padding: const EdgeInsets.all(5),
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      'by Yogesh',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white30 : Colors.black26,
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
