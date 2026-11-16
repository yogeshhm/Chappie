import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';
import '../services/outreach_service.dart';
import '../theme/app_theme.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final VoidCallback onTap;

  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.read<LeadProvider>();

    final phones = lead.allPhones;
    final statusColor = AppTheme.getStatusColor(lead.callStatus);
    final priorityColor = AppTheme.getPriorityColor(lead.leadPriority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Business Name + Location & Priority Pill
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
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lead.isCompanyVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 15,
                                  color: Color(0xFF3B82F6),
                                ),
                              ],
                            ],
                          ),
                          if (lead.location.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    lead.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        lead.leadPriority.toUpperCase(),
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                // Services / Description
                if (lead.services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    lead.services,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Caution / Sheet Note (if present)
                if (lead.hasCaution || lead.notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1710) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFD97706),
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            lead.cautionNotes.isNotEmpty ? lead.cautionNotes : lead.notes,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 10),

                // Phone Numbers & Direct Outreach Actions
                if (phones.isNotEmpty) ...[
                  ...phones.map((phone) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          // Exact phone number text with phone icon
                          const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),

                          // Direct Call Button (Goes straight to dialpad, zero prediction)
                          ElevatedButton.icon(
                            onPressed: () async {
                              await OutreachService.makePhoneCall(phone);
                              if (context.mounted) {
                                provider.recordCallAttempt(lead.id);
                              }
                            },
                            icon: const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                            label: const Text(
                              'Call',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // WhatsApp Button
                          IconButton(
                            tooltip: 'Chat on WhatsApp',
                            onPressed: () => OutreachService.openWhatsApp(phone),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 17),
                            padding: const EdgeInsets.all(7),
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'No phone number available in sheet',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // 1-Tap Status Selector (Zero modals, zero confirmation popups)
                Text(
                  'STATUS: ${lead.callStatus.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildStatusPill(
                      context: context,
                      label: 'Not Called',
                      targetStatus: 'Not Called',
                      currentStatus: lead.callStatus,
                      activeColor: const Color(0xFF64748B),
                      onTap: () => provider.updateLeadStatus(lead.id, 'Not Called'),
                    ),
                    _buildStatusPill(
                      context: context,
                      label: 'Interested',
                      targetStatus: 'Interested',
                      currentStatus: lead.callStatus,
                      activeColor: const Color(0xFF10B981),
                      onTap: () => provider.updateLeadStatus(lead.id, 'Interested'),
                    ),
                    _buildStatusPill(
                      context: context,
                      label: 'Follow-up',
                      targetStatus: 'Follow-up',
                      currentStatus: lead.callStatus,
                      activeColor: const Color(0xFFF59E0B),
                      onTap: () => provider.updateLeadStatus(lead.id, 'Follow-up'),
                    ),
                    _buildStatusPill(
                      context: context,
                      label: 'No Answer',
                      targetStatus: 'Called - No Answer',
                      currentStatus: lead.callStatus,
                      activeColor: const Color(0xFF8B5CF6),
                      onTap: () => provider.updateLeadStatus(lead.id, 'Called - No Answer'),
                    ),
                    _buildStatusPill(
                      context: context,
                      label: 'Not Interested',
                      targetStatus: 'Not Interested',
                      currentStatus: lead.callStatus,
                      activeColor: const Color(0xFFEF4444),
                      onTap: () => provider.updateLeadStatus(lead.id, 'Not Interested'),
                    ),
                  ],
                ),

                // Optional Quick Link Icons (Instagram, Website, Maps)
                if (lead.hasInstagram || lead.hasWebsite || lead.location.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (lead.hasInstagram) ...[
                        InkWell(
                          onTap: () => OutreachService.openInstagram(lead.instagramUsername),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 13, color: Color(0xFFE1306C)),
                                const SizedBox(width: 3),
                                Text(
                                  '@${lead.instagramUsername}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFE1306C), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (lead.hasWebsite) ...[
                        InkWell(
                          onTap: () => OutreachService.openUrl(lead.websiteLink),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.language_rounded, size: 13, color: Color(0xFF3B82F6)),
                                SizedBox(width: 3),
                                Text(
                                  'Website',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Details',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
