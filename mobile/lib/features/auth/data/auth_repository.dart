import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_api.dart';
import 'user.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient client,
    required TokenStorage tokenStorage,
    AuthApi? api,
  })  : _client = client,
        _tokenStorage = tokenStorage,
        _api = api ?? AuthApi(client);

  final ApiClient _client;
  final TokenStorage _tokenStorage;
  final AuthApi _api;

  Future<bool> restoreToken() async {
    final token = await _tokenStorage.read();

    if (token == null || token.isEmpty) {
      return false;
    }

    _client.setAuthToken(token);
    return true;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.login(
      email: email.toLowerCase().trim(),
      password: password,
    );
    await _persistSession(session.token);
    return session;
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final session = await _api.register(
      fullName: fullName.trim(),
      email: email.toLowerCase().trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    await _persistSession(session.token);
    return session;
  }

  Future<User> me() => _api.me();

  Future<void> clearSession() async {
    _client.setAuthToken(null);
    await _tokenStorage.clear();
  }

  Future<void> _persistSession(String token) async {
    _client.setAuthToken(token);
    await _tokenStorage.write(token);
  }
}
