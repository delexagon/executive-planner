import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'event_list.g.dart';

@JsonSerializable()
class Event {
  static final DateFormat dateFormat = DateFormat('MMM d, y hh:mm a');

  @JsonKey(required: true)
  String name;
  // The date of the event IN UTC. Use .toLocal to transform it to local time.
  DateTime? date;
  String? location;

  Event({this.name = "Unnamed Event"});

  String dateString() {
    if(date == null) {
      return "No date";
    } else {
      return dateFormat.format(date!.toLocal());
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

    return a.name.compareTo(b.name);
  }

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}

class EventList {
  Comparator<Event> comparator = Event.dateCompare;

  final _list = <Event>[];

  EventList();

  void add(Event e) {
    _list.add(e);
  }

  int get length {
    return _list.length;
  }

  Event operator [](int index) {
    return _list[index];
  }

  void combine(EventList e) {
    for(int i = 0; i < e.length; i++) {
      _list.add(e[i]);
    }
  }

  void sort() {
    _list.sort(comparator);
  }

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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    for(int i = 0; i < _list.length; i++){
      json["event-$i"] = _list[i].toJson();
    }
    return json;
  }
}