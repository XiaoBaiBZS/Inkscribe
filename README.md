# 墨痕题镌

**墨痕题镌**是一个由Flutter构建的跨平台手写笔记应用。

# Inkscribe

**Inkscribe** is a cross-platform handwriting note application built with Flutter.

# 使用Flutter框架构建精美的多端应用——以Windows平台为例
白展硕 2025年4月27日开始 浙江·杭州 Zhanshuo.Bai@outlook.com
# 前言
## 最佳实践
实现一个以Windows平台为主的手写笔笔记应用
## 项目背景
## 特殊说明
1. 由于项目实际上以 Windows 平台为主，那么就意味着我需要尽量以 Microsoft 官方推荐的 WinUI3 样式开发，那将必然舍弃一部分对于 Android 平台的适配。比如：无法在 Android 平台使用 Material Design 样式。我们在本项目中尽量选择全平台支持的依赖（插件）。但是很难保证所有的依赖在各个平台都能正常运行，我们会优先保证在Windows平台的效果。
2. 项目本身处于学习研究目的，可能会与文档有些许出入。
3. 本文档参考了一部分互联网媒体和官方提供的资料。
4. 尝试使用 `GestureDetector` 触摸类做了一个简单的演示，发现效果一般，延时很高，而且笔迹不够连贯毛刺像素比较多，所以采用一个封装集成度比较高的库 `flutter_drawing_board: ^0.8.1` 来实现手写的功能。
5. 本文部分内容使用人工智能大模型生成
# 参考文档
https://docs.flutter.cn/get-started/install/windows/desktop/

# 基本环境
1. 编辑器：Android Studio Giraffe | 2022.3.1 Patch 4
2. Flutter SDK：3.24.3
   注意：我们接下来用到的 fluent_ui 依赖的最近版本 4.11.3 的最低 Flutter SDK 版本是3.27.0，为了研究方便，下文将使用 fluent_ui 4.9.2 版本。

>**配置文本编辑器或 IDE**
你可以使用任意文本编辑器或集成开发环境 (IDE)，并结合 Flutter 的命令行工具，来使用 Flutter 构建应用程序。
使用带有 Flutter 扩展或插件的 IDE 会提供代码自动补全、语法高亮、widget 编写辅助、调试以及其他功能。
以下是热门的扩展插件：
>
> [Visual Studio Code](https://code.visualstudio.com/docs/setup/windows) 1.86 或更高版本使用 [Flutter extension for VS Code](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
> [Android Studio](https://developer.android.com/studio/install#windows) 2024.1.1 (Koala) 或更高版本使用 [Flutter plugin for IntelliJ](https://plugins.jetbrains.com/plugin/9212-flutter)
> [IntelliJ IDEA](https://www.jetbrains.com/help/idea/installation-guide.html) 2024.1 或更高版本使用 [Flutter plugin for IntelliJ](https://plugins.jetbrains.com/plugin/9212-flutter)
# 我的设备
- `Windows Platform`：Lenovo Thinkbook 16p Gen4 用于开发和调试
    - 处理器：13th Gen Intel i9-13900H
    - 显示卡：NVIDIA GeForce RTX 4060 Laptop GPU
    - 内存：32Gb
    - 操作系统：Windows 11 23H1 家庭版
- `Android Platform`：HUAWEI MatePad Pro 2020 MRX-W09 用于调试
    - 处理器：HUAWEI Kirin 990
    - 运行内存：8Gb
    - 操作系统：HarmonyOS 4.2.0（适配Android 10）
# 一些名词和解释
## 依赖 与 插件
在 Flutter 里，“依赖” 和 “插件” 这两个术语有不同的侧重点，不过它们都用于描述项目里引入的外部代码资源。本文中将不区分二者区别。
### 依赖（Dependency）
“依赖” 是一个更宽泛的概念，指的是项目所依赖的外部代码库。这些代码库可以提供各种功能，比如网络请求、数据存储、UI 组件等。在 Flutter 项目中，依赖通过 `pubspec.yaml` 文件进行管理。
#### 特点
- **范围广泛**：涵盖了各种类型的代码库，不局限于特定平台或功能。
- **跨平台性**：可以是纯 Dart 代码库，能在 Flutter 支持的所有平台上使用。
- **功能多样**：提供的功能包括但不限于工具函数、数据模型、UI 组件库等。
### 插件（Plugin）
“插件” 是一种特殊的依赖，它通常用于实现 Flutter 应用和原生平台（如 Android、iOS、Windows 等）之间的交互。插件通过封装原生代码，为 Flutter 应用提供访问原生功能的接口。
#### 特点
- **平台相关性**：通常会包含不同平台的原生代码，以实现特定平台的功能。
- **原生交互**：用于访问设备的硬件功能、系统服务等，如相机、蓝牙、推送通知等。
- **跨平台封装**：在 Flutter 层面提供统一的 API，方便开发者在不同平台上使用相同的代码。
# 工具推荐
## Fluent Icons
可以查找 Fluent Design 样式的图标。
Open source icons by Microsoft. Viewer by [Colton Griffith](https://twitter.com/coltongriffith)
https://fluenticons.co/?standalone=true
## Png to Ico
https://www.aconvert.com/cn/icon/png-to-ico/
## Fluent_UI
https://bdlukaa.github.io/fluent_ui/#/theming/icons

# 1. 起步
先来试试 Fluent UI
## 创建Flutter项目
1. New Flutter Project![[Pasted image 20250427174500.png]]
2. 选择Flutter SDK Path![[Pasted image 20250427174942.png]]
3. 填写项目的名称、组织、简介等
## 导入样式依赖
```yaml
# Windows Fluent Design Style
fluent_ui: ^4.9.2
# Fluent Design Icons Package
fluentui_system_icons: ^1.1.273
```
## 启动项目
`main.dart`是项目的启动文件，当你点击右上角的运行按钮后，将会首先执行这个文件，删除掉他的演示示例后精简如下。
main函数是程序的入口函数，main函数中执行`runApp()`函数启动了`MyApp`这个无状态组件（有关于什么是有状态组件和无状态组件见下文）。

```dart
import 'package:fluent_ui/fluent_ui.dart';  
//后续会创建，如果你只修改了main.dart这一个文件，那么这里会报错
import 'package:notebook/page/windows_test_page.dart'; 
  
void main() {  
  runApp(const MyApp());  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return FluentApp(  
      title: 'Fluent UI 起始项目',  
      debugShowCheckedModeBanner: false,  
      //后续会创建，如果你只修改了main.dart这一个文件，那么这里会报错
      home: const WindowsTestPage(),  
    );  
  }  
}
```
## Widget组件
在 Flutter 框架中，Widget 是构建用户界面的基础，是一个不可变的描述 UI 元素配置的类，它定义了 UI 元素的外观、行为以及交互逻辑。`Widget` 描述了界面的一部分，并且可以嵌套组合，从而构建出复杂的用户界面。

最直白的说，你能看到的所有页面都是由一个个Widget构成的，绘制页面布局的过程就是你将不同的Widget嵌套组合成组件树的过程。
## 有状态组件和无状态组件
无状态组件：StatelessWidget
有状态组件：StatefulWidget

最直白的说，当你创建好一个应用后往往示例中的`MyApp`继承自无状态组件，其他情况下基本上你都会使用有状态组件。当然你也可以通过更改让你的`MyApp`也继承自有状态组件，这可能更便于你更改全局的主题和设置。你看到的一些不会改变值的文本框、按钮等往往是无状态组件。
#### 有状态组件更新状态
```dart
setState({
	///你需要更新的变量
});
```
```dart
String data = "Hello World!";
Text(data)
setState({
	data = "你好！";
});
```
#### 有状态组件和无状态组件的一些区别

##### 状态管理
- **StatelessWidget**：这种组件是无状态的，也就是它一旦创建，其属性就不能再改变。组件的 UI 完全由创建时传入的参数决定，并且在整个生命周期中不会有变化。例如，文本、图标等，这些组件展示的内容是固定的。
- **StatefulWidget**：这是有状态的组件，它的状态会在组件的生命周期里发生变化。状态可以是用户的输入、网络请求的结果等。状态的改变会触发组件的重新构建，从而更新 UI。
##### 生命周期
- **StatelessWidget**：生命周期相对简单，仅包含 `build` 方法。当需要构建该组件的 UI 时，就会调用 `build` 方法。
- **StatefulWidget**：生命周期较为复杂，除了 `build` 方法外，还有 `initState`、`didUpdateWidget`、`dispose` 等方法。`initState` 方法在组件创建时调用，可用于初始化状态；`didUpdateWidget` 方法在组件更新时调用；`dispose` 方法在组件销毁时调用，可用于释放资源。
##### 使用场景
- **StatelessWidget**：适用于 UI 不需要动态改变的场景，比如静态文本、图片、图标等。这样可以提高性能，因为不需要管理状态的变化。
- **StatefulWidget**：适用于 UI 需要根据用户交互、数据变化等动态更新的场景，例如按钮的点击状态、列表的滚动位置等。
#### 经过修改后的main.dart
`main.dart`改为有状态组件的形式。
```dart
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:notebook/page/windows_test_page.dart';  
  
void main() {  
  runApp(const MyApp());  
}  
  
class MyApp extends StatefulWidget {  
  const MyApp({super.key});  
  
  @override  
  State<MyApp> createState() => _MyAppState();  
}  
  
class _MyAppState extends State<MyApp> {  
  @override  
  Widget build(BuildContext context) {  
    return FluentApp(  
      title: 'Fluent UI 起始项目',  
      debugShowCheckedModeBanner: false,  
      themeMode: ThemeMode.light,  
      home: const WindowsTestPage(),  
    );  
  }  
}
```
## 第一个测试用页面
创建第一个页面，我们在lib文件夹目录下方创建一个page文件夹用于存放我们的不同页面，再在page文件夹下方创建一个 `windows_test_page.dart` 文件用于验证我们的 Fluent UI 是否正常。
windows_test_page.dart
```dart
import 'package:fluent_ui/fluent_ui.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-04-27 *@Description: *@Version: 1.0 */
 class WindowsTestPage extends StatefulWidget {  
  const WindowsTestPage({super.key});  
  @override  
  State<WindowsTestPage> createState() => _WindowsTestPageState();  
}  
  
class _WindowsTestPageState extends State<WindowsTestPage> {  
  
  @override  
  Widget build(BuildContext context) {  
    return NavigationView(  
      appBar: NavigationAppBar(  
        automaticallyImplyLeading: false, // 设置为 false 以移除返回按钮  
        title: Text("Fluent Design App Bar",style: TextStyle(fontSize: 20),),  
      ),  
      pane: NavigationPane(  
          displayMode: PaneDisplayMode.auto,  
          selected: 1,  //测试用而已，没有具体编写其他逻辑函数
          items: [  
            PaneItem(  
                icon: Icon(FluentIcons.add),  
                title: Text("Sample Page 1"),  
                body: Container(  
                  child: Text("1111111"),  
                )  
            ),  
            PaneItem(  
                icon: Icon(FluentIcons.accept),  
                title: Text("Sample Page 2"),  
                body: Container(  
                  child: Text("2222222"),  
                )  
            )  
          ]  
      ),  
    );  
  }  
  
}
```
>提示：当你构建一个有状态组件时不必记忆这个结构化内容，你只需要在编辑器中输入`stf`，即可看到编辑器显示自动补全提示，补全后输入文件名（比如这里是“windows_test_page.dart”）的第一个字母大写（比如这里是’W‘），将会继续自动弹出自动补全，帮您补全类名。
>![[Pasted image 20250427220610.png]]
>![[Pasted image 20250427220628.png]]
>在编者的 Android Studio 编辑器中，如果有划红线报错，可以使用快捷键`alt`+`Enter`查看报错提示。
>![[Pasted image 20250427220742.png]]

## You did it!
点击右上角，选择在 Windows 设备上运行![[Pasted image 20250427220905.png]]然后点击Run按钮（当项目没有运行的时候，这个按钮应该是蓝色的，当项目已经运行你希望重新加载的时候，可以再次点击绿色的Run按钮）。等待项目加载成功，如果你看到下面这个页面，说明你成功了！
![[Pasted image 20250427221030.png]]
# 2. 欢迎页面
在用户第一次进入应用的时候显示欢迎页面，用于显示应用合规，实现效果如下：![[648a4445580aef3daacd7f56f43df7e9.png]]
顶部有一个AppLogo，然后又一段欢迎语，底部显示公司组织。只不过我们需要把中间的“稍等一分钟”换成我们的隐私合规。
在这一章节中我们将学习`FluentApp`、`ScaffoldPage`两个组件以及使用`window_manager`依赖。
## `window_manager`依赖
`window_manager` 是一个 Flutter 插件，用于管理 Windows 平台上的窗口，比如设置窗口大小、位置、标题栏样式等。
### 引入依赖
```yaml
	window_manager: ^0.3.0
```
### `WindowOptions`类常用属性
WindowOptions是WindowManager中对窗口属性的设置类，可以通过改变这个类对象的属性值来设置窗口参数。
```dart
const WindowOptions({  
  //窗口尺寸
  this.size,
  //是否居中  
  this.center,
  //最小尺寸  
  this.minimumSize,  
  //最大尺寸
  this.maximumSize,  
  //窗口是否置顶
  this.alwaysOnTop,  
  //全屏
  this.fullScreen,  
  //背景颜色
  this.backgroundColor,  
  //不在底部任务栏中显示
  this.skipTaskbar,  
  //窗口标题
  this.title,
  //窗口标题栏样式（是否显示）  
  this.titleBarStyle,  
  //用于控制窗口按钮（如关闭、最小化、最大化按钮）的可见性
  this.windowButtonVisibility,  
});
```
### 重写Main()函数
使得在Windows平台上窗口以固定尺寸启动
```dart
import 'package:window_manager/window_manager.dart';  
  
Future<void> main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  // 初始化 window_manager  try{  
    await windowManager.ensureInitialized();  
    WindowOptions windowOptions = WindowOptions(  
      titleBarStyle: TitleBarStyle.hidden,  
      // windowButtonVisibility :false ,  
      size: Size(800, 600),  
      center: true,  
      skipTaskbar: false,  
      title: '欢迎使用',  
    );  
    windowManager.waitUntilReadyToShow(windowOptions, () async {  
      await windowManager.show();  
      await windowManager.focus();  
    });  
  }catch(e){  
  
  }  
  runApp(const MyApp());  
}
```
## 关于`FluentApp`主题
### 重写`MyApp`
```dart
class MyApp extends StatefulWidget {  
  const MyApp({super.key});  
  
  @override  
  State<MyApp> createState() => _MyAppState();  
}  
  
class _MyAppState extends State<MyApp> {  
  @override  
  Widget build(BuildContext context) {  
    return FluentApp(  
      debugShowCheckedModeBanner: false,  
      themeMode: ThemeMode.system,  
      theme: FluentThemeData.light(  
      ),  
      darkTheme: FluentThemeData.dark(  
      ),  
      home: const WelcomePage(),  
    );  
  }  
}
```
## Dart语言中的with混入
在 Dart 语言里，`with` 关键字用于实现混入（mixin）。混入是一种代码复用机制，它允许一个类在不使用传统继承的情况下复用其他类的代码。
### 语法
```dart
class ClassName extends ParentClass with Mixin1, Mixin2, ... { 
	// 类的内容 
}
```
### 例子
```dart
// 定义混入类 
mixin Logger { 
	void log(String message) {
		print('Log: $message'); 
	} 
} 
mixin Validator { 
	bool isValid(String input) { 
		return input.isNotEmpty; 
	}
} 
// 使用混入的类 
class User with Logger, Validator { 
	String name; 
	User(this.name); 
	void register() { 
		if (isValid(name)) {
			log('User $name registered successfully.'); 
		} else { 
			log('Invalid user name.'); 
		}
	} 
} 
void main() {
	User user = User('John'); 
	user.register(); 
}
```
### 特点
- **多重混入**：一个类可以混入多个混入类，这些混入类的方法和属性都会被合并到该类中。
- **无需继承**：混入类不需要显式地继承自某个父类，它可以独立定义方法和属性。
- **方法优先级**：如果混入的多个类中有同名方法，后面的混入类会覆盖前面的混入类的方法。
### 注意

- 混入类不能有构造函数，因为混入类的目的是复用代码，而不是创建对象。
- 混入类的方法和属性通常是为了提供通用的功能，应该尽量避免与使用混入的类产生过多的耦合。
## 完整代码
`/page/welcome/welcome_page.dart`
```dart
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:window_manager/window_manager.dart';  
import '../../config/privacy_policy.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-04-27 *@Description: *@Version: 1.0 */  
class WelcomePage extends StatefulWidget {  
  const WelcomePage({super.key});  
  
  @override  
  State<WelcomePage> createState() => _WelcomePageState();  
}  
  
class _WelcomePageState extends State<WelcomePage> with WindowListener {  
  bool isButtonClicked = false;  
  
  @override  
  void initState() {  
    super.initState();  
    windowManager.addListener(this);  
  }  
  
  @override  
  void dispose() {  
    windowManager.removeListener(this);  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return ScaffoldPage(  
        padding: EdgeInsets.only(top: 0),  
        // 设置背景颜色  
        content: Container(  
          color: FluentTheme.of(context).micaBackgroundColor,  
          child: Center(  
            child: Column(  
              mainAxisAlignment: MainAxisAlignment.center,  
              children: [  
                // 这里替换为你的应用 Logo                Image.asset(  
                  'assets/icons/app_icon.ico',  
                  width: 100,  
                  height: 100,  
                ),  
                const SizedBox(height: 20),  
                Text(  
                  '欢迎使用 Inkscribe',  
                  style: TextStyle(  
                    fontSize: 26,  
                    fontWeight: FontWeight.bold,  
                  ),  
                ),  
                const SizedBox(height: 20),  
                Container(  
                  width: 500,  
                  height: 200,  
                  margin: EdgeInsets.only(left: 20,right: 20),  
                  child: SingleChildScrollView(  
                    child: Column(  
                      children: [  
                        PrivacyPolicy.buildPrivacyPolicy(),  
                      ],  
                    ),  
                  ),  
                ),  
                const SizedBox(height: 40),  
                FilledButton(  
                  onPressed: () async {  
                    setState(() {  
                      isButtonClicked = true;  
                    });  
                    await windowManager.maximize();  
                    // 这里可以添加进入应用主界面的逻辑  
                  },  
                  child: Text(  
                    isButtonClicked ? 'Entering...' : 'Get Started',  
                    style: TextStyle(),  
                  ),  
                ),  
              ],  
            ),  
          ),  
        ));  
  }  
}
```
# 3. 优化窗口
让欢迎页面可以自由拖动和显示右上角控制按钮。
## `DragToMoveArea`
实现可移动此处拖拽窗口，这里让他包裹整个页面。
```dart
DragToMoveArea(  
  child:Container(  
    color: FluentTheme.of(context).micaBackgroundColor,  
    child: Center(  
      child: Column(  
        mainAxisAlignment: MainAxisAlignment.center,  
        children: [  
          // 这里替换为你的应用 Logo          Image.asset(  
            'assets/icons/app_icon.ico',  
            width: 100,  
            height: 100,  
          ),  
          const SizedBox(height: 20),  
          Text(  
            '欢迎使用 Inkscribe',  
            style: TextStyle(  
              fontSize: 26,  
              fontWeight: FontWeight.bold,  
            ),  
          ),  
          const SizedBox(height: 20),  
          Container(  
            width: 500,  
            height: 200,  
            margin: EdgeInsets.only(left: 20, right: 20),  
            child: SingleChildScrollView(  
              child: Column(  
                children: [  
                  PrivacyPolicy.buildPrivacyPolicy(),  
                ],  
              ),  
            ),  
          ),  
          const SizedBox(height: 40),  
          FilledButton(  
            onPressed: () async {  
              setState(() {  
                isButtonClicked = true;  
              });  
              await windowManager.maximize();  
              // 这里可以添加进入应用主界面的逻辑  
            },  
            child: Text(  
              isButtonClicked ? 'Entering...' : 'Get Started',  
              style: TextStyle(),  
            ),  
          ),  
        ],  
      ),  
    ),  
  ),  
),
```
## 自定义`WindowButtons`类
`/module/window_button.dart`
```dart
class WindowButtons extends StatefulWidget {  
  const WindowButtons({Key? key}) : super(key: key);  
  @override  
  _WindowButtonsState createState() => _WindowButtonsState();  
}  
  
  
class _WindowButtonsState extends State<WindowButtons> {  
  @override  
  Widget build(BuildContext context) {  
    return SizedBox(  
      width: 138,  
      height: 50,  
      child: WindowCaption(  
        brightness: FluentTheme.of(context).brightness,  
        backgroundColor: Colors.transparent,  
      ),  
    );  
  
  }  
}
```
实际调用（搭配Stack组件）：
```dart
Platform.isWindows?Positioned(  
  top: 0,  
  right: 0,  
  child: WindowButtons(),  
):Container(),
```
## 完整代码
`/page/welcome/welcome_page.dart`
```dart
import 'dart:io';  
  
import 'package:bitsdojo_window/bitsdojo_window.dart';  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:window_manager/window_manager.dart';  
import '../../config/privacy_policy.dart';  
import '../module/window_buttons.dart';  
  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-04-27 *@Description: *@Version: 1.0 */  
class WelcomePage extends StatefulWidget {  
  const WelcomePage({super.key});  
  
  @override  
  State<WelcomePage> createState() => _WelcomePageState();  
}  
  
class _WelcomePageState extends State<WelcomePage> with WindowListener {  
  bool isButtonClicked = false;  
  
  @override  
  void initState() {  
    super.initState();  
    windowManager.addListener(this);  
  }  
  
  @override  
  void dispose() {  
    windowManager.removeListener(this);  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return ScaffoldPage(  
      padding: EdgeInsets.only(top: 0),  
      content: Stack(  
        children: [  
          DragToMoveArea(  
            child:Container(  
              color: FluentTheme.of(context).micaBackgroundColor,  
              child: Center(  
                child: Column(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [  
                    // 这里替换为你的应用 Logo                    Image.asset(  
                      'assets/icons/app_icon.ico',  
                      width: 100,  
                      height: 100,  
                    ),  
                    const SizedBox(height: 20),  
                    Text(  
                      '欢迎使用 Inkscribe',  
                      style: TextStyle(  
                        fontSize: 26,  
                        fontWeight: FontWeight.bold,  
                      ),  
                    ),  
                    const SizedBox(height: 20),  
                    Container(  
                      width: 500,  
                      height: 200,  
                      margin: EdgeInsets.only(left: 20, right: 20),  
                      child: SingleChildScrollView(  
                        child: Column(  
                          children: [  
                            PrivacyPolicy.buildPrivacyPolicy(),  
                          ],  
                        ),  
                      ),  
                    ),  
                    const SizedBox(height: 40),  
                    FilledButton(  
                      onPressed: () async {  
                        setState(() {  
                          isButtonClicked = true;  
                        });  
                        await windowManager.maximize();  
                        // 这里可以添加进入应用主界面的逻辑  
                      },  
                      child: Text(  
                        isButtonClicked ? 'Entering...' : 'Get Started',  
                        style: TextStyle(),  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
            ),  
          ),  
          Platform.isWindows?Positioned(  
            top: 0,  
            right: 0,  
            child: WindowButtons(),  
          ):Container(),  
        ],  
      ),  
    );  
  }  
}
```
# 4. 主页面之前
## 同意并开始按钮
我们希望当用户点击“同意并开始”按钮之后，我们希望进入到下一个页面，此时我们需要用到路由跳转功能。
![[Pasted image 20250508175955.png]]
## 路由跳转
所谓路由跳转，可以直白的认为就是不同页面的一个导航，要实现基本的跳转后退等功能，还要实现页面之间的参数传递。官方的`class FluentPageRoute< T > extends PageRoute < T >`，我们将对FluentPageRoute类提供的路由功能封装。以下是已经封装好的路由跳转类，使用的时候只需要完整复制这两个文件，并在`main.dart`中添加
```dart
      navigatorKey: RouteUtils.navigatorKey,  
      onGenerateRoute: Routes.generateRoute,  
```
具体的介绍和完整代码可以看下文。
>Q : 如果我希望在其他项目中使用这个路由跳转类，可以吗？
>A : 当然是可以的，只不过你可能需要根据情景微调，比如，我这里使用的是` 'package:fluent_ui/fluent_ui.dart`依赖，那么你需要在两个路由跳转类文件中`static FluentPageRoute pageRoute`处写`FluentPageRoute`；当你使用`package:flutter/material.dart`的时候就要做出修改，把所有的`FluentPageRoute`替换成`MaterialPageRoute`，我将在此小结的最后放置如果使用MaterialPageRoute的完整代码，请注意区分。
### 封装路由跳转类`RouteUtils`
#### `/route/route_utils.dart`
```dart
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2024-11-01 *@Description:RouteUtils *@Version: 1.0 */  
  
import 'package:fluent_ui/fluent_ui.dart';  
  
///方便路由跳转的工具类  
class RouteUtils {  
  RouteUtils._();  
  
  static final navigatorKey = GlobalKey<NavigatorState>();  
  
  // App 根节点Context  
  static BuildContext get context => navigatorKey.currentContext!;  
  
  static NavigatorState get navigator => navigatorKey.currentState!;  
  
  ///普通动态跳转-->page  
  static Future push(  
      BuildContext context,  
      Widget page, {  
        bool? fullscreenDialog,  
        RouteSettings? settings,  
        bool maintainState = true,  
      }) {  
    return Navigator.push(  
        context,  
        FluentPageRoute(  
          builder: (_) => page,  
          fullscreenDialog: fullscreenDialog ?? false,  
          settings: settings,  
          maintainState: maintainState,  
        ));  
  }  
  
  ///根据路由路径跳转  
  static Future pushForNamed(  
      BuildContext context,  
      String name, {  
        Object? arguments,  
      }) {  
    return Navigator.pushNamed(context, name, arguments: arguments);  
  }  
  
  ///自定义route动态跳转  
  static Future pushForPageRoute(BuildContext context, Route route) {  
    return Navigator.push(context, route);  
  }  
  
  ///清空栈，只留目标页面  
  static Future pushNamedAndRemoveUntil(  
      BuildContext context,  
      String name, {  
        Object? arguments,  
      }) {  
    return Navigator.pushNamedAndRemoveUntil(context, name, (route) => false, arguments: arguments);  
  }  
  
  ///清空栈，只留目标页面  
  static Future pushAndRemoveUntil(  
      BuildContext context,  
      Widget page, {  
        bool? fullscreenDialog,  
        RouteSettings? settings,  
        bool maintainState = true,  
      }) {  
    return Navigator.pushAndRemoveUntil(  
        context,  
        FluentPageRoute(  
          builder: (_) => page,  
          fullscreenDialog: fullscreenDialog ?? false,  
          settings: settings,  
          maintainState: maintainState,  
        ),  
            (route) => false);  
  }  
  
  ///用新的路由替换当路由  
  static Future pushReplacement(BuildContext context, Route route, {Object? result}) {  
    return Navigator.pushReplacement(context, route, result: result);  
  }  
  
  ///用新的路由替换当路由  
  static Future pushReplacementNamed(  
      BuildContext context,  
      String name, {  
        Object? result,  
        Object? arguments,  
      }) {  
    return Navigator.pushReplacementNamed(context, name, arguments: arguments, result: result);  
  }  
  
  ///关闭当前页面  
  static void pop(BuildContext context) {  
    Navigator.pop(context);  
  }  
  
  ///关闭当前页面:包含返回值  
  static void popOfData<T extends Object?>(BuildContext context, {T? data}) {  
    Navigator.of(context).pop(data);  
  }  
}
```
#### `/route/routes.dart`
```dart
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/page/home/home_page.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-05 *@Description: *@Version: 1.0 */  
  
  
class Routes {  
  static Route<dynamic> generateRoute(RouteSettings settings) {  
    switch (settings.name) {  
      case RoutePath.home_page:  
        return pageRoute(HomePage(), settings: settings);  
  
    }  
    return pageRoute(ScaffoldPage(  
      content: SafeArea(  
          child: Center(  
            child: Text("404:Route Path ${settings.name} Not Found"),  
          )),  
    ));  
  }  
  
  static FluentPageRoute pageRoute(Widget page,  
      {RouteSettings? settings,  
        bool? fullscreenDialog,  
        bool? maintainState,  
        bool? allowSnapshotting}) {  
    return FluentPageRoute(  
        builder: (context) {  
          return page;  
        },  
        settings: settings,  
        fullscreenDialog: fullscreenDialog ?? false,  
        maintainState: maintainState ?? true,  
        );  
  }  
}  
  
class RoutePath {  
  //HomePage  
  static const String home_page = "/home/home_page";  
  
  
}
```
### `main.dart`
- **`navigatorKey`**：把 `RouteUtils` 里的 `navigatorKey` 传递给 `FluentApp`，这样在整个应用中就能使用 `RouteUtils` 来进行路由跳转了。
- **`onGenerateRoute`**：将 `Routes.generateRoute` 方法传递给 `FluentApp` 的 `onGenerateRoute` 参数，这样当需要跳转路由时，就会调用该方法来生成对应的路由。
```dart
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/page/welcome/welcome_page.dart';  
import 'package:inksrcibe/route/route_utils.dart';  
import 'package:window_manager/window_manager.dart';  
  
import 'route/routes.dart';  
  
Future<void> main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  // 初始化 window_manager  try{  
    await windowManager.ensureInitialized();  
    WindowOptions windowOptions = WindowOptions(  
      windowButtonVisibility :true ,  
      titleBarStyle:TitleBarStyle.hidden,  
      size: Size(800, 600),  
      center: true,  
      skipTaskbar: false,  
      title: '欢迎使用 Inkscribe',  
    );  
    windowManager.waitUntilReadyToShow(windowOptions, () async {  
      await windowManager.show();  
      await windowManager.focus();  
    });  
  }catch(e){  
  
  }  
  runApp(const MyApp());  
}  
  
class MyApp extends StatefulWidget {  
  const MyApp({super.key});  
  
  @override  
  State<MyApp> createState() => _MyAppState();  
}  
  
class _MyAppState extends State<MyApp> {  
  @override  
  Widget build(BuildContext context) {  
    return FluentApp(  
      debugShowCheckedModeBanner: false,  
      themeMode: ThemeMode.system,  
      theme: FluentThemeData.light(  
      ),  
      darkTheme: FluentThemeData.dark(  
      ),  
      navigatorKey: RouteUtils.navigatorKey,  
      onGenerateRoute: Routes.generateRoute,  
      home: WelcomePage(),  
    );  
  }  
}
```
### 如何使用封装之后的路由跳转类？
1. 创建一个页面（stf）之后，需要在`routes.dart`中添加这两行代码。需要根据实际情况换成合适的路径，并import组件。
```dart
static const String welcome_setting_page = "/welcome/welcome_setting_page";

  
case RoutePath.welcome_setting_page:  
  return pageRoute(WelcomeSettingPage(), settings: settings);
```
2. 跳转页面
- 常规跳转
```dart
RouteUtils.pushForNamed(context, RoutePath.home_page);
```
- 带参数跳转
```dart
RouteUtils.pushForNamed(context, RoutePath.home_page,arguments: 参数);
```
- 返回页面
```dart
RouteUtils.pop(context);  
```
- 带参数返回
```dart
RouteUtils.popOfData(context,data: 参数);
```
### 使用MaterialPageRoute封装路由跳转类的完整代码
（此处代码和本项目无关，仅对上处Q&A补充，请注意区分）
#### `/route/route_utils.dart`
```dart
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2024-11-01 *@Description:RouteUtils *@Version: 1.0 */import 'package:flutter/material.dart';  
  
///方便路由跳转的工具类  
class RouteUtils {  
  RouteUtils._();  
  
  static final navigatorKey = GlobalKey<NavigatorState>();  
  
  // App 根节点Context  
  static BuildContext get context => navigatorKey.currentContext!;  
  
  static NavigatorState get navigator => navigatorKey.currentState!;  
  
  ///普通动态跳转-->page  
  static Future push(  
      BuildContext context,  
      Widget page, {  
        bool? fullscreenDialog,  
        RouteSettings? settings,  
        bool maintainState = true,  
      }) {  
    return Navigator.push(  
        context,  
        MaterialPageRoute(  
          builder: (_) => page,  
          fullscreenDialog: fullscreenDialog ?? false,  
          settings: settings,  
          maintainState: maintainState,  
        ));  
  }  
  
  ///根据路由路径跳转  
  static Future pushForNamed(  
      BuildContext context,  
      String name, {  
        Object? arguments,  
      }) {  
    return Navigator.pushNamed(context, name, arguments: arguments);  
  }  
  
  ///自定义route动态跳转  
  static Future pushForPageRoute(BuildContext context, Route route) {  
    return Navigator.push(context, route);  
  }  
  
  ///清空栈，只留目标页面  
  static Future pushNamedAndRemoveUntil(  
      BuildContext context,  
      String name, {  
        Object? arguments,  
      }) {  
    return Navigator.pushNamedAndRemoveUntil(context, name, (route) => false, arguments: arguments);  
  }  
  
  ///清空栈，只留目标页面  
  static Future pushAndRemoveUntil(  
      BuildContext context,  
      Widget page, {  
        bool? fullscreenDialog,  
        RouteSettings? settings,  
        bool maintainState = true,  
      }) {  
    return Navigator.pushAndRemoveUntil(  
        context,  
        MaterialPageRoute(  
          builder: (_) => page,  
          fullscreenDialog: fullscreenDialog ?? false,  
          settings: settings,  
          maintainState: maintainState,  
        ),  
            (route) => false);  
  }  
  
  ///用新的路由替换当路由  
  static Future pushReplacement(BuildContext context, Route route, {Object? result}) {  
    return Navigator.pushReplacement(context, route, result: result);  
  }  
  
  ///用新的路由替换当路由  
  static Future pushReplacementNamed(  
      BuildContext context,  
      String name, {  
        Object? result,  
        Object? arguments,  
      }) {  
    return Navigator.pushReplacementNamed(context, name, arguments: arguments, result: result);  
  }  
  
  ///关闭当前页面  
  static void pop(BuildContext context) {  
    Navigator.pop(context);  
  }  
  
  ///关闭当前页面:包含返回值  
  static void popOfData<T extends Object?>(BuildContext context, {T? data}) {  
    Navigator.of(context).pop(data);  
  }  
}
```
#### `/route/routes.dart`
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
///省略一些导入

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    ///这是一些例子，需要修改
      case RoutePath.tab:
        return pageRoute(TabPage(), settings: settings);
      case RoutePath.welcome_private:
        return pageRoute(WelcomePagePrivate(), settings: settings);
      case RoutePath.welcome_useragreement:
        return pageRoute(WelcomePageUseragreement(), settings: settings);
      case RoutePath.welcome_premission:
        return pageRoute(WelcomePagePermission(), settings: settings);
      case RoutePath.welcome_blank:
        return pageRoute(WelcomePageBlank(), settings: settings);
      case RoutePath.create_new_workflows:
        return pageRoute(CreateNewWorkflowsPage(), settings: settings);
      case RoutePath.create_new_workflows_tab:
        return pageRoute(CreateNewWorkflowsPageTab(), settings: settings);

    }
    return pageRoute(Scaffold(
      body: SafeArea(
          child: Center(
        child: Text("404:Route Path ${settings.name} Not Found"),
      )),
    ));
  }

  static MaterialPageRoute pageRoute(Widget page,
      {RouteSettings? settings,
      bool? fullscreenDialog,
      bool? maintainState,
      bool? allowSnapshotting}) {
    return MaterialPageRoute(
        builder: (context) {
          return page;
        },
        settings: settings,
        fullscreenDialog: fullscreenDialog ?? false,
        maintainState: maintainState ?? true,
        allowSnapshotting: allowSnapshotting ?? true);
  }
}

class RoutePath {
  //HomePage，同样需要修改
  static const String tab = "/";
  static const String welcome_private = "/welcome_page_private";
  static const String welcome_useragreement = "/welcome_page_useragreement";
  static const String welcome_premission = "/welcome_page_permission";
  static const String welcome_blank = "/welcome_page_blank";
  static const String create_new_workflows = "/create_new_workflows_page";
  static const String create_new_workflows_tab = "/create_new_workflows_page_tab";
}

```
## 用`flutter_settings_screens`快速写一个设置功能？
`flutter_settings_screens`是一个用于 Flutter 开发的第三方依赖库，其作用是助力开发者迅速且便捷地打造应用程序的设置界面。
### 导入依赖
```yaml
flutter_settings_screens: ^0.3.4  
shared_preferences: ^2.5.3
```
### 初始化
在`main.dart`中加入下面这两行初始化依赖。
```dart
WidgetsFlutterBinding.ensureInitialized();  
await Settings.init(cacheProvider: SharePreferenceCache());
```
修改完的代码如下：
```dart
Future<void> main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  // 初始化 window_manager  try{  
    await windowManager.ensureInitialized();  
    WindowOptions windowOptions = WindowOptions(  
      windowButtonVisibility :true ,  
      titleBarStyle:TitleBarStyle.hidden,  
      size: Size(800, 600),  
      center: true,  
      skipTaskbar: false,  
      title: '欢迎使用 Inkscribe',  
    );  
    windowManager.waitUntilReadyToShow(windowOptions, () async {  
      await windowManager.show();  
      await windowManager.focus();  
    });  
  }catch(e){  
  
  }  
  WidgetsFlutterBinding.ensureInitialized();  
  await Settings.init(cacheProvider: SharePreferenceCache());  
  runApp(const MyApp());  
}
```
### 读取Setting的键值对
我们可以理解有一个“Setting”类，里面有很多的键值对存储设置，每个键对应着一条数据，通过`flutter_settings_screens`依赖可以免去自己写Setting类的繁琐，简化操作。等下再`welcome_setting_page.dart`页面中“设置工作区文件夹路径”的功能案例中会举例介绍。让我们先来看看两个基本的用法。
#### getValue
这里workspacePathKey是一个String类型变量，是一个“键值对的键值”，defaultValue顾名思义，就是这个键值对的默认值。
```dart
String? path = await Settings.getValue<String>(workspacePathKey, defaultValue: '');  
```
#### setValue
这里workspacePathKey是一个String类型变量，是一个“键值对的键值”，result是设置键值对的值。
```dart
Settings.setValue(workspacePathKey, result);
```
### 试用一个例子使用`flutter_settings_screens`依赖
我们需要在用户同意应用协议后，提示用户设置一个工作区，用于存储用户保存的文件。试看下面的效果图，页面顶部依旧是一个Logo，中部有一行主标题和一行副标题提示用户选择路径，当用户没有选择的时候，最下部分的“继续”按钮无法点击，当用户选择文件夹后，“继续”按钮可以点击。
#### 效果
![[Pasted image 20250508165336.png]]
#### 开始
首先，让我们创建一个`welcome_setting_page.dart`页面，并修改`welcome_page.dart`同意跳转的按钮指向`welcome_setting_page.dart`。完整代码可参考本节最后，此处仅写出部分代码。
1. 创建`/welcome/welcome_setting_page.dart`，并写出基本stf框架。
2. 在`/route/routes.dart`中添加路径，修改后的路径跳转类完整代码如下。
   `/route/routes.dart`
```dart
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/page/home/home_page.dart';  
import 'package:inksrcibe/page/welcome/welcome_setting_page.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-05 *@Description: *@Version: 1.0 */  
  
  
class Routes {  
  static Route<dynamic> generateRoute(RouteSettings settings) {  
    switch (settings.name) {  
      case RoutePath.home_page:  
        return pageRoute(HomePage(), settings: settings);  
      case RoutePath.welcome_setting_page:  
        return pageRoute(WelcomeSettingPage(), settings: settings);  
  
    }  
    return pageRoute(ScaffoldPage(  
      content: SafeArea(  
          child: Center(  
            child: Text("404:Route Path ${settings.name} Not Found"),  
          )),  
    ));  
  }  
  
  static FluentPageRoute pageRoute(Widget page,  
      {RouteSettings? settings,  
        bool? fullscreenDialog,  
        bool? maintainState,  
        bool? allowSnapshotting}) {  
    return FluentPageRoute(  
        builder: (context) {  
          return page;  
        },  
        settings: settings,  
        fullscreenDialog: fullscreenDialog ?? false,  
        maintainState: maintainState ?? true,  
        );  
  }  
}  
  
class RoutePath {  
  //HomePage  
  static const String home_page = "/home/home_page";  
  static const String welcome_setting_page = "/welcome/welcome_setting_page";  
  
  
}
```
3.  修改`/page/welcome/welcome_page.dart`中曾写好的同意按钮点击事件为跳转页面。
```dart
FilledButton(  
  onPressed: () async {  
    RouteUtils.pushForNamed(context, RoutePath.welcome_setting_page);  
  },  
  child: Text(  
    '同意并开始',  
    style: TextStyle(),  
  ),  
),
```
4. 编写文件夹选择器功能
   首先引入依赖
```yaml
flutter_settings_screens: ^0.3.4  
shared_preferences: ^2.5.3
file_picker: ^5.2.6
```
然后修改`/welcome/welcome_setting_page.dart`中的代码，添加一个文件路径选择器，这里使用了`file_picker`的依赖，主要代码直接写出来了，可以参考：
`/welcome/welcome_setting_page.dart`
```dart
Row(  
  mainAxisAlignment: MainAxisAlignment.center,  
  children: [  
    SizedBox(  
      width: 300,  
      child: TextBox(  
        readOnly: true,  
        placeholder: '请选择或输入文件夹路径',  
        controller: TextEditingController(text: _selectedFolderPath),  
      ),  
    ),  
    const SizedBox(width: 10),  
    FilledButton(  
      onPressed: _selectFolder,  
      child: const Text('选择文件夹'),  
    ),  
  ],  
),
```
然后，为这个文件路径选择器添加`flutter_settings_screens`依赖提供的get/set，并在页面初始化的时候调用`_loadWorkspacePath`方法来读取设置的值。
```dart
Future<void> _loadWorkspacePath() async {  
  String? path = await Settings.getValue<String>(workspacePathKey, defaultValue: '');  
  setState(() {  
    _selectedFolderPath = path?? '';  
  });  
}  
  
Future<void> _selectFolder() async {  
  String? result = await FilePicker.platform.getDirectoryPath();  
  if (result != null) {  
    await Settings.setValue(workspacePathKey, result);  
    setState(() {  
      _selectedFolderPath = result;  
    });  
  }  
}

@override  
void initState() {  
  super.initState();  
  windowManager.addListener(this);  
  _loadWorkspacePath();  
}
```
上述的部分代码旨在一个提示思路，如果直接进行修改可能有很多报错，您可以在理解上述代码的作用后根据你自己的项目做调整，下面是至此的完整代码，可供参考。
#### 完整代码
##### `main.dart`
 ```dart
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:flutter_settings_screens/flutter_settings_screens.dart';  
import 'package:inksrcibe/page/welcome/welcome_page.dart';  
import 'package:inksrcibe/route/route_utils.dart';  
import 'package:window_manager/window_manager.dart';  
  
import 'route/routes.dart';  
  
Future<void> main() async {  
  WidgetsFlutterBinding.ensureInitialized();  
  // 初始化 window_manager  try{  
    await windowManager.ensureInitialized();  
    WindowOptions windowOptions = WindowOptions(  
      windowButtonVisibility :true ,  
      titleBarStyle:TitleBarStyle.hidden,  
      size: Size(800, 600),  
      center: true,  
      skipTaskbar: false,  
      title: '欢迎使用 Inkscribe',  
    );  
    windowManager.waitUntilReadyToShow(windowOptions, () async {  
      await windowManager.show();  
      await windowManager.focus();  
    });  
  }catch(e){  
  
  }  
  WidgetsFlutterBinding.ensureInitialized();  
  await Settings.init(cacheProvider: SharePreferenceCache());  
  runApp(const MyApp());  
}  
  
class MyApp extends StatefulWidget {  
  const MyApp({super.key});  
  
  @override  
  State<MyApp> createState() => _MyAppState();  
}  
  
  
  
class _MyAppState extends State<MyApp> {  
  @override  
  Widget build(BuildContext context) {  
    return FluentApp(  
      debugShowCheckedModeBanner: false,  
      themeMode: ThemeMode.system,  
      theme: FluentThemeData.light(),  
      darkTheme: FluentThemeData.dark(),  
      navigatorKey: RouteUtils.navigatorKey,  
      onGenerateRoute: Routes.generateRoute,  
      home: WelcomePage(),  
    );  
  }  
}
```
##### `/config/settings_config.dart`
```dart
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-08 *@Description: *@Version: 1.0 */  
class SettingsConfig{  
  static const String workspacePath = 'workspace_path';  
  static const String isUserPrivateAgree = 'is_user_private_agree';  
}
```
##### `/page/welcome/welcome_setting_page.dart`
```dart
import 'dart:io';  
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/config/settings_config.dart';  
import 'package:window_manager/window_manager.dart';  
import 'package:file_picker/file_picker.dart';  
import 'package:flutter_settings_screens/flutter_settings_screens.dart';  
  
import '../../config/privacy_policy.dart';  
import '../../module/window_buttons.dart';  
import '../../route/route_utils.dart';  
import '../../route/routes.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-08 *@Description: *@Version: 1.0 */  
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
      // RouteUtils.pushForNamed(context, RoutePath.home_page);  
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
                    // 这里替换为你的应用 Logo                    Image.asset(  
                      'assets/icons/app_icon.ico',  
                      width: 100,  
                      height: 100,  
                    ),  
                    const SizedBox(height: 20),  
                    Container(  
                      margin: EdgeInsets.only(left: 20, right: 20),  
                      child: Text(  
                        '开始之前，请先设置一个工作区',  
                        style: TextStyle(  
                          fontSize: 26,  
                          fontWeight: FontWeight.bold,  
                        ),  
                      ),  
                    ),  
                    Container(  
                      margin: EdgeInsets.only(left: 20, right: 20),  
                      child: Text(  
                        '工作区是存放Inkscribe项目文件的地方，Inkscribe会读取该位置下的文件。',  
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
                                        // readOnly: true,  
                                        placeholder: '请选择或输入文件夹路径',  
                                        controller: TextEditingController(  
                                            text: _selectedFolderPath),  
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
```
##### `/page/welcome/welcome_page.dart`
```dart
import 'dart:io';  
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/config/settings_config.dart';  
import 'package:window_manager/window_manager.dart';  
import 'package:file_picker/file_picker.dart';  
import 'package:flutter_settings_screens/flutter_settings_screens.dart';  
  
import '../../config/privacy_policy.dart';  
import '../../module/window_buttons.dart';  
import '../../route/route_utils.dart';  
import '../../route/routes.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-08 *@Description: *@Version: 1.0 */  
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
      // RouteUtils.pushForNamed(context, RoutePath.home_page);  
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
                    // 这里替换为你的应用 Logo                    Image.asset(  
                      'assets/icons/app_icon.ico',  
                      width: 100,  
                      height: 100,  
                    ),  
                    const SizedBox(height: 20),  
                    Container(  
                      margin: EdgeInsets.only(left: 20, right: 20),  
                      child: Text(  
                        '开始之前，请先设置一个工作区',  
                        style: TextStyle(  
                          fontSize: 26,  
                          fontWeight: FontWeight.bold,  
                        ),  
                      ),  
                    ),  
                    Container(  
                      margin: EdgeInsets.only(left: 20, right: 20),  
                      child: Text(  
                        '工作区是存放Inkscribe项目文件的地方，Inkscribe会读取该位置下的文件。',  
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
                                        // readOnly: true,  
                                        placeholder: '请选择或输入文件夹路径',  
                                        controller: TextEditingController(  
                                            text: _selectedFolderPath),  
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
```
# 5. 先为主页面搭一个框架
## 开始
还是先看看效果![[Pasted image 20250509074945.png]]让我们看看这个页面都有哪些部分，页面分为顶栏和侧边栏两个主要部分。我们不妨使用`NavigationView`组件，让我们看看这个`NavigationView`里面都有什么属性？
```dart
const NavigationView({  
  super.key,  
  this.appBar,  
  this.pane,  
  this.content,  
  this.clipBehavior = Clip.antiAlias,  
  this.contentShape,  
  this.onOpenSearch,  
  this.transitionBuilder,  
  this.paneBodyBuilder,  
  this.onDisplayModeChanged,  
})
```
- `this.appBar`：用于指定导航视图顶部的应用栏，通常包含标题、导航按钮等内容，用于提供页面的相关信息和操作入口。
- `this.pane`：代表导航视图的侧边栏或导航窗格，用于放置导航菜单、选项等内容，通常可以包含图标和文本，以引导用户进行不同页面或功能的切换。
- `this.content`：主要内容区域，是导航视图中展示主要页面内容的部分，会根据用户在导航栏中的选择来显示相应的页面或信息。
- `this.clipBehavior = Clip.antiAlias`：指定剪裁行为，`Clip.antiAlias`表示使用抗锯齿剪裁，会使剪裁后的边缘更加平滑，避免锯齿现象。
- `this.contentShape`：用于定义内容区域的形状，可以是圆形、矩形或其他自定义形状，通过此属性可以实现一些特殊的布局效果。
- `this.onOpenSearch`：是一个回调函数，当用户触发打开搜索功能时会调用此函数，可在函数中实现搜索相关的逻辑，如显示搜索框、执行搜索操作等。
- `this.transitionBuilder`：用于定义导航视图在不同状态（如展开、收起）之间切换时的过渡效果，通过自定义过渡构建器，可以实现各种动画效果，使界面切换更加流畅和美观。
- `this.paneBodyBuilder`：是一个函数，用于构建导航窗格的主体内容。可以根据具体需求在函数中返回不同的组件，以定制导航窗格的显示内容和布局。
- `this.onDisplayModeChanged`：当导航视图的显示模式（如全屏、侧边栏模式等）发生改变时会调用此回调函数，可在函数中根据新的显示模式进行相应的布局调整或其他操作。
  我们这里主要使用appBar和pane两个属性值，首先让我们看一下appBar，appBar应是一个`NavigationAppBar`组件，让我们看一下`NavigationAppBar`属性。
```dart
const NavigationAppBar({  
  this.key,  
  this.leading,  
  this.title,  
  this.actions,  
  this.automaticallyImplyLeading = true,  
  this.height = _kDefaultAppBarHeight,  
  this.backgroundColor,  
});
```
- `leading`：通常是一个 Widget，显示在导航栏的左侧，比如常见的返回按钮等。如果不设置，会根据`automaticallyImplyLeading`属性来决定是否显示默认的返回按钮。
- `title`：是导航栏中间显示的标题内容，一般是一个`Text` Widget 或者其他用于表示标题的 Widget。
- `actions`：是一个`Widget`列表，显示在导航栏的右侧，用于放置一些操作按钮，如搜索按钮、菜单按钮等。
- `automaticallyImplyLeading`：布尔值，默认值为`true`。当为`true`时，如果`leading`属性没有被设置，会自动根据平台和上下文等情况显示一个默认的返回按钮或其他合适的引导图标；如果为`false`，则不会自动显示默认的`leading` Widget。
- `height`：导航栏的高度，默认值为`_kDefaultAppBarHeight`，可以根据实际需求自定义导航栏的高度。
- `backgroundColor`：导航栏的背景颜色，如果不设置，会使用主题中的默认导航栏背景颜色。
  我们可以让`DragToMoveArea`包裹顶栏，这样，就可以用鼠标拖拽顶栏移动窗口了。再说说pane，panel应当是一个`NavigationPane`组件，这个组件有几个关键属性，`selected`属性是侧边导航栏的索引，表示当前侧边栏的选项卡所处位置。`onChanged`函数可以帮助更新组件状态，当侧边栏选项卡切换的时候更新`selected`。`displayMode`属性可以设置侧边栏的展开状态分别可以设置`PaneDisplayMode.auto`、`PaneDisplayMode.open`、`PaneDisplayMode.minial`、`PaneDisplayMode.compact`、`PaneDisplayMode.top`几个枚举。
 `PaneDisplayMode.auto`
- **描述**：自动根据窗口大小和平台特性选择最合适的显示模式。
- **行为**：
    - 在大屏幕上，可能表现为 `open` 模式（侧边栏完全展开）。
    - 在中等屏幕上，可能表现为 `compact` 模式（仅显示图标）。
    - 在小屏幕上，可能表现为 `minimal` 或 `top` 模式（顶部导航或折叠式菜单）。
- **适用场景**：希望界面能自适应不同设备尺寸时使用。
  `PaneDisplayMode.open`
- **描述**：侧边栏完全展开，同时显示图标和文本标签。
- **行为**：
    - 侧边栏占据固定宽度（通常较宽）。
    - 菜单项显示完整的图标和文本。
- **适用场景**：桌面端或大屏幕设备，用户需要快速识别导航项的名称。
  `PaneDisplayMode.minimal`
- **描述**：侧边栏仅在鼠标悬停时展开，平时只显示一个窄条。
- **行为**：
    - 默认状态下，侧边栏收缩为一条窄边（仅显示极少内容）。
    - 鼠标悬停时，侧边栏展开并显示完整内容。
- **适用场景**：需要最大化内容区域，同时保留侧边栏导航功能的场景（如代码编辑器）。
  `PaneDisplayMode.compact`
- **描述**：侧边栏始终显示，但仅展示图标，不显示文本标签。
- **行为**：
    - 侧边栏宽度较窄，仅容纳图标。
    - 文本标签仅在用户悬停时显示（通常以工具提示形式）。
- **适用场景**：需要节省空间，但仍希望导航栏常驻的场景（如笔记本电脑或平板）。
  `PaneDisplayMode.top`
- **描述**：导航项显示在顶部，而非侧边。
- **行为**：
    - 导航项以水平方式排列在应用顶部。
    - 通常与 `NavigationAppBar` 结合使用。
- **适用场景**：移动设备或垂直空间有限的界面（如手机应用）。
  items里面是一个`List<NavigationPaneItem>`，列表每个子项是`PaneItem`，`PaneItem`继承自`NavigationPaneItem`。
```dart
PaneItem({  
  super.key,  
  required this.icon,  
  required this.body,  
  this.title,  
  this.trailing,  
  this.infoBadge,  
  this.focusNode,  
  this.autofocus = false,  
  this.mouseCursor,  
  this.tileColor,  
  this.selectedTileColor,  
  this.onTap,  
  this.enabled = true,  
});
```
## 完整代码
`/page/home/home_page.dart`
```dart
import 'dart:io';  
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:window_manager/window_manager.dart';  
  
import '../../module/window_buttons.dart';  
  
  
class HomePage extends StatefulWidget {  
  const HomePage({super.key});  
  
  @override  
  State<HomePage> createState() => _HomePageState();  
}  
  
class _HomePageState extends State<HomePage> {  
  int _selectedIndex = 0;  
  
  final List<NavigationPaneItem> _items = [  
    PaneItem(  
      icon: const Icon(FluentIcons.home),  
      title: const Text('笔记'),  
      body: Container(),  
    ),  
    PaneItem(  
      icon: const Icon(FluentIcons.settings),  
      title: const Text('设置'),  
      body: Container(),  
    ),  
    PaneItem(  
      icon: const Icon(FluentIcons.help),  
      title: const Text('关于'),  
      body: Container(),  
    ),  
  ];  
  
  @override  
  Widget build(BuildContext context) {  
    return Container(  
      color: FluentTheme.of(context).micaBackgroundColor, // 设置 Padding 区域的背景颜色，这里使用灰色作为示例  
      child: Padding(  
        padding: EdgeInsets.only(top: 0), // 设置顶部间距为 10        child: NavigationView(  
          appBar: NavigationAppBar(  
              automaticallyImplyLeading:false,  
            title: DragToMoveArea(  
              child: Container(  
                  width: double.infinity,  
                  height: double.infinity,  
                  // padding: EdgeInsets.only(top: 20),  
                  child: Row(  
                    children: [  
                      Image.asset("assets/icons/app_icon.ico",width: 20,height: 20,),  
                      SizedBox(width: 20),  
                      Text("Inkscribe")  
                    ],  
                  )  
              ),  
            ),  
            actions: Platform.isWindows  
                ? Positioned(  
              top: 0,  
              right: 0,  
              child: WindowButtons(),  
            )  
                : Container(),  
          ),  
          pane: NavigationPane(  
            selected: _selectedIndex,  
            onChanged: (index) {  
              setState(() {  
                _selectedIndex = index;  
              });  
            },  
            displayMode: PaneDisplayMode.auto,  
            items: _items,  
          ),  
  
        ),  
      ),  
    );  
  }  
}
```
# 6. 先来写一个“手写页面”的模块
## 小记
没有什么依赖是那么专业的封装了各种画板有关的组件，我这里用到的`flutter_drawing_board`依赖支持”普通笔“、”模拟压感笔“、”直线“、”圆圈“、”导入图片“、”序列化保存笔迹“、”橡皮擦“等功能，但是一些笔记软件的”套选“、”文档导入“、”换页“、”电子笔压感“、”多指“等功能还没有封装，但是通过阅读这个依赖的原始代码可以翻到一些可以”再创作“的接口，可能也正是如此，让这件事有趣起来了。让我和大家一起学习，先做出一个框框，再逐步完善功能吧。再下面每个子节，我可能会记录一些我的思考，我的思考也许并不具有可行性或者复杂化了问题，但不妨作为思路或者想法讨论。让我们开始吧~抛开之前的那个架子，让我们学点真功能，从这个依赖起步。
## `Flutter_Drawing_Board`
### 引入依赖
```yaml
flutter_drawing_board: ^0.8.1
```
### 创建一个画板
我们可以使用`DrawingBoard`这个对象来创建一个画布，画布往往需用一个指定尺寸组件包裹起来，比如：`Sizebox`、`Container`等等。下面是一个创建画板的例子，不难看出，我们使用一个和窗口有效区域同尺寸的`Container`组件包裹了`DrawingBoard`，`DrawingBoard`中我们指定了一个类中全局变量`_drawingController`作为控制器，可以通过控制器来后续对画板进行操作，针对画板控制器将会在下文介绍。`DrawingBoard`中还有一个`background`必须属性值，这里可以指定画布的背景，比如下面这个例子就是指定了一个`Container`，这里的`background`的属性值必须是一个指定尺寸组件，不可以想当然的认为把`Container`的`width`亦或是`height`设置为`double.infinity`就实现了”无界画布“的操作。
```dart
Container(  
  width: MediaQuery.of(context).size.width, // 获取窗口宽度  
  height: MediaQuery.of(context).size.height - 50,  
  color: FluentTheme.of(context).micaBackgroundColor,  
	child: DrawingBoard(  
	  controller: _drawingController, 
	  background: Container(  
		width: MediaQuery.of(context).size.width,  
		height: MediaQuery.of(context).size.height,  
		color: Color(0xff264b42),  
	  ),  
),
```
>**我的思考**：
>1. 可以通过设置一个较大的尺寸来模拟”无界画布“的功能，而不是想当然的使用`double.infinity`
>2. 可以通过修改`background`这个属性值来实现图片标注（区别于导入图片，这里是以图片为背景）、PDF标注（可能需要其他解析PDF的插件）

再让我们看看这个`DrawingBoard`还有哪些好玩的属性值和方法函数，我们点进这个类，可以看到`DrawingBoard`继承自无状态组件，目前我写的页面其实有一些封装好的组件和这个画板组件类似，也是无状态组件，但是有的时候你不得不去为这些无状态组件添加类似更新状态的功能，如何实现我们放置在后文中具体例子来介绍。下面是`DrawingBoard`类的全部属性，我们不一一介绍，将通过注释提示大家各个属性的功能概况，如果有需要还请再详细搜索。
```dart
  const DrawingBoard({  
    super.key,  
    required this.background,  
    this.controller,  
    // 是否显示默认操作按钮（如撤销、清除）
    this.showDefaultActions = false,
	// 是否显示默认工具（如画笔、橡皮擦）
    this.showDefaultTools = false,  
    this.onPointerDown,          // 手指按下时触发
	this.onPointerMove,          // 手指移动时触发
	this.onPointerUp,            // 手指抬起时触发
	// 组件边缘裁剪方式（默认抗锯齿）
	this.clipBehavior = Clip.antiAlias,
	// 画板内容裁剪方式
	this.boardClipBehavior = Clip.hardEdge,      
	// 平移方向（自由、水平或垂直）
    this.panAxis = PanAxis.free,    
	// 画板边界边距
    this.boardBoundaryMargin,  
    // 是否限制在边界内
    this.boardConstrained = false,  
    // 最大缩放比例（默认20倍）
    this.maxScale = 20,  
    // 最小缩放比例（默认0.2倍）
    this.minScale = 0.2,  
    // 是否启用平移
    this.boardPanEnabled = true,  
    // 是否启用缩放
    this.boardScaleEnabled = true,  
    // 缩放灵敏度因子，越大越灵敏，轻轻一捏合即可更大缩放
    this.boardScaleFactor = 200.0,  
    // 交互开始时触发（如按下或缩放开始）
    this.onInteractionEnd,  
    // 交互更新时触发（如移动或缩放过程中）
    this.onInteractionStart,  
    // 交互结束时触发（如抬起或缩放结束）
    this.onInteractionUpdate,  
    // 自定义变换控制器
    this.transformationController,  
    // 内容对齐方式（默认顶部居中）
    this.alignment = Alignment.topCenter,  
  });
```
其实这个依赖包不光光提供了一个画板，他还帮我们封装了一个工具条样式，工具条中有”笔“、”橡皮“等工具，省去了我们自己写UI的繁琐，但是鉴于其提供好的工具条不能够满足项目场景需要，因此我们不使用他已经封装好的工具条组件。此外，这个`Drawing_Board`还有一些以`void Function(ScaleUpdateDetails)?`为返回类型的函数属性，可以利用这些属性来进行监听事件的回调，比如：当我进行了画布操作后执行事件等。
>**我的思考**
>1. 其实我目前还没有找到关于缩放的属性值，这里的缩放只是只画板可以缩放到怎样一个范围内，我get不到画板当前的zoom值，再其他的功能中我也只能看到每次缩放操作是前一次状态缩放值的倍数，即便我通过全局变量的功能设置初始zoom=1，然后通过函数累乘，得到的当前缩放zoom也是个不准确并且容易出错的值（尤其是再移动端的抖动），因此目前我还在尝试解决这个问题。

### 切换设置笔迹样式
在具体实现某个操作之前，我们先来看看这个画布控制器`DrawingController`，不难看到其最重要的一个操作是`setPaintContent`方法，这个方法可以帮助你去进行笔刷切换等功能。
```dart
DrawingController({DrawConfig? config, PaintContent? content}) {  
  _history = <PaintContent>[];  
  _currentIndex = 0;  
  // 底层画布刷新控制
  realPainter = RePaintNotifier();  
  // 表层画布刷新控制
  painter = RePaintNotifier();  
  drawConfig = SafeValueNotifier<DrawConfig>(  
      config ?? DrawConfig.def(contentType: SimpleLine));  
  setPaintContent(content ?? SimpleLine());  
}
```
假设我们有一个画布控制器`_drawingController`，让我们试着切换笔刷。先来看看文档：
```dart
/// 设置绘制内容  
void setPaintContent(PaintContent content) {  
  content.paint = drawConfig.value.paint;  
  _paintContent = content;  
  drawConfig.value =  
      drawConfig.value.copyWith(contentType: content.runtimeType);  
}
```
我们找到最后，发现这个`PaintContent`可以传入以下几个值`Circle`、`Eraser`、`Rectangle`、`SimpleLine`、`SmoothLine`、`StraightLine`。
![[Pasted image 20250513124443.png]]
下面是一个具体的例子，这里`_drawingController`是画布控制器。
```dart
/// 切换笔刷为模拟压感笔刷，设置模拟压感灵敏度为0.1(0-1中取值)
_drawingController.setPaintContent(SmoothLine(brushPrecision: 0.1));
```
### 设置笔样式
让我们看看`setStyle`里面的属性值：
```dart
/// 设置绘制样式  
void setStyle({  
  BlendMode? blendMode,  
  Color? color,  
  ColorFilter? colorFilter,  
  FilterQuality? filterQuality,  
  ui.ImageFilter? imageFilter,  
  bool? invertColors,  
  bool? isAntiAlias,  
  MaskFilter? maskFilter,  
  Shader? shader,  
  StrokeCap? strokeCap,  
  StrokeJoin? strokeJoin,  
  double? strokeMiterLimit,  
  double? strokeWidth,  
  PaintingStyle? style,  
})
```
1. **`BlendMode? blendMode`**：  
   这个参数用于指定绘制内容与已存在内容的混合模式。常见的混合模式有`srcOver`（默认值，新内容覆盖在旧内容之上）、`multiply`（正片叠底，颜色相乘）、`screen`（滤色，颜色变亮）等。
2. **`Color? color`**：  
   该参数用于设置绘制的颜色。若未设置，会使用默认颜色，不过一般不建议使用默认值。
3. **`ColorFilter? colorFilter`**：  
   它的作用是对绘制内容应用颜色滤镜。可以实现如黑白效果、色调调整等功能。
4. **`FilterQuality? filterQuality`**：  
   此参数用于指定滤镜的质量，可选值有`none`（无滤波，速度最快但质量最差）、`low`（低质量，速度较快）、`medium`（中等质量）、`high`（高质量，速度最慢但效果最佳）。
5. **`ui.ImageFilter? imageFilter`**：  
   用于对绘制内容应用图像滤镜，像模糊、阴影等效果都可以通过它来实现。
6. **`bool? invertColors`**：  
   这是一个布尔值参数，若设置为`true`，会对绘制内容进行颜色反转。
7. **`bool? isAntiAlias`**：  
   同样是布尔值参数，设置为`true`时会启用抗锯齿功能，让边缘看起来更平滑。
8. **`MaskFilter? maskFilter`**：  
   该参数用于对绘制内容应用掩码滤镜，例如可以实现模糊边缘的效果。
9. **`Shader? shader`**：  
   用于设置着色器，借助着色器能够实现渐变、图案填充等复杂的填充效果。
10. **`StrokeCap? strokeCap`**：  
    此参数用于指定线条端点的样式，可选值有`butt`（平头，默认值）、`round`（圆头）、`square`（方头）。
11. **`StrokeJoin? strokeJoin`**：  
    它用于指定线条连接点的样式，可选值有`miter`（尖角，默认值）、`round`（圆角）、`bevel`（斜角）。
12. **`double? strokeMiterLimit`**：  
    当`strokeJoin`为`miter`时，此参数用于控制尖角的长度限制。若尖角长度超过该限制，会自动转换为斜角。
13. **`double? strokeWidth`**：  
    用于设置线条的宽度，当`style`为`PaintingStyle.stroke`或`PaintingStyle.fillAndStroke`时生效。
14. **`PaintingStyle? style`**：  
    该参数用于指定绘制样式，可选值有`fill`（填充，默认值）、`stroke`（描边）、`fillAndStroke`（填充并描边）。
```dart
_drawingController.setStyle(  
    color: _penColor,  
    strokeWidth: _penWidth);
```
## 开始
### 创建一个handwriting页面，并写入stf
`/page/handwriting/handwriting_blank_page.dart`
```dart
import 'package:fluent_ui/fluent_ui.dart';  
  
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-09 *@Description: *@Version: 1.0 */  
class HandwritingBlankPage extends StatefulWidget {  
  const HandwritingBlankPage({super.key});  
  
  @override  
  State<HandwritingBlankPage> createState() => _HandwritingBlankPageState();  
}  
  
class _HandwritingBlankPageState extends State<HandwritingBlankPage> {  
  @override  
  Widget build(BuildContext context) {  
    return const Placeholder();  
  }  
}
```
### 在路由跳转类里面添加页面跳转
（省略掉了，可以看本节最后的完整代码）
### 修改home_page添加一个测试按钮
我们先来实现一个空白的手写页面，然后再实现其他功能，我们现在`home_page.dart`中创建一个按钮用于测试跳转空白页面。为了让主页面可以获取到`context`属性，我们把`/page/home/home_page.dart`中的`final List<NavigationPaneItem> _items`移动到build函数内，完整代码如下。
`/page/home/home_page.dart`
```dart
import 'dart:io';  
  
import 'package:fluent_ui/fluent_ui.dart';  
import 'package:inksrcibe/route/route_utils.dart';  
import 'package:inksrcibe/route/routes.dart';  
  
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
  Widget build(BuildContext context) {  
    // 定义导航项列表  
    final List<NavigationPaneItem> _items = [  
      PaneItem(  
        icon: const Icon(FluentIcons.home),  
        title: const Text('笔记'),  
        body: Container(  
          child:  Center(  
            child: FilledButton(  
              child: const Text("新建手写笔记"),  
              onPressed: () {  
                // 现在可以安全使用 context 进行路由跳转  
                RouteUtils.pushForNamed(context, RoutePath.handwriting_blank_page);  
              },  
            ),  
          )  
        ), 
      ),  
      PaneItem(  
        icon: const Icon(FluentIcons.settings),  
        title: const Text('设置'),  
        body: Container(),  
      ),  
      PaneItem(  
        icon: const Icon(FluentIcons.help),  
        title: const Text('关于'),  
        body: Container(),  
      ),  
    ];  
  
  
    return Container(  
      color: FluentTheme.of(context).micaBackgroundColor,  
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
                ? Positioned(  
              top: 0,  
              right: 0,  
              child: WindowButtons(),  
            )  
                : Container(),  
          ),  
          pane: NavigationPane(  
            selected: _selectedIndex,  
            onChanged: (index) {  
              setState(() {  
                _selectedIndex = index;  
              });  
            },  
            displayMode: PaneDisplayMode.auto,  
            items: _items,  
          ),  
  
        ),  
      ),  
    );  
  }  
}
```
# 7. 画布保存与导入
## 保存画板文件
然后我们为了方便管理文件与文件夹，我们可以使用一个配置文件来进行存储，并通过序列化保存文件树，下面来详细介绍。画布控制器中有一个方法`List<Map<String, dynamic>> getJsonList()`，通过这个方法我们可以获取当前画布的绘制json序列，我们可以对这个json处理和保存，以及后续导入这个json加载画布。
```dart
_drawingController.getJsonList()
```
## 从json导入
不同于导出json，`flutter_drawing_board`并没有具体提供一个专用方法来导入json，我们可以通过对存储的json进行处理，将json转换成Map，然后使用画布控制器的`void addContent(PaintContent content)`进行绘制。但是值得注意的是这个`PaintContent`有不同的继承，我们需要为这些继承来写不同的加载方法。下面是一个从本地json到画布呈现的实践：
```dart
_drawingBoardFile = DrawingBoardFile.fromMap(jsonDecode(await FileUtil.readFile("$path/$filePath")));  
jsonDecode(_drawingBoardFile.data).forEach((element) {  
  switch(element["type"]){  
    case "StraightLine":  
      _drawingController.addContent(StraightLine.fromJson(element));  
      break;  
    case "SimpleLine":  
      _drawingController.addContent(SimpleLine.fromJson(element));  
      break;  
    case "SmoothLine":  
      _drawingController.addContent(SmoothLine.fromJson(element));  
      break;  
    case "Eraser":  
      _drawingController.addContent(Eraser.fromJson(element));  
      break;  
    case "Rectangle":  
      _drawingController.addContent(Rectangle.fromJson(element));  
      break;  
    case "Circle":  
      _drawingController.addContent(Circle.fromJson(element));  
      break;  
  }  
});
```
我们通过对json文件的分析发现，每一步绘制都有一个`type`的属性值，这个属性值即是`PaintContent`的不同继承，我们通过分支语句，对不同的继承实现。
# 8. 文件树
## 重写`file_util`
解决如何保存画板文件和文件夹，以及管理文件树的功能。因为在Android平台非应用目录下保存文件需要更高的权限，因此我们为每一次文件读写前都加上权限检测和申请。以下是重新写好的`/utils/file_util.dart`
```dart
/**  
 *@Author: ZhanshuoBai *@CreateTime: 2025-05-15 *@Description: 文件操作工具类，确保每次读写文件前检查权限  
 *@Version: 1.0 */  
import 'dart:io';  
import 'package:path_provider/path_provider.dart';  
import 'package:permission_handler/permission_handler.dart';  
  
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
}
```
# 打包与发布
# 应用合规