import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:inksrcibe/page/handwriting/widget/eraser_button.dart';
import 'package:inksrcibe/page/handwriting/widget/menu_controller_button.dart';
import 'package:inksrcibe/page/handwriting/widget/page_number_list_button.dart';
import 'package:inksrcibe/page/handwriting/widget/page_number_next_button.dart';
import 'package:inksrcibe/page/handwriting/widget/page_number_now_button.dart';
import 'package:inksrcibe/page/handwriting/widget/pen_button.dart';
import 'package:inksrcibe/page/handwriting/widget/redo_button.dart';
import 'package:inksrcibe/page/handwriting/widget/undo_button.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:provider/provider.dart';

import 'package:window_manager/window_manager.dart';


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
  late FlyoutController eraserController;

  @override
  void initState() {
    super.initState();
    inkscribeController = FlyoutController();
    penController = FlyoutController();
    eraserController = FlyoutController();
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

    /// 膨胀组件
    final expandedContainer = Expanded(child: Container());

    /// 工具栏中的工具
    List<Widget> toolbar = [
      PenButton(penController: penController),
      EraserButton(eraserController: eraserController),
      UndoButton(),
      RedoButton(),
    ];

    /// 页面组件
    List<Widget> pageComponents = [
      PageNumberNowButton(),
      PageNumberListButton(),
      PageNumberNextButton(),
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
          children: [
            MenuControllerButton(inkscribeController: inkscribeController,),
            expandedContainer,
            ...toolbar,
            expandedContainer,
            ...pageComponents,
          ],
        ),
      ),
    );
  }
}
