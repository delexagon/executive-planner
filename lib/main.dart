
import 'dart:async';

import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/pages/home_page.dart';
import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// Generates an [ExecutivePlanner] [StatelessWidget] which holds everything else.
void main() {
  ListObserver.top = ListObserver();
  ListObserver.top.notify(NotificationType.loadFile);
  Timer.periodic(const Duration(minutes: 1), (timer) {ListObserver.top.notify(NotificationType.update);});
  runApp(const ExecutivePlanner());
}

/// Generates a [MaterialApp] which is needed to format all program data, and
/// initializes the home page.
class ExecutivePlanner extends StatelessWidget {
  const ExecutivePlanner({Key? key}) : super(key: key);
  // This widget is the root of your application.
  static late final ExecutiveHomePage top;

  @override
  Widget build(BuildContext context) {
    top = ExecutiveHomePage(
      title: 'Planner',
      events: ListObserver.top.makeList(),
      showCompleted: false,
      headlist: ListObserver.top,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planner',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/': (context) => top,
      },
    );
  }
}
