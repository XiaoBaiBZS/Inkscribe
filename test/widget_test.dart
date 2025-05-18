// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:inksrcibe/main.dart';
//
// class DrawingBoardFileManager {
//   late List<Map<String,List<DrawingBoardFileConfig>>> drawingBoardFilesList;
//
//   DrawingBoardFileManager({
//     required this.drawingBoardFilesList,
//   });
//
//   Map<String, dynamic> toMap() {
//     // 创建顶级Map
//     final resultMap = <String, dynamic>{};
//
//     // 遍历列表中的每个Map
//     for (var i = 0; i < drawingBoardFilesList.length; i++) {
//       final mapItem = drawingBoardFilesList[i];
//
//       // 为每个Map创建子Map
//       final subMap = <String, dynamic>{};
//
//       // 遍历Map中的每个键值对
//       mapItem.forEach((key, value) {
//         // 将List<DrawingBoardFileConfig>转换为List<Map<String,dynamic>>
//         final serializedList = value.map((config) => jsonEncode(config)).toList();
//         subMap[key] = serializedList;
//       });
//
//       // 将子Map添加到结果Map中，使用索引作为键
//       resultMap['item_$i'] = subMap;
//     }
//
//     return resultMap;
//   }
//
//   factory DrawingBoardFileManager.fromMap(Map<String, dynamic> map) {
//     // 初始化最终结果列表
//     final resultList = <Map<String, List<DrawingBoardFileConfig>>>[];
//
//     // 遍历顶级Map中的每个条目（格式为 "item_0": {...}）
//     map.forEach((key, value) {
//       // 跳过非item_前缀的键（如果存在）
//       if (!key.startsWith('item_')) return;
//
//       // 确保值是Map类型
//       if (value is! Map<String, dynamic>) return;
//
//       // 初始化当前Map项
//       final currentMap = <String, List<DrawingBoardFileConfig>>{};
//
//       // 遍历子Map中的每个键值对（格式为 "category": [...]）
//       value.forEach((category, listValue) {
//         // 确保列表值是List类型
//         if (listValue is! List<dynamic>) return;
//
//         // 将JSON对象列表转换为DrawingBoardFileConfig列表
//         final configList = listValue.map((item) {
//           // 确保每个列表项是Map类型
//           if (item is! Map<String, dynamic>) {
//             throw FormatException('Expected Map<String, dynamic> but got ${item.runtimeType}');
//           }
//           return DrawingBoardFileConfig.fromMap(item);
//         }).toList();
//
//         // 将解析后的列表添加到当前Map
//         currentMap[category] = configList;
//       });
//
//       // 将当前Map添加到结果列表
//       resultList.add(currentMap);
//     });
//
//     return DrawingBoardFileManager(
//       drawingBoardFilesList: resultList,
//     );
//   }
//
//   static void initFile() async {
//     String? path = await Settings.getValue<String>(SettingsConfig.workspacePath,
//         defaultValue: '');
//     if ((path ?? '') != null) {
//       return;
//     }
//     if (await FileUtil.fileExists("$path/DrawingBoardFileList.json")) {
//       // 配置文件存在
//     } else {
//       // 配置文件不存在
//       // 创建空文件
//       DrawingBoardFileManager drawingBoardFileManager = DrawingBoardFileManager(
//         drawingBoardFilesList: [],
//       );
//       FileUtil.writeFile("$path/DrawingBoardFileList.json", jsonEncode(drawingBoardFileManager));
//     }
//   }
//
//
//
// static Future<List<DrawingBoardFileConfig>> getFilesList() async {
//   String? path = await Settings.getValue<String>(SettingsConfig.workspacePath, defaultValue: '');
//   late DrawingBoardFileManager drawingBoardFileManager;
//   if (path == null) {
//     return [];
//   }
//   if (await FileUtil.fileExists("$path/DrawingBoardFileList.json")) {
//     // 配置文件存在
//     print("文件内容"+(await FileUtil.readFile("$path/DrawingBoardFileList.json") as String));
//     drawingBoardFileManager = DrawingBoardFileManager.fromMap(jsonDecode(await FileUtil.readFile("$path/DrawingBoardFileList.json") as String));
//
//     return drawingBoardFileManager.drawingBoardFilesList;
//   } else {
//     // 配置文件不存在
//     // 创建空文件
//     drawingBoardFileManager = DrawingBoardFileManager(drawingBoardFilesList: [],);
//     FileUtil.writeFile("$path/DrawingBoardFileList.json", jsonEncode(drawingBoardFileManager.toMap()));
//     return [];
//   }
// }
//
// static void saveNewFile(DrawingBoardFile drawingBoardFile) async {
//   String? path = await Settings.getValue<String>(SettingsConfig.workspacePath,
//       defaultValue: '');
//   late List<DrawingBoardFileConfig> drawingBoardFilesList;
//   late DrawingBoardFileManager drawingBoardFileManager;
//   if (path == null) {
//     return;
//   }
//   if (await FileUtil.fileExists("$path/DrawingBoardFileList.json")) {
//     // 配置文件存在
//     drawingBoardFileManager = DrawingBoardFileManager.fromMap(jsonDecode(
//         await FileUtil.readFile("$path/DrawingBoardFileList.json")
//             as String));
//   } else {
//     // 配置文件不存在
//     // 创建空文件
//     drawingBoardFileManager = DrawingBoardFileManager(
//       drawingBoardFilesList: [],
//     );
//     FileUtil.writeFile("$path/DrawingBoardFileList.json",
//         jsonEncode(drawingBoardFileManager.toMap()));
//   }
//   drawingBoardFileManager.drawingBoardFilesList
//       .add(DrawingBoardFileConfig.fromDrawingBoardFile(drawingBoardFile));
//   FileUtil.writeFile("$path/DrawingBoardFileList.json",
//       jsonEncode(drawingBoardFileManager.toMap()));
//   FileUtil.writeFile(
//       "$path${drawingBoardFile.path}", jsonEncode(drawingBoardFile.toMap()));
// }
//
// static void saveFile(DrawingBoardFile drawingBoardFile) async {
//   String? path = await Settings.getValue<String>(SettingsConfig.workspacePath,
//       defaultValue: '');
//   late List<DrawingBoardFileConfig> drawingBoardFilesList;
//   late DrawingBoardFileManager drawingBoardFileManager;
//   if (path == null) {
//     return;
//   }
//   FileUtil.writeFile("$path${drawingBoardFile.path}", jsonEncode(drawingBoardFile.toMap()));
// }
// }