class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.fieldErrors = const <String, String>{},
  });

  final String code;
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  static const String defaultMessage =
      'No fue posible completar la solicitud. Intenta de nuevo.';
  static const String networkMessage =
      'Sin conexión. Revisa tu red e intenta de nuevo.';
  static const String timeoutMessage =
      'La conexión tardó demasiado. Intenta de nuevo.';

  factory ApiException.fromResponse(int? statusCode, dynamic data) {
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final error = data['error'] as Map<String, dynamic>;
      final fieldErrors = <String, String>{};
      final details = error['details'];

      if (details is List<dynamic>) {
        for (final detail in details) {
          if (detail is Map<String, dynamic> &&
              detail['field'] is String &&
              detail['message'] is String) {
            fieldErrors[detail['field'] as String] =
                detail['message'] as String;
          }
        }
      }

      return ApiException(
        code: error['code']?.toString() ?? 'UNKNOWN',
        message: error['message']?.toString() ?? defaultMessage,
        statusCode: statusCode,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException(
      code: 'UNKNOWN',
      message: defaultMessage,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code, $message)';
}
