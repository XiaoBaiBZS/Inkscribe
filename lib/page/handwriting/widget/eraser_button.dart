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

class EraserButton extends StatefulWidget {
  const EraserButton({super.key, required this.eraserController});

  final FlyoutController eraserController;
  @override
  State<EraserButton> createState() => _EraserButtonState();
}

class _EraserButtonState extends State<EraserButton> {
  late DrawingState drawingState;

  @override
  Widget build(BuildContext context) {
    /// 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);
    return FlyoutTarget(
     controller: widget.eraserController,
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
                 widget.eraserController.showFlyout(
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
                                       drawingState.eraseButtonPressed = false;
                                       drawingState.penButtonPressed = true;
                                       drawingState.drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
                                       drawingState.drawingController.setStyle(color: drawingState.penColor, strokeWidth: drawingState.penWidth);
                                       sliderValue = 0;
                                       drawingState.notifyListeners();
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
               drawingState.notifyListeners();
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
  }
}
