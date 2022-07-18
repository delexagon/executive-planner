
import 'package:executive_planner/backend/master_list.dart';
import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// Generates an [ExecutivePlanner] [StatelessWidget] which holds everything else.
void main() {
  // TODO: Update the eventlist every few minutes or something
  masterList.init();
  runApp(const ExecutivePlanner());
}

/// Generates a [MaterialApp] which is needed to format all program data, and
/// initializes the home page.
class ExecutivePlanner extends StatelessWidget {
  const ExecutivePlanner({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planner',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/': (context) => masterList.rootWidget,
      },
    );
  }
}
