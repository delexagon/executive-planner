
import 'dart:convert';

import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:intl/intl.dart';

/// An enum for possible priorities. If you modify this, please also modify the
/// priorities list in Event.
enum Priority { none, low, medium, high, critical }

// TODO: Add subevents and tags.
class Event {

  Event({
    this.name = 'Unnamed Event', this.date, this.description = 'No description',
    this.priority = Priority.none, TagList? tags,}) {
    if(tags != null) {
      this.tags = tags;
    }
  }

  void update() {
    if (date != null && DateTime.now().isAfter(date!)) {
      addTag('Overdue');
      priority = Priority.critical;
    }
  }

  /// List of possible priorities for events; should have the same order and
  /// values as listed in the enum.
  static final List<String> priorities = [
    'None',
    'Low',
    'Medium',
    'High',
    'Critical'
  ];

  /// Format for displaying dates, not including times.
  static final DateFormat dateFormat = DateFormat('MMM d, y');

  /// Format for displaying times.
  static final DateFormat timeFormat = DateFormat('hh:mm a');

  /// The name of the event. Default is Unnamed Event.
  String name;

  /// The date of the event IN UTC. Use .toLocal to transform it to local time.
  DateTime? date;

  /// A description of the event.
  String description;

  /// The priority of the event (low, medium, high, or critical).
  Priority priority;
  // TODO: Add JSON for subevents
  EventList subevents = EventList();

  /// A list of tags of this event.
  /// Tags will be automatically formatted with toTitleCase when added to this list;
  /// make sure you are aware of this when modifying functions in Event!
  TagList tags = TagList(tags: []);

  

  /// Generate an English readable date string for this object, in the correct
  /// time zone. If the time is 12:00 AM, it is assumed time was not set and
  /// it is not displayed.
  String dateString() {
    if (date == null) {
      return 'No date';
    } else {
      if (date!.hour == 0 && date!.minute == 0) {
        return dateFormat.format(date!.toLocal());
      } else {
        return '${dateFormat.format(date!.toLocal())} ${timeFormat.format(date!.toLocal())}';
      }
    }
  }

  /// Add a tag to the event
  bool addTag(String tag) {
    return tags.addTag(tag);
  }

  bool addEventTag(EventTag tag) {
    return tags.addEventTag(tag);
  }

  /// Returns if a particular tag is stored in this event
  bool hasTag(String tag) {
    return tags.hasTag(tag);
  }

  /// Remove a tag from the event, and returns whether the event was correctly removed or not.
  bool removeTag(String tag) {
    return tags.removeTag(tag);
  }

  String tagsString() {
    return tags.asString();
  }
  
  TagList getTags() {
    return tags;
  }

  /// Sorts events by date, then priority, then name. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int dateCompare(Event a, Event b) {
    if (a.date != null && b.date != null) {
      final int before = a.date!.compareTo(b.date!);
      if (before != 0) return before;
    }
    if (a.date != null && b.date == null) {
      return -1;
    }
    if (a.date == null && b.date != null) {
      return 1;
    }
    final int priority = b.priority.index - a.priority.index;
    if (priority != 0) {
      return priority;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// Sorts events by priority, then date, then name. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int priorityCompare(Event a, Event b) {
    final int priority = b.priority.index - a.priority.index;
    if (priority != 0) {
      return priority;
    }
    if (a.date != null && b.date != null) {
      final int before = a.date!.compareTo(b.date!);
      if (before != 0) return before;
    }
    if (a.date != null && b.date == null) {
      return -1;
    }
    if (a.date == null && b.date != null) {
      return 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// Sorts events by name, then priority, then date. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int nameCompare(Event a, Event b) {
    final int name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (name != 0) {
      return name;
    }
    final int priority = b.priority.index - a.priority.index;
    if (priority != 0) {
      return priority;
    }
    if (a.date != null && b.date != null) {
      final int before = a.date!.compareTo(b.date!);
      if (before != 0) return before;
    }
    if (a.date != null && b.date == null) {
      return -1;
    }
    if (a.date == null && b.date != null) {
      return 1;
    }
    return 0;
  }

}

// TODO: Add the 54 methods that would allow this to actually extend List.
class EventList {

  EventList({List<Event>? list, TagList? allTags}) {
    if(list != null) {
      this.list = list;
    }
    if(allTags != null) {
      this.allTags = allTags;
    }
  }

  List<Event> list = <Event>[];
  Comparator<Event> sortFunc = Event.dateCompare;
  TagList allTags = TagList(tags: []);

  void addTagToMasterList(String tag) {
    allTags.addTag(tag);
  }

  TagList getTagMasterList() {
    return allTags;
  }



  /// Add an event to the list.
  void add(Event e) {
    list.add(e);
    sort();
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

  /// Adds all events in e to the current list, and returns it.
  /// This modifies the list you use it on!
  EventList removeAll(EventList e) {
    for (final Event event in list) {
      if (e.contains(event)) {
        list.remove(event);
      }
    }
    sort();
    return EventList();
  }

  /// Sorts list by event comparator. Various sorts can be found in the Event
  /// class. Should be called automatically when the list is modified.
  void sort() {
    list.sort(sortFunc);
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchName(String searchStr) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
        part.add(list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing events on a specific date or time
  EventList searchDate(DateTime date) {
    final EventList part = EventList();

    if (date.hour == 0 && date.minute == 0) {
      for (int i = 0; i < list.length; i++) {
        if (date.isSameDate(list[i].date)) {
          part.add(list[i]);
        }
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        if (date.isSameMoment(list[i].date)) {
          part.add(list[i]);
        }
      }
    }
    return part;
  }

  EventList searchRange(DateTime startDate, DateTime endDate) {
    final EventList part = EventList();
    for (int i = 0; i < list.length; i++) {
      if (startDate.isBefore(list[i].date!) &&
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
  // ignore: avoid_positional_boolean_parameters
  EventList searchTags(String s, [bool appears = true]) {
    final String searchStr = s.toTitleCase();
    final EventList part = EventList();
    if (appears) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].hasTag(searchStr.toTitleCase())) {
          part.add(list[i]);
        }
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        if (!list[i].hasTag(searchStr.toTitleCase())) {
          part.add(list[i]);
        }
      }
    }
    return part;
  }

  // Returns a list of ALL tags associated with events.
  TagList getAllTags() {
    final TagList tags = TagList(tags: []);
    for (final Event event in list) {
      tags.mergeTagLists(event.getTags());
    }
    return tags;
  }
}
