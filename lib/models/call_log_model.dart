import 'dart:convert';

class CallLogModel {
  final String id;
  final String leadId;
  final String outcome;
  final String notes;
  final DateTime? nextFollowUpDate;
  final int durationSeconds;
  final String pitchedOffering;
  final DateTime createdAt;

  CallLogModel({
    required this.id,
    required this.leadId,
    required this.outcome,
    this.notes = '',
    this.nextFollowUpDate,
    this.durationSeconds = 0,
    this.pitchedOffering = 'Custom Web Development',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lead_id': leadId,
      'outcome': outcome,
      'notes': notes,
      'next_follow_up_date': nextFollowUpDate?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'pitched_offering': pitchedOffering,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CallLogModel.fromMap(Map<String, dynamic> map) {
    return CallLogModel(
      id: map['id']?.toString() ?? '',
      leadId: map['lead_id']?.toString() ?? '',
      outcome: map['outcome']?.toString() ?? 'Connected',
      notes: map['notes']?.toString() ?? '',
      nextFollowUpDate: map['next_follow_up_date'] != null
          ? DateTime.tryParse(map['next_follow_up_date'].toString())
          : null,
      durationSeconds: int.tryParse(map['duration_seconds']?.toString() ?? '0') ?? 0,
      pitchedOffering: map['pitched_offering']?.toString() ?? 'Custom Web Development',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory CallLogModel.fromJson(String source) => CallLogModel.fromMap(json.decode(source));
}
