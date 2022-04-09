import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/pages/home_page.dart';
import 'package:flutter/material.dart';

/// The entry point of the application.
///
/// Generates an [ExecutivePlanner] [StatelessWidget] which holds everything else.
void main() {
  initMaster();
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
        '/': (context) => ExecutiveHomePage(
              title: 'Planner',
              events: EventList().union(masterList.toEventList()).searchTags('Completed', appears: false),
              isRoot: true,
            ),
      },
      
    );
  }
}
