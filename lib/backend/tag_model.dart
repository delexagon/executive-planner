
import 'package:executive_planner/backend/master_list.dart';
// TODO: Add a mapping between Events and Tags, so we can search Events by their Tag and vice versa.
// Currently, the only way to get to a tag is through a search or an Event.

// TODO: Make it so that tags cannot be modified via external classes
class EventTag {
  EventTag({required this.title});
  @override
  bool operator ==(Object other) {
    return other is EventTag && other.title == title;
  }

  final String title;

  @override
  int get hashCode => title.hashCode;
}

/// Stores a collection of EventTag objects
/// This class should only add existing EventTags, not construct new ones.
class TagList {
  TagList({Set<EventTag>? tags}) {
    if(tags != null) {
      this.tags = tags;
    }
  }
  TagList.copy(TagList other, {Function(EventTag t)? onAdd}) {
    for(final EventTag tag in other.tags) {
      tags.add(tag);
      if(onAdd != null) {
        onAdd(tag);
      }
    }
  }

  Set<EventTag> tags = <EventTag>{};

  List<EventTag> asList() {
    return tags.toList();
  }

  Set<EventTag> asSet() {
    return tags;
  }

  String asString() {
    return tags.map((tag) => tag.title).join(', ');
  }

  List<String> asStringList() {
    return tags.map((tag) => tag.title).toList();
  }

  // Adds a new tag to the tag list
  bool addTag(String title, {Function(EventTag t)? onAdd}) {
    final EventTag tag = EventTag(title: title);
    final bool added = tags.add(tag);
    if(added && onAdd != null) {
      onAdd(tag);
    }
    return added;
  }

  // Adds a new tag to the tag list
  bool addEventTag(EventTag tag, {Function(EventTag t)? onAdd}) {
    final bool added = tags.add(tag);
    if(added && onAdd != null) {
      onAdd(tag);
    }
    return added;
  }

  void mergeTagLists(TagList tags, {Function(EventTag t)? onAdd}) {
    for(final EventTag tag in tags.tags) {
      final bool added = this.tags.add(tag);
      if(added && onAdd != null) {
        onAdd(tag);
      }
    }
  }

  void removeAllTags(TagList tags, {Function(EventTag t)? onRemove}) {
    for(final EventTag tag in tags.tags) {
      final bool removed = this.tags.remove(tag);
      if(removed && onRemove != null) {
        onRemove(tag);
      }
    }
  }

  bool hasTag(String title) {
    return tags.any((tag) => tag.title == title);
  }

  bool hasEventTag(EventTag tag) {
    return tags.contains(tag);
  }

  EventTag? getTag(String title) {
    for(EventTag t in tags) {
      if(t.title == title) {
        return t;
      }
    }
    return null;
  }

  void clear({Function(EventTag t)? onRemove}) {
    for(final EventTag tag in tags) {
      tags.remove(tag);
      if(onRemove != null) {
        onRemove(tag);
      }
    }
  }

  // Removes a tag from the tag list
  bool removeTag(String title, {Function(EventTag t)? onRemove}) {
    final EventTag? tag = getTag(title);
    if(tag != null) {
      if(onRemove != null) {
        onRemove(tag);
      }
      return tags.remove(tag);
    } else {
      return false;
    }
  }

  bool removeEventTag(EventTag tag,  {Function(EventTag t)? onRemove}) {
    final bool removed = tags.remove(tag);
    if(removed && onRemove != null) {
      onRemove(tag);
    }
    return removed;
  }

  int get length => tags.length;
  bool get isNotEmpty => tags.isNotEmpty;
  bool contains(EventTag tag) => tags.contains(tag);
}
