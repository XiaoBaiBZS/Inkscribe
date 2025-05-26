import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:inksrcibe/page/handwriting/widget/base/base_tool_button.dart';

class PenToolButton extends BaseToolButton{
  final DrawingController _drawingController;
  late double _penWidth;
  late Color _penColor;
  late Color? _selectedColor; // 使用late初始化
  final List<Color> _quickSelectColor = [
    Colors.white, Colors.black, Colors.red, Colors.green,
    Colors.blue, Colors.yellow, Colors.orange, Colors.purple,
  ];

  /// 笔刷历史颜色（最多8种）
  late List<Color> _colorHistory = [];

  PenToolButton(this._drawingController, this._penWidth, this._penColor, {
    super.key,
    required super.controllerBarHeight,
    required super.controllerBarWidth,
    required super.context,
  }) {
    icon = const Icon(FluentIcons.pen_workspace);
    toolName = "pen";
    _initColorState(); // 初始化颜色状态
  }

  void _initColorState() {
    _selectedColor = _penColor;
    if (_colorHistory.isEmpty) {
      _colorHistory.addAll(_quickSelectColor.take(8)); // 使用快速选择颜色初始化
    }
  }

  @override
  Function get toolSelectOnce => () {
    _drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
    _drawingController.setStyle(color: _penColor, strokeWidth: _penWidth);
    isSelected = true;
  };

  @override
  Function get toolSelectTwice => () => _showToolSettings();

  /// 显示工具设置浮窗
  void _showToolSettings() {
    super.flyoutController.showFlyout(builder: (context) {
      return FlyoutContent(
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            width: 210,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorSelectorRow(setState),
                const SizedBox(height: 16),
                _buildMoreColorsButton(context,setState),
                const SizedBox(height: 16),
                _buildStrokeWidthSlider(setState),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 构建颜色选择行
  Widget _buildColorSelectorRow(StateSetter setState) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _quickSelectColor.map((color) {
        return _buildColorButton(color, setState);
      }).toList(),
    );
  }

  /// 构建单个颜色按钮
  Widget _buildColorButton(Color color, StateSetter setState) {
    final isSelected = _selectedColor == color;
    return SizedBox(
      width: 40,
      height: 40,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: ButtonState.all(color),
          shape: ButtonState.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: isSelected ? FluentTheme.of(context).accentColor : Colors.transparent,
              width: 2,
            ),
          )),
        ),
        child: isSelected ? Icon(FluentIcons.check_mark, size: 18) : Container(),
        onPressed: () => _handleColorSelection(color, setState),
      ),
    );
  }

  /// 处理颜色选择
  void _handleColorSelection(Color color, StateSetter setState) {
    setState(() {
      _penColor = color;
      _selectedColor = color;
      _drawingController.setStyle(color: color, strokeWidth: _penWidth);
      _updateColorHistory(color); // 更新颜色历史
    });
  }

  /// 构建更多颜色按钮
  Widget _buildMoreColorsButton(BuildContext thisContext,StateSetter setState) {
    return Row(
      children: [
        FilledButton(
          child:Text("更多颜色"),
          onPressed: () {
            showColorPicker(context, setState);
          },
        ),
      ],
    );
  }

  /// 构建笔触宽度滑块
  Widget _buildStrokeWidthSlider(StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _penWidth,
            min: 1,
            max: 10,
            onChanged: (value) => setState(() {
              _penWidth = value;
              _drawingController.setStyle(strokeWidth: value);
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text("${_penWidth.toStringAsFixed(1)}", ),
      ],
    );
  }

  /// 显示颜色选择器，用于“更多颜色”功能
  void showColorPicker(BuildContext context, StateSetter setState) {
    // 更新颜色历史记录
    void updateColorHistory(Color color) {
      // 如果颜色已在历史记录中，将其移至最前面
      if (_colorHistory.contains(color)) {
        _colorHistory.remove(color);
      }
      // 添加到历史记录的最前面
      _colorHistory.insert(0, color);

      // 限制历史记录最多8种颜色
      if (_colorHistory.length > 32) {
        _colorHistory.removeRange(32, _colorHistory.length);
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
                left: (MediaQuery.of(context).size.width - 365) / 2,
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
                                  pickerAreaBorderRadius:
                                  BorderRadius.circular(8.0),
                                  paletteType: PaletteType.hsvWithValue,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 110,
                            padding: const EdgeInsets.all(4.0),
                            child: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return GridView.builder(
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                                          borderRadius:
                                          BorderRadius.circular(4),
                                          border: Border.all(
                                            color: tempColor == color
                                                ? FluentTheme.of(context)
                                                .accentColor
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
                          });

                          // 更新颜色历史记录
                          updateColorHistory(tempColor);

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ))
          ],
        );
      },
    );
  }

  /// 更新颜色历史记录
  void _updateColorHistory(Color color) {
    if (_colorHistory.contains(color)) _colorHistory.remove(color);
    _colorHistory.insert(0, color);
    if (_colorHistory.length > 8) _colorHistory.removeRange(8, _colorHistory.length); // 保持最多8种
  }
}