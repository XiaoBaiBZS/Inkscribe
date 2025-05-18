import 'package:fluent_ui/fluent_ui.dart';
import 'package:inksrcibe/page/handwriting/handwriting_blank_page.dart';
import 'package:inksrcibe/page/home/home_page.dart';
import 'package:inksrcibe/page/welcome/welcome_private_policy_page.dart';
import 'package:inksrcibe/page/welcome/welcome_setting_page.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-05
 *@Description:
 *@Version: 1.0
 */



class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePath.home_page:
        return pageRoute(HomePage(), settings: settings);
      case RoutePath.welcome_setting_page:
        return pageRoute(WelcomeSettingPage(), settings: settings);
      case RoutePath.welcome_private_policy_page:
        return pageRoute(WelcomePrivatePolicyPage(), settings: settings);
      case RoutePath.handwriting_blank_page:
        return pageRoute(HandwritingBlankPage(), settings: settings);


    }
    return pageRoute(ScaffoldPage(
      content: SafeArea(
          child: Center(
            child: Text("404:Route Path ${settings.name} Not Found"),
          )),
    ));
  }

  static FluentPageRoute pageRoute(Widget page,
      {RouteSettings? settings,
        bool? fullscreenDialog,
        bool? maintainState,
        bool? allowSnapshotting}) {
    return FluentPageRoute(
        builder: (context) {
          return page;
        },
        settings: settings,
        fullscreenDialog: fullscreenDialog ?? false,
        maintainState: maintainState ?? true,
        );
  }
}

class RoutePath {
  //HomePage
  static const String home_page = "/home/home_page";
  static const String welcome_setting_page = "/welcome/welcome_setting_page";
  static const String welcome_private_policy_page = "/welcome/welcome_private_policy_page";
  static const String handwriting_blank_page = "/handwriting/handwriting_blank_page";

}
