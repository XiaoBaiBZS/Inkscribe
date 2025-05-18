import 'dart:convert';

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/util/file_util.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-15
 *@Description:
 *@Version: 1.0
 */

/// 画板基础信息
class DrawingBoardFileConfig {
  /// 画板文件名
  late String name;

  /// 画板存放相对路径
  late String path;

  /// 画板类型
  late String type = DrawingBoardType.normal;

  /// 创建日期时间
  late DateTime createDateTime;

  DrawingBoardFileConfig({
    required this.name,
    required this.path,
    required this.type,
    required this.createDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "path": path,
      "type": type,
      "createDateTime": createDateTime.toIso8601String(),
    };
  }

  factory DrawingBoardFileConfig.fromMap(Map<String, dynamic> map) {
    return DrawingBoardFileConfig(
      name: map['name'],
      path: map['path'],
      type: map['type'],
      createDateTime: DateTime.parse(map['createDateTime']),
    );
  }

  factory DrawingBoardFileConfig.fromDrawingBoardFile(
      DrawingBoardFile drawingBoardFile) {
    return DrawingBoardFileConfig(
      name: drawingBoardFile.name,
      path: drawingBoardFile.path,
      type: drawingBoardFile.type,
      createDateTime: drawingBoardFile.createDateTime,
    );
  }
}

/// 画板全部信息
class DrawingBoardFile extends DrawingBoardFileConfig {
  /// 数据
  late String data;

  DrawingBoardFile({
    required this.data,
    required super.name,
    required super.path,
    required super.type,
    required super.createDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "path": path,
      "type": type,
      "createDateTime": createDateTime.toIso8601String(),
      "data": data
    };
  }

  factory DrawingBoardFile.fromMap(Map<String, dynamic> map) {
    return DrawingBoardFile(
      name: map['name'],
      path: map['path'],
      type: map['type'],
      createDateTime: DateTime.parse(map['createDateTime']),
      data: map['data'],
    );
  }


  void saveFile() async {
    String? workspacePath = Settings.getValue(SettingsConfig.workspacePath,defaultValue:  "");
    FileUtil.writeFile("$workspacePath$path", json.encode(toMap()));
  }
}

/// 画板可选类型
class DrawingBoardType {
  static const String normal = "normal";
  static const String pdf = "pdf";
  static const String image = "image";
}

/// 文件树系统相关类
abstract class FileSystemNode {
  String get name;
  String get path;
  bool get isDirectory;
  DateTime get createDateTime;

  // 文件/目录操作
  void delete();
  void rename(String newName);

  // 目录特有操作
  void addChild(FileSystemNode node);
  void removeChild(FileSystemNode node);
  List<FileSystemNode> get children;
}

/// 文件夹节点
class DirectoryNode implements FileSystemNode {
  @override
  final String name;

  @override
  final String path;

  @override
  final bool isDirectory = true;

  @override
  final DateTime createDateTime;

  final List<FileSystemNode> _children = [];

  DirectoryNode({
    required this.name,
    required this.path,
    DateTime? createDateTime,
  }) : createDateTime = createDateTime ?? DateTime.now();

  @override
  void addChild(FileSystemNode node) {
    _children.add(node);
  }

  @override
  void removeChild(FileSystemNode node) {
    _children.remove(node);
  }

  @override
  List<FileSystemNode> get children => List.unmodifiable(_children);

  @override
  void delete() {
    // 递归删除所有子节点
    for (var child in children) {
      child.delete();
    }
    _children.clear();
    // TODO: 删除物理目录
  }

  @override
  void rename(String newName) {
    // TODO: 实现目录重命名逻辑
  }
}

/// 文件节点
class FileNode implements FileSystemNode {
  @override
  final String name;

  @override
  final String path;

  @override
  final bool isDirectory = false;

  @override
  final DateTime createDateTime;

  final DrawingBoardFileConfig fileConfig;

  FileNode(this.fileConfig)
      : name = fileConfig.name,
        path = fileConfig.path,
        createDateTime = fileConfig.createDateTime;

  @override
  void delete() {
    // TODO: 删除物理文件
  }

  @override
  void rename(String newName) {
    // TODO: 实现文件重命名逻辑
  }

  @override
  void addChild(FileSystemNode node) {
    throw UnsupportedError("文件不能添加子节点");
  }

  @override
  void removeChild(FileSystemNode node) {
    throw UnsupportedError("文件不能移除子节点");
  }

  @override
  List<FileSystemNode> get children => [];
}

/// 文件树管理
class FileTreeManager {
  final DirectoryNode root;

  FileTreeManager({required String rootPath})
      : root = DirectoryNode(
    name: rootPath.split('/').last,
    path: rootPath,
  );

  /// 添加文件到指定目录
  void addFile(DrawingBoardFileConfig fileConfig, {String? directoryPath}) {
    final directory = _findDirectory(directoryPath ?? root.path);
    final fileNode = FileNode(fileConfig);
    directory.addChild(fileNode);
  }

  /// 创建新目录
  DirectoryNode createDirectory(String name, {String? parentPath}) {
    final parent = _findDirectory(parentPath ?? root.path);
    final newPath = '${parent.path}/$name';

    final newDirectory = DirectoryNode(
      name: name,
      path: newPath,
    );

    parent.addChild(newDirectory);
    return newDirectory;
  }

  /// 查找目录
  DirectoryNode _findDirectory(String path) {
    if (path == root.path) return root;

    // 实现目录查找逻辑
    List<String> pathComponents = path.split('/');
    DirectoryNode currentNode = root;

    for (int i = 1; i < pathComponents.length; i++) {
      String component = pathComponents[i];
      bool found = false;

      for (var child in currentNode.children) {
        if (child.isDirectory && child.name == component) {
          currentNode = child as DirectoryNode;
          found = true;
          break;
        }
      }

      if (!found) {
        throw ArgumentError("目录不存在: $path");
      }
    }

    return currentNode;
  }

  /// 删除文件或目录
  void deleteNode(String path) {
    final components = path.split('/');
    final name = components.last;
    final parentPath = components.sublist(0, components.length - 1).join('/');

    final parent = _findDirectory(parentPath);

    for (var child in parent.children) {
      if (child.name == name) {
        parent.removeChild(child);
        child.delete();
        break;
      }
    }
  }

  /// 获取目录内容
  List<FileSystemNode> getDirectoryContent(String path) {
    return _findDirectory(path).children;
  }

  /// 将文件树转换为JSON
  Map<String, dynamic> toJson() {
    return _nodeToJson(root);
  }

  Map<String, dynamic> _nodeToJson(FileSystemNode node) {
    if (node.isDirectory) {
      final dirNode = node as DirectoryNode;
      return {
        'name': dirNode.name,
        'path': dirNode.path,
        'isDirectory': true,
        'createDateTime': dirNode.createDateTime.toIso8601String(),
        'children': dirNode.children.map(_nodeToJson).toList(),
      };
    } else {
      final fileNode = node as FileNode;
      return {
        'name': fileNode.name,
        'path': fileNode.path,
        'isDirectory': false,
        'createDateTime': fileNode.createDateTime.toIso8601String(),
        'fileConfig': fileNode.fileConfig.toMap(),
      };
    }
  }

  /// 从JSON恢复文件树
  factory FileTreeManager.fromJson(Map<String, dynamic> json) {
    final rootPath = json['path'] as String;
    final manager = FileTreeManager(rootPath: rootPath);

    final rootNode = manager.root;
    _parseChildren(json['children'] as List<dynamic>, rootNode);

    return manager;
  }

  static void _parseChildren(List<dynamic> childrenJson, DirectoryNode parent) {
    for (var childJson in childrenJson) {
      if (childJson['isDirectory'] as bool) {
        final dirNode = DirectoryNode(
          name: childJson['name'] as String,
          path: childJson['path'] as String,
          createDateTime: DateTime.parse(childJson['createDateTime'] as String),
        );

        parent.addChild(dirNode);
        _parseChildren(childJson['children'] as List<dynamic>, dirNode);
      } else {
        final fileConfig = DrawingBoardFileConfig.fromMap(
            childJson['fileConfig'] as Map<String, dynamic>
        );

        final fileNode = FileNode(fileConfig);
        parent.addChild(fileNode);
      }
    }
  }

  /// 将文件树json写入配置文件
  void writeToConfigFile() async {
    String? workplacePath = await Settings.getValue(SettingsConfig.workspacePath,defaultValue: "");
    if (workplacePath != null && workplacePath.isNotEmpty) {
      FileUtil.writeFile("$workplacePath/DrawingBoardFileList.json", jsonEncode(toJson()));
    }
  }

  /// 从文件读取json
  static Future<FileTreeManager> readFromConfigFile()  async {
    String? workplacePath = await Settings.getValue(SettingsConfig.workspacePath,defaultValue: "");
    if (workplacePath != null && workplacePath.isNotEmpty) {
      if(await FileUtil.fileExists("$workplacePath/DrawingBoardFileList.json")){
        String jsonString = await FileUtil.readFile("$workplacePath/DrawingBoardFileList.json");
        Map<String, dynamic> json = jsonDecode(jsonString);
        return FileTreeManager.fromJson(json);
      }else{
        FileUtil.writeFile("$workplacePath/DrawingBoardFileList.json", jsonEncode(FileTreeManager(rootPath: '').toJson()));
        return FileTreeManager(rootPath: '');
      }
    }else{
      return FileTreeManager(rootPath: '');
    }
  }

}