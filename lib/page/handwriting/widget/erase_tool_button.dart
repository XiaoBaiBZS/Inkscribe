import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-26
 *@Description:
 *@Version: 1.0
 */

class  EraseToolButton extends BaseToolButton{
  final DrawingController _drawingController;
  late double _eraseWidth;

  EraseToolButton(this._drawingController, this._eraseWidth ,{
    super.key,
    required super.controllerBarHeight,
    required super.controllerBarWidth,
    required super.context,
  }) {
    icon = const Icon(FluentIcons.erase_tool);
    toolName = "erase";
  }

  @override
  Function get toolSelectOnce => () {
    _drawingController.setPaintContent(Eraser());
    _drawingController.setStyle(strokeWidth: _eraseWidth);
    isSelected = true;
  };

  @override
  Function get toolSelectTwice => (){
    double slider_value = 0;
    flyoutController.showFlyout(
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
                        if (slider_value == 1) {}
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
                          // _selectedTool = 'pen';
                          // _drawingController.setPaintContent(
                          //     SmoothLine(brushPrecision: 0.1));
                          // _drawingController.setStyle(
                          //     color: _penColor,
                          //     strokeWidth: _penWidth);
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
  };


}