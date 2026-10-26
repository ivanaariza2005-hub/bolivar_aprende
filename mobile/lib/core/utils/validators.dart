class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _letterPattern = RegExp('[A-Za-z]');
  static final RegExp _digitPattern = RegExp('[0-9]');

  static String? fullName(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa tu nombre completo.';
    }
    if (text.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres.';
    }
    if (text.length > 80) {
      return 'El nombre no puede superar 80 caracteres.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (text.length > 120) {
      return 'El correo no puede superar 120 caracteres.';
    }
    if (!_emailPattern.hasMatch(text)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Ingresa una contraseña.';
    }
    if (text.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (text.length > 64) {
      return 'La contraseña no puede superar 64 caracteres.';
    }
    if (!_letterPattern.hasMatch(text)) {
      return 'La contraseña debe incluir al menos una letra.';
    }
    if (!_digitPattern.hasMatch(text)) {
      return 'La contraseña debe incluir al menos un número.';
    }
    return null;
  }

  static String? passwordConfirmation(String? value, String password) {
    final text = value ?? '';

    if (text.isEmpty) {
      return 'Confirma tu contraseña.';
    }
    if (text != password) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  static String? title(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa el título de la oferta.';
    }
    if (text.length < 5) {
      return 'El título debe tener al menos 5 caracteres.';
    }
    if (text.length > 120) {
      return 'El título no puede superar 120 caracteres.';
    }
    return null;
  }

  static String? institution(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa la institución que publica la oferta.';
    }
    if (text.length < 2) {
      return 'La institución debe tener al menos 2 caracteres.';
    }
    if (text.length > 120) {
      return 'La institución no puede superar 120 caracteres.';
    }
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Ingresa la descripción de la oferta.';
    }
    if (text.length < 20) {
      return 'La descripción debe tener al menos 20 caracteres.';
    }
    if (text.length > 2000) {
      return 'La descripción no puede superar 2000 caracteres.';
    }
    return null;
  }
}
