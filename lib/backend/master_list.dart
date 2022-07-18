
import 'dart:collection';

import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/backend/jason.dart';
import 'package:executive_planner/pages/home_page.dart';


// ignore: avoid_classes_with_only_static_members, camel_case_types
class masterList {
  /// Holds ALL EVENTS in the program.
  static Set<Event> _masterList = <Event>{};
  static final HashMap<String, int> _masterTagList = HashMap<String, int>();
  static late final ExecutiveHomePage rootWidget;

  static void init() {
    final EventList allEvents = EventList();
    rootWidget = ExecutiveHomePage(
      title: 'Planner',
      events: allEvents,
      showCompleted: false,
      onEventListChanged: (Event? e) {
        saveMaster();
      },
      headlist: allEvents,
    );
    masterList.initMaster();
  }

  static void update() {
    for(final Event e in _masterList) {
      e.update();
    }
  }

  static bool hasEvent(Event e) {
    return _masterList.contains(e);
  }

  static void addTag(String t, Event e) {
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
    e.removeThis();
    e.headlist = null;
    for(final String tag in e.tags.asStringList()) {
      removeTag(tag, e);
    }
    _masterList.remove(e);
    saveMaster();
  }

  static void clear() {
    rootWidget.events.clear();
    _masterList.clear();
    _masterTagList.clear();
  }

  static EventList toEventList() {
    return _masterList.toEventList();
  }

  /// Initializes the masterList to whatever is stored locally.
  static void initMaster([String location = 'events']) {
    readString(location).then((jason) {
      if (jason != null) {
        loadMaster(jason);
      }
    });
  }

  static void loadMaster(String jason,) {
    clear();
    _masterList = JasonSetEvent.fromJason(jason);
    for(final Event e in _masterList) {
      rootWidget.events.add(e);
      e.headlist = rootWidget.events;
      for(final String tag in e.tags.asStringList()) {
        addTag(tag, e);
      }
    }
  }

  static String toJason() {
    return _masterList.toJason();
  }

  static void saveMaster([Event? e, String location = 'events']) {
    if(e == null || _masterList.contains(e)) {
      write(location, toJason());
    }
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
