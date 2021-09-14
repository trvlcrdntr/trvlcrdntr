import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/../application_state/app_values/app_constants.dart';
import '/../application_state/auth/auth_cubit.dart';
import '/../injection.dart';
import '/../view/routes/app_router.gr.dart';


///statefull
class AppWidget extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppWidgetState createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final BotToastNavigatorObserver botToastNavigatorObserver =
  BotToastNavigatorObserver();
  final botToastBuilder = BotToastInit();
  final AppRouter _appRouter = getIt<AppRouter>();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container(
            child: Center(
              child: Text("Something is fishy"),
            ),
          );
        }

        // Once complete, show your application_state
        if (snapshot.connectionState == ConnectionState.done) {
          return BlocProvider(
            lazy: false,
            create: (context) => getIt<AuthCubit>(),
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerDelegate: _appRouter.delegate(
                  navigatorObservers: () => [
                    botToastNavigatorObserver,
                  ]),
              routeInformationParser: _appRouter.defaultRouteParser(),
              builder: (context, child) {
                return botToastBuilder(context, child);
              },
              title: AppTitle,
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }
}
