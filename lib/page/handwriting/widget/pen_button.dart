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

class PenButton extends StatefulWidget {
  const PenButton({super.key, required this.penController});

  final FlyoutController penController;
  @override
  State<PenButton> createState() => _PenButtonState();
}

class _PenButtonState extends State<PenButton> {
  late DrawingState drawingState;

  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);
    final List<Color> colorOptions = [
      Colors.white,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];
    // 定义第二行颜色列表
    final List<Color> secondRowColors = [
      Colors.black,
      Colors.yellow,
      Colors.red,
      Colors.orange,
    ];

    // 提取为独立的颜色按钮组件
    Widget _buildColorButton({
      required Color color,
      required DrawingState drawingState,
      required StateSetter setState,
      double spacing = 0, // 可选间隔参数
    }) {
      return Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Button(
              style: ButtonStyle(
                backgroundColor: ButtonState.all(color),
              ),
              child: drawingState.selectedColor == color
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(),
                  Icon(
                    FluentIcons.check_mark,
                    color: color == Colors.white
                        ? Colors.black
                        : Colors.white, // 自动适配图标颜色
                  ),
                ],
              )
                  : const SizedBox(),
              onPressed: () {
                setState(() {
                  drawingState.penColor = color;
                  drawingState.drawingController.setStyle(
                    color: drawingState.penColor,
                    strokeWidth: drawingState.penWidth,
                  );
                  drawingState.selectedColor = color;
                  drawingState.notifyListeners();
                });
              },
            ),
          ),

          if (spacing > 0) SizedBox(width: spacing), // 条件添加间隔
        ],
      );
    }

    return FlyoutTarget(
      controller: widget.penController,
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
                drawingState.notifyListeners();

                if (drawingState.penButtonPressed) {
                  widget.penController.showFlyout(
                    builder: (context) => FlyoutContent(

                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Container(
                            width: 210,
                            height: 230,
                            padding: EdgeInsets.only(left: 10.0),
                            child:Center(
                              child:  Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      // 使用循环生成颜色按钮，减少重复代码
                                      ...colorOptions.map((color) {
                                        return _buildColorButton(
                                          color: color,
                                          drawingState: drawingState,
                                          setState: setState,
                                          spacing: 10, // 仅在非最后一个元素添加间隔
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ...secondRowColors.map((color) {
                                        return _buildColorButton(
                                          color: color,
                                          drawingState: drawingState,
                                          setState: setState,
                                          spacing: 10,
                                        );
                                      }).toList(),
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
                drawingState.notifyListeners();
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
  }
}
