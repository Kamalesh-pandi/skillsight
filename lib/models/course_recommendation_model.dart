class CourseRecommendationModel {
  final String id;
  final String title;
  final String platform;
  final String url;
  final bool isPaid;
  final String price; // e.g. "Free", "$19.99"
  final String duration; // e.g. "4 weeks", "10 hours"
  final String level; // Beginner, Intermediate, Advanced
  final double rating;
  final List<String> skills;

  CourseRecommendationModel({
    required this.id,
    required this.title,
    required this.platform,
    required this.url,
    required this.isPaid,
    required this.price,
    required this.duration,
    required this.level,
    required this.rating,
    required this.skills,
  });

  factory CourseRecommendationModel.fromMap(Map<String, dynamic> map) {
    return CourseRecommendationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      platform: map['platform'] ?? '',
      url: map['url'] ?? '',
      isPaid: map['isPaid'] ?? false,
      price: map['price'] ?? '',
      duration: map['duration'] ?? '',
      level: map['level'] ?? 'Beginner',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      skills: List<String>.from(map['skills'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'url': url,
      'isPaid': isPaid,
      'price': price,
      'duration': duration,
      'level': level,
      'rating': rating,
      'skills': skills,
    };
  }
}
