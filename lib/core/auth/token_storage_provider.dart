import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../features/auth/models/auth_models.dart';

class TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';


  final FlutterSecureStorage _secure = FlutterSecureStorage();

  Future<void> saveTokens(AuthTokens t) async {
    await _secure.write(key: _kAccess, value: t.accessToken);
    await _secure.write(key: _kRefresh, value: t.refreshToken);
  }

  Future<String?> readAccessToken() => _secure.read(key: _kAccess);
  Future<String?> readRefreshToken() => _secure.read(key: _kRefresh);

  Future<void> clear() async {
    await _secure.delete(key: _kAccess);
    await _secure.delete(key: _kRefresh);

    await _secure.deleteAll();
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
