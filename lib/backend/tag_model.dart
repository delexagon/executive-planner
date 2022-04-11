
// TODO: Add a mapping between Events and Tags, so we can search Events by their Tag and vice versa.
// Currently, the only way to get to a tag is through a search or an Event.


/// Stores a collection of EventTag objects
/// This class should only add existing EventTags, not construct new ones.
class TagList {
  TagList({Set<String>? tags}) {
    if(tags != null) {
      this.tags = tags;
    }
  }
  TagList.copy(TagList other, {Function(String t)? onAdd}) {
    for(final String tag in other.tags) {
      tags.add(tag);
      if(onAdd != null) {
        onAdd(tag);
      }
    }
  }

  Set<String> tags = <String>{};

  List<String> asList() {
    return tags.toList();
  }

  Set<String> asSet() {
    return tags;
  }

  String asString() {
    return tags.join(', ');
  }

  List<String> asStringList() {
    return tags.toList();
  }

  // Adds a new tag to the tag list
  bool addTag(String title, {Function(String t)? onAdd}) {
    final String tag = title;
    final bool added = tags.add(tag);
    if(added && onAdd != null) {
      onAdd(tag);
    }
    return added;
  }

  void mergeTagLists(TagList other, {Function(String t)? onAdd}) {
    for(final String tag in other.tags) {
      if(!tags.contains(tag) && onAdd != null) {
        onAdd(tag);
      }
    }
    tags.addAll(other.tags);
  }

  void removeAllTags(TagList other, {Function(String t)? onRemove}) {
    for(final String tag in other.tags) {
      if(tags.contains(tag) && onRemove != null) {
        onRemove(tag);
      }
    }
    tags.removeAll(other.tags);
  }

  bool hasTag(String title) {
    return tags.contains(title);
  }

  void clear({Function(String t)? onRemove}) {
    for(final String tag in tags) {
      if(onRemove != null) {
        onRemove(tag);
      }
    }
    tags.clear();
  }

  // Removes a tag from the tag list
  bool removeTag(String tag, {Function(String t)? onRemove}) {
    if(tags.contains(tag)) {
      if(onRemove != null) {
        onRemove(tag);
      }
    }
    return tags.remove(tag);
  }

  int get length => tags.length;
  bool get isNotEmpty => tags.isNotEmpty;
  bool contains(String tag) => tags.contains(tag);
}
