import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/module/window_buttons.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:window_manager/window_manager.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-17
 *@Description:
 *@Version: 1.0
 */

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>  with WindowListener{

  @override
  void initState() {
    super.initState();
    // 延迟
    Future.delayed(Duration(milliseconds: Platform.isAndroid?300:800), () {
      Future.microtask(() async {
        bool? isUserPrivateAgree = await Settings.getValue<bool>(SettingsConfig.isUserPrivateAgree, defaultValue: false);
        if (isUserPrivateAgree?? false) {
          String? path = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
          if ((path ?? "").isNotEmpty) {
            fileTreeManager = await FileTreeManager.readFromConfigFile();
            RouteUtils.pushReplacementNamed(context, RoutePath.home_page);
          }else{
            RouteUtils.pushReplacementNamed(context, RoutePath.welcome_setting_page);
          }
        }else{
          RouteUtils.pushReplacementNamed(context, RoutePath.welcome_private_policy_page);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.only(top: 0),
      content: Stack(
        children: [
          DragToMoveArea(
            child:Container(
              color: FluentTheme.of(context).micaBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 这里替换为你的应用 Logo
                    Image.asset(
                      'assets/icons/app_icon.ico',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '欢迎使用 Inkscribe',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ink Inscribe · 墨痕题镌',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 250,
                      child: ProgressBar(),
                    )
                  ],
                ),
              ),
            ),
          ),
          Platform.isWindows?Positioned(
            top: 0,
            right: 0,
            child: WindowButtons(),
          ):Container(),
        ],
      ),
    );
  }
}
