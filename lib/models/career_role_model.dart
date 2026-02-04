class CareerRoleModel {
  final String id;
  final String title;
  final String category;
  final int? iconCode;
  final List<String> requiredSkills;
  final String description;

  CareerRoleModel({
    required this.id,
    required this.title,
    required this.category,
    this.iconCode,
    required this.requiredSkills,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'iconCode': iconCode,
      'requiredSkills': requiredSkills,
      'description': description,
    };
  }

  factory CareerRoleModel.fromMap(Map<String, dynamic> map) {
    return CareerRoleModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? 'General',
      iconCode: map['iconCode'],
      requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
      description: map['description'] ?? '',
    );
  }
}
