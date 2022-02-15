

class Event {
  String name;
  DateTime? date;
  String? location;

  Event({this.name = "Unnamed Event"});


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
}


class EventList {
  Comparator<Event> comparator = Event.dateCompare;

  final _list = <Event>[];

  EventList() {
    _list.add(Event(name: "Boyo"));
    _list.add(Event(name: "Eugh"));
  }

  void add(Event e) {
    _list.add(e);
  }

  int get length {
    return _list.length;
  }

  Event operator [](int index) {
    return _list[index];
  }

  void sort() {
    _list.sort(comparator);
  }
}