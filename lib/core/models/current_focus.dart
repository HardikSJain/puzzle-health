import 'dart:convert';

import 'fitness_state.dart';
import 'pathway.dart';

class CurrentFocus {
  final String weekStartIso; // YYYY-MM-DD at local midnight
  final int targetSteps;
  final String reason;
  final String state; // normal_progression | low_compliance | consistency_rebuild
  final int baselineSteps;
  final double? completionRate; // last week's completion rate when archived
  final int? targetRunsPerWeek;

  // Intelligence metadata
  final String goalType; // steps | run_frequency
  final FitnessState fitnessState;
  final List<String> overlays;
  final Pathway? pathway;
  final String? changeSummary;

  const CurrentFocus({
    required this.weekStartIso,
    required this.targetSteps,
    required this.reason,
    required this.state,
    required this.baselineSteps,
    this.completionRate,
    this.targetRunsPerWeek,
    this.goalType = 'steps',
    this.fitnessState = FitnessState.inconsistentWalker,
    this.overlays = const [],
    this.pathway,
    this.changeSummary,
  });

  DateTime get weekStart => DateTime.parse(weekStartIso);

  Map<String, dynamic> toJson() => {
    'weekStartIso': weekStartIso,
    'targetSteps': targetSteps,
    'reason': reason,
    'state': state,
    'baselineSteps': baselineSteps,
    'completionRate': completionRate,
    'targetRunsPerWeek': targetRunsPerWeek,
    'goalType': goalType,
    'fitnessState': fitnessState.key,
    'overlays': overlays,
    'pathway': pathway?.toJson(),
    'changeSummary': changeSummary,
  };

  factory CurrentFocus.fromJson(Map<String, dynamic> json) => CurrentFocus(
    weekStartIso: json['weekStartIso'] as String,
    targetSteps: json['targetSteps'] as int,
    reason: json['reason'] as String,
    state: json['state'] as String,
    baselineSteps: json['baselineSteps'] as int,
    completionRate: (json['completionRate'] as num?)?.toDouble(),
    targetRunsPerWeek: json['targetRunsPerWeek'] as int?,
    goalType: json['goalType'] as String? ?? 'steps',
    fitnessState: FitnessStateX.fromKey(json['fitnessState'] as String?),
    overlays: (json['overlays'] as List<dynamic>?)?.cast<String>() ?? const [],
    pathway: json['pathway'] != null
        ? Pathway.fromJson(json['pathway'] as Map<String, dynamic>)
        : null,
    changeSummary: json['changeSummary'] as String?,
  );

  String encode() => jsonEncode(toJson());

  static CurrentFocus decode(String raw) {
    return CurrentFocus.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
