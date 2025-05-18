/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-15
 *@Description:
 *@Version: 1.0
 */

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/widgets.dart';

class WindowUtils {
  static void setTransparentBackground() {
    if (!Platform.isWindows) return;

    // 获取当前窗口句柄
    final hwnd = GetForegroundWindow();
    if (hwnd == NULL) return;

    // 设置窗口扩展样式为分层窗口
    final exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE);
    SetWindowLongPtr(hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED);

    // 设置窗口透明度 (0-255, 255为完全不透明)
    SetLayeredWindowAttributes(hwnd, 0, 200, LWA_ALPHA);

    // 设置窗口背景为透明色
    final hbrush = CreateSolidBrush(0);
    SetClassLongPtr(hwnd, 0x00ffffff, hbrush);
  }

  static void enableTransparentRegion() {
    if (!Platform.isWindows) return;

    final hwnd = GetForegroundWindow();
    if (hwnd == NULL) return;

    // 创建一个与窗口大小相同的区域
    final rect = calloc<RECT>();
    GetClientRect(hwnd, rect);

    final region = CreateRectRgn(
        0, 0, rect.ref.right, rect.ref.bottom
    );

    // 设置窗口区域为透明区域
    SetWindowRgn(hwnd, region, 1);

    free(rect);
  }
}