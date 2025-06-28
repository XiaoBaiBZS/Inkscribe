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

class PageNumberNowButton extends StatefulWidget {
  const PageNumberNowButton({super.key,});

  @override
  State<PageNumberNowButton> createState() => _PageNumberNowButtonState();
}

class _PageNumberNowButtonState extends State<PageNumberNowButton> {
  late DrawingState drawingState;

  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);
    return  SizedBox(
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
  }
}
