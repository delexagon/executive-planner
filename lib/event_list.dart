import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'event_list.g.dart';

// TODO: Add subevents and tags.
@JsonSerializable()
class Event {
  /// Format for displaying dates, not including times.
  static final DateFormat dateFormat = DateFormat('MMM d, y');
  /// Format for displaying times.
  static final DateFormat timeFormat = DateFormat('hh:mm a');

  @JsonKey(required: true)
  /// The name of the event. Default is Unnamed Event.
  String name;
  /// The date of the event IN UTC. Use .toLocal to transform it to local time.
  DateTime? date;
  /// The location of the event, if entered. This is not yet handled or displayed.
  String? location;
  /// The sub-events of this event.
  final EventList _subevents = EventList();

  Event({this.name = "Unnamed Event"});

  EventList get subevents {
    return _subevents;
  }

  /// Generate an English readable date string for this object. If the time is
  /// 12:00 AM, it is assumed time was not set and it is not displayed.
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

  EventList();

  /// Add an event to the list.
  void add(Event e) {
    _list.add(e);
  }

  /// Remove an event from the list.
  void remove(Event e) {
    _list.remove(e);
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
  }

  /// Sorts list by given comparator. Various sorts can be found in the Event
  /// class.
  void sort(Comparator<Event> compare) {
    _list.sort(compare);
  }

  // TODO: Add more types of search.
  /// Return an EventList containing the strings that have searchStr in their name.
  EventList search(String searchStr) {
    EventList part = EventList();
    for(int i = 0; i < _list.length; i++) {
      if(_list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
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