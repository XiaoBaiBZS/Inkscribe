
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/page/welcome/welcome_page.dart';
import 'package:window_manager/window_manager.dart';

import 'util/route/route_util.dart';
import 'util/route/routes.dart';

late  FileTreeManager  fileTreeManager;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 window_manager
  try{
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      windowButtonVisibility :true ,
      titleBarStyle:TitleBarStyle.hidden,
      size: Size(800, 600),
      minimumSize:Size(800, 600),
      center: true,
      skipTaskbar: false,
      title: 'Inkscribe',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }catch(e){

  }
  await Settings.init(cacheProvider: SharePreferenceCache());
  // 在Flutter渲染前设置窗口透明
  // if (Platform.isWindows) {
  //   WindowUtils.setTransparentBackground();
  //   WindowUtils.enableTransparentRegion();
  // }
  // await Window.initialize();
  // await Window.setEffect(
  //   effect:  WindowEffect.mica,
  //   dark: false,
  // );
  fileTreeManager = await FileTreeManager.readFromConfigFile();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      color: Colors.transparent,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FluentThemeData.light(),
      darkTheme: FluentThemeData.dark(),
      navigatorKey: RouteUtils.navigatorKey,
      onGenerateRoute: Routes.generateRoute,
      home: WelcomePage(),
    );
  }
}
