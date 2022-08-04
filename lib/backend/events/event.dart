
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/backend/jason.dart';
import 'package:executive_planner/backend/recurrence.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:intl/intl.dart';

/// An enum for possible priorities. If you modify this, please also modify the
/// priorities list in Event.
enum Priority { none, low, medium, high, critical }

class Event {
  /// Create an event. Subevents are NOT added here; do so manually
  Event({
    String name = 'Unnamed Event', DateTime? date, String description = 'No description',
    Priority priority = Priority.none, TagList? tags, Recurrence? recur, DateTime? completed, ListObserver? subevents,}) {
    _name = name;
    _date = date;
    _description = description;
    _priority = priority;
    _recur = recur;
    _completedDate = completed;
    if(subevents != null) {
      this.subevents = subevents;
    } else {
      this.subevents = ListObserver();
    }
    if(tags != null) {
      this.tags = tags;
    }
  }

  /// Get a new event that's a copy of the first one, including subevents
  factory Event.copy(Event other) {
    return JasonEvent.fromJason(other.toJason());
  }

  /// Determines whether the event is marked as completed
  DateTime? _completedDate;

  DateTime? get completedDate {
    return _completedDate;
  }

  /// Get whether the event is completed
  // TODO: Migrate this to a more general 'hide' marker'
  bool get isComplete {
    return _completedDate != null;
  }

  /// Do not touch this manually, it should only be modified in ListObserver code
  ListObserver? observer;

  /// Adds a subevent to this event
  void addSubevent(Event e) {
    subevents.notify(NotificationType.eventAdd, event: e);
  }

  /// Copies another event into an event that already exists.
  void copy(Event other) {
    _name = other._name;
    _date = other._date;
    _description = other._description;
    _priority = other._priority;
    _completedDate = other._completedDate;

    observer?.unsetTags(this);
    final TagList newTags = TagList();
    tags = newTags;
    tags.mergeTagLists(other.tags);
    observer?.resetTags(this);

    if(other.recur != null) {
      recur = Recurrence.copy(other.recur!);
    } else {
      recur = null;
    }
    observer?.notify(NotificationType.eventsChanged);
  }

  /// Integrates a MassEditor object into an event, including removing and adding tags.
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
    }
    observer?.unsetTags(this);
    tags.removeAllTags(other.tagsRemove);
    tags.mergeTagLists(other.tags);
    observer?.resetTags(this);
    observer?.notify(NotificationType.eventsChanged);
  }

  void update() {
    final DateTime now = DateTime.now().toUtc();
    if(date != null && date!.isBefore(now)) {
      if(!isComplete) {
        if(recur != null && !recur!.isZero()) {
          while(date!.isBefore(now)) {
            date = recur!.getNextRecurrence(date!);
          }
        } else {
          addTag('Overdue');
        }
      } else {
        if(_completedDate!.add(const Duration(days: 7)).isBefore(DateTime.now())) {
          observer?.notify(NotificationType.eventRemove, event: this);
        }
      }
    }
    subevents.notify(NotificationType.update);
  }

  void complete() {
    if(recur == null || date == null) {
      if(_completedDate != null) {
        _completedDate = null;
      } else {
        _completedDate = DateTime.now();
      }
    } else {
      date = recur!.getNextRecurrence(date!);
    }
    observer?.notify(NotificationType.eventsChanged, orderChange: false);
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
    observer?.notify(NotificationType.eventsChanged);
  }
  String get name {
    return _name;
  }

  /// The date of the event IN UTC. Use .toLocal to transform it to local time.
  DateTime? _date;
  set date(DateTime? date) {
    _date = date;
    observer?.notify(NotificationType.eventsChanged);
  }
  DateTime? get date {
    return _date;
  }

  /// A description of the event.
  String _description = 'No description';
  set description(String description) {
    _description = description;
    observer?.notify(NotificationType.eventsChanged, orderChange: false);
  }
  String get description {
    return _description;
  }

  /// The priority of the event (low, medium, high, or critical).
  Priority _priority = Priority.none;
  set priority(Priority priority) {
    _priority = priority;
    observer?.notify(NotificationType.eventsChanged);
  }
  Priority get priority {
    return _priority;
  }

  /// The observer for the subevents. Use this when changing subevents, do not modify
  /// events directly.
  late ListObserver subevents;

  /// A list of tags of this event.
  /// Tags will be automatically formatted with toTitleCase when added to this list;
  /// make sure you are aware of this when modifying functions in Event!
  TagList tags = TagList(tags: {});

  Recurrence? _recur;
  set recur(Recurrence? recurrence) {
    _recur = recurrence;
    observer?.notify(NotificationType.eventsChanged, orderChange: false);
  }
  Recurrence? get recur {
    return _recur;
  }

  /// The time string displayed on the event.
  /// Minutes are not displayed on the default time; 11:59 PM.
  String timeString() {
    if(date == null || (date!.hour == 23 && date!.minute == 59)) {
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
      return '${dateFormat.format(date!.toLocal())} ${timeString()}';
    }
  }

  /// Add a tag to the event
  void addTag(String tag) {
    if(observer != null) {
      observer!.notify(NotificationType.eventAddTag, event: this, tag: tag);
    } else {
      tags.addTag(tag);
    }
  }

  /// Remove a tag from the event, and returns whether the event was correctly removed or not.
  void removeTag(String tag) {
    if(observer != null) {
      observer!.notify(NotificationType.eventRemoveTag, event: this, tag: tag);
    } else {
      tags.removeTag(tag);
    }
  }

  /// Returns if a particular tag is stored in this event
  bool hasTag(String tag) {
    return tags.hasTag(tag);
  }

  /// The string of the tags.
  String tagsString() {
    return tags.asString();
  }

  /// Get the subtitle string that this event has when printing to the app.
  String subtitleString({bool descMode = false}) {
    final StringBuffer subtitleString = StringBuffer();
    if(!descMode) {
      subtitleString.write(dateString());
      if(recur != null) {
        subtitleString.write('\n${recur!.toString()}');
      }
      if(tags.isNotEmpty) {
        subtitleString.write('\nTags: ${tagsString()}');
      }
    } else {
      subtitleString.write(description);
    }
    if(isComplete) {
      subtitleString.write('\nCompleted');
    }
    return subtitleString.toString();
  }

  /// Sorts events by date, then priority, then name. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int dateCompare(Event a, Event b) {
    if(a.hasTag('Leading') || b.hasTag('Leading')) {
      if(a.hasTag('Leading') && !b.hasTag('Leading')) {
        return -1;
      } else if(!a.hasTag('Leading') && b.hasTag('Leading')) {
        return 1;
      }
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
    if(a.hasTag('Leading') || b.hasTag('Leading')) {
      if(a.hasTag('Leading') && !b.hasTag('Leading')) {
        return -1;
      } else if(!a.hasTag('Leading') && b.hasTag('Leading')) {
        return 1;
      }
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
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// Sorts events by name, then priority, then date. Events with a null date are placed after
  /// those with a defined date. Events with the same name and date may change
  /// order.
  static int nameCompare(Event a, Event b) {
    if(a.hasTag('Leading') || b.hasTag('Leading')) {
      if(a.hasTag('Leading') && !b.hasTag('Leading')) {
        return -1;
      } else if(!a.hasTag('Leading') && b.hasTag('Leading')) {
        return 1;
      }
    }
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
  MassEditor() {
    name = 'Event editor';
    description = 'Edit all events at once by typing changes and then checking the boxes below. Tags will automatically be added or removed.';
  }
  MassEditor.copy(Event e, this.tagsRemove, this.changes, {required this.markForDeletion}) {
    super.copy(e);
  }

  bool markForDeletion = false;
  List<bool> changes = <bool>[];

  TagList tagsRemove = TagList();
}
