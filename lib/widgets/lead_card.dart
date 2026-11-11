import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';
import 'call_log_dialog.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
  });

  void _showWhatsAppPitchSheet(BuildContext context) {
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
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Falconate WhatsApp Pitch',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Sending to: ${lead.businessName} (${lead.primaryPhone})',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 24),
              ...templates.where((t) => t.channel == 'WhatsApp').map((t) {
                final message = t.format(
                  businessName: lead.businessName,
                  services: lead.services,
                  location: lead.location,
                  website: lead.websiteLink,
                  handle: lead.instagramUsername,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await OutreachService.openWhatsApp(
                                  lead.primaryPhone!,
                                  message: message,
                                );
                                if (context.mounted) {
                                  CallLogDialog.show(context, lead);
                                }
                              },
                              icon: const Icon(Icons.send, size: 14, color: Colors.white),
                              label: const Text('Send on WA', style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await OutreachService.openWhatsApp(lead.primaryPhone!);
                    if (context.mounted) {
                      CallLogDialog.show(context, lead);
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Open Empty WhatsApp Chat'),
                ),
              ),
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
    final statusColor = AppTheme.getStatusColor(lead.callStatus);
    final priorityColor = AppTheme.getPriorityColor(lead.leadPriority);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Business Name, Priority, Call Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${lead.id}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                lead.businessName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lead.services,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: priorityColor.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          '${lead.leadPriority.toUpperCase()} PRIORITY',
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lead.callStatus,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Caution Warning Banner
              if (lead.hasCaution) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFFB45309) : const Color(0xFFFBBF24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lead.cautionNotes,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.3,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Metadata Pills (Location, Instagram, Website, Verification)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Location
                  if (lead.location.isNotEmpty)
                    InkWell(
                      onTap: () => OutreachService.openMaps(lead.location),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            lead.location.length > 25
                                ? '${lead.location.substring(0, 25)}...'
                                : lead.location,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                  // Instagram Handle & Followers
                  if (lead.hasInstagram)
                    InkWell(
                      onTap: () => OutreachService.openInstagram(lead.instagramUsername),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1306C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 13, color: Color(0xFFE1306C)),
                            const SizedBox(width: 4),
                            Text(
                              '@${lead.instagramUsername} (${NumberFormat.compact().format(lead.instagramFollowers)})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFE1306C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Website Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: lead.hasWebsite
                          ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          lead.hasWebsite ? Icons.language : Icons.link_off,
                          size: 13,
                          color: lead.hasWebsite ? const Color(0xFF2563EB) : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lead.websiteStatus,
                          style: TextStyle(
                            fontSize: 11,
                            color: lead.hasWebsite ? const Color(0xFF2563EB) : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nested Data Verification Pill (Interactive Toggle!)
                  Consumer<LeadProvider>(
                    builder: (context, provider, _) {
                      final isVerified = lead.isNestedDataVerified;
                      return InkWell(
                        onTap: () => provider.toggleNestedDataVerified(lead.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isVerified
                                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified ? Icons.check_circle : Icons.help_outline,
                                size: 12,
                                color: isVerified
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified ? 'Nested Data Verified' : 'Nested Data Unverified',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isVerified
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Follow-up Alert if scheduled
              if (lead.nextFollowUpDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 14,
                      color: lead.isFollowUpDue ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Follow-up: ${DateFormat('EEE, MMM d, h:mm a').format(lead.nextFollowUpDate!)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: lead.isFollowUpDue ? const Color(0xFFEF4444) : const Color(0xFF0EA5E9),
                      ),
                    ),
                    if (lead.isFollowUpDue)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DUE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              const Divider(height: 20),

              // Action Toolbar
              Row(
                children: [
                  // Call Button
                  if (lead.hasPhone) ...[
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final phone = lead.primaryPhone!;
                          await OutreachService.makePhoneCall(phone);
                          if (context.mounted) {
                            CallLogDialog.show(context, lead);
                          }
                        },
                        icon: const Icon(Icons.call, size: 16, color: Colors.white),
                        label: Text(
                          'Call ${lead.primaryPhone}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // WhatsApp Button
                    IconButton.filledTonal(
                      tooltip: 'WhatsApp Outreach Pitch',
                      onPressed: () => _showWhatsAppPitchSheet(context),
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Expanded(
                      flex: 3,
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Find Phone / Inspect', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Email Button
                  if (lead.hasEmail)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton.filledTonal(
                        tooltip: 'Send Falconate Email',
                        onPressed: () => OutreachService.sendEmail(lead.email),
                        icon: const Icon(Icons.email_outlined, size: 20),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                  // Log Call Manual Button
                  IconButton.filledTonal(
                    tooltip: 'Log Call Outcome',
                    onPressed: () => CallLogDialog.show(context, lead),
                    icon: const Icon(Icons.edit_note, size: 22),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
