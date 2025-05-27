// 📁 lib/injection.dart

import 'package:flutter_base/src/features/auth/auth_injection.dart';
import 'package:get_it/get_it.dart';

import 'core/index.dart';

final sl = GetIt.instance;

Future<void> setup() async {
  // await dotenv.load();
  // Core
  sl.registerLazySingleton(() => DioClient().instance);

  // Feature injections
  await initAuthInjection();
}
