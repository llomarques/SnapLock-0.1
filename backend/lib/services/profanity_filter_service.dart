class ProfanityFilterService {
  // Common list of inappropriate words, insults, and hate speech terms in Portuguese and English
  static final List<String> _badWords = [
    'palavra_impropria',
    'odeio',
    'odio',
    'violencia',
    'bullying',
    'ofensa',
    'xingamento',
    'idiota',
    'imbecil',
    'fdp',
    'porra',
    'caralho',
    'merda',
    'cacete',
    'desgraça',
    'arrombado',
    'otario',
    'babaca',
    'filho da puta',
    'vai tomar no cu',
    'tomar no cu',
    'racista',
    'preconceituoso',
  ];

  /// Checks if the text contains profanity or hate speech.
  static bool hasProfanity(String text) {
    if (text.trim().isEmpty) return false;
    final lower = text.toLowerCase();
    for (final word in _badWords) {
      if (lower.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// Sanitizes text by masking improper words with asterisks.
  static String filter(String text) {
    if (text.trim().isEmpty) return text;
    String result = text;
    for (final word in _badWords) {
      final pattern = RegExp(RegExp.escape(word), caseSensitive: false);
      result = result.replaceAllMapped(pattern, (match) {
        final matchedText = match.group(0)!;
        return '*' * matchedText.length;
      });
    }
    return result;
  }
}
