import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:executive_planner/backend/misc.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'event_list.g.dart';

/// An enum for possible priorities. If you modify this, please also modify the
/// priorities list in Event.
enum Priority {
  none,
  low,
  medium,
  high,
  critical
}

// TODO: Add subevents and tags.
@JsonSerializable()
class Event {
  /// List of possible priorities for events; should have the same order and
  /// values as listed in the enum.
  static final List<String> priorities = ["None", "Low", "Medium", "High", "Critical"];
  /// Format for displaying dates, not including times.
  static final DateFormat dateFormat = DateFormat('MMM d, y');
  /// Format for displaying times.
  static final DateFormat timeFormat = DateFormat('hh:mm a');

  @JsonKey(required: true)
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
  HashSet<String> tags = HashSet<String>();

  Event({
    this.name = "Unnamed Event",
    this.description = "No description",
    this.priority = Priority.none});

  /// Generate an English readable date string for this object, in the correct
  /// time zone. If the time is 12:00 AM, it is assumed time was not set and
  /// it is not displayed.
  String dateString() {
    if(date == null) {
      return "No date";
    } else {
      if(date!.hour == 0 && date!.minute == 0) {
        return dateFormat.format(date!.toLocal());
      } else {
        return "${dateFormat.format(date!.toLocal())} ${timeFormat.format(date!.toLocal())}";
      }
    }
  }

  /// Add a tag to the event
  bool addTag(String tag) {
    return tags.add(tag);
  }

  /// Returns if a particular tag is stored in this event
  bool hasTag(String tag) {
    if(tags.contains(tag)) {
      return true;
    }
    return false;
  }

  /// Remove a tag from the event, and returns whether the event was correctly removed or not.
  bool removeTag(String tag) {
    return tags.remove(tag);
  }

  String tagsString() {
    String build = "";
    for(String tag in tags) {
      build += tag + ", ";
    }
    return build.substring(0, build.length-2);
  }

  /// Sorts events by date, then name. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int dateCompare(Event a, Event b) {
    if(a.date != null && b.date != null) {
      int before = a.date!.compareTo(b.date!);
      if (before != 0) return before;
    }
    if(a.date != null && b.date == null) {
      return -1;
    }
    if(a.date == null && b.date != null) {
      return 1;
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// Automatically generated JSON function, in event_list.g.dart.
  /// Run build_runner to regenerate.
  /// Make sure that this does not break if you add new data to Event!
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  /// Automatically generated JSON function, in event_list.g.dart.
  /// Run build_runner to regenerate.
  /// Make sure that this does not break if you add new data to Event!
  Map<String, dynamic> toJson() => _$EventToJson(this);
}

// TODO: Add the 54 methods that would allow this to actually extend List.
class EventList {

  final _list = <Event>[];
  Comparator<Event> sortFunc = Event.dateCompare;

  EventList();

  /// Add an event to the list.
  void add(Event e) {
    _list.add(e);
    _sort();
  }

  /// Remove an event from the list.
  void remove(Event e) {
    _list.remove(e);
  }

  bool contains(Event e) {
    for(Event event in _list) {
      if(e == event) {
        return true;
      }
    }
    return false;
  }

  /// The length of the list.
  int get length {
    return _list.length;
  }

  Event operator[](int index) {
    return _list[index];
  }

  /// Adds all events in e to the current list.
  void combine(EventList e) {
    for(int i = 0; i < e.length; i++) {
      _list.add(e[i]);
    }
    _sort();
  }

  /// Sorts list by event comparator. Various sorts can be found in the Event
  /// class. Should be called automatically when the list is modified.
  void _sort() {
    _list.sort(sortFunc);
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchName(String searchStr) {
    EventList part = EventList();
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
        part.add(_list[i]);
      }
    }
    return part;
  }

  /// Return an EventList containing events on a specific date or time
  EventList searchDate(DateTime date) {
    EventList part = EventList();

    if(date.hour == 0 && date.minute == 0) {
      for (int i = 0; i < _list.length; i++) {
        if(date.isSameDate(_list[i].date)) {
          part.add(_list[i]);
        }
      }
    } else {
      for (int i = 0; i < _list.length; i++) {
        if(date.isSameMoment(_list[i].date)) {
          part.add(_list[i]);
        }
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have a specific tag.
  EventList searchTags(String searchStr) {
    searchStr = searchStr.toTitleCase();
    EventList part = EventList();
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].hasTag(searchStr.toTitleCase())) {
        part.add(_list[i]);
      }
    }
    return part;
  }

  /// Manually created JSON function. Events are assumed to have names of event-1,
  /// event-2, etc.
  factory EventList.fromJson(Map<String, dynamic> json) {
    $checkKeys(
      json,
    );

    EventList list = EventList();
    int i = 0;
    while(json["event-$i"] != null) {
      list.toJson();
      list.add(Event.fromJson(json["event-$i"]));
      i++;
    }
    return list;
  }
  /// Manually created JSON function. Events are given names of event-1, event-2, etc.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    for(int i = 0; i < _list.length; i++){
      json["event-$i"] = _list[i].toJson();
    }
    return json;
  }
}