
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/backend/misc.dart';

class EventList {

  EventList({List<Event>? list, this.managed = false}) {
    if(list != null) {
      this.list = list;
    }
    if(managed) {
      masterList.manageEventList(this);
    }
  }

  List<Event> list = <Event>[];
  static Comparator<Event> sortFunc = Event.dateCompare;
  bool managed;

  /// Add an event to the list.
  void add(Event e) {
    list.add(e);
    sort();
  }

  void clear() {
    list.clear();
  }

  EventList noDate() {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].date == null) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Remove an event from the list.
  void remove(Event e) {
    list.remove(e);
  }

  bool contains(Event e) {
    for (final Event event in list) {
      if (e == event) {
        return true;
      }
    }
    return false;
  }

  /// The length of the list.
  int get length {
    return list.length;
  }

  Event operator [](int index) {
    return list[index];
  }

  /// Returns stored events as List<Event>
  List<Event> asList() {
    return list;
  }

  /// Adds all events in e to the current list, and returns it.
  /// This modifies the list you use it on!
  EventList union(EventList e) {
    for (int i = 0; i < e.length; i++) {
      list.add(e[i]);
    }
    sort();
    return this;
  }

  /// This function is not Master safe, do not use on persistent events.
  void removeAll(EventList other) {
    if(this == other) {
      list = <Event>[];
    }
    for(final Event e in other.list) {
      list.remove(e);
    }
  }

  /// Adds all events in e to the current list, and returns it.
  /// This modifies the list you use it on!
  EventList intersection(EventList e) {
    for(final Event event in list) {
      if(!e.contains(event)) {
        list.remove(event);
      }
    }
    return this;
  }

  /// Sorts list by event comparator. Various sorts can be found in the Event
  /// class. Should be called automatically when the list is modified.
  EventList sort() {
    list.sort(sortFunc);
    return this;
  }

  Set<Event> toSet() {
    return list.toSet();
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchName(String searchStr, {bool appears = true}) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchCompleted() {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].isComplete) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchDescription(String searchStr) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].description.toLowerCase().contains(searchStr.toLowerCase())) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchPriority(Priority priority) {
    final EventList part = EventList();
    for(int i = 0; i < list.length; i++) {
      if(list[i].priority == priority) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchRecurrence() {
    final EventList part = EventList();
    for(int i = 0; i < list.length; i++) {
      if(list[i].recur != null) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing events on a specific date
  EventList searchDate(DateTime date) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (date.isSameDate(list[i].date)) {
        part.add(list[i]);
      }
    }
    return part;
  }

  EventList searchBefore(DateTime endDate) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].date != null && endDate.isAfter(list[i].date!)) {
        part.add(list[i]);
      }
    }
    return part;
  }

  EventList searchRange(DateTime startDate, DateTime endDate) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].date != null && startDate.isBefore(list[i].date!) &&
          endDate.isAfter(list[i].date!)) {
        part.add(list[i]);
      }
    }
    return part;
  }

  void update() {
    for (final Event event in list) {
      event.update();
    }
  }

  /// Return an EventList containing the events that have a specific tag.
  EventList searchTags(String s) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].hasTag(s)) {
        part.add(list[i]);
      }
    }
    return part;
  }
}
