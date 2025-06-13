import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:provider/provider.dart';

import 'package:window_manager/window_manager.dart';

import 'base_drawing_board.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-06-13
 *@Description:
 *@Version: 1.0
 */

class ControllerBar extends StatefulWidget {
  const ControllerBar({super.key});

  @override
  State<ControllerBar> createState() => _ControllerBarState();
}

class _ControllerBarState extends State<ControllerBar> {

  late FlyoutController inkscribeController;
  late FlyoutController penController;
  late FlyoutController eraseController;

  @override
  void initState() {
    super.initState();
    inkscribeController = FlyoutController();
    penController = FlyoutController();
    eraseController = FlyoutController();
  }




  /// 窗口控制
  // final windowsButton = Platform.isWindows ?
  // SizedBox(
  //   height: 50,
  //   width: 50,
  //   child: IconButton(
  //     icon: Icon(_isWindowButtonsVisible
  //         ? FluentSystemIcons.ic_fluent_arrow_next_regular
  //         : FluentSystemIcons
  //         .ic_fluent_arrow_previous_regular),
  //     onPressed: () {
  //       setState(() {
  //         _isWindowButtonsVisible = !_isWindowButtonsVisible;
  //       });
  //     },
  //   ),
  // )
  //     :
  // Container();
  // if (_isWindowButtonsVisible)
  // Platform.isWindows ? WindowButtons() : Container();

  // 重写了DragToMoveArea类，来自定义DragToMoveArea事件
  // 原始的DragToMoveArea双击事件会造成连续点击笔按钮、橡皮按钮卡顿，故删掉

  @override
  Widget build(BuildContext context) {

    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);

    /// 膨胀组件
    final expandedContainer = Expanded(child: Container());
    /// 最左边的AppLogo按钮：用于显示二级菜单
    Widget menuControllerButton = FlyoutTarget(
      controller: inkscribeController,
      child: SizedBox(
        height: 50,
        width: 50,
        child: IconButton(
          icon: Image.asset("assets/icons/app_icon.ico", width: 20, height: 20),
          onPressed: () {
            inkscribeController.showFlyout(
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
                                  drawingState.saveFile();
                                  RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
                                  drawingState.reset();
                                },
                              ),
                              ListTile(
                                leading: Icon(FluentIcons.cancel),
                                title: Text('不保存退出'),
                                onPressed: () {
                                  // RouteUtils.pushForNamed(context, RoutePath.home_page);
                                  RouteUtils.pushNamedAndRemoveUntil(context, RoutePath.home_page);
                                  drawingState.reset();
                                },
                              ),
                              ListTile(
                                leading: Icon(FluentIcons.back_to_window),
                                title: Text('最小化'),
                                onPressed: () {
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
              drawingState.selectedTool == 'inkscribe'
                  ? FluentTheme.of(context).menuColor
                  : FluentTheme.of(context).micaBackgroundColor,
            ),
          ),
        ),
      ),
    );
    /// 画笔工具按钮
    Widget penButton = FlyoutTarget(
      controller: penController,
      child: SizedBox(
        height: 50,
        width: 50,
        child: IconButton(
          icon: Icon(FluentIcons.pen_workspace),
          onPressed: () {
            setState(() {
              if (drawingState.selectedTool == 'pen') {
                drawingState.drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
                drawingState.drawingController.setStyle(color: drawingState.penColor, strokeWidth: drawingState.penWidth);
                drawingState.penButtonPressed = !drawingState.penButtonPressed;
                drawingState.selectedTool = 'pen';
                drawingState.penButtonPressed = true;
                drawingState.eraseButtonPressed = false;

                if (drawingState.penButtonPressed) {
                  penController.showFlyout(
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
                                          child: drawingState.selectedColor == Colors.white
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
                                              drawingState.penColor = Colors.white;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.white;
                                              drawingState.notifyListeners();
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
                                          child: drawingState.selectedColor == Colors.green
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
                                              drawingState.penColor = Colors.green;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.green;

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
                                          child: drawingState.selectedColor == Colors.blue
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
                                              drawingState.penColor = Colors.blue;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.blue;
                                              drawingState.notifyListeners();
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
                                          child: drawingState.selectedColor == Colors.purple
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
                                              drawingState.penColor = Colors.purple;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.purple;
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
                                          child: drawingState.selectedColor == Colors.black
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
                                              drawingState.penColor = Colors.black;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.black;
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
                                          child: drawingState.selectedColor == Colors.yellow
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
                                              drawingState.penColor = Colors.yellow;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.yellow;
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
                                          child: drawingState.selectedColor == Colors.red
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
                                              drawingState.penColor = Colors.red;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.red;
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
                                          child: drawingState.selectedColor == Colors.orange
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
                                              drawingState.penColor = Colors.orange;
                                              drawingState.drawingController.setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth: drawingState.penWidth);
                                              drawingState.selectedColor = Colors.orange;
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
                                            drawingState.showColorPicker(context);
                                          }),
                                      SizedBox(width: 10),


                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Slider(
                                          value: drawingState.penWidth,
                                          max:10,min:1,
                                          onChanged: (value) {
                                            setState(() {
                                              drawingState.penWidth = value ;
                                              drawingState.drawingController
                                                  .setStyle(
                                                  color: drawingState.penColor,
                                                  strokeWidth:
                                                  drawingState.penWidth);
                                            });
                                          }),
                                      SizedBox(width: 1),
                                      Text("${drawingState.penWidth.toStringAsFixed(1)}"),//保留一位小数
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Checkbox(
                                        checked: drawingState.isChangePenWidthByZoom, onChanged: null,
                                        // onChanged: (bool? newValue) {
                                        //   setState(() {
                                        //     drawingState.isChangePenWidthByZoom = newValue ?? false;
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
                drawingState.drawingController
                    .setPaintContent(SmoothLine(brushPrecision: 0.1));
                drawingState.drawingController.setStyle(
                    color: drawingState.penColor, strokeWidth: drawingState.penWidth);
                drawingState.selectedTool = 'pen';
                drawingState.penButtonPressed = true;
                drawingState.eraseButtonPressed = false;
              }
            });
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(
              drawingState.selectedTool == 'pen'
                  ? FluentTheme.of(context).menuColor
                  : FluentTheme.of(context).micaBackgroundColor,
            ),
          ),
        ),
      ),
    );
    /// 橡皮擦工具按钮
    Widget eraseButton = FlyoutTarget(
      controller: eraseController,
      child: SizedBox(
        height: 50,
        width: 50,
        child: IconButton(
          icon: Icon(FluentIcons.erase_tool),
          onPressed: () {
            setState(() {
              if (drawingState.selectedTool == 'erase') {
                drawingState.eraseButtonPressed = !drawingState.eraseButtonPressed;
                drawingState.eraseButtonPressed = true;
                drawingState.penButtonPressed = false;
                drawingState.drawingController.setPaintContent(Eraser());
                drawingState.drawingController.setStyle(strokeWidth: drawingState.eraseWidth);
                if (drawingState.eraseButtonPressed) {
                  double sliderValue = 0;
                  eraseController.showFlyout(
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
                                  value: sliderValue,
                                  min: 0,
                                  max: 1,
                                  onChanged: (double value) {
                                    setState(() {
                                      sliderValue = value;
                                      if (sliderValue == 1) {
                                      }
                                    });
                                  },
                                  onChangeEnd: (double endValue) {
                                    if (endValue < 1) {
                                      setState(() {
                                        sliderValue = 0;
                                      });
                                    } else {
                                      drawingState.drawingController.clear();
                                      setState(() {
                                        Flyout.of(context).close();
                                        drawingState.selectedTool = 'pen';
                                        drawingState.drawingController.setPaintContent(
                                            SmoothLine(
                                                brushPrecision: 0.1));
                                        drawingState.drawingController.setStyle(
                                            color: drawingState.penColor,
                                            strokeWidth: drawingState.penWidth);
                                        sliderValue = 0;
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
                drawingState.drawingController.setPaintContent(Eraser());
                drawingState.drawingController.setStyle(strokeWidth: drawingState.eraseWidth);
                drawingState.selectedTool = 'erase';
                drawingState.eraseButtonPressed = true;
                drawingState.penButtonPressed = false;
              }
            });
          },
          style: ButtonStyle(
            backgroundColor: ButtonState.all(
              drawingState.selectedTool == 'erase'
                  ? FluentTheme.of(context).menuColor
                  : FluentTheme.of(context).micaBackgroundColor,
            ),
          ),
        ),
      ),
    );
    /// 撤销按钮：根据drawingState.canUndo状态控制可用性
    Widget undoButton = SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        icon: Icon(FluentIcons.undo),
        onPressed: drawingState.canUndo
            ? () {
          drawingState.drawingController.undo();
          // _updateUndoState(); // 撤销后更新状态
        }
            : null, // 禁用状态
        style: ButtonStyle(
          backgroundColor: ButtonState.all(
            drawingState.canUndo
                ? FluentTheme.of(context).micaBackgroundColor
                : FluentTheme.of(context).micaBackgroundColor,
          ),
          // foregroundColor: ButtonState.all(
          //   drawingState.canUndo
          //       ? null
          //       : FluentTheme.of(context).micaBackgroundColor,
          // ),
        ),
      ),
    );
    /// 重做按钮
    Widget redoButton = SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        icon: Icon(FluentIcons.redo),
        onPressed: drawingState.canRedo
            ? () {
          drawingState.drawingController.redo();
          // _updateUndoState(); // 撤销后更新状态
        }
            : null, // 禁用状态
        style: ButtonStyle(
          backgroundColor: ButtonState.all(
            drawingState.canRedo
                ? FluentTheme.of(context).micaBackgroundColor
                : FluentTheme.of(context).micaBackgroundColor,
          ),
          // foregroundColor: ButtonState.all(
          //   drawingState.canUndo
          //       ? null
          //       : FluentTheme.of(context).micaBackgroundColor,
          // ),
        ),
      ),
    );
    /// 工具栏中的工具
    List<Widget> toolbar = [
      penButton,
      eraseButton,
      undoButton,
      redoButton,
    ];
    /// 页码组件-当前页
    Widget pageNumberNow = SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
          icon: Icon(FluentIcons.chevron_left),
          style: ButtonStyle(
            backgroundColor: ButtonState.all(
                FluentTheme.of(context).micaBackgroundColor
            ),
          ),
          onPressed:drawingState.nowPageIndex<=0?null:(){
            // 保存当前页面内容
            drawingState.drawingBoardData[drawingState.nowPageIndex] = jsonEncode(drawingState.drawingController.getJsonList());
            drawingState.drawingController.clear();
            // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
            setState(() {
              drawingState.nowPageIndex--;
            });
            drawingState.loadPage();
          }
      ),
    );
    /// 页码组件-页码展示器
    Widget pageNumber = SizedBox(
      height: 50,
      child: IconButton(
        icon: Text("${drawingState.nowPageIndex+1} / ${drawingState.drawingBoardData.length}"),
        onPressed: () {

        },
      ),
    );
    /// 页码组件-下一页/添加页
    Widget pageNumberNext = SizedBox(
      height: 50,
      width: 50,
      child: IconButton(
        icon: (drawingState.nowPageIndex==drawingState.drawingBoardData.length-1)?Icon(FluentIcons.add):Icon(FluentIcons.chevron_right),
        style: ButtonStyle(
          backgroundColor: ButtonState.all(
              FluentTheme.of(context).micaBackgroundColor
          ),
        ),
        onPressed: () {
          // 保存当前页面内容
          print("drawingState.nowPageIndex:${drawingState.nowPageIndex}");
          drawingState.drawingBoardData[drawingState.nowPageIndex] = jsonEncode(drawingState.drawingController.getJsonList());
          drawingState.drawingController.clear();
          // 如果下一页的预计角标超出存储数据的列表长度，则给列表添加一项，否则则去本地文件中读取下一页数据
          setState(() {
            drawingState.nowPageIndex++;
          });
          if((drawingState.nowPageIndex)>(drawingState.drawingBoardData.length-1)){
            drawingState.drawingBoardData.add("");
          }else{
            drawingState.loadPage();
          }


        },
      ),
    );
    
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
            menuControllerButton,
            expandedContainer,
            Row(
              children: toolbar,
            ),
            expandedContainer,
            pageNumberNow,
            pageNumber,
            pageNumberNext,
          ],
        ),
      ),
    );
  }
}
