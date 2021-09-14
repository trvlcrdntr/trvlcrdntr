import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/../application_state/app_values/shared_pref_constants.dart';
import '/../application_state/auth/auth_cubit.dart';
import '/../view/routes/app_router.gr.dart';

class AppInit extends StatefulWidget {
  const AppInit({Key? key}) : super(key: key);

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends State<AppInit> {


  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final bool isUserLoggedIn = context.read<AuthCubit>().state.isLoggedIn;
      final bool isUserCheckedFromAuthService =
          context.read<AuthCubit>().state.isUserCheckedFromAuthService;
      if (isUserLoggedIn) {
        AutoRouter.of(context).replace(const AppHomeRoute());
      } else if (!isUserLoggedIn && isUserCheckedFromAuthService) {
        AutoRouter.of(context).replace(const UserLogin());
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) =>
      p.isUserCheckedFromAuthService != c.isUserCheckedFromAuthService &&
          c.isUserCheckedFromAuthService,
      listener: (context, state) {
        final bool isUserLoggedIn = state.isLoggedIn;

        if (isUserLoggedIn) {
          AutoRouter.of(context).replace(const AppHomeRoute());
        } else {
          AutoRouter.of(context).replace(const UserLogin());
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_checkUserAuthAndNavigate(context);
  }

  Future<void> _checkUserAuthAndNavigate(BuildContext context) async {
    ///Check any phone number in shared preference
    SharedPreferences _sp = await SharedPreferences.getInstance();
    String? phone = _sp.getString(PREF_KEY_PHN_NO);
    if (phone != null && phone.isNotEmpty) {
      User? _user = FirebaseAuth.instance.currentUser;
      if (_user != null && _user.phoneNumber.toString() == phone.toString()) {
        /// user is already signed in need to navigate to home page
        AutoRouter.of(context).replace(
          const AppHomeRoute(),
        );
      } else {
        /// navigate sing in page
        AutoRouter.of(context).replace(
          const UserLogin(),
        );
      }
    } else {
      /// navigate to sing up
      AutoRouter.of(context).replace(
        const UserLogin(),
      );
    }
  }
}
