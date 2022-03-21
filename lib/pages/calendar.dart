import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:executive_planner/backend/event_list.dart';

// Initialize calendar as child of Scaffold widget
class Calendar extends StatelessWidget {

  final String title;

  const Calendar(
      {Key? key,
      required this.title,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (context) => IconButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ExecutiveHomePage(title: "Home", storage: FileStorage(), events: ExecutiveHomePage.masterList)));
          }, icon: const Icon(Icons.arrow_back))),
          title: Text(title),
        ),
        body: SfCalendar(
          view: CalendarView.month,
        )
      );
  }


}

/*
TODO: Add EventList data source for Calendar so it can show stuff

class DataSource extends CalendarDataSource() {
 
}
*/