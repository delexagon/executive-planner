
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/backend/recurrence.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:intl/intl.dart';

/// An enum for possible priorities. If you modify this, please also modify the
/// priorities list in Event.
enum Priority { none, low, medium, high, critical }

class Event {

  Event({
    String name = 'Unnamed Event', DateTime? date, String description = 'No description',
    Priority priority = Priority.none, TagList? tags, Recurrence? recur,}) {
    _name = name;
    _date = date;
    _description = description;
    _priority = priority;
    _recur = recur;
    if(tags != null) {
      this.tags = tags;
    }
  }

  Event.copy(Event other) {
    _name = other._name;
    _date = other._date;
    _description = other._description;
    _priority = other._priority;
    tags.mergeTagLists(other.tags, onAdd: onAdd);
    if(other.recur != null) {
      recur = Recurrence.copy(other.recur!);
    } else {
      recur = null;
    }
  }

  static final List<String> specialTags = ['Recurring'];

  void onAdd(String tag) {
    masterList.addTag(tag, this);
  }

  void onRemove(String tag) {
    masterList.removeTag(tag, this);
  }

  void copy(Event other) {
    _name = other._name;
    _date = other._date;
    _description = other._description;
    _priority = other._priority;
    for(final String tag in tags.asSet()) {
      onRemove(tag);
    }
    tags = TagList();
    tags.mergeTagLists(other.tags, onAdd: onAdd);
    if(other.recur != null) {
      recur = Recurrence.copy(other.recur!);
    } else {
      recur = null;
    }
    masterList.saveMaster(this);
  }

  void integrate(MassEditor other) {
    if(other.changes[0]) {
      _name = other._name;
    }
    if(other.changes[1]) {
      _description = other._description;
    }
    if(other.changes[2]) {
      _date = other._date;
    }
    if(other.changes[3]) {
      _priority = other._priority;
    }
    if(other.changes[4]) {
      if(other.recur != null) {
        recur = Recurrence.copy(other.recur!);
      } else {
        recur = null;
      }
    } else {
      tags.removeTag('Recurring');
    }
    tags.removeAllTags(other.tagsRemove, onRemove: onRemove);
    tags.mergeTagLists(other.tags, onAdd: onAdd);
    masterList.saveMaster(this);
  }

  void update() {
    if (date != null && DateTime.now().isAfter(date!)) {
      addTag('Overdue');
      priority = Priority.critical;
      masterList.saveMaster(this);
    }
  }

  void complete() {
    if(recur == null || date == null) {
      addTag('Completed', special: true);
    } else {
      date = recur!.getNextRecurrence(date!);
    }
    masterList.saveMaster(this);
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
  String _name = 'Unnamed Event';
  set name(String name) {
    _name = name;
    masterList.saveMaster(this);
  }
  String get name {
    return _name;
  }

  /// The date of the event IN UTC. Use .toLocal to transform it to local time.
  DateTime? _date;
  set date(DateTime? date) {
    _date = date;
    masterList.saveMaster(this);
  }
  DateTime? get date {
    return _date;
  }

  /// A description of the event.
  String _description = 'No description';
  set description(String description) {
    _description = description;
    masterList.saveMaster(this);
  }
  String get description {
    return _description;
  }

  /// The priority of the event (low, medium, high, or critical).
  Priority _priority = Priority.none;
  set priority(Priority priority) {
    _priority = priority;
    masterList.saveMaster(this);
  }
  Priority get priority {
    return _priority;
  }
  // TODO: Add JSON for subevents
  EventList subevents = EventList();

  /// A list of tags of this event.
  /// Tags will be automatically formatted with toTitleCase when added to this list;
  /// make sure you are aware of this when modifying functions in Event!
  TagList tags = TagList(tags: {});

  Recurrence? _recur;
  set recur(Recurrence? recurrence) {
    if(recurrence != null) {
      addTag('Recurring', special: true);
    } else {
      removeTag('Recurring', special: true);
    }
    _recur = recurrence;
    masterList.saveMaster(this);
  }
  Recurrence? get recur {
    return _recur;
  }

  String timeString() {
    if(date == null || date!.hour == 0 && date!.minute == 0) {
      return '';
    }
    return timeFormat.format(date!.toLocal());
  }

  /// Generate an English readable date string for this object, in the correct
  /// time zone. If the time is 12:00 AM, it is assumed time was not set and
  /// it is not displayed.
  String dateString() {
    if (date == null) {
      return 'Reminder';
    } else {
      if (date!.hour == 0 && date!.minute == 0) {
        return dateFormat.format(date!.toLocal());
      } else {
        return '${dateFormat.format(date!.toLocal())} ${timeString()}';
      }
    }
  }

  /// Add a tag to the event
  bool addTag(String tag, {bool special = false}) {
    if(!special && specialTags.contains(tag)) {
      return false;
    }
    final bool ret = tags.addTag(tag, onAdd: onAdd);
    masterList.saveMaster(this);
    return ret;
  }

  /// Returns if a particular tag is stored in this event
  bool hasTag(String tag) {
    return tags.hasTag(tag);
  }

  /// Remove a tag from the event, and returns whether the event was correctly removed or not.
  bool removeTag(String tag, {bool special = false}) {
    if(!special && (tag == 'Recurring' || tag == 'Completed')) {
      return false;
    }
    final bool ret = tags.removeTag(tag, onRemove: onRemove);
    masterList.saveMaster(this);
    return ret;
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

class MassEditor extends Event {
  MassEditor(Event e, this.tagsRemove, this.changes, {required this.markForDeletion}) {
    super.copy(e);
  }

  bool markForDeletion;
  List<bool> changes;

  TagList tagsRemove;
}

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
  void sort() {
    list.sort(sortFunc);
  }

  Set<Event> toSet() {
    return list.toSet();
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchName(String searchStr, {bool appears = true}) {
    final EventList part = EventList();
    if(appears) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
          part.add(list[i]);
        }
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        if (!list[i].name.toLowerCase().contains(searchStr.toLowerCase())) {
          part.add(list[i]);
        }
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchDescription(String searchStr, {bool appears = true}) {
    final EventList part = EventList();
    if(appears) {
      for (int i = 0; i < list.length; i++) {
        if (list[i].description.toLowerCase().contains(searchStr.toLowerCase())) {
          part.add(list[i]);
        }
      }
    } else {
      for (int i = 0; i < list.length; i++) {
        if (!list[i].description.toLowerCase().contains(searchStr.toLowerCase())) {
          part.add(list[i]);
        }
      }
    }
    return part;
  }

  /// Return an EventList containing the events that have searchStr in their name.
  EventList searchPriority(Priority priority, {bool appears = true}) {
    final EventList part = EventList();
    if(appears) {
      for(int i = 0; i < list.length; i++) {
        if(list[i].priority == priority) {
          part.add(list[i]);
        }
      }
    } else {
      for(int i = 0; i < list.length; i++) {
        if(!(list[i].priority == priority)) {
          part.add(list[i]);
        }
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
  EventList searchTags(String s, {bool appears = true}) {
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
}
