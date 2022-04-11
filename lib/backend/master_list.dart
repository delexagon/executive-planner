
import 'dart:collection';

import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/backend/jason.dart';

import 'package:executive_planner/pages/home_page.dart';


// ignore: avoid_classes_with_only_static_members, camel_case_types
class masterList {
  /// Holds ALL EVENTS in the program.
  static Set<Event> _masterList = <Event>{};
  static final HashMap<String, int> _masterTagList = HashMap<String, int>();
  static final HashMap<EventList, int> _eventListList = HashMap<EventList, int>();
  static final ExecutiveHomePage rootWidget = ExecutiveHomePage(
    title: 'Planner',
    events: EventList(),
  );

  static void update() {
    for(final Event e in _masterList) {
      e.update();
    }
  }

  static void clearManaged() {
    _eventListList.clear();
    manageEventList(rootWidget.events);
  }

  static bool hasEvent(Event e) {
    return _masterList.contains(e);
  }

  static void addTag(String t, Event e) {
    if(Event.specialTags.contains(t)) {
      return;
    }
    if(_masterList.contains(e)) {
      if(_masterTagList.containsKey(t)) {
        _masterTagList[t] = _masterTagList[t]! + 1;
      } else {
        _masterTagList[t] = 1;
      }
    }
  }

  static void removeTag(String t, Event e) {
    if(_masterList.contains(e)) {
      if(_masterTagList.containsKey(t)) {
        _masterTagList[t] = _masterTagList[t]! - 1;
        if(_masterTagList[t] == 0) {
          _masterTagList.remove(t);
        }
      }
    }
  }

  static bool hasTag(String tag) {
    return _masterTagList.containsKey(tag);
  }

  static Iterable<String> tags() {
    return _masterTagList.keys;
  }

  // Returns a list of Tags matching a partial string query
  static Set<String> queryTags(String str) {
    return _masterTagList.keys.where((tag) {
      return tag.toLowerCase().startsWith(str.toLowerCase());
    }).toSet();
  }

  static void add(Event e) {
    _masterList.add(e);
    saveMaster();
    for(final String tag in e.tags.asStringList()) {
      addTag(tag, e);
    }
  }

  static void remove(Event e) {
    for(final String tag in e.tags.asStringList()) {
      removeTag(tag, e);
    }
    _masterList.remove(e);
    saveMaster();
    for(final EventList list in _eventListList.keys) {
      list.remove(e);
    }
  }

  static void clear() {
    _masterList.clear();
    _masterTagList.clear();
    for(final EventList e in _eventListList.keys) {
      e.clear();
    }
  }

  static EventList toEventList() {
    return _masterList.toEventList();
  }

  /// The masterList will automatically delete events in all managed lists throughout the program.
  /// Make sure to use removeManagedEventList in any path returning from the page you use it in.
  static void manageEventList(EventList e) {
    if(!_eventListList.containsKey(e)) {
      _eventListList[e] = 1;
    } else {
      _eventListList[e] = _eventListList[e]! + 1;
    }
  }

  static void removeManagedEventList(EventList e) {
    if(_eventListList.containsKey(e)) {
      _eventListList[e] = _eventListList[e]! - 1;
      if(_eventListList[e] == 0) {
        _eventListList.remove(e);
      }
    }
  }

  /// Initializes the masterList to whatever is stored locally.
  static void initMaster() {
    readString('events').then((jason) {
      if (jason != null) {
        loadMaster(jason);
      }
    });
  }

  static void loadMaster(String jason) {
    clear();
    _masterList = JasonSetEvent.fromJason(jason);
    for(final Event e in _masterList) {
      for(final String tag in e.tags.asStringList()) {
        addTag(tag, e);
      }
    }
  }

  static String toJason() {
    return _masterList.toJason();
  }

  static void saveMaster([Event? e]) {
    if(e == null || _masterList.contains(e)) {
      write('events', toJason());
    }
  }
}


// ignore: avoid_classes_with_only_static_members, camel_case_types
class optionsStorage {

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
