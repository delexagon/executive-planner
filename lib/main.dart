import 'package:flutter/material.dart';

import 'package:executive_planner/file_io.dart';
import 'package:executive_planner/pages/home_page.dart';

void main() {
  ExecutiveHomePage.initMaster();
  runApp(const ExecutivePlanner());
}

class ExecutivePlanner extends StatelessWidget {
  const ExecutivePlanner({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planner',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: ExecutiveHomePage(title: 'Planner', storage: FileStorage(),
        events: ExecutiveHomePage.masterList,),
    );
  }
}
