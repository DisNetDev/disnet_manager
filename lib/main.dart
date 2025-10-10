import 'package:disnet_manager/features/homescreen/views/homescreen.dart';
import 'package:disnet_manager/usecases/init_sb.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disnet_manager/usecases/init_env.dart';
import 'package:disnet_manager/usecases/run_app_with_wrappers.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  //Hydrated Bloc Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
        (await getApplicationDocumentsDirectory()).path),
  );

// Init environment files
  await initEnv();
//Init Supabase Clients
  await initSB();

  WindowOptions windowOptions = WindowOptions(
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // Hide native title bar
      title: "DisNet Manager");
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runAppWithWrappers(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homescreen(),
    );
  }
}
