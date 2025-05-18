import 'package:fluent_ui/fluent_ui.dart';
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
  List<BreadcrumbItem<String>> _filePath = <BreadcrumbItem<String>>[
    BreadcrumbItem(
      label: const Text("所有笔记", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      value: "",
    ),
  ];
  /// 当前页面
  String nowNodePath = "";

  /// 创建封面
  Widget buildBookCover(FileSystemNode fileSystemNode) {
    if(fileSystemNode.isDirectory){
      DirectoryNode fileNode = fileSystemNode as DirectoryNode;
      return  IconButton(
          style: ButtonStyle(padding: ButtonState.all(EdgeInsets.zero),),
          icon: Container(
            decoration: BoxDecoration(
              // color: FluentTheme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5,bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(icon: const Icon(FluentIcons.more), onPressed: () {})
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Center(
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset("assets/folder_cover.png",width: double.infinity,),
                            ),
                            Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 10,left: 12,right:12),
                                  child: Text(
                                    fileNode.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                            )
                          ],
                        )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${fileNode.createDateTime.year}-${fileNode.createDateTime.month}-${fileNode.createDateTime.day}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPressed:(){
            setState(() {
              _filePath.add(
                BreadcrumbItem(
                  label: Text(fileNode.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  value: fileNode.path,
                ),
              );
              nowNodePath = fileNode.path;
            });
            _loadFiles(nowNodePath);
          });
    }else{
      FileNode fileNode = fileSystemNode as FileNode;
      return IconButton(
          style: ButtonStyle(padding: ButtonState.all(EdgeInsets.zero),),
          icon: Container(
        decoration: BoxDecoration(
          // color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5,bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: const Icon(FluentIcons.more), onPressed: () {})
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                    child: Stack(
                        children:[
                          Center(
                            child: Image.asset("assets/board_cover.png",width: double.infinity,),
                          ),

                          Center(
                            child:Container(
                              margin: EdgeInsets.only(top: 0,left: 15,right: 15),
                              child:Text(
                                fileNode.fileConfig.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ]
                    )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:Column(
                children: [
                  Text(
                    "${fileNode.fileConfig.createDateTime.year}-${fileNode.fileConfig.createDateTime.month}-${fileNode.fileConfig.createDateTime.day}",
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
          onPressed: (){
            RouteUtils.pushForNamed(context, RoutePath.handwriting_blank_page,arguments: {"path":fileNode.fileConfig.path,"function":"load"});
          }
      );
    }

  }

  /// 新建文件夹
  void _createFolder(BuildContext context) async {
    bool _isSameFolderName(String name){
      for(FileSystemNode item in fileTreeManager.root.children) {
        if(item.isDirectory&&item.name==name){
          return true;
        }
      }
      return false;
    }
    TextEditingController controller = TextEditingController();
    // 输入文件夹名称
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('请输入文件夹名称'),
        content:Container(
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
              if(controller.text.trim()==""){
                InfoBarUtil.showErrorInfoBar(context: context, title: "文件夹命名不能为空", message: "请输入文件夹名称");
              }else if(controller.text.trim().length>32){
                InfoBarUtil.showErrorInfoBar(context: context, title: "文件夹名称过长", message: "请重新输入");
              }else if(_isSameFolderName(controller.text.trim())){
                InfoBarUtil.showErrorInfoBar(context: context, title: "当前目录下已有同名文件夹", message: "请重新输入");
              }else{
                Navigator.pop(context, controller.text.trim());
              }
            }
          ),
        ],
      ),
    );
    // 创建文件夹
    if(result!=null&&result!=""){
      FileUtil.createFolder(result);
      String workspacePath =Settings.getValue(SettingsConfig.workspacePath,defaultValue: "")??"";
      FileUtil.createFolder("$workspacePath/${nowNodePath==''?'':(nowNodePath+'/')}$result");
      fileTreeManager.createDirectory(result,parentPath: nowNodePath);
      fileTreeManager.writeToConfigFile();
      InfoBarUtil.showSuccessInfoBar(context: context, title: "创建成功", message: "");
      _loadFiles(nowNodePath);
    }
  }


  @override
  void initState() {
    super.initState();
    _loadFiles(nowNodePath);
  }

  /// 加载首页笔记/封面
  Future<void> _loadFiles(String path) async {
    _fileSystemNode = [];
    try {
      for(FileSystemNode item in fileTreeManager.getDirectoryContent(path)){
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
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                BreadcrumbBar<String>(
                  items: _filePath,
                  onItemPressed: (item) {
                    setState(() {
                      final index = _filePath.indexOf(item);
                      _filePath.removeRange(index + 1, _filePath.length);
                      nowNodePath = item.value;
                    });
                      _loadFiles(nowNodePath);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    FilledButton(
                      child: Row(
                        children: const [
                          Icon(FluentIcons.circle_addition),
                          SizedBox(width: 5),
                          Text("快速笔记"),
                        ],
                      ),
                      onPressed: () {
                        RouteUtils.pushForNamed(context, RoutePath.handwriting_blank_page,arguments: {"path":nowNodePath,"function":"create"});
                      },
                    ),
                    const SizedBox(width: 10),
                    Button(
                      child: Row(
                        children: const [
                          Icon(FluentIcons.new_folder),
                          SizedBox(width: 5),
                          Text("创建文件夹"),
                        ],
                      ),
                      onPressed: () {
                        _createFolder(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 加载状态处理
                if (_isLoading)
                  const Center(child: ProgressRing())
                else if (_error != null)
                  Center(child: Text(_error!, style: TextStyle(color: FluentTheme.of(context).accentColor)))
                else if (_fileSystemNode != null && _fileSystemNode!.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) ? 5 : 3,
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
                    )
                  else
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: MediaQuery.of(context).size.height-300,
                      child: Center(
                          child: Container(
                            height: (MediaQuery.of(context).size.height-300)/2+30,
                            child: Column(
                              children: [
                                Image.asset("assets/no_file_tip.png",width: (MediaQuery.of(context).size.height-300)/2,height: (MediaQuery.of(context).size.height-300)/2),

                                Text("暂无笔记",style: TextStyle(fontSize: 18),)

                              ],
                            ),
                          ),
                      ),
                    ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}