import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-26
 *@Description:
 *@Version: 1.0
 */

class LogoButton extends BaseToolButton{

  final DrawingController _drawingController;

  LogoButton(this._drawingController, {super.key, required super.controllerBarHeight, required super.controllerBarWidth, required super.context,}){
    icon  = Image.asset("assets/icons/app_icon.ico", width: 20, height: 20);
    toolName = "logo";
    toolLocation  = WidgetLocation.left;
  }



  @override
  Function get toolSelectOnce => () {
    /// 保存退出
    ListTile  saveAndExitListTile = ListTile(
      leading: Icon(FluentIcons.save),
      title: Text('保存退出'),
      onPressed: () {
        // TODO: 添加保存功能
        // _saveFile();
        RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
      },
    );

    /// 不保存退出
    ListTile  exitWithoutSaveListTile =ListTile(
      leading: Icon(FluentIcons.cancel),
      title: Text('不保存退出'),
      onPressed: () {
        RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
      },
    );

    /// 列表项集合
    ListBody listBodyContent = ListBody(
      children: [
        saveAndExitListTile,
        exitWithoutSaveListTile,
        // ListTile(
        //   leading: Icon(FluentIcons.back_to_window),
        //   title: Text('最小化'),
        //   onPressed: () {
        //   },
        // ),

      ],
    );

    /// 按钮二级菜单
    Widget flyoutContent = Acrylic(
      child: Container(
        width: 160,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [listBodyContent],
        ),
      ),
    );

    flyoutController.showFlyout(
      builder: (context) => FlyoutContent(
        padding: EdgeInsets.zero,
        child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return flyoutContent;
        }),
      ),
    );
  };


}
