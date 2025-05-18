import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/util/file_util.dart';
import 'package:inksrcibe/util/info_bar_util.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:math' as math;
import '../../config/settings_config.dart';
import '../../module/window_buttons.dart';


class HandwritingBlankPage extends StatefulWidget {
  const HandwritingBlankPage({super.key});

  @override
  State<HandwritingBlankPage> createState() => _HandwritingBlankPageState();
}

class _HandwritingBlankPageState extends State<HandwritingBlankPage> with WindowListener {
  /// 画布控制器
  late DrawingController _drawingController;

  /// 画布是否可以撤销或者重做
  bool _canUndo = false;
  bool _canRedo = false;

  /// 控制WindowButtons是否显示
  bool _isWindowButtonsVisible = false;

  /// 画笔工具相关属性
  // 画笔颜色
  Color _penColor = Colors.white;
  // 画笔粗细
  double _penWidth = 3.0;
  // 记录当前选中的颜色
  Color? _selectedColor = Colors.white;

  /// 橡皮工具相关属性
  // 橡皮擦粗细
  double _eraseWidth = 40.0;

  /// 当前选中的工具
  // 跟踪当前选中的工具
  String _selectedTool = 'pen';
  bool _penButtonPressed = false;
  bool _eraseButtonPressed = false;

  /// 鼠标位置
  Offset? _mousePosition;
  /// 鼠标按下状态
  bool _isMousePressed = false;

  /// 笔刷历史颜色
  List<Color> _colorHistory = [];

  bool _isChangePenWidthByZoom = true;
  double _zoomLevel = 1.0;

  /// 画板数据
  late DrawingBoardFile _drawingBoardFile;

  /// 是否已经加载画板
  bool _isExecuted = false;

  /// 当前画板页面索引
  int _nowPageIndex = 0;

  /// 当前画板总数据
  List<String> _drawingBoardData = [];
  
  /// 当前画板文件相对路径
  String _filePath = '';

  /// 创建文件对象
  void _createFile(String path) async {
    DateTime now = DateTime.now();
    _drawingBoardData.add( _drawingController.getJsonList().toString());
    _drawingBoardFile  = DrawingBoardFile(
      name: "未命名笔记",
      path: "$path/${now.millisecondsSinceEpoch}.json",
      type: "normal",
      createDateTime: now,
      data: _drawingBoardData,
    );
    fileTreeManager.addFile(DrawingBoardFileConfig.fromDrawingBoardFile(_drawingBoardFile),directoryPath: path);
    fileTreeManager.writeToConfigFile();
    _drawingBoardFile.saveFile();
  }

  /// 保存笔记文件
  void _saveFile() async {
    _drawingBoardFile.data = _drawingBoardData;
    _drawingBoardFile.saveFile();
  }

  /// 更新撤销状态
  void _updateUndoState() {
    setState(() {
      _canUndo = _drawingController.canUndo();
    });
  }

  /// 更新重做状态
  void _updateRedoState() {
    setState(() {
      _canRedo = _drawingController.canRedo();
    });
  }


  /// 构建工具栏（底栏）
  Widget _buildControllerBar() {
    final FlyoutController _inkscribe_controller = FlyoutController();
    final FlyoutController _pen_controller = FlyoutController();
    final FlyoutController _erase_controller = FlyoutController();

    // 重写了DragToMoveArea类，来自定义DragToMoveArea事件
    // 原始的DragToMoveArea双击事件会造成连续点击笔按钮、橡皮按钮卡顿，故删掉
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
          children: [
            FlyoutTarget(
              controller: _inkscribe_controller,
              child: SizedBox(
                height: 50,
                width: 50,
                child: IconButton(
                  icon: Image.asset("assets/icons/app_icon.ico",
                      width: 20, height: 20),
                  onPressed: () {
                    _inkscribe_controller.showFlyout(
                      builder: (context) => FlyoutContent(
                        padding: EdgeInsets.zero,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Acrylic(

                            child: Container(
                              width: 160,
                              padding: EdgeInsets.zero,
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [


                                  ListBody(
                                    children: [
                                      ListTile(
                                        leading: Icon(FluentIcons.save),
                                        title: Text('保存退出'),
                                        onPressed: () {
                                          _saveFile();
                                          RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
                                        },
                                      ),
                                      // ListTile(
                                      //   leading: Icon(FluentIcons.back_to_window),
                                      //   title: Text('最小化'),
                                      //   onPressed: () {
                                      //   },
                                      // ),
                                      ListTile(
                                        leading: Icon(FluentIcons.cancel),
                                        title: Text('不保存退出'),
                                        onPressed: () {
                                          // RouteUtils.pushForNamed(context, RoutePath.home_page);
                                          RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: ButtonState.all(
                      _selectedTool == 'inkscribe'
                          ? FluentTheme.of(context).menuColor
                          : FluentTheme.of(context).micaBackgroundColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(child: Container()),
            Row(
              children: [
                // 画笔工具按钮
                FlyoutTarget(
                  controller: _pen_controller,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      icon: Icon(FluentIcons.pen_workspace),
                      onPressed: () {
                        setState(() {
                          if (_selectedTool == 'pen') {
                            _drawingController
                                .setPaintContent(SmoothLine(brushPrecision: 0.1));
                            _drawingController.setStyle(
                                color: _penColor, strokeWidth: _penWidth);
                            _penButtonPressed = !_penButtonPressed;
                            _selectedTool = 'pen';
                            _penButtonPressed = true;
                            _eraseButtonPressed = false;

                            if (_penButtonPressed) {
                              _pen_controller.showFlyout(
                                builder: (context) => FlyoutContent(

                                  child: StatefulBuilder(builder:
                                      (BuildContext context, StateSetter setState) {
                                    return Container(
                                        width: 210,
                                        height: 230,
                                        padding: EdgeInsets.all(8.0),
                                        child:Center(
                                          child:  Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.white),
                                                      ),
                                                      child: _selectedColor == Colors.white
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                            FluentIcons.check_mark,
                                                            color: Colors.black,
                                                          ),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.white;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.white;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.green),
                                                      ),
                                                      child: _selectedColor == Colors.green
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.green;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.green;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.blue),
                                                      ),
                                                      child: _selectedColor == Colors.blue
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.blue;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.blue;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.purple),
                                                      ),
                                                      child: _selectedColor == Colors.purple
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.purple;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.purple;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.black),
                                                      ),
                                                      child: _selectedColor == Colors.black
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.black;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.black;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.yellow),
                                                      ),
                                                      child: _selectedColor == Colors.yellow
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                            FluentIcons.check_mark,
                                                            color: Colors.black,
                                                          ),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.yellow;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.yellow;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.red),
                                                      ),
                                                      child: _selectedColor == Colors.red
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.red;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.red;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Button(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                        ButtonState.all(Colors.orange),
                                                      ),
                                                      child: _selectedColor == Colors.orange
                                                          ? Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Container(),
                                                          const Icon(
                                                              FluentIcons.check_mark),
                                                        ],
                                                      )
                                                          : Container(),
                                                      onPressed: () {
                                                        setState(() {
                                                          _penColor = Colors.orange;
                                                          _drawingController.setStyle(
                                                              color: _penColor,
                                                              strokeWidth: _penWidth);
                                                          _selectedColor = Colors.orange;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Row(
                                                children: [
                                                  FilledButton(
                                                      child: Row(
                                                        children: [Text("更多颜色")],
                                                      ),
                                                      onPressed: () {
                                                        Flyout.of(context).close();
                                                        _showColorPicker();
                                                      }),
                                                  SizedBox(width: 10),


                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                children: [
                                                  Slider(
                                                      value: _penWidth,
                                                      max:10,min:1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _penWidth = value ;
                                                          _drawingController
                                                              .setStyle(
                                                              color: _penColor,
                                                              strokeWidth:
                                                              _penWidth);
                                                        });
                                                      }),
                                                  SizedBox(width: 1),
                                                  Text("${_penWidth.toStringAsFixed(1)}"),//保留一位小数
                                                ],
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    checked: _isChangePenWidthByZoom, onChanged: null,
                                                    // onChanged: (bool? newValue) {
                                                    //   setState(() {
                                                    //     _isChangePenWidthByZoom = newValue ?? false;
                                                    //   });
                                                    //
                                                    // },
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Text("粗细跟随屏幕缩放(未来)",),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                    );
                                  }),
                                ),
                              );
                            }
                          } else {
                            _drawingController
                                .setPaintContent(SmoothLine(brushPrecision: 0.1));
                            _drawingController.setStyle(
                                color: _penColor, strokeWidth: _penWidth);
                            _selectedTool = 'pen';
                            _penButtonPressed = true;
                            _eraseButtonPressed = false;
                          }
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: ButtonState.all(
                          _selectedTool == 'pen'
                              ? FluentTheme.of(context).menuColor
                              : FluentTheme.of(context).micaBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // 橡皮擦工具按钮
                FlyoutTarget(
                  controller: _erase_controller,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: IconButton(
                      icon: Icon(FluentIcons.erase_tool),
                      onPressed: () {
                        setState(() {
                          if (_selectedTool == 'erase') {
                            _eraseButtonPressed = !_eraseButtonPressed;
                            _eraseButtonPressed = true;
                            _penButtonPressed = false;
                            _drawingController.setPaintContent(Eraser());
                            _drawingController.setStyle(strokeWidth: _eraseWidth);
                            if (_eraseButtonPressed) {
                              double slider_value = 0;
                              _erase_controller.showFlyout(
                                builder: (context) => FlyoutContent(
                                  child: StatefulBuilder(
                                    builder:
                                        (BuildContext context, StateSetter setState) {
                                      return Container(
                                        width: 150,
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("滑动清空(无法撤销)"),
                                            Slider(
                                              value: slider_value,
                                              min: 0,
                                              max: 1,
                                              onChanged: (double value) {
                                                setState(() {
                                                  slider_value = value;
                                                  if (slider_value == 1) {
                                                  }
                                                });
                                              },
                                              onChangeEnd: (double endValue) {
                                                if (endValue < 1) {
                                                  setState(() {
                                                    slider_value = 0;
                                                  });
                                                } else {
                                                  _drawingController.clear();
                                                  setState(() {
                                                    Flyout.of(context).close();
                                                    _selectedTool = 'pen';
                                                    _drawingController.setPaintContent(
                                                        SmoothLine(
                                                            brushPrecision: 0.1));
                                                    _drawingController.setStyle(
                                                        color: _penColor,
                                                        strokeWidth: _penWidth);
                                                    slider_value = 0;
                                                  });
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          } else {
                            _drawingController.setPaintContent(Eraser());
                            _drawingController.setStyle(strokeWidth: _eraseWidth);
                            _selectedTool = 'erase';
                            _eraseButtonPressed = true;
                            _penButtonPressed = false;
                          }
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: ButtonState.all(
                          _selectedTool == 'erase'
                              ? FluentTheme.of(context).menuColor
                              : FluentTheme.of(context).micaBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),

                // 撤销按钮 - 根据_canUndo状态控制可用性
                SizedBox(
                  height: 50,
                  width: 50,
                  child: IconButton(
                    icon: Icon(FluentIcons.undo),
                    onPressed: _canUndo
                        ? () {
                      _drawingController.undo();
                      // _updateUndoState(); // 撤销后更新状态
                    }
                        : null, // 禁用状态
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(
                        _canUndo
                            ? FluentTheme.of(context).micaBackgroundColor
                            : FluentTheme.of(context).micaBackgroundColor,
                      ),
                      // foregroundColor: ButtonState.all(
                      //   _canUndo
                      //       ? null
                      //       : FluentTheme.of(context).micaBackgroundColor,
                      // ),
                    ),
                  ),
                ),

                // 重做按钮
                SizedBox(
                  height: 50,
                  width: 50,
                  child: IconButton(
                    icon: Icon(FluentIcons.redo),
                    onPressed: _canRedo
                        ? () {
                      _drawingController.redo();
                      // _updateUndoState(); // 撤销后更新状态
                    }
                        : null, // 禁用状态
                    style: ButtonStyle(
                      backgroundColor: ButtonState.all(
                        _canRedo
                            ? FluentTheme.of(context).micaBackgroundColor
                            : FluentTheme.of(context).micaBackgroundColor,
                      ),
                      // foregroundColor: ButtonState.all(
                      //   _canUndo
                      //       ? null
                      //       : FluentTheme.of(context).micaBackgroundColor,
                      // ),
                    ),
                  ),
                ),


              ],
            ),
            Expanded(child: Container()),
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                icon: Icon(FluentIcons.chevron_left),
                style: ButtonStyle(
                    backgroundColor: ButtonState.all(
                       FluentTheme.of(context).micaBackgroundColor
                    ),
                ),
                onPressed:_nowPageIndex<=0?null:(){
                  // 保存当前页面内容
                  _drawingBoardData[_nowPageIndex] = jsonEncode(_drawingController.getJsonList());
                  _drawingController.clear();
                  // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
                  setState(() {
                    _nowPageIndex--;
                  });
                  _loadPage();
                }
              ),
            ),
            SizedBox(
              height: 50,

              child: IconButton(
                icon: Text("${_nowPageIndex+1} / ${_drawingBoardData.length}"),
                onPressed: () {

                },
              ),
            ),
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                icon: (_nowPageIndex==_drawingBoardData.length-1)?Icon(FluentIcons.add):Icon(FluentIcons.chevron_right),
                style: ButtonStyle(
                  backgroundColor: ButtonState.all(
                      FluentTheme.of(context).micaBackgroundColor
                  ),
                ),
                onPressed: () {
                  // 保存当前页面内容
                  _drawingBoardData[_nowPageIndex] = jsonEncode(_drawingController.getJsonList());
                  _drawingController.clear();
                  // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
                  setState(() {
                    _nowPageIndex++;
                  });
                  if((_nowPageIndex)>(_drawingBoardData.length-1)){
                    _drawingBoardData.add("");
                  }else{
                    _loadPage();
                  }


                },
              ),
            ),
            Platform.isWindows ?
            SizedBox(
              height: 50,
              width: 50,
              child: IconButton(
                icon: Icon(_isWindowButtonsVisible
                    ? FluentSystemIcons.ic_fluent_arrow_next_regular
                    : FluentSystemIcons
                    .ic_fluent_arrow_previous_regular),
                onPressed: () {
                  setState(() {
                    _isWindowButtonsVisible = !_isWindowButtonsVisible;
                  });
                },
              ),
            ):Container(),
            if (_isWindowButtonsVisible)
              Platform.isWindows ? WindowButtons() : Container(),
          ],
        ),
      ),
    );
  }

  /// 显示颜色选择器，用于“更多颜色”功能
  void _showColorPicker() {


    // 更新颜色历史记录
    void _updateColorHistory(Color color) {
      // 如果颜色已在历史记录中，将其移至最前面
      if (_colorHistory.contains(color)) {
        _colorHistory.remove(color);
      }
      // 添加到历史记录的最前面
      _colorHistory.insert(0, color);

      // 限制历史记录最多8种颜色
      if (_colorHistory.length > 32) {
        _colorHistory.removeRange(8, _colorHistory.length);
      }
    }

    // 初始化颜色历史记录（如果为空）
    if (_colorHistory.isEmpty) {
      _colorHistory = [
        _penColor, // 添加当前颜色作为第一个历史记录
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
      builder: (BuildContext context) {
        Color tempColor = _penColor; // 临时存储用户选择的颜色

        return Stack(
          children: [
            Positioned(
                bottom: 50,
                left: (MediaQuery.of(context).size.width-365) / 2 ,
                child: Center(
                  child:  ContentDialog(

                    title: const Text('选择画笔颜色'),
                    content: Container(
                      height: 340,
                      child: Column(
                        children: [
                          // 颜色选择器主体
                          Container(
                            child: material.Material(
                              child: Container(
                                color: FluentTheme.of(context).menuColor,
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
                                  paletteType:PaletteType.hsvWithValue,
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
                                  itemCount: _colorHistory.length,
                                  itemBuilder: (context, index) {
                                    final color = _colorHistory[index];
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
                                            color: tempColor == color ? FluentTheme.of(context).accentColor : Colors.transparent,
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
                          Navigator.of(context).pop();
                        },
                      ),
                      FilledButton(
                        child: const Text('确定'),
                        onPressed: () {
                          setState(() {
                            _penColor = tempColor;
                            _selectedColor = tempColor;
                            _drawingController.setStyle(
                              color: _penColor,
                              strokeWidth: _penWidth,
                            );

                            // 更新颜色历史记录
                            _updateColorHistory(tempColor);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                )
            )
          ],
        );
      },
    );
  }

  /// 加载画板
  void _loadFile(String filePath) async {
    String? path  = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
    if(path == null){
      return;
    }
    _drawingBoardFile = DrawingBoardFile.fromMap(jsonDecode(await FileUtil.readFile("$path/$filePath")));
    setState((){
      _drawingBoardFile;
      _drawingBoardData = _drawingBoardFile.data;
    });
    jsonDecode(_drawingBoardFile.data[_nowPageIndex]).forEach((element) {
      switch(element["type"]){
        case "StraightLine":
          _drawingController.addContent(StraightLine.fromJson(element));
          break;
        case "SimpleLine":
          _drawingController.addContent(SimpleLine.fromJson(element));
          break;
        case "SmoothLine":
          _drawingController.addContent(SmoothLine.fromJson(element));
          break;
        case "Eraser":
          _drawingController.addContent(Eraser.fromJson(element));
          break;
        case "Rectangle":
          _drawingController.addContent(Rectangle.fromJson(element));
          break;
        case "Circle":
          _drawingController.addContent(Circle.fromJson(element));
          break;
      }
    });
  }
  void _loadPage() async {
    jsonDecode(_drawingBoardData[_nowPageIndex]).forEach((element) {
      switch(element["type"]){
        case "StraightLine":
          _drawingController.addContent(StraightLine.fromJson(element));
          break;
        case "SimpleLine":
          _drawingController.addContent(SimpleLine.fromJson(element));
          break;
        case "SmoothLine":
          _drawingController.addContent(SmoothLine.fromJson(element));
          break;
        case "Eraser":
          _drawingController.addContent(Eraser.fromJson(element));
          break;
        case "Rectangle":
          _drawingController.addContent(Rectangle.fromJson(element));
          break;
        case "Circle":
          _drawingController.addContent(Circle.fromJson(element));
          break;
      }
    });
  }

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
    // 初始化画布控制器
    _drawingController = DrawingController();
    // 监听画布更新，当画布更新的时候更新撤销按钮状态和重做按钮状态
    _drawingController.realPainter?.addListener(() {
      _updateUndoState();
      _updateRedoState();
      // _drawingBoardData[_nowPageIndex] = jsonEncode(_drawingController.getJsonList());
      _drawingBoardFile.data = _drawingBoardData;
    });
    // 设置默认画笔为模拟压感笔，模拟压感灵敏度为0.1
    _drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
    // 设置画笔颜色和粗细
    _drawingController.setStyle(color: _penColor, strokeWidth: _penWidth);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(!_isExecuted){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Map? args = ModalRoute.of(context)?.settings.arguments as Map?;
        try{
          if(args==null){

          }else{
            if(args["function"]!=null || args["path"]==null){
              switch(args["function"]){
                case "load":
                  _loadFile(args["path"]);
                  break;
                case "create":
                  _createFile(args["path"]);
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
        _isExecuted = true;
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.only(top: 0),
      content: Container(
        color: FluentTheme.of(context).micaBackgroundColor,
        // color: Colors.transparent,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width, // 获取窗口宽度
                  height: MediaQuery.of(context).size.height - 50,
                  color: FluentTheme.of(context).micaBackgroundColor,
                  child:
                  // 当切换到橡皮的时候显示一个透明白方块（按钮）模拟橡皮擦跟随触摸点位运动
                  Listener(
                    onPointerDown: (event) {
                      if (_selectedTool == 'erase') {
                        setState(() {
                          _isMousePressed = true;
                          _mousePosition = event.position;
                        });
                      }
                    },
                    onPointerUp: (event) {
                      if (_selectedTool == 'erase') {
                        setState(() {
                          _isMousePressed = false;
                        });
                      }
                    },
                    onPointerMove: (event) {
                      if (_selectedTool == 'erase' && _isMousePressed) {
                        setState(() {
                          _mousePosition = event.position;
                        });
                      }
                    },
                    child:
                    /// 画布
                    DrawingBoard(
                      // 画布控制器
                      controller: _drawingController,
                      // 监听画布事件
                      onInteractionUpdate: (event) {
                          _zoomLevel = ((_zoomLevel * (event.scale==0?1:event.scale)) > 20 ? 20:((_zoomLevel * (event.scale==0?1:event.scale))<0.2?0.2:(_zoomLevel * (event.scale==0?1:event.scale))));
                        setState(() {
                          _zoomLevel;
                        });
                      },
                      // 画布背景，这里是默认的黑板背景
                      background: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Color(0xff264b42),
                      ),
                      // showDefaultTools:true,
                      // showDefaultActions:true,
                    ),
                  ),
                ),
                // 可拖动的浮动Container
                // Positioned(
                //   left: _left,
                //   top: _top,
                //   child: GestureDetector(
                //     onPanStart: (details) {
                //       setState(() {
                //         _isDragging = true;
                //         _dragStart = details.globalPosition;
                //       });
                //     },
                //     onPanUpdate: (details) {
                //       if (_isDragging) {
                //         final dx = details.globalPosition.dx - _dragStart.dx;
                //         final dy = details.globalPosition.dy - _dragStart.dy;
                //
                //         // 更新位置
                //         setState(() {
                //           _left += dx;
                //           _top += dy;
                //           _dragStart = details.globalPosition;
                //
                //           // 确保Container不会被拖出屏幕
                //           _left = _left.clamp(
                //               0.0, MediaQuery.of(context).size.width - _width);
                //           _top = _top.clamp(
                //               0.0,
                //               MediaQuery.of(context).size.height -
                //                   50 -
                //                   _height);
                //         });
                //       }
                //     },
                //     onPanEnd: (details) {
                //       setState(() {
                //         _isDragging = false;
                //       });
                //     },
                //     child: Container(
                //       width: _width,
                //       height: _height,
                //       decoration: BoxDecoration(
                //         color: Colors.white.withOpacity(0.8),
                //         borderRadius: BorderRadius.circular(8),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black.withOpacity(0.2),
                //             blurRadius: 10,
                //             offset: Offset(0, 3),
                //           )
                //         ],
                //       ),
                //       child: Column(
                //         children: [
                //           Container(
                //             height: 30,
                //             width: double.infinity,
                //             decoration: BoxDecoration(
                //               color: FluentTheme.of(context).accentColor,
                //               borderRadius: BorderRadius.vertical(
                //                   top: Radius.circular(8)),
                //             ),
                //             child: Center(
                //               child: Text(
                //                 "可拖动面板",
                //                 style: TextStyle(color: Colors.white),
                //               ),
                //             ),
                //           ),
                //           Expanded(
                //             child: Padding(
                //               padding: EdgeInsets.all(8),
                //               child: Text(
                //                 "_zoomLevel=${_zoomLevel}",
                //                 style: TextStyle(fontSize: 12),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // 当选中橡皮擦且鼠标按下时显示跟随鼠标的白色小Container
                /// 橡皮擦白色透明框框
                if (_selectedTool == 'erase' &&
                    _isMousePressed &&
                    _mousePosition != null)
                  Positioned(
                    left: _mousePosition!.dx - _eraseWidth/2,
                    top: _mousePosition!.dy - _eraseWidth/2,
                    child:
                    // 橡皮擦
                    SizedBox(
                      width: _eraseWidth,
                      height:_eraseWidth ,
                      child: Button(child: Container(), onPressed: () {}),
                    ),
                  ),
              ],
            ),
            // 底部控制栏
            _buildControllerBar(),
          ],
        ),
      ),
    );
  }
}
