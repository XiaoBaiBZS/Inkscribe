import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../../config/privacy_policy.dart';
import '../../module/window_buttons.dart';


/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-08
 *@Description:
 *@Version: 1.0
 */

class WelcomeSettingPage extends StatefulWidget {
  const WelcomeSettingPage({super.key});

  @override
  State<WelcomeSettingPage> createState() => _WelcomeSettingPageState();
}

class _WelcomeSettingPageState extends State<WelcomeSettingPage>
    with WindowListener {
  String _selectedFolderPath = '';


  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _loadWorkspacePath();

  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _loadWorkspacePath() async {
    String? path = await Settings.getValue<String>(SettingsConfig.workspacePath,
        defaultValue: '');
    if ((path ?? "").isNotEmpty) {
      fileTreeManager = await FileTreeManager.readFromConfigFile();
      RouteUtils.pushReplacementNamed(context, RoutePath.home_page);
    }
    setState(() {
      _selectedFolderPath = path ?? '';
    });
  }

  Future<void> _selectFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await Settings.setValue(SettingsConfig.workspacePath, result);
      setState(() {
        _selectedFolderPath = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.only(top: 0),
      content: Stack(
        children: [

          DragToMoveArea(
            child: Container(
              color: FluentTheme.of(context).micaBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 这里替换为你的应用 Logo
                    Image.asset(
                      'assets/icons/app_icon.ico',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        '开始之前，请设置一个工作区',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        '工作区是存放Inkscribe项目文件的地方，Inkscribe会读取该位置下的文件。若点选“选择文件夹”按钮无效，即您的设备未安装文件选择器，请选择“使用应用文件夹”。',
                        style: TextStyle(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // 计算可用宽度
                        double availableWidth =
                            constraints.maxWidth - 150; // 两侧各留20边距

                        return Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              availableWidth >= 300
                                  ? SizedBox(
                                      width: 300,
                                      child: TextBox(
                                        // readOnly: true,
                                        placeholder: '请选择或输入文件夹路径',
                                        controller: TextEditingController(
                                            text: _selectedFolderPath),
                                      ),
                                    )
                                  : Expanded(
                                      child: TextBox(
                                        readOnly: true,
                                        placeholder: '请选择或输入文件夹路径',
                                        controller: TextEditingController(
                                            text: _selectedFolderPath),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedFolderPath = value;
                                          });
                                        },
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              FilledButton(
                                onPressed: _selectFolder,
                                child: const Text('选择文件夹'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Platform.isAndroid?Button(
                      onPressed:() async {
                        _selectedFolderPath = (await getExternalStorageDirectory())!.path;
                        setState(() {
                          _selectedFolderPath;
                        });
                        await Settings.setValue(SettingsConfig.workspacePath,_selectedFolderPath);

                      },
                      child: const Text(
                        '使用应用文件夹',
                        style: TextStyle(),
                      ),
                    ):Container(),
                    SizedBox(height: 20),
                    FilledButton(
                      onPressed:_selectedFolderPath.isNotEmpty?(){RouteUtils.pushForNamed(context, RoutePath.home_page);}:null,
                      child: const Text(
                        '继续',
                        style: TextStyle(),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
          Platform.isWindows
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: WindowButtons(),
                )
              : Container(),
        ],
      ),
    );
  }
}
