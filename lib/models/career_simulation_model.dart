class CareerSimulationModel {
  final String currentRole;
  final String futureRole;
  final List<TimelineEvent> timelineEvents;
  final List<String> recommendedSkills;
  final Map<String, dynamic> salaryProjection;

  CareerSimulationModel({
    required this.currentRole,
    required this.futureRole,
    required this.timelineEvents,
    required this.recommendedSkills,
    required this.salaryProjection,
  });

  factory CareerSimulationModel.fromJson(Map<String, dynamic> json) {
    return CareerSimulationModel(
      currentRole: json['currentRole'] ?? '',
      futureRole: json['futureRole'] ?? '',
      timelineEvents: (json['timelineEvents'] as List?)
              ?.map((e) => TimelineEvent.fromJson(e))
              .toList() ??
          [],
      recommendedSkills: List<String>.from(json['recommendedSkills'] ?? []),
      salaryProjection: json['salaryProjection'] ?? {},
    );
  }
}

class TimelineEvent {
  final int yearOffset;
  final String title;
  final String description;
  final String type; // 'milestone', 'learning', 'promotion'

  TimelineEvent({
    required this.yearOffset,
    required this.title,
    required this.description,
    required this.type,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      yearOffset: json['yearOffset'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'milestone',
    );
  }
}
