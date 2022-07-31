
/// Stores a collection of EventTag objects
/// This class should only add existing EventTags, not construct new ones.
class TagList {
  TagList({Set<String>? tags}) {
    if(tags != null) {
      this.tags = tags;
    }
  }
  TagList.copy(TagList other) {
    for(final String tag in other.tags) {
      tags.add(tag);
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
  bool addTag(String title) {
    final String tag = title;
    final bool added = tags.add(tag);
    return added;
  }

  void mergeTagLists(TagList other) {
    tags.addAll(other.tags);
  }

  void removeAllTags(TagList other) {
    tags.removeAll(other.tags);
  }

  bool hasTag(String title) {
    return tags.contains(title);
  }

  void clear() {
    tags.clear();
  }

  // Removes a tag from the tag list
  bool removeTag(String tag) {
    return tags.remove(tag);
  }

  int get length => tags.length;
  bool get isNotEmpty => tags.isNotEmpty;
  bool contains(String tag) => tags.contains(tag);
}
