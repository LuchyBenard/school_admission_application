class SchoolModel {
  final String name;
  final String country;
  final String state;
  final String website;
  final String? imageUrl;
  final String? description;
  final String? applicationFee;
  final String? deadline;
  final bool isFeatured;
  final List<String> domains;

  SchoolModel({
    required this.name,
    required this.country,
    required this.state,
    required this.website,
    this.imageUrl,
    this.description,
    this.applicationFee,
    this.deadline,
    this.isFeatured = false,
    this.domains = const [],
  });

  /// Parsed deadline as a DateTime. Returns null when unset/invalid.
  /// Date-only values (e.g. "2026-09-30") are treated as the end of that
  /// day so applications remain open throughout the deadline day.
  DateTime? get deadlineDate {
    final raw = deadline;
    if (raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    final hasTime = raw.contains(':');
    if (!hasTime) {
      return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
    }
    return parsed;
  }

  /// True when a deadline is set and has already passed (i.e. now is after it).
  bool get isDeadlinePassed {
    final dt = deadlineDate;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt);
  }

  /// From external API response (GitHub mirror / Hipolabs)
  factory SchoolModel.fromApi(Map<String, dynamic> json) {
    return SchoolModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state-province'] ?? '',
      website: (json['web_pages'] as List?)?.first ?? '',
      domains: List<String>.from(json['domains'] ?? []),
    );
  }

  /// From Firestore
  factory SchoolModel.fromFirestore(Map<String, dynamic> json) {
    return SchoolModel(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      website: json['website'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
      applicationFee: json['applicationFee'],
      deadline: json['deadline'],
      isFeatured: json['isFeatured'] ?? false,
      domains: List<String>.from(json['domains'] ?? []),
    );
  }

  /// To Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'state': state,
      'website': website,
      'imageUrl': imageUrl,
      'description': description,
      'applicationFee': applicationFee,
      'deadline': deadline,
      'isFeatured': isFeatured,
      'domains': domains,
    };
  }
}