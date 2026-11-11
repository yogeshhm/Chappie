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

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'FL';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1523) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            ),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Falconate Pitch Selector',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Sending to ${lead.businessName} • ${lead.primaryPhone}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151D30) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await OutreachService.openWhatsApp(
                                lead.primaryPhone!,
                                message: message,
                              );
                            },
                            icon: const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                            label: const Text('Send on WA', style: TextStyle(color: Colors.white, fontSize: 11.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
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
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
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
    final statusColor = AppTheme.getStatusColor(lead.callStatus);
    final priorityColor = AppTheme.getPriorityColor(lead.leadPriority);
    final avatarGradient = AppTheme.getAvatarGradient(lead.businessName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lead.isHighPriority
              ? priorityColor.withValues(alpha: 0.35)
              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          width: lead.isHighPriority ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Monogram Avatar + Title + Badges
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Monogram Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: avatarGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: avatarGradient.colors.first.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(lead.businessName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Business Name & Services
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lead.businessName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lead.isCompanyVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 15,
                                  color: Color(0xFF3B82F6),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            lead.services,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Priority & Status Pill Badges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: priorityColor.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                lead.leadPriority.toUpperCase(),
                                style: TextStyle(
                                  color: priorityColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Call Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            lead.callStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Caution Warning Box (Linear Callout Style)
                if (lead.hasCaution) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1710) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFF59E0B),
                          width: 3.5,
                        ),
                        top: BorderSide(color: isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFDE68A)),
                        right: BorderSide(color: isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFDE68A)),
                        bottom: BorderSide(color: isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lead.cautionNotes,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Intel Tags Row (Location, Instagram, Website, Audit Toggle)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Location Pill
                    if (lead.location.isNotEmpty)
                      InkWell(
                        onTap: () => OutreachService.openMaps(lead.location),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                lead.location.length > 22
                                    ? '${lead.location.substring(0, 22)}...'
                                    : lead.location,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Instagram Pill
                    if (lead.hasInstagram)
                      InkWell(
                        onTap: () => OutreachService.openInstagram(lead.instagramUsername),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF833AB4).withValues(alpha: 0.15),
                                const Color(0xFFFD1D1D).withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE1306C).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, size: 12, color: Color(0xFFE1306C)),
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

                    // Website Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: lead.hasWebsite
                            ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                            : (isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: lead.hasWebsite
                              ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                              : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lead.hasWebsite ? Icons.language_rounded : Icons.link_off_rounded,
                            size: 12,
                            color: lead.hasWebsite ? const Color(0xFF3B82F6) : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lead.websiteStatus,
                            style: TextStyle(
                              fontSize: 11,
                              color: lead.hasWebsite ? const Color(0xFF3B82F6) : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Interactive Nested Data Audit Toggle
                    Consumer<LeadProvider>(
                      builder: (context, provider, _) {
                        final isVerified = lead.isNestedDataVerified;
                        return InkWell(
                          onTap: () => provider.toggleNestedDataVerified(lead.id),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
                                  isVerified ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                  size: 12,
                                  color: isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'Nested Verified' : 'Audit Nested Data',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
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

                const Divider(height: 22),

                // Tactile Outreach Dock
                Row(
                  children: [
                    // Primary Direct Call Button (Goes directly to dialpad!)
                    if (lead.hasPhone) ...[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final phone = lead.primaryPhone!;
                              await OutreachService.makePhoneCall(phone);
                              if (context.mounted) {
                                context.read<LeadProvider>().recordCallAttempt(lead.id);
                              }
                            },
                            icon: const Icon(Icons.call_rounded, size: 15, color: Colors.white),
                            label: Text(
                              'Call ${lead.primaryPhone}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // WhatsApp Button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
                        ),
                        child: IconButton(
                          tooltip: 'Send Falconate Pitch on WhatsApp',
                          onPressed: () => _showWhatsAppPitchSheet(context),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 18),
                          padding: const EdgeInsets.all(9),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.search_rounded, size: 15),
                          label: const Text('Inspect / Add Phone Number', style: TextStyle(fontSize: 12.5)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Email Quick Action
                    if (lead.hasEmail) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                        ),
                        child: IconButton(
                          tooltip: 'Send Email',
                          onPressed: () => OutreachService.sendEmail(lead.email),
                          icon: const Icon(Icons.email_outlined, size: 18),
                          padding: const EdgeInsets.all(9),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Log Details / Change Status Action
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      ),
                      child: IconButton(
                        tooltip: 'Log Call Outcome & Notes',
                        onPressed: () => CallLogDialog.show(context, lead),
                        icon: const Icon(Icons.edit_note_rounded, size: 20),
                        padding: const EdgeInsets.all(9),
                        constraints: const BoxConstraints(),
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
