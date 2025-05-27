import 'package:dio/dio.dart';

import 'index.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8081',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([PrettyDioLogger(), DioInterceptor()]);
  }

  Dio get instance => dio;
}
