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

class UndoButton extends StatefulWidget {
  const UndoButton({super.key,});

  @override
  State<UndoButton> createState() => _UndoButtonState();
}

class _UndoButtonState extends State<UndoButton> {
  late DrawingState drawingState;

  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);
    return SizedBox(
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
  }
}
