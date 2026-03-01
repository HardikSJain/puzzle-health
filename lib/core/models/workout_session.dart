class WorkoutSession {
  final String id;
  final String type; // running, walking, cycling, other
  final DateTime start;
  final DateTime end;
  final double durationMinutes;
  final double? distanceMeters;
  final double? paceMinPerKm;
  final String source;

  const WorkoutSession({
    required this.id,
    required this.type,
    required this.start,
    required this.end,
    required this.durationMinutes,
    this.distanceMeters,
    this.paceMinPerKm,
    required this.source,
  });

  bool get isRun => type == 'running';

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'durationMinutes': durationMinutes,
    'distanceMeters': distanceMeters,
    'paceMinPerKm': paceMinPerKm,
    'source': source,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      type: json['type'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      durationMinutes: (json['durationMinutes'] as num).toDouble(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble(),
      source: json['source'] as String? ?? 'unknown',
    );
  }
}
