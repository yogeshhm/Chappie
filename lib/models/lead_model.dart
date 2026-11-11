import 'dart:convert';

class LeadModel {
  final String id;
  final String businessName;
  final String instagramUsername;
  final String services;
  final String phoneNumbers;
  final String email;
  final String location;
  final int instagramFollowers;
  final int instagramPosts;
  final String websiteStatus;
  final String websiteLink;
  final String leadPriority; // 'High', 'Medium', 'Low'
  final String callStatus; // 'Not Called', 'Called - No Answer', 'Connected', 'Interested', 'Follow-up Scheduled', 'Pitch Sent', 'Closed Won', 'Not Interested', 'Invalid Number'
  final DateTime? lastCallDate;
  final DateTime? nextFollowUpDate;
  final String notes;
  final String cautionNotes;
  final bool isCompanyVerified;
  final bool isNestedDataVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadModel({
    required this.id,
    required this.businessName,
    this.instagramUsername = '',
    this.services = '',
    this.phoneNumbers = '',
    this.email = '',
    this.location = '',
    this.instagramFollowers = 0,
    this.instagramPosts = 0,
    this.websiteStatus = 'No matching website verified',
    this.websiteLink = '',
    this.leadPriority = 'Medium',
    this.callStatus = 'Not Called',
    this.lastCallDate,
    this.nextFollowUpDate,
    this.notes = '',
    this.cautionNotes = '',
    this.isCompanyVerified = true,
    this.isNestedDataVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Helper getters
  List<String> get allPhones {
    if (phoneNumbers.isEmpty) return [];
    return phoneNumbers
        .split(RegExp(r'[,/;&]+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  String? get primaryPhone {
    final phones = allPhones;
    return phones.isNotEmpty ? phones.first : null;
  }

  bool get hasPhone => primaryPhone != null && primaryPhone!.isNotEmpty;
  bool get hasEmail => email.trim().isNotEmpty;
  bool get hasWebsite => websiteLink.trim().isNotEmpty;
  bool get hasInstagram =>
      instagramUsername.trim().isNotEmpty &&
      instagramUsername.toLowerCase() != 'not visible';

  bool get hasCaution => cautionNotes.trim().isNotEmpty;
  bool get isHighPriority => leadPriority.toLowerCase() == 'high';

  bool get isFollowUpDue {
    if (nextFollowUpDate == null) return false;
    final now = DateTime.now();
    return nextFollowUpDate!.isBefore(now.add(const Duration(hours: 12)));
  }

  LeadModel copyWith({
    String? id,
    String? businessName,
    String? instagramUsername,
    String? services,
    String? phoneNumbers,
    String? email,
    String? location,
    int? instagramFollowers,
    int? instagramPosts,
    String? websiteStatus,
    String? websiteLink,
    String? leadPriority,
    String? callStatus,
    DateTime? lastCallDate,
    DateTime? nextFollowUpDate,
    String? notes,
    String? cautionNotes,
    bool? isCompanyVerified,
    bool? isNestedDataVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      services: services ?? this.services,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      email: email ?? this.email,
      location: location ?? this.location,
      instagramFollowers: instagramFollowers ?? this.instagramFollowers,
      instagramPosts: instagramPosts ?? this.instagramPosts,
      websiteStatus: websiteStatus ?? this.websiteStatus,
      websiteLink: websiteLink ?? this.websiteLink,
      leadPriority: leadPriority ?? this.leadPriority,
      callStatus: callStatus ?? this.callStatus,
      lastCallDate: lastCallDate ?? this.lastCallDate,
      nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
      notes: notes ?? this.notes,
      cautionNotes: cautionNotes ?? this.cautionNotes,
      isCompanyVerified: isCompanyVerified ?? this.isCompanyVerified,
      isNestedDataVerified: isNestedDataVerified ?? this.isNestedDataVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'instagram_username': instagramUsername,
      'services': services,
      'phone_numbers': phoneNumbers,
      'email': email,
      'location': location,
      'instagram_followers': instagramFollowers,
      'instagram_posts': instagramPosts,
      'website_status': websiteStatus,
      'website_link': websiteLink,
      'lead_priority': leadPriority,
      'call_status': callStatus,
      'last_call_date': lastCallDate?.toIso8601String(),
      'next_follow_up_date': nextFollowUpDate?.toIso8601String(),
      'notes': notes,
      'caution_notes': cautionNotes,
      'is_company_verified': isCompanyVerified,
      'is_nested_data_verified': isNestedDataVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      id: map['id']?.toString() ?? '',
      businessName: map['business_name']?.toString() ?? '',
      instagramUsername: map['instagram_username']?.toString() ?? '',
      services: map['services']?.toString() ?? '',
      phoneNumbers: map['phone_numbers']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      instagramFollowers: int.tryParse(map['instagram_followers']?.toString() ?? '0') ?? 0,
      instagramPosts: int.tryParse(map['instagram_posts']?.toString() ?? '0') ?? 0,
      websiteStatus: map['website_status']?.toString() ?? 'No matching website verified',
      websiteLink: map['website_link']?.toString() ?? '',
      leadPriority: map['lead_priority']?.toString() ?? 'Medium',
      callStatus: map['call_status']?.toString() ?? 'Not Called',
      lastCallDate: map['last_call_date'] != null
          ? DateTime.tryParse(map['last_call_date'].toString())
          : null,
      nextFollowUpDate: map['next_follow_up_date'] != null
          ? DateTime.tryParse(map['next_follow_up_date'].toString())
          : null,
      notes: map['notes']?.toString() ?? '',
      cautionNotes: map['caution_notes']?.toString() ?? '',
      isCompanyVerified: map['is_company_verified'] == true ||
          map['is_company_verified'] == 1 ||
          map['is_company_verified'] == 'true',
      isNestedDataVerified: map['is_nested_data_verified'] == true ||
          map['is_nested_data_verified'] == 1 ||
          map['is_nested_data_verified'] == 'true',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory LeadModel.fromJson(String source) => LeadModel.fromMap(json.decode(source));
}
