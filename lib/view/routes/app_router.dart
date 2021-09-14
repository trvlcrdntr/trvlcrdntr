import 'package:auto_route/annotations.dart';
import '/../homepage.dart';
import '/../view/pages/auth/login.dart';

import '/../view/pages/initial/app_init.dart';


@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: AppInit, initial: true,),
    AutoRoute(page: UserLogin,),
    AutoRoute(page: AppHomePage,),
  ],
)class $AppRouter {}