import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/token_storage_provider.dart';
import '../data/auth_api.dart';
import '../models/auth_models.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class AuthState {
  final AuthStatus status;
  final UserMe? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserMe? user, String? error}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        error: error,
      );
}

final authStateProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref)..loadFromStorage();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref)
      : super(const AuthState(status: AuthStatus.unauthenticated));


  Future<void> loadFromStorage() async {
    final storage = ref.read(tokenStorageProvider);

    final access = await storage.readAccessToken();
    final refresh = await storage.readRefreshToken();

    if (access == null || refresh == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final me = await ref.read(authApiProvider).me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } catch (_) {
      await storage.clear();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  String _msgFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return fallback;
  }

  Future<String?> registerEmail(String email, {bool sendCodeAfter = true}) async {
    try {
      await ref.read(authApiProvider).registerEmail(email: email);
      if (sendCodeAfter) {
        await ref.read(authApiProvider).sendCode(email: email);
      }
      return null;
    } on DioException catch (e) {
      return _msgFromDio(e, 'Falha ao registrar e-mail');
    } catch (_) {
      return 'Falha ao registrar e-mail';
    }
  }

  Future<String?> requestCode(String email) async {
    try {
      await ref.read(authApiProvider).sendCode(email: email);
      return null;
    } on DioException catch (e) {
      return _msgFromDio(e, 'Falha ao enviar código');
    } catch (_) {
      return 'Falha ao enviar código';
    }
  }

  Future<void> verifyCode(String email, String code) async {
    state = const AuthState(status: AuthStatus.authenticating);
    try {
      final api = ref.read(authApiProvider);
      final tokens = await api.verifyCode(email: email, code: code);
      await ref.read(tokenStorageProvider).saveTokens(tokens);
      final me = await api.me();
      state = AuthState(status: AuthStatus.authenticated, user: me);
    } on DioException catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _msgFromDio(e, 'Código inválido ou expirado'),
      );
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Código inválido ou expirado',
      );
    }
  }


  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
