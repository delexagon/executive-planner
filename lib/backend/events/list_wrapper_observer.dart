
import 'dart:collection';

import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/backend/jason.dart';

enum NotificationType {
  // Needs special handling because the lists themselves need to change
  eventRemove,
  eventAdd,
  listClear,
  // Needs special handling because the tag needs to be added/removed from masterlist
  eventRemoveTag,
  eventAddTag,
  // General case
  eventsChanged,
  // Recursive
  update,
  load,
}

/// Moved all code to here.
/// All things which modify events or event lists should be passed immediately to here,
/// which will handle updating pages and lists.
/// Do not pass through EventLists or otherwise.
class ListObserver {
  /// Supervisor should be set immediately after this constructor is called.
  /// This allows to reference supervisors in events which are just created as
  ListObserver() {
    _lists.add(pairedList);
  }

  factory ListObserver.jason(String jason) {
    final events = JasonSetEvent.fromJason(jason);
    final observer = ListObserver();
    for(final e in events) {
      observer._add(e);
    }
    return observer;
  }

  /// The top of the supervisor tree; the base supervisor that all other supervisors lead to.
  static late ListObserver top;

  ListObserver? supervisor;
  final Set<Event> _head = <Event>{};
  final Set<EventList> _lists = <EventList>{};
  final HashMap<Object, Function()> updateFuncs = HashMap<Object, Function()>();
  final HashMap<String, int> _tags = HashMap<String, int>();
  final EventList pairedList = EventList();

  /// All calls to modify events should be passed directly through this function at some point.
  /// This will update the display, sort event lists if orderChange is true, and save to the filesystem.
  void notify(final NotificationType type, {Event? event, String? tag, String? fileStr, bool orderChange = true}) {
    bool sort = orderChange;
    switch (type) {
      // Expected data: Removed event
      case NotificationType.eventRemove:
        if(_head.contains(event)) {
          _remove(event);
        }
        break;
      // Expected data: Added event
      case NotificationType.eventAdd:
        if(!_head.contains(event)) {
          _add(event);
        }
        break;
      case NotificationType.listClear:
        _clear();
        break;
      case NotificationType.load:
        if(fileStr != null) {
          _loadFile(fileStr);
        } else {
          _loadFile();
        }
        break;
      case NotificationType.eventRemoveTag:
        if(_head.contains(event) && tag != null && event!.tags.contains(tag)) {
          event.tags.removeTag(tag);
          _removeTag(tag);
        }
        sort = false;
        break;
      case NotificationType.eventAddTag:
        if(_head.contains(event) && tag != null && !event!.tags.contains(tag)) {
          event.tags.addTag(tag);
          _addTag(tag);
        }
        sort = false;
        break;
      case NotificationType.eventsChanged:
        // Just update and save
        break;
      case NotificationType.update:
        _update();
        break;
    }
    if(!_preserve) {
      if(sort) {
        for(final list in _lists) {
          list.sort();
        }
      }
      for(final Function() func in updateFuncs.values) {
        func();
      }
      save();
    }
  }

  int get length => _head.length;

  static final specialTags = {'Leading',};

  // Returns a list of Tags matching a partial string query
  Set<String> queryTags(String str) {
    return _tags.keys.followedBy(specialTags).where((tag) {
      return tag.toLowerCase().startsWith(str.toLowerCase());
    }).toSet();
  }

  bool hasList(EventList e) {
    return _lists.contains(e);
  }

  bool hasEvent(Event e) {
    return _head.contains(e);
  }

  Iterable<String> tags() {
    return _tags.keys;
  }

  EventList makeList() {
    final events = EventList();
    for(final e in _head) {
      events.add(e);
    }
    return events;
  }

  void addList(EventList list) {
    _lists.add(list);
  }

  void removeList(EventList list) {
    if(list != pairedList) {
      _lists.remove(list);
    }
  }

  void addFunc(Object that, Function() update) {
    updateFuncs[that] = update;
  }

  void removeFunc(Object that) {
    updateFuncs.remove(that);
  }

  bool hasTag(String tag) {
    return _tags.containsKey(tag);
  }

  void _add(Event? event) {
    if(event != null) {
      if(event.observer != null && event.observer != this) {
        event.observer!._remove(event);
      }
      // TODO: Make this tracked in just one place somehow.
      event.observer = this;
      event.subevents.supervisor = this;
      _head.add(event);
      for(final EventList list in _lists) {
        list.add(event);
      }
      for(final tag in event.tags.asStringList()) {
        _addTag(tag);
      }
    }
  }

  void _remove(Event? event) {
    _head.remove(event);
    for(final EventList list in _lists) {
      list.remove(event);
    }
    if(event != null) {
      event.observer = null;
      event.subevents.supervisor = null;
      for(final tag in event.tags.asStringList()) {
        _removeTag(tag);
      }
    }
  }

  void _addTag(String? tag) {
    if(tag != null) {
      if (_tags.containsKey(tag)) {
        _tags[tag] = _tags[tag]! + 1;
      } else {
        _tags[tag] = 1;
      }
    }
  }

  void _removeTag(String? tag) {
    if(tag != null) {
      if(_tags.containsKey(tag)) {
        _tags[tag] = _tags[tag]! - 1;
        if(_tags[tag] == 0) {
          _tags.remove(tag);
        }
      }
    }
  }

  void _clear() {
    _head.clear();
    _tags.clear();
    for(final EventList list in _lists) {
      list.clear();
    }
  }

  String toJason() {
    return _head.toJason();
  }

  void _loadFile([String location = 'events']) {
    readString(location).then((jason) {
      if(jason != null) {
        loadJason(jason);
      }
    });
  }

  void loadJason(String jason) {
    _clear();
    final events = JasonSetEvent.fromJason(jason);
    for(final e in events) {
      _add(e);
    }
  }

  void save([String location = 'events']) {
    if(this == top) {
      write(location, _head.toJason());
    } else {
      supervisor!.save();
    }
  }

  void _update() {
    for(final e in _head) {
      e.update();
    }
    notify(NotificationType.eventsChanged);
  }

  /// For when a large amount of tags are being added or removed at once.
  /// If resetTags is not run as soon as possible after this, then there is a possibility
  /// that tags will not be tracked correctly for event.
  void unsetTags(Event event) {
    if(_head.contains(event)) {
      for(final tag in event.tags.asStringList()) {
        _removeTag(tag);
      }
    }
  }
  void resetTags(Event event) {
    if(_head.contains(event)) {
      for(final tag in event.tags.asStringList()) {
        _addTag(tag);
      }
    }
    save();
  }

  bool _preserve = false;

  void preserve() {
    _preserve = true;
  }
  void unpreserve() {
    _preserve = false;
    for(final list in _lists) {
      list.sort();
    }
    for(final Function() func in updateFuncs.values) {
      func();
    }
    save();
  }
}
