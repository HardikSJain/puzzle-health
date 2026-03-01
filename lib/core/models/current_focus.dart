import 'dart:convert';

class CurrentFocus {
  final String weekStartIso; // YYYY-MM-DD at local midnight
  final int targetSteps;
  final String reason;
  final String state; // normal_progression | low_compliance | consistency_rebuild
  final int baselineSteps;
  final double? completionRate; // last week's completion rate when archived

  const CurrentFocus({
    required this.weekStartIso,
    required this.targetSteps,
    required this.reason,
    required this.state,
    required this.baselineSteps,
    this.completionRate,
  });

  DateTime get weekStart => DateTime.parse(weekStartIso);

  Map<String, dynamic> toJson() => {
    'weekStartIso': weekStartIso,
    'targetSteps': targetSteps,
    'reason': reason,
    'state': state,
    'baselineSteps': baselineSteps,
    'completionRate': completionRate,
  };

  factory CurrentFocus.fromJson(Map<String, dynamic> json) => CurrentFocus(
    weekStartIso: json['weekStartIso'] as String,
    targetSteps: json['targetSteps'] as int,
    reason: json['reason'] as String,
    state: json['state'] as String,
    baselineSteps: json['baselineSteps'] as int,
    completionRate: (json['completionRate'] as num?)?.toDouble(),
  );

  String encode() => jsonEncode(toJson());

  static CurrentFocus decode(String raw) {
    return CurrentFocus.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
