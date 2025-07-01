/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-15
 *@Description: 文件操作工具类，确保每次读写文件前检查权限
 *@Version: 1.0
 */

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class FileUtil {
  /// 检查并请求存储权限
  static Future<bool> _checkAndRequestPermission() async {
    // 仅在Android上需要权限检查
    if (!Platform.isAndroid) return true;

    // 检查权限状态
    PermissionStatus status_storage = await Permission.storage.status;
    PermissionStatus status_manageExternalStorage = await Permission.manageExternalStorage.status;

    if (status_storage.isGranted&&status_manageExternalStorage.isGranted) {
      return true;
    }

    // 请求权限
    Map<Permission, PermissionStatus> result = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    return result[Permission.storage] == PermissionStatus.granted;
  }

  /// 获取应用文档目录
  static Future<Directory> get _appDocDir async {
    return await getApplicationDocumentsDirectory();
  }

  /// 获取文件路径
  static Future<String> _getFilePath(String fileName) async {
    final directory = await _appDocDir;
    return '${directory.path}/$fileName';
  }

  /// 创建文件夹
  static Future<void> createFolder(String folderPath, {bool recursive = true}) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法创建文件夹');
    }

    try {
      final directory = Directory(folderPath);
      if (!(await directory.exists())) {
        await directory.create(recursive: recursive);
      }
    } catch (e) {
      print('创建文件夹错误: $e');
      rethrow;
    }
  }

  /// 删除文件夹
  static Future<void> deleteFolder(String folderPath, {bool recursive = true}) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法删除文件夹');
    }

    try {
      final directory = Directory(folderPath);
      if (await directory.exists()) {
        await directory.delete(recursive: recursive);
      } else {
        throw FileSystemException('文件夹不存在，无法删除', folderPath);
      }
    } catch (e) {
      print('删除文件夹错误: $e');
      rethrow;
    }
  }

  /// 写入文件
  static Future<void> writeFile(String filePath, String content, {FileMode mode = FileMode.write}) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法写入文件');
    }

    try {
      final file = File(filePath);

      // 先确保父目录存在
      await file.parent.create(recursive: true);

      // 写入文件
      await file.writeAsString(content, mode: mode);
    } catch (e) {
      print('写入文件错误: $e');
      rethrow;
    }
  }

  /// 读取文件
  static Future<String> readFile(String filePath) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法读取文件');
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw FileSystemException('文件不存在', filePath);
      }
    } catch (e) {
      print('读取文件错误: $e');
      rethrow;
    }
  }

  /// 删除文件
  static Future<void> deleteFile(String filePath) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法删除文件');
    }

    try {
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      } else {
        throw FileSystemException('文件不存在，无法删除', filePath);
      }
    } catch (e) {
      print('删除文件错误: $e');
      rethrow;
    }
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String filePath) async {
    if (!await _checkAndRequestPermission()) {
      return false;
    }

    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('检查文件存在错误: $e');
      return false;
    }
  }

  /// 获取文件大小（字节）
  static Future<int> getFileSize(String filePath) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法获取文件大小');
    }

    try {
      final file = File(filePath);

      if (await file.exists()) {
        return await file.length();
      } else {
        throw FileSystemException('文件不存在', filePath);
      }
    } catch (e) {
      print('获取文件大小错误: $e');
      rethrow;
    }
  }

  /// 修改文件名
  static Future<void> renameFile(String oldFilePath, String newFilePath) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法修改文件名');
    }

    try {
      final oldFile = File(oldFilePath);

      if (await oldFile.exists()) {
        // 先确保新文件的父目录存在
        await File(newFilePath).parent.create(recursive: true);
        await oldFile.rename(newFilePath);
      } else {
        throw FileSystemException('原文件不存在，无法修改名称', oldFilePath);
      }
    } catch (e) {
      print('修改文件名错误: $e');
      rethrow;
    }
  }

  /// 修改文件夹名称
  static Future<void> renameFolder(String oldFolderPath, String newFolderPath) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法修改文件夹名称');
    }

    try {
      final oldDirectory = Directory(oldFolderPath);

      if (await oldDirectory.exists()) {
        // 先确保新文件夹的父目录存在
        await Directory(newFolderPath).parent.create(recursive: true);
        await oldDirectory.rename(newFolderPath);
      } else {
        throw FileSystemException('原文件夹不存在，无法修改名称', oldFolderPath);
      }
    } catch (e) {
      print('修改文件夹名称错误: $e');
      rethrow;
    }
  }

  /// 移动文件（剪切并粘贴到新位置）
  static Future<void> moveFile(String sourcePath, String destinationPath, {bool overwrite = false}) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法移动文件');
    }

    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      // 检查源文件是否存在
      if (!await sourceFile.exists()) {
        throw FileSystemException('源文件不存在', sourcePath);
      }

      // 检查目标文件是否存在
      if (await destinationFile.exists()) {
        if (overwrite) {
          await destinationFile.delete();
        } else {
          throw FileSystemException('目标文件已存在且不允许覆盖', destinationPath);
        }
      }

      // 确保目标目录存在
      await destinationFile.parent.create(recursive: true);

      // 执行移动（通过重命名实现）
      await sourceFile.rename(destinationPath);
    } catch (e) {
      print('移动文件错误: $e');
      rethrow;
    }
  }

  /// 移动文件夹（剪切并粘贴到新位置）
  static Future<void> moveFolder(String sourcePath, String destinationPath, {bool overwrite = false}) async {
    if (!await _checkAndRequestPermission()) {
      throw Exception('缺少存储权限，无法移动文件夹');
    }

    try {
      final sourceDir = Directory(sourcePath);
      final destinationDir = Directory(destinationPath);

      // 检查源文件夹是否存在
      if (!await sourceDir.exists()) {
        throw FileSystemException('源文件夹不存在', sourcePath);
      }

      // 检查目标文件夹是否存在
      if (await destinationDir.exists()) {
        if (overwrite) {
          await destinationDir.delete(recursive: true);
        } else {
          throw FileSystemException('目标文件夹已存在且不允许覆盖', destinationPath);
        }
      }

      // 确保目标父目录存在
      await destinationDir.parent.create(recursive: true);

      // 执行移动（通过重命名实现）
      await sourceDir.rename(destinationPath);
    } catch (e) {
      print('移动文件夹错误: $e');
      rethrow;
    }
  }

  /// 复制文件
  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);

      // 检查源文件是否存在
      if (!await sourceFile.exists()) {
        throw FileSystemException('源文件不存在', sourcePath);
      }

      // 复制文件
      final destinationFile = await sourceFile.copy(destinationPath);
      print('文件已复制到: ${destinationFile.path}');
    } catch (e) {
      print('复制文件时出错: $e');
      rethrow;
    }
  }

  /// 从文件路径中提取文件名（不包含文件扩展名）
  static String getFileName(String filePath) {
    try {
      // 1. 去除路径中的多余分隔符并标准化
      final normalizedPath = path.normalize(filePath);

      // 2. 从路径中提取文件名（包含扩展名）
      final fileNameWithExt = path.basename(normalizedPath);

      // 3. 去除扩展名
      return path.withoutExtension(fileNameWithExt);
    } catch (e) {
      // 错误处理：如果路径格式不正确，返回空字符串或原始路径
      print('提取文件名时出错: $e');
      return path.basename(filePath); // fallback返回包含扩展名的文件名
    }
  }
}