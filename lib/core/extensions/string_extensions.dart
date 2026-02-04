extension StringExtension on String {
  String toSentenceCase() {
    if (isEmpty) return '';
    if (length == 1) return this[0].toUpperCase();
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String capitalizeFirstLetter() {
    if (isEmpty) return '';
    if (length == 1) return this[0].toUpperCase();
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeAllWords() {
    if (isEmpty) return '';
    return split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (word.length == 1) return word[0].toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String splitLongStringForLogging() => splitMapJoin(
    RegExp('.{250}'),
    onMatch: (match) => '${match.group(0)}',
    onNonMatch: (last) => '\n$last',
  );
}
