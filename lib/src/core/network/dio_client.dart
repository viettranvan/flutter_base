import 'package:dio/dio.dart';

import '../config/env_config.dart';
import 'index.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.getBaseUrl(),
        connectTimeout: Duration(seconds: EnvConfig.getConnectTimeout()),
        receiveTimeout: Duration(seconds: EnvConfig.getReceiveTimeout()),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([PrettyDioLogger(), DioInterceptor()]);
  }

  Dio get instance => dio;
}
