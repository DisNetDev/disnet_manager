import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:disnet_manager/models/global_blocs.dart';
import 'package:toastification/toastification.dart';

void runAppWithWrappers(Widget app) {
  runApp(
    MultiBlocProvider(
      providers: GlobalBlocs.globalBlocs,
      child: ToastificationWrapper(
        child: KeyboardVisibilityProvider(child: app),
      ),
    ),
  );
}
