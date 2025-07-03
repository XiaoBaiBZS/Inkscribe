/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-06-13
 *@Description: 重构为工厂模式的DrawingState类
 *@Version: 1.0
 */

import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/main.dart';
import 'package:flutter/material.dart' as material;
import 'package:inksrcibe/util/file_util.dart';
import 'package:pdfrx/pdfrx.dart';

class DrawingState extends ChangeNotifier {
  // 私有静态实例映射，用于存储不同标识的实例
  static final Map<String, DrawingState> _instances = {};

  // 工厂构造函数，根据标识符获取或创建实例
  factory DrawingState([String identifier = 'default']) {
    return _instances.putIfAbsent(
      identifier,
          () => DrawingState._internal(identifier),
    );
  }

  // 获取默认实例的便捷方式
  static DrawingState get instance => DrawingState();

  // 私有构造函数
  DrawingState._internal(this._identifier);

  // 实例标识符
  final String _identifier;

  /// 画布控制器
  DrawingController drawingController = DrawingController();

  PdfViewerController pdfViewerController = PdfViewerController();

  /// 画布是否可以撤销或者重做
  bool canUndo = false;
  bool canRedo = false;

  /// 控制WindowButtons是否显示
  bool isWindowButtonsVisible = false;

  /// 画笔工具相关属性
  // 画笔颜色
  Color penColor = Colors.white;
  // 画笔粗细
  double penWidth = 3.0;
  // 记录当前选中的颜色
  Color? selectedColor = Colors.white;

  /// 橡皮工具相关属性
  // 橡皮擦粗细
  double eraseWidth = 40.0;

  /// 当前选中的工具
  // 跟踪当前选中的工具
  String selectedTool = 'pen';
  bool penButtonPressed = false;
  bool eraseButtonPressed = false;

  /// 鼠标位置
  Offset? mousePosition;
  /// 鼠标按下状态
  bool isMousePressed = false;

  /// 笔刷历史颜色
  List<Color> colorHistory = [];

  bool isChangePenWidthByZoom = true;
  double zoomLevel = 1.0;

  /// 画板数据
  late DrawingBoardFile drawingBoardFile;

  /// 是否已经加载画板
  bool isExecuted = false;

  /// 当前画板页面索引
  int nowPageIndex = 0;

  /// 当前画板总数据
  List<String> drawingBoardData = [];

  /// 当前画板文件相对路径
  String _filePath = '';

  /// 获取画板数据
  Future<DrawingBoardFile> getDrawingBoardData() async {
    return drawingBoardFile;
  }

  /// 恢复默认值，用于退出画板和重新加载画板
  void reset() {
    // 重置控制器内容，但保留控制器实例
    drawingController.clear();

    // 重置撤销/重做状态
    canUndo = false;
    canRedo = false;

    // 重置窗口按钮可见性
    isWindowButtonsVisible = false;

    // 重置画笔工具属性
    penColor = Colors.white;
    penWidth = 3.0;
    selectedColor = Colors.white;

    // 重置橡皮工具属性
    eraseWidth = 40.0;

    // 重置选中工具状态
    selectedTool = 'pen';
    penButtonPressed = false;
    eraseButtonPressed = false;

    // 重置鼠标状态
    mousePosition = null;
    isMousePressed = false;

    // 重置颜色历史
    // colorHistory = [
    //   Colors.white,
    //   Colors.green,
    //   Colors.blue,
    //   Colors.purple,
    //   Colors.black,
    //   Colors.yellow,
    //   Colors.red,
    //   Colors.orange,
    // ];

    // 重置缩放设置
    isChangePenWidthByZoom = true;
    zoomLevel = 1.0;

    // 重置画板数据状态
    isExecuted = false;
    nowPageIndex = 0;
    drawingBoardData = [];
    _filePath = '';

    // 清空当前的drawingBoardFile
    drawingBoardFile = DrawingBoardFile(
      name: "未命名笔记",
      path: "",
      type: "normal",
      createDateTime: DateTime.now(),
      data: [],
    );

    // 通知状态更新
    notifyListeners();
  }

  /// 保存笔记文件
  void saveFile() async {
    drawingBoardData[nowPageIndex] = jsonEncode(drawingController.getJsonList());
    drawingBoardFile.data = drawingBoardData;
    drawingBoardFile.saveFile();
  }

  /// 更新撤销状态
  void updateUndoState() {
    canUndo = drawingController.canUndo();
    notifyListeners();
  }

  /// 更新重做状态
  void updateRedoState() {
    canRedo = drawingController.canRedo();
    notifyListeners();
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
    fileTreeManager.addFile(DrawingBoardFileConfig.fromDrawingBoardFile(drawingBoardFile), directoryPath: path);
    fileTreeManager.writeToConfigFile();
    drawingBoardData[nowPageIndex] = jsonEncode(drawingController.getJsonList());
    notifyListeners();
    drawingBoardFile.saveFile();
  }

  /// 创建PDF文件
  void createPdfFile(String path, String filePath) async{
    DateTime now = DateTime.now();
    // 复制PDF文件到当前节点
    // 修改PDF文件名称为“now.json”
    String? workspacePath = Settings.getValue(SettingsConfig.workspacePath,defaultValue:  "");
    FileUtil.copyFile(filePath, "$workspacePath$path/${now.millisecondsSinceEpoch}.pdf");
    // 提取PDF文件的名称作为画板名称
    String drawingBoardName = FileUtil.getFileName(filePath);
    drawingBoardData.add(drawingController.getJsonList().toString());
    drawingBoardFile = DrawingBoardFile(
      name: drawingBoardName,
      path: "$path/${now.millisecondsSinceEpoch}.json",
      type: "pdf",
      createDateTime: now,
      data: drawingBoardData,
    );
    fileTreeManager.addFile(DrawingBoardFileConfig.fromDrawingBoardFile(drawingBoardFile), directoryPath: path);
    fileTreeManager.writeToConfigFile();
    drawingBoardData[nowPageIndex] = jsonEncode(drawingController.getJsonList());
    notifyListeners();
    drawingBoardFile.saveFile();
  }

  /// 显示颜色选择器，用于"更多颜色"功能
  void showColorPicker(BuildContext context) {
    // 更新颜色历史记录
    void updateColorHistory(Color color) {
      // 如果颜色已在历史记录中，将其移至最前面
      if (colorHistory.contains(color)) {
        colorHistory.remove(color);
      }
      // 添加到历史记录的最前面
      colorHistory.insert(0, color);

      // 限制历史记录最多32种颜色
      if (colorHistory.length > 32) {
        colorHistory.removeRange(32, colorHistory.length);
      }
    }

    // 初始化颜色历史记录（如果为空）
    if (colorHistory.isEmpty) {
      colorHistory = [
        penColor, // 添加当前颜色作为第一个历史记录
        Colors.green,
        Colors.blue,
        Colors.purple,
        Colors.black,
        Colors.yellow,
        Colors.red,
        Colors.orange,
      ];
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        Color tempColor = penColor; // 临时存储用户选择的颜色

        return Stack(
          children: [
            Positioned(
              bottom: 50,
              left: (MediaQuery.of(dialogContext).size.width - 365) / 2,
              child: Center(
                child: ContentDialog(
                  title: const Text('选择画笔颜色'),
                  content: Container(
                    height: 340,
                    child: Column(
                      children: [
                        // 颜色选择器主体
                        Container(
                          child: material.Material(
                            child: Container(
                              color: FluentTheme.of(dialogContext).menuColor,
                              child: ColorPicker(
                                pickerColor: tempColor,
                                onColorChanged: (Color color) {
                                  tempColor = color; // 更新临时颜色
                                },
                                portraitOnly: true,
                                enableAlpha: false,
                                labelTypes: [],
                                displayThumbColor: true,
                                pickerAreaHeightPercent: 0.5,
                                pickerAreaBorderRadius: BorderRadius.circular(8.0),
                                paletteType: PaletteType.hsvWithValue,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 110,
                          padding: const EdgeInsets.all(4.0),
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4,
                                ),
                                itemCount: colorHistory.length,
                                itemBuilder: (context, index) {
                                  final color = colorHistory[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        tempColor = color; // 选择历史颜色
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: tempColor == color
                                              ? FluentTheme.of(context).accentColor
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Button(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    FilledButton(
                      child: const Text('确定'),
                      onPressed: () {
                        // 直接修改静态属性
                        penColor = tempColor;
                        selectedColor = tempColor;
                        drawingController.setStyle(
                          color: penColor,
                          strokeWidth: penWidth,
                        );

                        // 更新颜色历史记录
                        updateColorHistory(tempColor);

                        // 通知状态更新
                        notifyListeners();

                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  /// 加载画板
  void loadFile(String filePath) async {
    String? path = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
    if (path == null) {
      return;
    }

    drawingBoardFile = DrawingBoardFile.fromMap(jsonDecode(await FileUtil.readFile("$path/$filePath")));
    drawingBoardData = drawingBoardFile.data;
    // 清空控制器内容
    drawingController.clear();
    // 加载当前页面内容
    loadPage();
    // 通知状态更新
    notifyListeners();
  }

  /// 加载当前页面
  void loadPage() {
    // 清空控制器内容
    drawingController.clear();

    if (nowPageIndex >= 0 && nowPageIndex < drawingBoardData.length) {
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

    // 通知状态更新
    notifyListeners();
  }


}