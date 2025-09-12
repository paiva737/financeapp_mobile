import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/models/auth_models.dart';

class TokenStorage {
  static const _kTokens = 'auth_tokens';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _kTokens, value: jsonEncode(tokens.toJson()));
  }

  Future<AuthTokens?> readTokens() async {
    final raw = await _storage.read(key: _kTokens);
    if (raw == null) return null;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return AuthTokens.fromJson(j);
  }

  Future<String?> readAccessToken() async => (await readTokens())?.accessToken;
  Future<String?> readRefreshToken() async => (await readTokens())?.refreshToken;

  Future<void> clear() async => _storage.delete(key: _kTokens);
}
