import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */

class PenToolButton extends BaseToolButton{
  final DrawingController _drawingController;
  late double _penWidth;
  late Color _penColor;

  PenToolButton(this._drawingController, this._penWidth, this._penColor, {super.key, required super.controllerBarHeight, required super.controllerBarWidth, required super.context,}){
    icon  = const Icon(FluentIcons.pen_workspace);
    toolName = "pen";

  }

  @override
  Function get toolSelectOnce => () {
    _drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
    _drawingController.setStyle(color: _penColor, strokeWidth: _penWidth);
  };

  @override
  Function get toolSelectTwice => () {
    super.flyoutController.showFlyout(
      builder: (context) => FlyoutContent(
        child: StatefulBuilder(builder:
            (BuildContext context, StateSetter setState) {
          return Container(
              width: 210,
              height: 230,
              padding: EdgeInsets.all(8.0),
              );
        }),
      ),
    );
  };


}