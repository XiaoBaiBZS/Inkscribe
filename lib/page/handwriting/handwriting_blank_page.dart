import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/base_drawing_board.dart';
import 'package:inksrcibe/page/handwriting/widget/controller_bar.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:inksrcibe/util/info_bar_util.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class HandwritingBlankPage extends StatefulWidget {
  const HandwritingBlankPage({super.key});

  @override
  State<HandwritingBlankPage> createState() => _HandwritingBlankPageState();
}

class _HandwritingBlankPageState extends State<HandwritingBlankPage> with WindowListener {
  late DrawingState drawingState;

  @override
  void initState() {
    super.initState();
    // 监听窗口事件
    windowManager.addListener(this);
    // 全屏窗口
    try{
      if(Platform.isWindows){
        Future.microtask(() async {
          await windowManager.maximize();
        });
      }
    }catch(e){
      return;
    }

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    drawingState = Provider.of<DrawingState>(context, listen: false);
    // 初始化画布控制器，这里删除了，因为会在provider状态管理中初始化
    // drawingState.drawingController = DrawingController();
    // 监听画布更新，当画布更新的时候更新撤销按钮状态和重做按钮状态
    drawingState.drawingController.realPainter?.addListener(() {
      drawingState.updateUndoState();
      drawingState.updateRedoState();
      // _drawingBoardData[_nowPageIndex] = jsonEncode(_drawingController.getJsonList());
      drawingState.drawingBoardFile.data = drawingState.drawingBoardData;
    });
    // 设置默认画笔为模拟压感笔，模拟压感灵敏度为0.1
    drawingState.drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
    // 设置画笔颜色和粗细
    drawingState.drawingController.setStyle(color: drawingState.penColor, strokeWidth: drawingState.penWidth);
    if(!drawingState.isExecuted){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Map? args = ModalRoute.of(context)?.settings.arguments as Map?;
        try{
          if(args==null){

          }else{
            if(args["function"]!=null || args["path"]==null){
              switch(args["function"]){
                case "load":
                  drawingState.loadFile(args["path"]);
                  break;
                case "create":
                  drawingState.createFile(args["path"]);
                  InfoBarUtil.showSuccessInfoBar(context: context, title: "开始你的书写", message: "文件创建成功");
                  break;
              }
            }else{
              InfoBarUtil.showErrorInfoBar(context: context, title: "无法正确执行操作", message: "请重新打开画板,参数丢失");
              RouteUtils.pushReplacementNamed(context, RoutePath.home_page);
            }
          }
        }catch(e){
          InfoBarUtil.showErrorInfoBar(context: context, title: "无法正确执行操作", message: "请重新打开画板,参数丢失");
          RouteUtils.pushReplacementNamed(context, RoutePath.home_page);
        }
        drawingState.isExecuted = true;
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取绘图状态
    return ScaffoldPage(
      padding: EdgeInsets.only(top: 0),
      content: Container(
        color: FluentTheme.of(context).micaBackgroundColor,
        // color: Colors.transparent,
        child: Column(
          children: [
            Stack(
              children: [
                BaseDrawingBoard(),

                /// 橡皮擦白色透明框框
                if (drawingState.selectedTool == 'erase' &&
                    drawingState.isMousePressed &&
                    drawingState.mousePosition != null)
                  Positioned(
                    left: drawingState.mousePosition!.dx - drawingState.eraseWidth/2,
                    top: drawingState.mousePosition!.dy - drawingState.eraseWidth/2,
                    child:
                    // 橡皮擦
                    SizedBox(
                      width: drawingState.eraseWidth,
                      height:drawingState.eraseWidth ,
                      child: Button(child: Container(), onPressed: () {}),
                    ),
                  ),
              ],
            ),
            // 底部工具栏
            ControllerBar(),
          ],
        ),
      ),
    );
  }
}
