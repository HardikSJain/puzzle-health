enum FitnessState {
  sedentaryStarter,
  inconsistentWalker,
  consistentWalker,
  emergingRunner,
  regularRunner,
  unstableLoad,
}

extension FitnessStateX on FitnessState {
  String get key {
    switch (this) {
      case FitnessState.sedentaryStarter:
        return 'sedentary_starter';
      case FitnessState.inconsistentWalker:
        return 'inconsistent_walker';
      case FitnessState.consistentWalker:
        return 'consistent_walker';
      case FitnessState.emergingRunner:
        return 'emerging_runner';
      case FitnessState.regularRunner:
        return 'regular_runner';
      case FitnessState.unstableLoad:
        return 'unstable_load';
    }
  }

  String get label {
    switch (this) {
      case FitnessState.sedentaryStarter:
        return 'Starter';
      case FitnessState.inconsistentWalker:
        return 'Inconsistent walker';
      case FitnessState.consistentWalker:
        return 'Consistent walker';
      case FitnessState.emergingRunner:
        return 'Emerging runner';
      case FitnessState.regularRunner:
        return 'Regular runner';
      case FitnessState.unstableLoad:
        return 'Unstable load';
    }
  }

  static FitnessState fromKey(String? key) {
    return FitnessState.values.firstWhere(
      (state) => state.key == key,
      orElse: () => FitnessState.inconsistentWalker,
    );
  }
}
