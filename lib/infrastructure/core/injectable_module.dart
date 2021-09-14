import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '/../view/routes/app_router.gr.dart';

@module
abstract class InjectableModule {
  @singleton
  AppRouter get appRouter => AppRouter();
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
