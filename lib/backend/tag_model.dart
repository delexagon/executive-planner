
// TODO: Add a mapping between Events and Tags, so we can search Events by their Tag and vice versa.
// Currently, the only way to get to a tag is through a search or an Event.

// TODO: Make it so that tags cannot be modified via external classes
class EventTag {
  EventTag({
    required this.id,
    required this.title,
  });

  String id;
  String title;
}

// Stores a collection of EventTag objects
class TagList {
  TagList({
    required this.tags,
  });
  final List<EventTag> tags;

  List<EventTag> asList() {
    return tags;
  }
  String asString() {
    return tags.map((tag) => tag.title).join(', ');
  }

  List<String> asStringList() {
    return tags.map((tag) => tag.title).toList();
  }

  // Adds a new tag to the tag list
  bool addTag(String title) {
    if (tags.any((tag) => tag.title == title)) {
      return false;
    }
    tags.add(EventTag(
      id: title,
      title: title,
    ),);
    return true;
  }

  bool addEventTag(EventTag tag) {
    if (tags.any((tag) => tag.id == tag.id)) {
      return false;
    }
    tags.add(tag);
    return true;
  }

  void mergeTagLists(TagList tags) {
    for (final EventTag tag in tags.tags) {
      addEventTag(tag);
    }
  }

  bool hasTag(String title) {
    return tags.any((tag) => tag.title == title);
  }

  bool hasEventTag(EventTag tag) {
    return tags.any((tag) => tag.id == tag.id);
  }

  // Removes a tag from the tag list
  bool removeTag(String title) {
    if (tags.any((tag) => tag.title == title)) {
      tags.removeWhere((tag) => tag.id == title);
      return true;
    }
    return false;
  }

  bool removeEventTag(EventTag tag) {
    if (tags.any((tag) => tag.id == tag.id)) {
      tags.remove(tag);
      return true;
    }
    return false;
  }

  // Returns a list of Tags matching a partial string query
  TagList queryTags(String str) {
    return TagList(
      tags: tags
          .where((tag) => tag.title.toLowerCase().contains(str.toLowerCase()))
          .toList(),
    );
  }

  int get length => tags.length;
  bool get isNotEmpty => tags.isNotEmpty;
  bool contains(EventTag tag) => tags.contains(tag);



}
