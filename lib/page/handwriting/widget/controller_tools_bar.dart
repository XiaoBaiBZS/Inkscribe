import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_drawboard.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';
import 'package:inksrcibe/page/handwriting/widget/erase_tool_button.dart';
import 'package:inksrcibe/page/handwriting/widget/logo_button.dart';
import 'package:inksrcibe/page/handwriting/widget/pen_tool_button.dart';
import 'package:inksrcibe/page/handwriting/widget/undo_tool_button.dart';
import 'package:inksrcibe/util/file_util.dart';
import 'package:window_manager/window_manager.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */

class ControllerToolsBar extends StatefulWidget {
  ControllerToolsBar({super.key, required this.context,required this.baseDrawboard});

  BuildContext context;

  /// 画布
  BaseDrawboard baseDrawboard;

  /// 工具组件按钮
  List<BaseToolButton> toolButtons = [];

  /// 当前画笔颜色
  // Color penColor = Colors.white;

  /// 当前画笔粗细
  // double penWidth = 3.0;

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

  final GlobalKey<BaseToolButtonState> undoToolButtonKey = GlobalKey<BaseToolButtonState>();
  final GlobalKey<BaseToolButtonState> redoToolButtonKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    widget.baseDrawboard.drawingController.addListener(() {
      setState(() {
        undoToolButtonKey.currentState?.setCanOnTap(widget.baseDrawboard.drawingController.canUndo());
        widget._canRedo = widget.baseDrawboard.drawingController.canRedo();
      });
    });


    // 设置默认画笔为模拟压感笔，模拟压感灵敏度为0.1
    widget.baseDrawboard.drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
    // 设置画笔颜色和粗细
    widget.baseDrawboard.drawingController.setStyle(color: Colors.white, strokeWidth:3.0);


  }

  @override
  Widget build(BuildContext context) {
    widget.toolButtons = [
      LogoButton(widget.baseDrawboard.drawingController, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: widget.context,),
      PenToolButton(widget.baseDrawboard.drawingController, 3.0,Colors.white, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: widget.context,),
      EraseToolButton(widget.baseDrawboard.drawingController, 40, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: context),
      UndoToolButton(key: undoToolButtonKey,widget.baseDrawboard.drawingController, controllerBarHeight: widget.controllerBarHeight, controllerBarWidth: widget.controllerBarWidth, context: context)
    ];

    List<Widget> ToolButtons(WidgetLocation location){
      List<Widget> result = [];
      for(BaseToolButton toolButton in widget.toolButtons){
        if(toolButton.toolLocation == location){
          result.add(toolButton);
        }
      }
      return result;
    }

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
          children:[
            Row(
              children: ToolButtons(WidgetLocation.left),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    (MediaQuery.of(context).size.width - 4 * widget.controllerBarWidth) >
                        widget.toolButtons.length * widget.controllerBarWidth
                        ? SizedBox(
                      width: (MediaQuery.of(context).size.width -
                          4 * widget.controllerBarWidth) /
                          2,
                    )
                        : SizedBox(
                      width: 0,
                    ),
                    Row(
                      children: ToolButtons(WidgetLocation.center),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: widget.controllerBarHeight,
              width: widget.controllerBarWidth,
              child: IconButton(
                  icon: Icon(FluentIcons.chevron_left),
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(
                        FluentTheme.of(context).micaBackgroundColor),
                  ),
                  onPressed: widget.baseDrawboard.nowPageIndex <= 0
                      ? null
                      : () {
                    // 保存当前页面内容
                    widget.baseDrawboard.drawingBoardData[widget.baseDrawboard.nowPageIndex] =
                        jsonEncode(widget.baseDrawboard.drawingController.getJsonList());
                    widget.baseDrawboard.drawingController.clear();
                    // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
                    setState(() {
                      widget.baseDrawboard.nowPageIndex--;
                    });
                    widget.baseDrawboard.loadPage();
                  }),
            ),
            SizedBox(
                height: widget.controllerBarHeight,
                width: widget.controllerBarWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: IconButton(
                    icon: Text(
                        "${widget.baseDrawboard.nowPageIndex + 1} / ${widget.baseDrawboard.drawingBoardData.length}"),
                    onPressed: () {},
                  ),
                )),
            SizedBox(
              height: widget.controllerBarHeight,
              width: widget.controllerBarWidth,
              child: IconButton(
                icon: (widget.baseDrawboard.nowPageIndex == widget.baseDrawboard.drawingBoardData.length - 1)
                    ? Icon(FluentIcons.add)
                    : Icon(FluentIcons.chevron_right),
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(
                      FluentTheme.of(context).micaBackgroundColor),
                ),
                onPressed: () {
                  // 保存当前页面内容
                  widget.baseDrawboard.drawingBoardData[widget.baseDrawboard.nowPageIndex] = jsonEncode(widget.baseDrawboard.drawingController.getJsonList());
                  widget.baseDrawboard.drawingController.clear();
                  // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
                  setState(() {
                    widget.baseDrawboard.nowPageIndex++;
                  });
                  if ((widget.baseDrawboard.nowPageIndex) > (widget.baseDrawboard.drawingBoardData.length - 1)) {
                    widget.baseDrawboard.drawingBoardData.add("");
                  } else {
                    widget.baseDrawboard.loadPage();
                  }
                },
              ),
            ),

          ]
        ),
      ),
    );
  }
}
