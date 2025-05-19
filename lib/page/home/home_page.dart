import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inksrcibe/class/drawing_board_file.dart';
import 'package:inksrcibe/main.dart';
import 'package:inksrcibe/page/home/all_files_page.dart';
import 'package:inksrcibe/util/route/route_util.dart';
import 'package:inksrcibe/util/route/routes.dart';

import 'package:window_manager/window_manager.dart';

import '../../module/window_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 定义导航项列表
    final List<NavigationPaneItem> _items = [
      PaneItemHeader(header: const Text('笔记')),
      PaneItem(
        icon: const Icon(FluentIcons.home),
        title: const Text('所有笔记'),
        body: AllFilesPage(),
      ),
      PaneItemHeader(header: const Text('应用')),
      PaneItem(
        icon: const Icon(FluentIcons.settings),
        title: const Text('设置'),
        body: Container(
          child: FilledButton(child: Text("pdf"), onPressed: (){
            RouteUtils.pushForNamed(context, RoutePath.pdf);
          }),
        ),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.help),
        title: const Text('关于'),
        body: Container(),
      ),
    ];


    return Container(
      child: Container(
        // color: FluentTheme.of(context).micaBackgroundColor,
        color:  Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: NavigationView(
            appBar: NavigationAppBar(
              automaticallyImplyLeading: false,
              title: DragToMoveArea(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Row(
                    children: [
                      Image.asset("assets/icons/app_icon.ico", width: 20, height: 20),
                      const SizedBox(width: 20),
                      const Text("Inkscribe")
                    ],
                  ),
                ),
              ),
              actions: Platform.isWindows
                  ?  WindowButtons()

                  : Container(),
            ),

            pane: NavigationPane(
              key:GlobalKey(),
              selected: _selectedIndex,
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                // print(this.context.size?.width);
              },
              displayMode: PaneDisplayMode.auto,
              footerItems: _items,
            ),

          ),


        ),
      ),
    );
  }
}