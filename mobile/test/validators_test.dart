import 'package:bolivar_aprende/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('acepta un correo válido', () {
      expect(Validators.email('demo@bolivaraprende.co'), isNull);
    });

    test('rechaza un correo vacío', () {
      expect(Validators.email(''), 'Ingresa tu correo electrónico.');
    });

    test('rechaza un correo sin dominio', () {
      expect(Validators.email('demo@'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('acepta una contraseña con letra y número', () {
      expect(Validators.password('Demo12345'), isNull);
    });

    test('rechaza una contraseña corta', () {
      expect(
        Validators.password('Demo1'),
        'La contraseña debe tener al menos 8 caracteres.',
      );
    });

    test('rechaza una contraseña sin números', () {
      expect(
        Validators.password('DemoDemoDemo'),
        'La contraseña debe incluir al menos un número.',
      );
    });
  });

  group('Validators.passwordConfirmation', () {
    test('acepta la confirmación que coincide', () {
      expect(Validators.passwordConfirmation('Demo12345', 'Demo12345'), isNull);
    });

    test('rechaza una confirmación distinta', () {
      expect(
        Validators.passwordConfirmation('Demo12345', 'Demo54321'),
        'Las contraseñas no coinciden.',
      );
    });
  });

  group('Validators de oferta', () {
    test('acepta un título de longitud válida', () {
      expect(Validators.title('Operario de producción'), isNull);
    });

    test('rechaza una descripción menor a 20 caracteres', () {
      expect(Validators.description('Muy corta'), isNotNull);
    });

    test('acepta una descripción de 20 caracteres o más', () {
      expect(
        Validators.description(
          'Descripción suficientemente larga para la oferta.',
        ),
        isNull,
      );
    });
  });
}
