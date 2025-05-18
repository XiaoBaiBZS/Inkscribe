/*
 * Copyright (C) 2023-2025 moluopro. All rights reserved.
 * Github: https://github.com/moluopro
 */

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';


class MyBrowser extends StatefulWidget {
  const MyBrowser({super.key, this.title});
  final String? title;

  @override
  MyBrowserState createState() => MyBrowserState();
}

class MyBrowserState extends State<MyBrowser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body:PdfViewer.file("/storage/emulated/0/Download/WeiXin/你好.pdf"),
      body:PdfViewer.file("C:/Users/12985/Downloads/你好.pdf"),
    );
  }
}