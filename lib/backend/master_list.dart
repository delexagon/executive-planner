import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/backend/jason.dart';

/// Holds ALL EVENTS in the program.
final EventList masterList = EventList();

/// Initializes the masterList to whatever is stored locally.
void initMaster() {
  readString('events').then((jason) {
    if (jason != null) {
      final EventList events =
        JasonEventList.fromJason(jason);
        masterList.union(events);
    }
  });
}

void saveMaster() {
  write('events', masterList.toJason());
}