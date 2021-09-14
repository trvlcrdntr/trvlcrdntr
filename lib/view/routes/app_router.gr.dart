// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import '../../homepage.dart' as _i5;
import '../pages/auth/login.dart' as _i4;
import '../pages/initial/app_init.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    AppInit.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i3.AppInit();
        }),
    UserLogin.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i4.UserLogin();
        }),
    AppHomeRoute.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i5.AppHomePage();
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(AppInit.name, path: '/'),
        _i1.RouteConfig(UserLogin.name, path: '/user-login'),
        _i1.RouteConfig(AppHomeRoute.name, path: '/app-home-page')
      ];
}

class AppInit extends _i1.PageRouteInfo {
  const AppInit() : super(name, path: '/');

  static const String name = 'AppInit';
}

class UserLogin extends _i1.PageRouteInfo {
  const UserLogin() : super(name, path: '/user-login');

  static const String name = 'UserLogin';
}

class AppHomeRoute extends _i1.PageRouteInfo {
  const AppHomeRoute() : super(name, path: '/app-home-page');

  static const String name = 'AppHomeRoute';
}
