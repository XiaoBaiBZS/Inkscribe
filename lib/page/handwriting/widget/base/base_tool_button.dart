import 'package:fluent_ui/fluent_ui.dart';


/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */

class BaseToolButton extends StatefulWidget {
  BaseToolButton({super.key});
  final FlyoutController flyoutController = FlyoutController();
  final Function toolSelectOnce = (){};
  final Function toolSelectTwice = (){};
  double controllerBarHeight = 50;
  double controllerBarWidth = 50;
  late final Icon icon;
  bool isSelected = false;
  late final String toolName;

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
