class AgeCalculator {
  /// Validates if a user is at least 16 years old given their birthdate string (YYYY-MM-DD) or DateTime.
  static bool isAtLeast16(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;

    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }

    return age >= 16;
  }

  static DateTime? parseBirthdate(String birthdateStr) {
    try {
      return DateTime.parse(birthdateStr);
    } catch (_) {
      return null;
    }
  }
}
