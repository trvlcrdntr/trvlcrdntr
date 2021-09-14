import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '/../view/core/app_widget.dart';

import '/../application_state/app_values/app_constants.dart';
import 'injection.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection(runAppInDebug ? Environment.dev : Environment.prod);
  runApp(AppWidget());
}