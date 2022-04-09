import 'dart:collection';

import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/backend/jason.dart';

/// Holds ALL EVENTS in the program.
final Set<Event> masterList = <Event>{};

/// Initializes the masterList to whatever is stored locally.
void initMaster() {
  readString('events').then((jason) {
    if (jason != null) {
      masterList.addAll(JasonSetEvent.fromJason(jason));
    }
  });
}

void saveMaster([Event? e]) {
  if(e == null || masterList.contains(e)) {
    write('events', masterList.toJason());
  }
}

extension Master on Set<Event> {
  EventList toEventList() {
    final EventList events = EventList();
    for(final Event e in this) {
      events.add(e);
    }
    return events;
  }
}
