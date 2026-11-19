import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
import '../widgets/lost_reason_sheet.dart';
import '../widgets/call_log_dialog.dart';

class LeadDetailScreen extends StatelessWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  void _showEditLeadModal(BuildContext context, LeadModel lead) {
    final nameCtrl = TextEditingController(text: lead.businessName);
    final serviceCtrl = TextEditingController(text: lead.services);
    final phoneCtrl = TextEditingController(text: lead.phoneNumbers);
    final emailCtrl = TextEditingController(text: lead.email);
    final locCtrl = TextEditingController(text: lead.location);
    final igCtrl = TextEditingController(text: lead.instagramUsername);
    final webLinkCtrl = TextEditingController(text: lead.websiteLink);
    final notesCtrl = TextEditingController(text: lead.notes);
    String priority = lead.leadPriority;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF131B2E) : Colors.white;

        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Edit Prospect Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildBorderlessField(nameCtrl, 'Business Name', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(serviceCtrl, 'Services / Offering', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(phoneCtrl, 'Phone Number(s)', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(emailCtrl, 'Email Address', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(locCtrl, 'Location / City', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(igCtrl, 'Instagram Handle', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(webLinkCtrl, 'Website URL', isDark),
                const SizedBox(height: 10),
                _buildBorderlessField(notesCtrl, 'Notes & Context', isDark, maxLines: 3),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = lead.copyWith(
                        businessName: nameCtrl.text.trim(),
                        services: serviceCtrl.text.trim(),
                        phoneNumbers: phoneCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        location: locCtrl.text.trim(),
                        instagramUsername: igCtrl.text.trim(),
                        websiteLink: webLinkCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        leadPriority: priority,
                        updatedBy: 'Yogesh',
                      );
                      context.read<LeadProvider>().updateLead(updated);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes (by Yogesh)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBorderlessField(TextEditingController ctrl, String hint, bool isDark, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          labelText: hint,
          labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }

  void _showWhatsAppPitchSheet(BuildContext context, LeadModel lead) {
    final templates = context.read<LeadProvider>().pitchTemplates;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF131B2E) : Colors.white;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'WhatsApp Outreach to ${lead.businessName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              ...templates.where((t) => t.channel == 'WhatsApp').map((t) {
                final message = t.format(
                  businessName: lead.businessName,
                  services: lead.services,
                  location: lead.location,
                  website: lead.websiteLink,
                  handle: lead.instagramUsername,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await OutreachService.openWhatsApp(lead.primaryPhone!, message: message);
                            },
                            icon: const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                            label: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.35, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<LeadProvider>();

    final leadIndex = provider.allLeads.indexWhere((l) => l.id == leadId);
    if (leadIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Not Found')),
        body: const Center(child: Text('This lead does not exist.')),
      );
    }

    final lead = provider.allLeads[leadIndex];
    final callLogs = provider.logsForLead(lead.id);
    final statusColor = AppTheme.getStatusColor(lead.callStatus);
    final priorityColor = AppTheme.getPriorityColor(lead.leadPriority);
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(lead.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            tooltip: 'Edit Prospect',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditLeadModal(context, lead),
          ),
          IconButton(
            tooltip: 'Delete Lead',
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Lead?'),
                  content: Text('Are you sure you want to delete ${lead.businessName}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        provider.deleteLead(lead.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (NO borders, clean tonal surface)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    lead.businessName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                ),
                                if (lead.isCompanyVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, size: 16, color: Color(0xFF3B82F6)),
                                ],
                              ],
                            ),
                            if (lead.location.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    lead.location,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 5),
                            Text(
                              lead.services,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Priority Pill (NO borders)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lead.leadPriority.toUpperCase(),
                          style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 1-Tap Pipeline Status Selector (NO borders)
                  Row(
                    children: [
                      Text(
                        'PIPELINE STAGE: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      Text(
                        lead.callStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildPipelinePill(
                        context: context,
                        label: 'Outreach',
                        targetStatus: 'Outreach',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFF3B82F6),
                        onTap: () => provider.updateLeadStatus(lead.id, 'Outreach'),
                      ),
                      _buildPipelinePill(
                        context: context,
                        label: 'Interested',
                        targetStatus: 'Interested',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFF10B981),
                        onTap: () => provider.updateLeadStatus(lead.id, 'Interested'),
                      ),
                      _buildPipelinePill(
                        context: context,
                        label: 'Demo',
                        targetStatus: 'Demo',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFF8B5CF6),
                        onTap: () => provider.updateLeadStatus(lead.id, 'Demo'),
                      ),
                      _buildPipelinePill(
                        context: context,
                        label: 'Deal',
                        targetStatus: 'Deal',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFF059669),
                        onTap: () => provider.updateLeadStatus(lead.id, 'Deal'),
                      ),
                      _buildPipelinePill(
                        context: context,
                        label: 'Junk',
                        targetStatus: 'Junk',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFF64748B),
                        onTap: () => provider.updateLeadStatus(lead.id, 'Junk'),
                      ),
                      _buildPipelinePill(
                        context: context,
                        label: 'Lost',
                        targetStatus: 'Lost',
                        currentStatus: lead.callStatus,
                        activeColor: const Color(0xFFEF4444),
                        onTap: () => LostReasonSheet.show(context, lead),
                      ),
                    ],
                  ),

                  // If Lost: Display Reason Callout
                  if (lead.isLost && lead.lostReason.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Lost Reason: ${lead.lostReason}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Primary Direct Outreach CTAs (Call & WhatsApp) - NO borders!
                  Row(
                    children: [
                      // Prominent Call Button
                      if (lead.hasPhone) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await OutreachService.makePhoneCall(lead.primaryPhone!);
                              if (context.mounted) {
                                provider.recordCallAttempt(lead.id);
                              }
                            },
                            icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                            label: Text(
                              'Call ${lead.primaryPhone}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Prominent WhatsApp Button
                        ElevatedButton.icon(
                          onPressed: () => _showWhatsAppPitchSheet(context, lead),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 16),
                          label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Secondary Channels Row (Instagram, Website, Maps, Email)
                  // Fixed layout using Wrap so Maps NEVER overflows the screen edge!
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (lead.location.isNotEmpty)
                        _buildSecondaryPill(
                          icon: Icons.location_on_outlined,
                          label: 'Google Maps',
                          color: const Color(0xFFF59E0B),
                          onTap: () => OutreachService.openMaps(lead.location),
                          isDark: isDark,
                        ),
                      if (lead.hasInstagram)
                        _buildSecondaryPill(
                          icon: Icons.camera_alt_outlined,
                          label: '@${lead.instagramUsername}',
                          color: const Color(0xFFE1306C),
                          onTap: () => OutreachService.openInstagram(lead.instagramUsername),
                          isDark: isDark,
                        ),
                      if (lead.hasWebsite)
                        _buildSecondaryPill(
                          icon: Icons.language_rounded,
                          label: 'Website',
                          color: const Color(0xFF0EA5E9),
                          onTap: () => OutreachService.openUrl(lead.websiteLink),
                          isDark: isDark,
                        ),
                      if (lead.hasEmail)
                        _buildSecondaryPill(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: const Color(0xFFEA4335),
                          onTap: () => OutreachService.sendEmail(lead.email),
                          isDark: isDark,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Cadence User Logging Stamp
                  Row(
                    children: [
                      Icon(Icons.account_circle_outlined, size: 13, color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        'Cadence logging: Yogesh • ${DateFormat('MMM d, h:mm a').format(lead.updatedAt)}',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 2. Caution Warning Box (if present, NO borders)
            if (lead.hasCaution) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF241A0F) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Lead Sheet Caution',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            lead.cautionNotes,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. Contact & Phone Numbers Card (NO borders, clean tonal)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact & Phone Lines',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  if (lead.allPhones.isNotEmpty) ...[
                    ...lead.allPhones.map((phone) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                phone,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await OutreachService.makePhoneCall(phone);
                                if (context.mounted) {
                                  provider.recordCallAttempt(lead.id);
                                }
                              },
                              icon: const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                              label: const Text('Call', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'WhatsApp $phone',
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF25D366)),
                              onPressed: () => OutreachService.openWhatsApp(phone),
                              padding: const EdgeInsets.all(7),
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const Text(
                      'No phone numbers listed in sheet',
                      style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Notes & Research (NO borders)
            if (lead.notes.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Research & Client Context',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lead.notes,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 5. Cadence Interaction Activity Log (NO borders)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Cadence Interaction Log',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => CallLogDialog.show(context, lead),
                        icon: const Icon(Icons.add, size: 14, color: Colors.white),
                        label: const Text('Add Note', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (callLogs.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No interactions logged yet. Calls and status updates are tracked here under Yogesh.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ] else ...[
                    ...callLogs.map((log) => _buildTimelineItem(log, isDark)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelinePill({
    required BuildContext context,
    required String label,
    required String targetStatus,
    required String currentStatus,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isSelected = currentStatus.toLowerCase() == targetStatus.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF1E283D) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 11, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(dynamic log, bool isDark) {
    final statusColor = AppTheme.getStatusColor(log.outcome);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log.outcome,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'by ${log.loggedBy ?? 'Yogesh'}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d • h:mm a').format(log.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if (log.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                log.notes,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
