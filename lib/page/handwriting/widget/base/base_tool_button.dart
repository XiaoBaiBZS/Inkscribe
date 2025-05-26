import 'package:fluent_ui/fluent_ui.dart';


/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */

enum WidgetLocation{
  left,
  right,
  center,
}

class BaseToolButton extends StatefulWidget {
  BaseToolButton({super.key, required this.context,required this.controllerBarHeight, required this.controllerBarWidth,});
  BuildContext context;
  final FlyoutController flyoutController = FlyoutController();
  final Function toolSelectOnce = (){};
  final Function toolSelectTwice = (){};
  final double controllerBarHeight;
  final double controllerBarWidth;
  late final Widget icon;
  bool isSelected = false;
  late final String toolName;
  WidgetLocation toolLocation = WidgetLocation.center;


  @override
  State<BaseToolButton> createState() => _BaseToolButtonState();
}

class _BaseToolButtonState extends State<BaseToolButton> {



  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: widget.flyoutController,
      child: SizedBox(
        height: widget.controllerBarHeight,
        width: widget.controllerBarWidth,
        child: IconButton(
          icon: widget.icon,
          onPressed: () {
            setState(() {
              if (!widget.isSelected) {
                widget.toolSelectOnce();
                widget.isSelected = true;
              }else{
                widget.toolSelectTwice();
              }
            });
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(
              widget.isSelected
                  ? FluentTheme.of(context).menuColor
                  : FluentTheme.of(context).micaBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
