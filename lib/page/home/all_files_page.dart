import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/config/settings_config.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/util/file_util.dart';
import 'package:inksrcibe/util/info_bar_util.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';

/**
 *@Author: ZhanshuoBai
 *@CreateTime: 2025-05-15
 *@Description:
 *@Version: 1.0
 */

class AllFilesPage extends StatefulWidget {
  const AllFilesPage({super.key});

  @override
  State<AllFilesPage> createState() => _AllFilesPageState();
}

class _AllFilesPageState extends State<AllFilesPage> {
  /// 笔记列表
  List<FileSystemNode> _fileSystemNode = [];

  /// 是否加载中
  bool _isLoading = true;

  /// 错误信息
  String? _error;

  /// 文件路径
  // 用于顶部主要的面包屑导航
  List<BreadcrumbItem<String>> _filePath = <BreadcrumbItem<String>>[
    BreadcrumbItem(
      label: const Text("所有笔记",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      value: "",
    ),
  ];
  // 用于底部次要的面包屑导航
  List<BreadcrumbItem<String>> _filePathBottom = <BreadcrumbItem<String>>[
    BreadcrumbItem(
      label: Container(
        child: Row(
          children: [
            Icon(FluentIcons.fabric_folder),
            SizedBox(
              width: 5,
            ),
            Text(
              "所有笔记",
            )
          ],
        ),
        width: 80,
      ),
      value: "",
    ),
  ];

  /// 当前页面
  String nowNodePath = "";

  /// 列表树
  List<TreeViewItem> _fileTreeItems = [
    TreeViewItem(
      content: const Text('Personal Documents'),
      value: 'personal_docs',
      children: [
        TreeViewItem(
          content: const Text('Home Remodel'),
          value: 'home_remodel',
          children: [
            TreeViewItem(
              content: const Text('Contractor Contact Info'),
              value: 'contr_cont_inf',
            ),
            TreeViewItem(
              content: const Text('Paint Color Scheme'),
              value: 'paint_color_scheme',
            ),
            TreeViewItem(
              content: const Text('Flooring weedgrain type'),
              value: 'flooring_weedgrain_type',
            ),
            TreeViewItem(
              content: const Text('Kitchen cabinet style'),
              value: 'kitch_cabinet_style',
            ),
          ],
        ),
        TreeViewItem(
          content: const Text('Tax Documents'),
          value: 'tax_docs',
          children: [
            TreeViewItem(content: const Text('2017'), value: "tax_2017"),
            TreeViewItem(
              content: const Text('Middle Years'),
              value: 'tax_middle_years',
              children: [
                TreeViewItem(content: const Text('2018'), value: "tax_2018"),
                TreeViewItem(content: const Text('2019'), value: "tax_2019"),
                TreeViewItem(content: const Text('2020'), value: "tax_2020"),
              ],
            ),
            TreeViewItem(content: const Text('2021'), value: "tax_2021"),
            TreeViewItem(content: const Text('Current Year'), value: "tax_cur"),
          ],
        ),
      ],
    ),
  ];


  /// 创建封面
  Widget buildBookCover(FileSystemNode fileSystemNode) {

    /// 移动文件/文件夹
    void move(FileSystemNode node){
      void showContentDialog(BuildContext context) async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('移动目标位置'),
            content: TreeView(
              selectionMode: TreeViewSelectionMode.single,
              shrinkWrap: true,
              items: _fileTreeItems,
              // onItemInvoked: (item) async {},
              onSelectionChanged: (selectedItems) async => debugPrint(
                  'onSelectionChanged: \${selectedItems.map((i) => i.value)}'),
              onSecondaryTap: (item, details) async {
                debugPrint('onSecondaryTap $item at ${details.globalPosition}');
              },
            ),
            actions: [
              Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '');
                },
              ),
              FilledButton(
                  child: const Text('确认'),
                  onPressed: () async {

                  }),
            ],
          ),
        );
      }
      showContentDialog(context);
    }

    /// 删除文件/文件夹
    void delete(FileSystemNode node){
      void showContentDialog(BuildContext context) async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            title: const Text('删除文件或文件夹？'),
            content: const Text("文件夹内的文件也将永久删除，此操作不可以恢复。"),
            actions: [
              Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '');
                },
              ),
              FilledButton(
                  child: const Text('确认'),
                  onPressed: () async {
                    displayInfoBar(context, builder: (context, close,) {
                      return InfoBar(
                        title:  Text("再次确认"),
                        content: Text("删除后无法通过任何方式恢复"),
                        action: Button(
                          child: const Text('仍然删除'),
                          onPressed: () {
                            Navigator.pop(context, '');
                            close();
                            fileTreeManager.deleteNode(node.path);
                            fileTreeManager.writeToConfigFile();
                            String? workspacePath = Settings.getValue(SettingsConfig.workspacePath,defaultValue: "");
                            switch(node.isDirectory){
                              case true:
                                FileUtil.deleteFolder("$workspacePath${node.path}");
                                break;
                              case false:
                                FileUtil.deleteFile("$workspacePath${node.path}");
                            }
                            _loadFiles(nowNodePath);
                          },
                        ),
                        severity: InfoBarSeverity.warning,
                      );
                    });



                  }),
            ],
          ),
        );
      }
      showContentDialog(context);


    }

    /// 构建文件夹封面
    Widget buildFolderCover(DirectoryNode fileNode){

      /// 顶部更多按钮
      Widget _buildTopMoreButton() {

        /// 二级菜单控制器
        FlyoutController folderCoverController = FlyoutController();

        /// 重命名文件夹
        void renameFold(DirectoryNode fileNode) async {
          TextEditingController controller = TextEditingController();
          void showContentDialog(BuildContext context) async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => ContentDialog(
                title: const Text('重命名文件夹'),
                content: Container(
                  height: 50,
                  child: TextBox(
                    controller: controller,
                    placeholder: '文件夹名称',
                    maxLines: 1,
                    maxLength: 32,
                  ),
                ),
                actions: [
                  Button(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.pop(context, '');
                    },
                  ),
                  FilledButton(
                      child: const Text('确认'),
                      onPressed: () async {
                        if (controller.text.trim() == "") {
                          InfoBarUtil.showErrorInfoBar(
                              context: context,
                              title: "文件夹命名不能为空",
                              message: "请输入文件夹名称");
                        } else if (controller.text.trim().length > 32) {
                          InfoBarUtil.showErrorInfoBar(
                              context: context, title: "文件夹名称过长", message: "请重新输入");
                        } else if (fileTreeManager.isSameFolder(nowNodePath,controller.text.trim())) {
                          InfoBarUtil.showErrorInfoBar(
                              context: context,
                              title: "当前目录下已有同名文件夹",
                              message: "请重新输入");
                        } else {
                          Navigator.pop(context, controller.text.trim());
                        }
                      }),
                ],
              ),
            );
            if (result != null && result != "") {
              fileTreeManager.renameFolder(fileNode.path, result);
              InfoBarUtil.showSuccessInfoBar(context: context, title: "修改成功", message: '');
            }
            setState(() {});
          }
          showContentDialog(context);
        }

        /// build
        return Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlyoutTarget(
                controller: folderCoverController,
                child: IconButton(
                  icon: const Icon(FluentIcons.more),
                  onPressed: () {
                    folderCoverController.showFlyout(
                      autoModeConfiguration: FlyoutAutoConfiguration(
                        preferredMode: FlyoutPlacementMode.bottomCenter,
                      ),
                      builder: (context) => FlyoutContent(
                        padding: EdgeInsets.zero,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Acrylic(
                            child: Container(
                              width: 160,
                              padding: EdgeInsets.zero,
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListBody(
                                    children: [
                                      ListTile(
                                        leading: Icon(FluentIcons.move),
                                        title: Text('移动'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          move(fileNode);
                                        },
                                      ),

                                      ListTile(
                                        leading: Icon(FluentIcons.rename),
                                        title: Text('重命名'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          renameFold(fileNode);
                                        },
                                      ),

                                      ListTile(
                                        leading: Icon(FluentIcons.delete,),
                                        title: Text('删除'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          delete(fileNode);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      /// 构建封面图片
      Widget _buildCoverImage(){
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Center(
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/folder_cover.png",
                        width: double.infinity,
                      ),
                    ),
                    Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10, left: 12, right: 12),
                          child: Text(
                            fileNode.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ))
                  ],
                )),
          ),
        );
      }

      /// 构建底部文字
      Widget _buildBottomText(){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "${fileNode.createDateTime.year}-${fileNode.createDateTime.month}-${fileNode.createDateTime.day}",
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        );
      }

      /// build
      return IconButton(
          style: ButtonStyle(
            padding: ButtonState.all(EdgeInsets.zero),
          ),
          icon: Container(
            decoration: BoxDecoration(
              // color: FluentTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopMoreButton(),
                _buildCoverImage(),
                _buildBottomText(),
              ],
            ),
          ),
          onPressed: () {
            setState(() {
              _filePath.add(
                BreadcrumbItem(
                  label: Text(fileNode.name,
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  value: fileNode.path,
                ),
              );
              _filePathBottom.add(
                BreadcrumbItem(
                  label: Text(
                    fileNode.name,
                  ),
                  value: fileNode.path,
                ),
              );
              nowNodePath = fileNode.path;
            });
            _loadFiles(nowNodePath);
          });
    }

    /// 构建文件封面
    Widget buildFileCover(FileNode fileNode){

      /// 顶部更多按钮
      Widget _buildTopMoreButton() {

        /// 二级菜单控制器
        FlyoutController fileCoverController = FlyoutController();

        /// 文件重命名
        void renameFile(FileNode fileNode) async {
          TextEditingController controller = TextEditingController();
          void showContentDialog(BuildContext context) async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => ContentDialog(
                title: const Text('重命名画布'),
                content: Container(
                  height: 50,
                  child: TextBox(
                    controller: controller,
                    placeholder: '画布名称',
                    maxLines: 1,
                    maxLength: 32,
                  ),
                ),
                actions: [
                  Button(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.pop(context, '');
                    },
                  ),
                  FilledButton(
                      child: const Text('确认'),
                      onPressed: () async {
                        if (controller.text.trim() == "") {
                          InfoBarUtil.showErrorInfoBar(
                              context: context,
                              title: "画布命名不能为空",
                              message: "请输入画布名称");
                        } else if (controller.text.trim().length > 32) {
                          InfoBarUtil.showErrorInfoBar(
                              context: context, title: "画布名称过长", message: "请重新输入");
                        } else if (fileTreeManager.isSameFile(fileNode.path,controller.text.trim())) {
                          displayInfoBar(context, builder: (context, close,) {
                            return InfoBar(
                              title:  Text("当前目录下已有同名画布"),
                              content: Text("可能对查找画布造成影响"),
                              action: Button(
                                child: const Text('仍然修改'),
                                onPressed: () {
                                  Navigator.pop(context, controller.text.trim());
                                },
                              ),
                              severity: InfoBarSeverity.warning,
                            );
                          });

                        } else {
                          Navigator.pop(context, controller.text.trim());
                        }
                      }),
                ],
              ),
            );
            if (result != null && result != "") {
              fileTreeManager.renameFile(fileNode.path, result);
              InfoBarUtil.showSuccessInfoBar(context: context, title: "修改成功", message: '');
            }
            setState(() {});
          }
          showContentDialog(context);
        }

        /// build
        return Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlyoutTarget(
                controller: fileCoverController,
                child: IconButton(
                  icon: const Icon(FluentIcons.more),
                  onPressed: () {
                    fileCoverController.showFlyout(
                      autoModeConfiguration: FlyoutAutoConfiguration(
                        preferredMode: FlyoutPlacementMode.bottomCenter,
                      ),
                      builder: (context) => FlyoutContent(
                        padding: EdgeInsets.zero,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Acrylic(
                            child: Container(
                              width: 160,
                              padding: EdgeInsets.zero,
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListBody(
                                    children: [
                                      ListTile(
                                        leading: Icon(FluentIcons.move),
                                        title: Text('移动'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          move(fileNode);
                                        },
                                      ),

                                      ListTile(
                                        leading: Icon(FluentIcons.rename),
                                        title: Text('重命名'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          renameFile(fileNode);
                                        },
                                      ),

                                      ListTile(
                                        leading: Icon(FluentIcons.delete,),
                                        title: Text('删除'),
                                        onPressed: () {
                                          Flyout.of(context).close();
                                          delete(fileNode);
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      /// 构建封面图片
      Widget _buildCoverImage(){
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Center(
                child: Stack(children: [
                  Center(
                    child: Image.asset(
                      "assets/board_cover.png",
                      width: double.infinity,
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 0, left: 15, right: 15),
                      child: Text(
                        fileNode.fileConfig.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ])),
          ),
        );
      }

      /// 构建底部文字
      Widget _buildBottomText(){
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "${fileNode.fileConfig.createDateTime.year}-${fileNode.fileConfig.createDateTime.month}-${fileNode.fileConfig.createDateTime.day}",
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ));
      }

      /// 点击事件，打开画板加载文件
      void _openFile(String path){
        RouteUtils.pushForNamed(context, RoutePath.handwriting_blank_page,
            arguments: {
              "path": path,
              "function": "load"
            });
      }

      /// build
      return IconButton(
          style: ButtonStyle(
            padding: ButtonState.all(EdgeInsets.zero),
          ),
          icon: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopMoreButton(),
                _buildCoverImage(),
                _buildBottomText(),
              ],
            ),
          ),
          onPressed: () {
            _openFile(fileNode.fileConfig.path);
          });
    }

    if (fileSystemNode.isDirectory) {
      // 创建文件夹封面
      DirectoryNode fileNode = fileSystemNode as DirectoryNode;
      return buildFolderCover(fileNode);
    } else {
      // 创建文件封面
      FileNode fileNode = fileSystemNode as FileNode;
      return buildFileCover(fileNode);
    }
  }

  /// 新建文件夹
  void _createFolder(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    // 输入文件夹名称
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('请输入文件夹名称'),
        content: Container(
          height: 50,
          child: TextBox(
            controller: controller,
            placeholder: '文件夹名称',
            maxLines: 1,
            maxLength: 32,
          ),
        ),
        actions: [
          Button(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context, '');
            },
          ),
          FilledButton(
              child: const Text('确认'),
              onPressed: () async {
                if (controller.text.trim() == "") {
                  InfoBarUtil.showErrorInfoBar(
                      context: context,
                      title: "文件夹命名不能为空",
                      message: "请输入文件夹名称");
                } else if (controller.text.trim().length > 32) {
                  InfoBarUtil.showErrorInfoBar(
                      context: context, title: "文件夹名称过长", message: "请重新输入");
                } else if (fileTreeManager.isSameFolder(nowNodePath,controller.text.trim())) {
                  InfoBarUtil.showErrorInfoBar(
                      context: context,
                      title: "当前目录下已有同名文件夹",
                      message: "请重新输入");
                } else {
                  Navigator.pop(context, controller.text.trim());
                }
              }),
        ],
      ),
    );
    // 创建文件夹
    if (result != null && result != "") {
      FileUtil.createFolder(result);
      String workspacePath =
          Settings.getValue(SettingsConfig.workspacePath, defaultValue: "") ??
              "";
      FileUtil.createFolder(
          "$workspacePath/${nowNodePath == '' ? '' : (nowNodePath + '/')}$result");
      fileTreeManager.createDirectory(result, parentPath: nowNodePath);
      fileTreeManager.writeToConfigFile();
      InfoBarUtil.showSuccessInfoBar(
          context: context, title: "创建成功", message: "");
      _loadFiles(nowNodePath);
    }
  }

  /// 加载首页笔记/封面
  Future<void> _loadFiles(String path) async {
    _fileSystemNode = [];
    try {
      for (FileSystemNode item in fileTreeManager.getDirectoryContent(path)) {
        _fileSystemNode.add(item);
      }
      setState(() {
        _fileSystemNode;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '加载失败: $e';
      });
    }
  }

  /// 加载文件树
  void _loadFileTree() {
    _fileTreeItems = [];

    // 解析 JSON 数据
    Map<String, dynamic> data = fileTreeManager.toJson();

    // 递归函数来处理每个节点，只包含目录
    TreeViewItem processNode(Map<String, dynamic> node) {
      String name = node['name']==''?'所有笔记':node['name'];
      String path = node['path'];
      bool isDirectory = node['isDirectory'];
      List<dynamic> children = node['children'] ?? [];

      // 过滤掉非目录的子项
      List<TreeViewItem> filteredChildren = [];
      for (var child in children) {
        if (child['isDirectory'] == true) {
          filteredChildren.add(processNode(child));
        }
      }

      // 创建 TreeViewItem，只包含目录子项
      TreeViewItem treeItem = TreeViewItem(
        content: Text(name,style: const TextStyle(fontSize: 16),),
        value: path,
        children: filteredChildren,
      );

      return treeItem;
    }


    _fileTreeItems =  [processNode(data)];
  }


  @override
  void initState() {
    super.initState();
    /// 加载主页的封面
    _loadFiles(nowNodePath);
    /// 加载文件树
    _loadFileTree();
  }

  @override
  Widget build(BuildContext context) {
    /// 构建页面中的封面网格视图
    Widget _buildCover(){

      /// 顶部面包屑导航
      Widget _buildTopBreadBar(){
        return BreadcrumbBar<String>(
          items: _filePath,
          onItemPressed: (item) {
            setState(() {
              final index = _filePath.indexOf(item);
              _filePath.removeRange(index + 1, _filePath.length);
              _filePathBottom.removeRange(
                  index + 1, _filePathBottom.length);
              nowNodePath = item.value;
            });
            _loadFiles(nowNodePath);
          },
        );
      }

      /// 圆环进度指示器
      Widget _buildLoadingRing(){
        return Center(child: ProgressRing());
      }

      /// 错误信息
      Widget _buildErrorMeggage(){
        return Center(
            child: Text(
                _error!,
                style: TextStyle(color: FluentTheme.of(context).accentColor)));
      }

      /// 封面网格视图
      Widget _buildCoverGridView(){
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (MediaQuery.of(context).size.width >
                MediaQuery.of(context).size.height)
                ? 5
                : 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: _fileSystemNode.length,
          itemBuilder: (context, index) {
            final fileSystemNode = _fileSystemNode[index];
            return GestureDetector(
              onTap: () {
                // 点击笔记封面的操作
              },
              child: buildBookCover(fileSystemNode),
            );
          },
        );
      }

      /// 空视图
      Widget _buildNoFileView(){
        return Container(
          width: MediaQuery.of(context).size.width - 50,
          height: MediaQuery.of(context).size.height - 300,
          child: Center(
            child: Container(
              height:
              (MediaQuery.of(context).size.height - 300) / 2 +
                  30,
              child: Column(
                children: [
                  Image.asset("assets/no_file_tip.png",
                      width: (MediaQuery.of(context).size.height -
                          300) /
                          2,
                      height: (MediaQuery.of(context).size.height -
                          300) /
                          2),
                  Text(
                    "暂无笔记",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
          ),
        );
      }

      /// build
      return Expanded(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildTopBreadBar(),
                const SizedBox(height: 20),
                // 加载状态处理
                if (_isLoading)
                  _buildLoadingRing()
                else if (_error != null)
                  _buildErrorMeggage()
                else if (_fileSystemNode != null && _fileSystemNode!.isNotEmpty)
                    _buildCoverGridView()
                else
                  _buildNoFileView(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    /// 构建底部控制条
    Widget _buildBootomBar(){

      /// 左侧的面包屑导航
      Widget _buildBreadBar(double maxWidth){
        return Container(
          width: (maxWidth - 32) / 3,
          margin: EdgeInsets.only(right: 8, left: 8),
          child: BreadcrumbBar<String>(
            items: _filePathBottom,
            onItemPressed: (item) {
              setState(() {
                final index = _filePathBottom.indexOf(item);
                _filePathBottom.removeRange(
                    index + 1, _filePathBottom.length);
                _filePath.removeRange(index + 1, _filePath.length);
                nowNodePath = item.value;
              });
              _loadFiles(nowNodePath);
            },
          ),
        );
      }

      /// 右侧的控制条
      Widget _buildCommandBar(double maxWidth){
        return Container(
          width: 2 * (maxWidth - 32) / 3,
          margin: EdgeInsets.only(right: 8, left: 8),
          child: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            overflowBehavior:
            CommandBarOverflowBehavior.dynamicOverflow,
            primaryItems: [
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.quick_note),
                label: const Text('快速笔记'),
                onPressed: () {
                  RouteUtils.pushForNamed(
                      context, RoutePath.handwriting_blank_page,
                      arguments: {
                        "path": nowNodePath,
                        "function": "create"
                      });
                },
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.new_folder),
                label: const Text('创建文件夹'),
                onPressed: () {
                  _createFolder(context);
                },
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.power_point_document),
                label: const Text('从PPT创建'),
                onPressed: () {
                  // Create something new!
                },
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.pdf),
                label: const Text('从PDF创建'),
                onPressed: () {
                  // Create something new!
                },
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                icon: const Icon(FluentIcons.camera),
                label: const Text('扫描仪'),
                onPressed: () {
                  // Delete what is currently selected!
                },
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        // 用于获取最大宽度，并根据最大宽度计算左右两个组件的占比宽度，目前是2:3的宽度比
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          return SizedBox(
              width: maxWidth, // 使用最大宽度的80%
              child: Row(
                children: [
                  _buildBreadBar(maxWidth),
                  _buildCommandBar(maxWidth),
                ],
              ));
        },
      );
    }

    /// build
    return SafeArea(
        child: Column(
          children: [
            /// 封面网格视图
            _buildCover(),
            /// 底部控制条
            _buildBootomBar(),
      ],
    ));
  }
}
