import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lead_model.dart';
import '../providers/lead_provider.dart';

class CallLogDialog extends StatefulWidget {
  final LeadModel lead;

  const CallLogDialog({super.key, required this.lead});

  static Future<void> show(BuildContext context, LeadModel lead) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CallLogDialog(lead: lead),
    );
  }

  @override
  State<CallLogDialog> createState() => _CallLogDialogState();
}

class _CallLogDialogState extends State<CallLogDialog> {
  String _selectedOutcome = 'Interested';
  String _selectedOffering = 'Custom Web Development (falconate.com)';
  DateTime? _selectedFollowUpDate;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _outcomes = [
    {
      'label': 'Interested (Hot Lead)',
      'value': 'Interested',
      'icon': Icons.local_fire_department,
      'color': Color(0xFF10B981)
    },
    {
      'label': 'Follow-up Scheduled',
      'value': 'Follow-up Scheduled',
      'icon': Icons.calendar_month,
      'color': Color(0xFFF59E0B)
    },
    {
      'label': 'Connected - Pitch Sent',
      'value': 'Pitch Sent',
      'icon': Icons.send,
      'color': Color(0xFF0EA5E9)
    },
    {
      'label': 'No Answer / Busy',
      'value': 'Called - No Answer',
      'icon': Icons.phone_missed,
      'color': Color(0xFF8B5CF6)
    },
    {
      'label': 'Closed Won (Signed Client)',
      'value': 'Closed Won',
      'icon': Icons.verified,
      'color': Color(0xFF059669)
    },
    {
      'label': 'Not Interested',
      'value': 'Not Interested',
      'icon': Icons.thumb_down,
      'color': Color(0xFFEF4444)
    },
    {
      'label': 'Invalid Number',
      'value': 'Invalid Number',
      'icon': Icons.cancel,
      'color': Color(0xFF64748B)
    },
  ];

  final List<String> _offerings = [
    'Custom Web Development (falconate.com)',
    'Mobile App (Flutter / Android / iOS)',
    'Website Redesign & Speed Optimization',
    'E-commerce & Client Booking Portal',
    'SEO & Digital Transformation',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFollowUpDate ?? now.add(const Duration(days: 2)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 11, minute: 0),
      );

      setState(() {
        _selectedFollowUpDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? 11,
          pickedTime?.minute ?? 0,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_in_talk, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Outreach Interaction',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.lead.businessName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF0EA5E9),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 28),

            // Outcome selection
            Text(
              'Call / Pitch Outcome',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _outcomes.map((item) {
                final isSelected = _selectedOutcome == item['value'];
                final itemColor = item['color'] as Color;

                return ChoiceChip(
                  avatar: Icon(
                    item['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : itemColor,
                  ),
                  label: Text(item['label'] as String),
                  selected: isSelected,
                  selectedColor: itemColor,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedOutcome = item['value'] as String;
                        // Auto-prompt follow-up if outcome is follow-up
                        if (_selectedOutcome == 'Follow-up Scheduled' && _selectedFollowUpDate == null) {
                          _selectedFollowUpDate = DateTime.now().add(const Duration(days: 2));
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Falconate Offering Pitched
            Text(
              'Falconate Service Pitched',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedOffering,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: _offerings.map((offering) {
                    return DropdownMenuItem(
                      value: offering,
                      child: Text(offering, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOffering = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Next Follow-Up Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Follow-up Reminder',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickFollowUpDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedFollowUpDate != null
                                  ? const Color(0xFF0EA5E9)
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: _selectedFollowUpDate != null
                                    ? const Color(0xFF0EA5E9)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedFollowUpDate != null
                                      ? DateFormat('EEE, MMM d, yyyy • h:mm a')
                                          .format(_selectedFollowUpDate!)
                                      : 'Set Follow-up Date & Time',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _selectedFollowUpDate != null
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : Colors.grey,
                                    fontWeight: _selectedFollowUpDate != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (_selectedFollowUpDate != null)
                                GestureDetector(
                                  onTap: () => setState(() => _selectedFollowUpDate = null),
                                  child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Discussion Notes
            Text(
              'Call / Conversation Notes',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Spoke with owner, interested in mobile app for order tracking. Budget ~₹40k. Send demo proposal.',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Save Action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final provider = context.read<LeadProvider>();
                  await provider.logCall(
                    leadId: widget.lead.id,
                    outcome: _selectedOutcome,
                    notes: _notesController.text.trim(),
                    nextFollowUpDate: _selectedFollowUpDate,
                    pitchedOffering: _selectedOffering,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Interaction logged for ${widget.lead.businessName} (Status: $_selectedOutcome)'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Save & Update Lead Status',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
