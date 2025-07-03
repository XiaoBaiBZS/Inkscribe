import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/page/handwriting/widget/drawing_state.dart';
import 'package:inksrcibe/util/file_util.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-06-13
 *@Description:
 *@Version: 1.0
 */
class BaseDrawingBoard extends StatefulWidget {



  @override
  State<BaseDrawingBoard> createState() => _BaseDrawingBoardState();
}

class _BaseDrawingBoardState extends State<BaseDrawingBoard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取绘图状态
    final drawingState = Provider.of<DrawingState>(context);

    Future<Widget> buildDrawingBoardBackground() async {
      print(drawingState.drawingBoardFile.type);
      print(drawingState.drawingBoardFile.path);
      String? path = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
      String pdfFileName = "${FileUtil.getFileName(drawingState.drawingBoardFile.path)}.pdf";
      String pdfFilePath = "$path/$pdfFileName";
      switch(drawingState.drawingBoardFile.type){
        case "pdf":
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xff264b42),
            child: PdfViewer.file(
              controller: drawingState.pdfViewerController , pdfFilePath

            ),
          );
        case "normal":
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xff264b42),
          );
        default:
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color(0xff264b42),
          );
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width, // 获取窗口宽度
      height: MediaQuery.of(context).size.height - 50,
      color: FluentTheme.of(context).micaBackgroundColor,
      child:
          // 当切换到橡皮的时候显示一个透明白方块（按钮）模拟橡皮擦跟随触摸点位运动
          Listener(
        onPointerDown: (event) {
          if (drawingState.selectedTool == 'erase') {
              drawingState.isMousePressed = true;
              drawingState.mousePosition = event.position;
              drawingState.notifyListeners();
          }
        },
        onPointerUp: (event) {
          if (drawingState.selectedTool == 'erase') {
              drawingState.isMousePressed = false;
              drawingState.notifyListeners();
          }
        },
        onPointerMove: (event) {
          if (drawingState.selectedTool == 'erase' &&
              drawingState.isMousePressed) {
              drawingState.mousePosition = event.position;
              drawingState.notifyListeners();
          }
        },
        child: DrawingBoard(
          // 画布控制器
          controller: drawingState.drawingController,
          // 监听画布事件
          // onInteractionUpdate: (event) {
          //   drawingState.zoomLevel = ((drawingState.zoomLevel *
          //               (event.scale == 0 ? 1 : event.scale)) >
          //           20
          //       ? 20
          //       : ((drawingState.zoomLevel *
          //                   (event.scale == 0 ? 1 : event.scale)) <
          //               0.2
          //           ? 0.2
          //           : (drawingState.zoomLevel *
          //               (event.scale == 0 ? 1 : event.scale))));
          //   setState(() {
          //     drawingState.zoomLevel;
          //   });
          // },
          // 画布背景，这里是默认的黑板背景
          background: FutureBuilder(future: buildDrawingBoardBackground(), builder: (
              BuildContext context,
              AsyncSnapshot<Widget> snapshot
              ){
            return snapshot.hasData ? snapshot.data! : Container();
          }),


              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              //   // child:  PdfViewer.file("/storage/emulated/0/Download/WeiXin/你好.pdf"),
              //   child:  PdfViewer.file("C:/Users/12985/Downloads/你好.pdf"),
              // )
          //     Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   color: Color(0xff264b42),
          // ),
        ),
      ),
    );
  }
}
