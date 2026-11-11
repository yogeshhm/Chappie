import 'dart:convert';

class PitchTemplateModel {
  final String id;
  final String title;
  final String channel; // 'WhatsApp', 'Email', 'Call Script', 'Instagram DM'
  final String content;
  final bool isActive;

  PitchTemplateModel({
    required this.id,
    required this.title,
    required this.channel,
    required this.content,
    this.isActive = true,
  });

  String format({
    required String businessName,
    required String services,
    required String location,
    String? website,
    String? handle,
  }) {
    return content
        .replaceAll('{{name}}', businessName)
        .replaceAll('{{services}}', services)
        .replaceAll('{{location}}', location.isNotEmpty ? location : 'your area')
        .replaceAll('{{website}}', website ?? '')
        .replaceAll('{{handle}}', handle != null && handle.isNotEmpty ? '@$handle' : '');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'channel': channel,
      'content': content,
      'is_active': isActive,
    };
  }

  factory PitchTemplateModel.fromMap(Map<String, dynamic> map) {
    return PitchTemplateModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      channel: map['channel']?.toString() ?? 'WhatsApp',
      content: map['content']?.toString() ?? '',
      isActive: map['is_active'] != false,
    );
  }

  String toJson() => json.encode(toMap());
  factory PitchTemplateModel.fromJson(String source) =>
      PitchTemplateModel.fromMap(json.decode(source));
}
