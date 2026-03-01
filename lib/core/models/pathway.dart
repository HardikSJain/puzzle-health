class Pathway {
  final String now;
  final String next;
  final String later;
  final int confidence; // 0-100

  const Pathway({
    required this.now,
    required this.next,
    required this.later,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
    'now': now,
    'next': next,
    'later': later,
    'confidence': confidence,
  };

  factory Pathway.fromJson(Map<String, dynamic> json) {
    return Pathway(
      now: json['now'] as String? ?? 'Baseline unavailable',
      next: json['next'] as String? ?? 'Build consistency',
      later: json['later'] as String? ?? 'Progress adapts each week',
      confidence: json['confidence'] as int? ?? 50,
    );
  }
}
