import 'package:fluent_ui/fluent_ui.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-17
 *@Description:
 *@Version: 1.0
 */

class InfoBarUtil {
  static Future<void> showErrorInfoBar({required BuildContext context, required String title,required String message,Icon icon = const Icon(FluentIcons.clear)}) async {
    await displayInfoBar(context, builder: (context, close,) {
      return InfoBar(
        title:  Text(title),
        content: Text(message),
        action: IconButton(
          icon:  icon,
          onPressed: close,
        ),
        severity: InfoBarSeverity.error,
      );
    });
  }
  static Future<void> showWarningInfoBar({required BuildContext context, required String title,required String message,Icon icon = const Icon(FluentIcons.clear)}) async {
    await displayInfoBar(context, builder: (context, close,) {
      return InfoBar(
        title:  Text(title),
        content: Text(message),
        action: IconButton(
          icon:  icon,
          onPressed: close,
        ),
        severity: InfoBarSeverity.warning,
      );
    });
  }
  static Future<void> showNormalInfoBar({required BuildContext context, required String title,required String message,Icon icon = const Icon(FluentIcons.clear)}) async {
    await displayInfoBar(context, builder: (context, close,) {
      return InfoBar(
        title:  Text(title),
        content: Text(message),
        action: IconButton(
          icon:  icon,
          onPressed: close,
        ),
        severity: InfoBarSeverity.info,
      );
    });
  }
  static Future<void> showSuccessInfoBar({required BuildContext context, required String title,required String message,Icon icon = const Icon(FluentIcons.clear)}) async {
    await displayInfoBar(context, builder: (context, close,) {
      return InfoBar(
        title:  Text(title),
        content: Text(message),
        action: IconButton(
          icon:  icon,
          onPressed: close,
        ),
        severity: InfoBarSeverity.success,
      );
    });
  }
}

