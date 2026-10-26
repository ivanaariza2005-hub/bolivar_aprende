import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        );

  final Dio _dio;
  String? _token;

  void Function()? onUnauthorized;

  void setAuthToken(String? token) {
    _token = token;

    if (token == null) {
      _dio.options.headers.remove('Authorization');
      return;
    }

    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _request(() => _dio.post<dynamic>(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _request(() => _dio.put<dynamic>(path, data: body));

  Future<dynamic> delete(String path) =>
      _request(() => _dio.delete<dynamic>(path));

  Future<dynamic> _request(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (error) {
      final apiException = _mapError(error);

      if (apiException.statusCode == 401 && _token != null) {
        onUnauthorized?.call();
      }

      throw apiException;
    }
  }

  ApiException _mapError(DioException error) {
    final response = error.response;

    if (response != null) {
      return ApiException.fromResponse(response.statusCode, response.data);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          code: 'TIMEOUT',
          message: ApiException.timeoutMessage,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          code: 'NETWORK_ERROR',
          message: ApiException.networkMessage,
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return const ApiException(
          code: 'UNKNOWN',
          message: ApiException.defaultMessage,
        );
    }
  }
}
