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
this.domains = const[],
});


}