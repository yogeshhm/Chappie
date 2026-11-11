import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
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
    final webStatusCtrl = TextEditingController(text: lead.websiteStatus);
    final webLinkCtrl = TextEditingController(text: lead.websiteLink);
    final notesCtrl = TextEditingController(text: lead.notes);
    final cautionCtrl = TextEditingController(text: lead.cautionNotes);

    String priority = lead.leadPriority;
    String status = lead.callStatus;
    bool nestedVerified = lead.isNestedDataVerified;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Edit Lead Details',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Business Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: serviceCtrl,
                      decoration: const InputDecoration(labelText: 'Services / Products'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Numbers (comma separated)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locCtrl,
                      decoration: const InputDecoration(labelText: 'Location / Address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: igCtrl,
                      decoration: const InputDecoration(labelText: 'Instagram Handle'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: webLinkCtrl,
                      decoration: const InputDecoration(labelText: 'Website / Profile URL'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: webStatusCtrl,
                      decoration: const InputDecoration(labelText: 'Website Status'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: priority,
                            decoration: const InputDecoration(labelText: 'Priority'),
                            items: const [
                              DropdownMenuItem(value: 'High', child: Text('High')),
                              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                              DropdownMenuItem(value: 'Low', child: Text('Low')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => priority = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: status,
                            decoration: const InputDecoration(labelText: 'Call Status'),
                            items: const [
                              DropdownMenuItem(value: 'Not Called', child: Text('Not Called')),
                              DropdownMenuItem(value: 'Called - No Answer', child: Text('No Answer')),
                              DropdownMenuItem(value: 'Connected', child: Text('Connected')),
                              DropdownMenuItem(value: 'Pitch Sent', child: Text('Pitch Sent')),
                              DropdownMenuItem(value: 'Interested', child: Text('Interested')),
                              DropdownMenuItem(value: 'Follow-up Scheduled', child: Text('Follow-up')),
                              DropdownMenuItem(value: 'Closed Won', child: Text('Closed Won')),
                              DropdownMenuItem(value: 'Not Interested', child: Text('Not Interested')),
                              DropdownMenuItem(value: 'Invalid Number', child: Text('Invalid')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => status = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Nested Data Verified?'),
                      subtitle: const Text('Confirm phone, website and profile details have been verified.'),
                      value: nestedVerified,
                      onChanged: (val) => setModalState(() => nestedVerified = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cautionCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Caution / Warning Note (Optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Internal Notes'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
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
                            websiteStatus: webStatusCtrl.text.trim(),
                            leadPriority: priority,
                            callStatus: status,
                            isNestedDataVerified: nestedVerified,
                            cautionNotes: cautionCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                          );

                          context.read<LeadProvider>().updateLead(updated);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWhatsAppPitchSheet(BuildContext context, LeadModel lead) {
    final templates = context.read<LeadProvider>().pitchTemplates;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Falconate Pitch to ${lead.businessName}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Phone: ${lead.primaryPhone}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 20),
              ...templates.where((t) => t.channel == 'WhatsApp').map((t) {
                final message = t.format(
                  businessName: lead.businessName,
                  services: lead.services,
                  location: lead.location,
                  website: lead.websiteLink,
                  handle: lead.instagramUsername,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                              icon: const Icon(Icons.send, size: 14, color: Colors.white),
                              label: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 12)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(lead.businessName),
        actions: [
          IconButton(
            tooltip: 'Edit Lead Details',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card: Business Name, Monogram, Status & Priority
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 14,
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.getAvatarGradient(lead.businessName),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lead.businessName.substring(0, lead.businessName.length >= 2 ? 2 : 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.businessName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              lead.services,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: priorityColor.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              '${lead.leadPriority.toUpperCase()} PRIORITY',
                              style: TextStyle(
                                color: priorityColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              lead.callStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                    const Divider(height: 24),

                    // Quick Outreach Action Dock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionDockButton(
                          icon: Icons.call,
                          label: 'Call',
                          color: const Color(0xFF2563EB),
                          enabled: lead.hasPhone,
                          onTap: () async {
                            await OutreachService.makePhoneCall(lead.primaryPhone!);
                            if (context.mounted) {
                              context.read<LeadProvider>().recordCallAttempt(lead.id);
                            }
                          },
                        ),
                        _buildActionDockButton(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          enabled: lead.hasPhone,
                          onTap: () => _showWhatsAppPitchSheet(context, lead),
                        ),
                        _buildActionDockButton(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: const Color(0xFFEA4335),
                          enabled: lead.hasEmail,
                          onTap: () => OutreachService.sendEmail(lead.email),
                        ),
                        _buildActionDockButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Instagram',
                          color: const Color(0xFFE1306C),
                          enabled: lead.hasInstagram,
                          onTap: () => OutreachService.openInstagram(lead.instagramUsername),
                        ),
                        _buildActionDockButton(
                          icon: Icons.language,
                          label: 'Website',
                          color: const Color(0xFF0EA5E9),
                          enabled: lead.hasWebsite,
                          onTap: () => OutreachService.openUrl(lead.websiteLink),
                        ),
                        _buildActionDockButton(
                          icon: Icons.location_on_outlined,
                          label: 'Maps',
                          color: const Color(0xFFF59E0B),
                          enabled: lead.location.isNotEmpty,
                          onTap: () => OutreachService.openMaps(lead.location),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Caution Warning Box
            if (lead.hasCaution) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFFB45309) : const Color(0xFFFBBF24),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Lead Sheet Warning / Caution',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
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
              const SizedBox(height: 16),
            ],

            // Verification Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, color: Color(0xFF2563EB), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Data Verification Status',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Company Identity: Verified by You',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          lead.isNestedDataVerified ? Icons.check_circle : Icons.help_outline,
                          color: lead.isNestedDataVerified
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lead.isNestedDataVerified
                                ? 'Nested Data: Verified & Audited'
                                : 'Nested Data: Unverified (AI Transcribed)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: lead.isNestedDataVerified
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => provider.toggleNestedDataVerified(lead.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lead.isNestedDataVerified
                                ? Colors.grey
                                : const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: Text(
                            lead.isNestedDataVerified ? 'Mark Unverified' : 'Verify Now',
                            style: const TextStyle(fontSize: 11.5, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact & Details Grid
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact & Outreach Coordinates',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: 'Phone Numbers',
                      value: lead.phoneNumbers.isNotEmpty ? lead.phoneNumbers : 'Not visible in screenshot',
                      actionIcon: lead.hasPhone ? Icons.call : null,
                      onAction: lead.hasPhone
                          ? () => OutreachService.makePhoneCall(lead.primaryPhone!)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: lead.email.isNotEmpty ? lead.email : 'Not visible in screenshot',
                      actionIcon: lead.hasEmail ? Icons.send : null,
                      onAction: lead.hasEmail ? () => OutreachService.sendEmail(lead.email) : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Physical Location',
                      value: lead.location.isNotEmpty ? lead.location : 'Not specified',
                      actionIcon: lead.location.isNotEmpty ? Icons.map : null,
                      onAction: lead.location.isNotEmpty
                          ? () => OutreachService.openMaps(lead.location)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.camera_alt_outlined,
                      label: 'Instagram Profile',
                      value: lead.instagramUsername.isNotEmpty
                          ? '@${lead.instagramUsername} • ${NumberFormat.compact().format(lead.instagramFollowers)} followers, ${lead.instagramPosts} posts'
                          : 'Not visible',
                      actionIcon: lead.hasInstagram ? Icons.open_in_new : null,
                      onAction: lead.hasInstagram
                          ? () => OutreachService.openInstagram(lead.instagramUsername)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.language,
                      label: 'Website Status',
                      value: lead.websiteLink.isNotEmpty
                          ? '${lead.websiteStatus} (${lead.websiteLink})'
                          : lead.websiteStatus,
                      actionIcon: lead.hasWebsite ? Icons.open_in_browser : null,
                      onAction: lead.hasWebsite ? () => OutreachService.openUrl(lead.websiteLink) : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes & Prospect Context
            if (lead.notes.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notes, color: Color(0xFF2563EB), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Prospect Context & Research Notes',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
              ),
              const SizedBox(height: 16),
            ],

            // Call / Outreach Interaction Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history, color: Color(0xFF2563EB), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Interaction Timeline (${callLogs.length})',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => CallLogDialog.show(context, lead),
                          icon: const Icon(Icons.add, size: 14, color: Colors.white),
                          label: const Text('Log Call', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    if (callLogs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Icon(Icons.phone_missed_outlined, size: 36, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('No calls logged yet for this lead.'),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () => CallLogDialog.show(context, lead),
                                child: const Text('Log first outreach call'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...callLogs.map((log) => _buildTimelineItem(log, isDark)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionDockButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (actionIcon != null && onAction != null)
          IconButton(
            icon: Icon(actionIcon, size: 18, color: const Color(0xFF2563EB)),
            onPressed: onAction,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(dynamic log, bool isDark) {
    final statusColor = AppTheme.getStatusColor(log.outcome);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.phone_in_talk, size: 14, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.outcome,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(log.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Service: ${log.pitchedOffering}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if (log.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    log.notes,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ],
                if (log.nextFollowUpDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.alarm, size: 12, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        'Follow-up set: ${DateFormat('EEE, MMM d, yyyy').format(log.nextFollowUpDate)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
