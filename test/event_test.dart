// Import the test package and Counter class
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:flutter_test/flutter_test.dart';

// TODO: Add unit tests for the following methods:
//  Event Tags: addTag(), addEventTag(), hasTag(), removeTag(), tagsString(), getTags()
//  Event Dates: dateString(), dateCompare()
//  EventList Tags: addTagToMasterList(), getTagMasterList(),
//  EventList Events: add(), remove(), removeAll
//  EventList Search: searchName(), searchDate(), searchRange(), searchTags()


void main() {
  // Create two Event objects and store them in an EventList
  test('Event Object Constructor', () {
    // Test if attributes passed into the Event object's constructor
    // are properly saved and can be retreived
    final Event e = Event(
      name: 'Test Event',
      description: 'This is a test event.',
      priority: Priority.high,
    );

    expect(e.name, 'Test Event');
    expect(e.description, 'This is a test event.');
    expect(e.priority, Priority.high);
  });
  // Tests if an EventList Object can be instantiated as empty
  // Then adds two Event objects to the list
  test('EventList Constructor', () {
    // Test if the EventList constructor properly represents an empty list
    final EventList e = EventList();
    expect(e.length, 0);

    // Create an Event Object and add it to the list
    final Event e2 = Event(
      name: 'Test Event 2',
      description: 'This is a test event.',
      priority: Priority.high,
    );
    e.add(e2);
    expect(e.length, 1);

    // Create another Event Object and add it to the list
    final Event e3 = Event(
      name: 'Test Event 3',
      description: 'This is a test event.',
      priority: Priority.high,
    );
    e.add(e3);
    expect(e.length, 2);
  });

  test('Compare methods', () {
    final EventList e = EventList();
    final Event a1 = Event(
        name: 'A',
        description: 'This is a test event.',
        priority: Priority.low,);
    final Event a2 = Event(
        name: 'A',
        description: 'This is a test event.',
        priority: Priority.medium,);
    final Event b1 = Event(
        name: 'B',
        description: 'This is a test event.',
        priority: Priority.high,);

    e.add(a1);
    e.add(a2);
    e.add(b1);

    // Test if names are properly compared
    expect(Event.nameCompare(a1, b1), -1);
    // Test if priorities are properly compared if names are the same
    expect(Event.nameCompare(a1, a2), 1);

    // Test if priorityCompare correctly compares 'low' and 'medium' values
    expect(Event.priorityCompare(a1, a2), 1);
    // Test if priorityCompare correctly compares 'medium' and 'high' values
    expect(Event.priorityCompare(a2, b1), 1);
  });
}
