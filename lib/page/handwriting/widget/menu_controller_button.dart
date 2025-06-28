import 'package:fluent_ui/fluent_ui.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:provider/provider.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-06-28
 *@Description:
 *@Version: 1.0
 */

class MenuControllerButton extends StatefulWidget {
  const MenuControllerButton({super.key, required this.inkscribeController});

  final FlyoutController inkscribeController;

  @override
  State<MenuControllerButton> createState() => _MenuControllerButtonState();
}

class _MenuControllerButtonState extends State<MenuControllerButton> {

  late DrawingState drawingState;



  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);

    /// 功能菜单项
    List<Widget> buildMenuItems(BuildContext context) {
      Widget buildMenuItem({
        required IconData icon,
        required String title,
        required VoidCallback onPressed,
      }) {
        return ListTile(
          leading: Icon(icon),
          title: Text(title),
          onPressed: onPressed,
        );
      }

      void handleMenuItemPress(VoidCallback action) {
        action(); // 执行具体操作
      }
      return [
        // 保存退出菜单项
        buildMenuItem(
          icon: FluentIcons.save,
          title: '保存退出',
          onPressed: () => handleMenuItemPress(() {
            drawingState.saveFile();
            RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
            drawingState.reset();
          }),
        ),

        // 不保存退出菜单项
        buildMenuItem(
          icon: FluentIcons.cancel,
          title: '不保存退出',
          onPressed: () => handleMenuItemPress(() {
            RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
            drawingState.reset();
          }),
        ),

        // 最小化菜单项
        buildMenuItem(
          icon: FluentIcons.back_to_window,
          title: '最小化',
          onPressed: () => handleMenuItemPress(() {
            // 实现窗口最小化逻辑
          }),
        ),
      ];
    }

    return FlyoutTarget(
      controller: widget.inkscribeController,
      child: SizedBox(
        height: 50,
        width: 50,
        child: IconButton(
          icon: Image.asset("assets/icons/app_icon.ico", width: 20, height: 20),
          onPressed: () {
            widget.inkscribeController.showFlyout(
              builder: (context) => FlyoutContent(
                padding: EdgeInsets.zero,
                child: StatefulBuilder(builder:
                    (BuildContext context, StateSetter setState) {
                  return Acrylic(
                    child: Container(
                      width: 160,
                      padding: EdgeInsets.zero,
                      child:Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...buildMenuItems(context),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(
              drawingState.selectedTool == 'inkscribe'
                  ? FluentTheme.of(context).menuColor
                  : FluentTheme.of(context).micaBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
