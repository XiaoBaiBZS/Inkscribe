import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:provider/provider.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-06-28
 *@Description:
 *@Version: 1.0
 */

class PageNumberListButton extends StatefulWidget {
  const PageNumberListButton({super.key,});

  @override
  State<PageNumberListButton> createState() => _PageNumberListButtonState();
}

class _PageNumberListButtonState extends State<PageNumberListButton> {
  late DrawingState drawingState;

  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);
    return  SizedBox(
      height: 50,
      child: IconButton(
        icon: Text("${drawingState.nowPageIndex+1} / ${drawingState.drawingBoardData.length}"),
        onPressed: () {

        },
      ),
    );
  }
}
