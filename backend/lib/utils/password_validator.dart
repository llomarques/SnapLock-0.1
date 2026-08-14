class PasswordValidator {
  /// Validates password complexity per RN07:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter (A-Z)
  /// - At least 1 lowercase letter (a-z)
  /// - At least 1 number (0-9)
  /// - At least 1 special character (@, #, $, %, !, &, *, ?, etc.)
  static String? validate(String password) {
    if (password.length < 8) {
      return 'A senha deve conter no mínimo 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra maiúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra minúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'A senha deve conter pelo menos um número.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return r'A senha deve conter pelo menos um caractere especial (ex: @, #, $, !).';
    }

    return null; // Valid
  }
}
