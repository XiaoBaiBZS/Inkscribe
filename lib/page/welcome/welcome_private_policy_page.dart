import 'dart:io';


import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';

import 'package:window_manager/window_manager.dart';
import '../../config/privacy_policy.dart';
import '../../config/settings_config.dart';
import '../../module/window_buttons.dart';



/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-04-27
 *@Description:
 *@Version: 1.0
 */

class WelcomePrivatePolicyPage extends StatefulWidget {
  const WelcomePrivatePolicyPage({super.key});

  @override
  State<WelcomePrivatePolicyPage> createState() => _WelcomePrivatePolicyPageState();
}

class _WelcomePrivatePolicyPageState extends State<WelcomePrivatePolicyPage> with WindowListener {

  @override
 void initState()  {
    super.initState();
    windowManager.addListener(this);

  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
                    const SizedBox(height: 20),
                    Container(
                      width: 500,
                      height: 200,
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            PrivacyPolicy.buildPrivacyPolicy(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FilledButton(
                      onPressed: () async {
                        await Settings.setValue(SettingsConfig.isUserPrivateAgree, true);
                        RouteUtils.pushForNamed(context,RoutePath.welcome_setting_page);
                      },
                      child: Text(
                        '同意并开始',
                        style: TextStyle(),
                      ),
                    ),
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


