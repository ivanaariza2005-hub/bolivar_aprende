import '../../../core/network/api_client.dart';
import 'user.dart';

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final User user;
}

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _client.post(
      '/auth/register',
      body: <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
        'passwordConfirmation': passwordConfirmation,
      },
    );

    return _toSession(data);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );

    return _toSession(data);
  }

  Future<User> me() async {
    final data = await _client.get('/auth/me') as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  AuthSession _toSession(dynamic data) {
    final map = data as Map<String, dynamic>;
    return AuthSession(
      token: map['token'] as String,
      user: User.fromJson(map['user'] as Map<String, dynamic>),
    );
  }
}
