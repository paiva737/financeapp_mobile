import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../features/auth/models/auth_models.dart';
import '../auth/token_storage_provider.dart';


const kBaseUrl = 'http://127.0.0.1:3000';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));


  var printedBase = false;
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) {
      if (!printedBase) {

        print('[BOOT] BASE=${o.baseUrl}');
        printedBase = true;
      }

      print('[REQ] ${o.method} ${o.uri}  data=${o.data}');
      h.next(o);
    },
    onResponse: (r, h) {

      print('[RES] ${r.statusCode} ${r.requestOptions.uri}  data=${r.data}');
      h.next(r);
    },
    onError: (e, h) {

      print('[ERR] type=${e.type} uri=${e.requestOptions.uri} msg=${e.message}');
      if (e.response != null) {
        // ignore: avoid_print
        print('[ERR] status=${e.response?.statusCode} body=${e.response?.data}');
      } else {
        // ignore: avoid_print
        print('[ERR] no response (provável conexão/host/porta)');
      }
      h.next(e);
    },
  ));


  dio.interceptors.add(QueuedInterceptorsWrapper(
    onRequest: (options, handler) async {
      final storage = ref.read(tokenStorageProvider);
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (err, handler) async {
      if (err.response?.statusCode == 401) {
        final storage = ref.read(tokenStorageProvider);
        final refresh = await storage.readRefreshToken();

        if (refresh != null && refresh.isNotEmpty && !JwtDecoder.isExpired(refresh)) {
          try {
            final r = await dio.post('/auth/refresh', data: {'refreshToken': refresh});
            final newTokens = AuthTokens.fromJson(r.data as Map<String, dynamic>);
            await storage.saveTokens(newTokens);

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
            final clone = await dio.fetch(opts);
            return handler.resolve(clone);
          } catch (_) {
            await storage.clear();
          }
        } else {
          await storage.clear();
        }
      }
      handler.next(err);
    },
  ));

  return dio;
});
