import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-04-28
 *@Description:
 *@Version: 1.0
 */

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}


class _WindowButtonsState extends State<WindowButtons> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: FluentTheme.of(context).brightness,
        backgroundColor: Colors.transparent,
      ),
    );

  }
}