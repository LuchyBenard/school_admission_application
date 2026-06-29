class SchoolModel {
  final String name;
  final String country;
  final String state;
  final String website;
  final String? imageURL;
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
    this.imageURL,
    this.description,
    this.applicationFee,
    this.deadline,
    this.isFeatured = false,
    this.domains = const [],
  });

  /// From Hipolabs API response
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
      imageURL: json['imageURL'],
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
      'imageURL': imageURL,
      'description': description,
      'applicationFee': applicationFee,
      'deadline': deadline,
      'isFeatured': isFeatured,
      'domains': domains,
    };
  }
}