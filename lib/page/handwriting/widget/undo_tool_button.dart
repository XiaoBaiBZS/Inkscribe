import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-26
 *@Description:
 *@Version: 1.0
 */

class UndoToolButton extends BaseToolButton{
  final DrawingController _drawingController;

  UndoToolButton(this._drawingController ,{
    super.key,
    required super.controllerBarHeight,
    required super.controllerBarWidth,
    required super.context,
  }) {
    icon = const Icon(FluentIcons.undo);
    toolName = "erase";
  }


  @override
  Function get toolSelectOnce => () {
    _drawingController.undo();
  };

}