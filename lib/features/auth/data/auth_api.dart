import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/auth_models.dart';


const kRegisterEmailEndpoint = '/auth/register-email';
const kSendCodeEndpoint      = '/auth/send-code';
const kVerifyCodeEndpoint    = '/auth/verify-code';
const kMeEndpoint            = '/auth/me';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.read(dioProvider)));

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<void> registerEmail({required String email}) async {
    await _dio.post(kRegisterEmailEndpoint, data: {'email': email});
  }

  Future<void> sendCode({required String email}) async {
    await _dio.post(kSendCodeEndpoint, data: {'email': email});
  }

  Future<AuthTokens> verifyCode({required String email, required String code}) async {
    final res = await _dio.post(kVerifyCodeEndpoint, data: {'email': email, 'code': code});
    return AuthTokens.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserMe> me() async {
    final res = await _dio.get(kMeEndpoint);
    return UserMe.fromJson(res.data as Map<String, dynamic>);
  }
}
