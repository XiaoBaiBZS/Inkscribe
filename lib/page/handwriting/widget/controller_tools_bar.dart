import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';
import 'package:inksrcibe/page/handwriting/widget/logo_button.dart';
import 'package:inksrcibe/page/handwriting/widget/pen_tool_button.dart';
import 'package:window_manager/window_manager.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */

class ControllerToolsBar extends StatefulWidget {
  ControllerToolsBar({super.key, required this.context,required this.drawingController});

  BuildContext context;

  /// 画布控制器
  final DrawingController drawingController;

  /// 工具组件按钮
  List<BaseToolButton> toolButtons = [];

  /// 当前画笔颜色
  Color _penColor = Colors.white;

  /// 当前画笔粗细
  double _penWidth = 3.0;

  /// 单个按钮高度
  final double controllerBarHeight = 50;

  /// 单个按钮宽度
  final double controllerBarWidth = 50;

  /// 画布是否可以撤销或者重做
  bool _canUndo = false;
  bool _canRedo = false;

  @override
  State<ControllerToolsBar> createState() => _ControllerToolsBarState();
}

class _ControllerToolsBarState extends State<ControllerToolsBar> {



  @override
  void initState() {
    super.initState();
    widget.drawingController.addListener(() {
      setState(() {
        widget._canUndo = widget.drawingController.canUndo();
        widget._canRedo = widget.drawingController.canRedo();
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    widget.toolButtons = [
      LogoButton(widget.drawingController, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: widget.context,),
      PenToolButton(widget.drawingController, widget._penWidth, widget._penColor, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: widget.context,),

    ];
    return GestureDetector(
      // 穿透
      behavior: HitTestBehavior.deferToChild,
      // 拖动，设置最大化时不可拖动，窗口时可以拖动
      onPanStart: (details) async {
        bool isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          windowManager.startDragging();
        } else {
          // windowManager.unmaximize();
        }
      },
      child: Mica(
        child: Row(
          children:widget.toolButtons,
        ),
      ),
    );
  }
}
