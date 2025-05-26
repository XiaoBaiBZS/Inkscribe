import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';
import 'package:inksrcibe/page/handwriting/widget/undo_tool_button.dart';
import 'package:inksrcibe/util/file_util.dart';
import 'package:window_manager/window_manager.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-25
 *@Description:
 *@Version: 1.0
 */


class BaseDrawboard extends StatefulWidget {
  BaseDrawboard({
    super.key,
    required this.context,
    required this.drawingController,
    required this.backgroundWidget,
  });

  final BuildContext context;
  final DrawingController drawingController;
  Widget backgroundWidget;


  /// 当前画板页面索引
  int nowPageIndex = 0;

  /// 当前画板总数据
  List<String> drawingBoardData = [];

  /// 画板数据
  late DrawingBoardFile drawingBoardFile;

  /// 加载当前页面
  void loadPage() async {
    jsonDecode(drawingBoardData[nowPageIndex]).forEach((element) {
      switch (element["type"]) {
        case "StraightLine":
          drawingController.addContent(StraightLine.fromJson(element));
          break;
        case "SimpleLine":
          drawingController.addContent(SimpleLine.fromJson(element));
          break;
        case "SmoothLine":
          drawingController.addContent(SmoothLine.fromJson(element));
          break;
        case "Eraser":
          drawingController.addContent(Eraser.fromJson(element));
          break;
        case "Rectangle":
          drawingController.addContent(Rectangle.fromJson(element));
          break;
        case "Circle":
          drawingController.addContent(Circle.fromJson(element));
          break;
      }
    });
  }

  /// 加载画板文件
  void loadFile(String filePath) async {
    String? path = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
    if (path == null) {
      return;
    }
    drawingBoardFile = DrawingBoardFile.fromMap(jsonDecode(await FileUtil.readFile("$path/$filePath")));
    drawingBoardFile;
    drawingBoardData = drawingBoardFile.data;
    jsonDecode(drawingBoardFile.data[nowPageIndex]).forEach((element) {
      switch (element["type"]) {
        case "StraightLine":
          drawingController.addContent(StraightLine.fromJson(element));
          break;
        case "SimpleLine":
          drawingController.addContent(SimpleLine.fromJson(element));
          break;
        case "SmoothLine":
          drawingController.addContent(SmoothLine.fromJson(element));
          break;
        case "Eraser":
          drawingController.addContent(Eraser.fromJson(element));
          break;
        case "Rectangle":
          drawingController.addContent(Rectangle.fromJson(element));
          break;
        case "Circle":
          drawingController.addContent(Circle.fromJson(element));
          break;
      }
    });
  }


  /// 创建文件对象
  void createFile(String path) async {
    DateTime now = DateTime.now();
    drawingBoardData.add(drawingController.getJsonList().toString());
    drawingBoardFile = DrawingBoardFile(
      name: "未命名笔记",
      path: "$path/${now.millisecondsSinceEpoch}.json",
      type: "normal",
      createDateTime: now,
      data: drawingBoardData,
    );
    fileTreeManager.addFile(
        DrawingBoardFileConfig.fromDrawingBoardFile(drawingBoardFile),
        directoryPath: path);
    fileTreeManager.writeToConfigFile();
    drawingBoardFile.saveFile();
  }

  /// 保存笔记文件
  void _saveFile() async {
    drawingBoardFile.data = drawingBoardData;
    drawingBoardFile.saveFile();
  }

  @override
  State<BaseDrawboard> createState() => BaseDrawboardState();
}

class BaseDrawboardState extends State<BaseDrawboard> {

  void changeBackgroundWidget(Widget newBackgroundWidget){
    setState(() {
      widget.backgroundWidget = newBackgroundWidget;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DrawingBoard(
        // 画布控制器
        controller: widget.drawingController,
        // 监听画布事件
        onInteractionUpdate: (event) {
        },
        // 画布背景，这里是默认的黑板背景
        background:widget.backgroundWidget,
        // SizedBox(
        //   width: MediaQuery.of(context).size.width,
        //   height: MediaQuery.of(context).size.height,
        //   // child:  PdfViewer.file("/storage/emulated/0/Download/WeiXin/你好.pdf"),
        //   child:  PdfViewer.file("C:/Users/12985/Downloads/你好.pdf"),
        // )

        // showDefaultTools:true,
        // showDefaultActions:true,
      );
  }
}
