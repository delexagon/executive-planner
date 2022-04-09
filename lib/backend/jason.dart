import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/tag_model.dart';

// Feel free to try implementing all the json yourself, if you want.
// I'm not going to.

/// Jason is a very simple language that just has brackets and data, nothing else.
/// Something going fromJason to an object had better know where everything is supposed
/// to be first.
/// For example, a default new event is {{Unnamed Event}{null}{No description}{0}{{}}}}{{}}
/// All of the spare brackets at the end are things which don't exist yet, like tags and
/// priority.
/// Note that theoretically any function that can translate an object to and
/// from a string can be used as proper to/fromJason functions, as long as it doesn't
/// lead to curly braces scattered around.
/// Also, note that text anywhere not immediately inside a set of curly braces
/// ("{fejiosj{Unnamed Event}{null}{No description}{0}{{}}}}{{}}")
/// is completely ignored.
// TODO: Make it so that you can't break the Jason by putting curly braces in your strings
// TODO: Make sure the time complexity of getBrackets doesn't make this approach really bad

/// The core function of Jason. This goes through a String and takes out every string that's
/// within a set of curly brackets, so you can use fromJason on those component parts.
/// This is an O(n) sized algorithm, so it's going to scale badly; I think it's possible
/// to start to construct objects as soon as we get in their brackets rather than doing this
/// recursive strategy, but that's harder to write and I don't care enough.
List<String> getBrackets(String str) {
  final List<String> strings = <String>[];
  int brackets = 0;
  int startPos = 0;
  for(int pos = 0; pos < str.length; pos++) {
    if(str[pos] == '{') {
      brackets++;
      if(brackets == 1) {
        startPos = pos + 1;
      }
    }
    if(str[pos] == '}') {
      if(brackets == 1) {
        strings.add(str.substring(startPos, pos));
      }
      if(brackets == 0) {
        break;
      }
      brackets--;
    }
  }
  return strings;
}

/// This is a list of extensions for various classes, each of which adds
/// the toJason() and a static fromJason() function. I think JasonEvent especially
/// makes it clear how Jason is meant to be used.
/// You may notice that there is repeat code for lists of different types; I think it may
/// actually be impossible in Dart to write an extension for a generic type and then use json functions
/// that may not exist for that type. Certainly, I couldn't figure out how to do it.
/// At least you have to admit that having an easy way to create jason for a list is
/// better than lists having no json support at all, which is really good.
/// Well, actually this sort of solution could probably work with json as well, I just really
/// hate it and everything about how Dart deals with it.
extension JasonInt on int {
  String toJason() {
    return toString();
  }

  static int fromJason(String jason) {
    return int.parse(jason);
  }
}

extension JasonString on String {
  String toJason() {
    return this;
  }

  static String fromJason(String jason) {
    return jason;
  }
}

extension JasonEventTag on EventTag {
  String toJason() {
    return '{$id}{$title}';
  }

  static EventTag fromJason(String jason) {
    final List<String> strings = getBrackets(jason);
    return EventTag(id: JasonString.fromJason(strings[0]), title: JasonString.fromJason(strings[1]));
  }
}

extension JasonListEventTag on List<EventTag> {
  String toJason() {
    final str = StringBuffer();
    for(final EventTag obj in this) {
      str.write('{${obj.toJason()}}');
    }
    return str.toString();
  }

  static List<EventTag> fromJason(String jason) {
    final List<EventTag> list = <EventTag>[];
    final List<String> strings = getBrackets(jason);
    for(final String str in strings) {
      list.add(JasonEventTag.fromJason(str));
    }
    return list;
  }
}

extension JasonTagList on TagList {
  String toJason() {
    return '{${tags.toJason()}}';
  }

  static TagList fromJason(String jason) {
    final List<String> strings = getBrackets(jason);
    return TagList(tags: JasonListEventTag.fromJason(strings[0]));
  }
}

extension JasonDateTime on DateTime? {
  String toJason() {
    if(this == null) {
      return 'null';
    } else {
      return this!.toIso8601String();
    }
  }

  static DateTime? fromJason(String jason) {
    if(jason == 'null') {
      return null;
    } else {
      return DateTime.parse(jason);
    }
  }
}

extension JasonPriority on Priority {
  String toJason() {
    return index.toString();
  }

  static Priority fromJason(String jason) {
    return Priority.values[int.parse(jason)];
  }
}

extension JasonEvent on Event {
  String toJason() {
    return '{${name.toJason()}}{${date.toJason()}}{${description.toJason()}}{${priority.toJason()}}{${tags.toJason()}}';
  }

  static Event fromJason(String jason) {
    final List<String> strings = getBrackets(jason);
    return Event(name: JasonString.fromJason(strings[0]), date: JasonDateTime.fromJason(strings[1]), description: JasonString.fromJason(strings[2]), priority: JasonPriority.fromJason(strings[3]), tags: JasonTagList.fromJason(strings[4]));
  }
}

extension JasonListEvent on List<Event> {
  String toJason() {
    final str = StringBuffer();
    for(final Event obj in this) {
      str.write('{${obj.toJason()}}');
    }
    return str.toString();
  }

  static List<Event> fromJason(String jason) {
    final List<Event> list = <Event>[];
    final List<String> strings = getBrackets(jason);
    for(final String str in strings) {
      list.add(JasonEvent.fromJason(str));
    }
    return list;
  }
}

extension JasonEventList on EventList {
  String toJason() {
    return '{${list.toJason()}}{${allTags.toJason()}}';
  }

  static EventList fromJason(String jason) {
    final List<String> strings = getBrackets(jason);
    return EventList(list: JasonListEvent.fromJason(strings[0]), allTags: JasonTagList.fromJason(strings[1]));
  }
}

extension JasonSetEvent on Set<Event> {
  String toJason() {
    final str = StringBuffer();
    for(final Event obj in this) {
      str.write('{${obj.toJason()}}');
    }
    return str.toString();
  }

  static List<Event> fromJason(String jason) {
    final List<Event> list = <Event>[];
    final List<String> strings = getBrackets(jason);
    for(final String str in strings) {
      list.add(JasonEvent.fromJason(str));
    }
    return list;
  }
}