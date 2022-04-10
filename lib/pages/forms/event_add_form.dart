import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/forms/event_form.dart';
import 'package:executive_planner/widgets/tag_selector.dart';
import 'package:flutter/material.dart';

/// Allows a user to modify an existing event or add a new event.
class EventAddForm extends EventForm {
  EventAddForm({
    required EventList events,
    Key? key,})
      : super(key: key, old: null, event: Event(), events: events);

  @override
  _EventAddFormState createState() => _EventAddFormState();
}

class _EventAddFormState extends EventFormState {

  @override
  Widget bottomButtons() {
    final Widget leftButton = makeButton('Add Event', confirmButtonColor, () {
      Navigator.pop(context, widget.event);
    });
    return SizedBox(
      height: 70,
      child: Align(
        alignment: Alignment.centerLeft,
        child: padded(10,10,leftButton),
      ),);
  }

  // TODO: Let the user collapse features which are used less often.
  // TODO: Bring some of this code up to the parent
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an event'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              paddedText('Event name:'),
              eventNameField(),
              paddedText('Event description:'),
              descriptionField(),
              paddedText('Select tags:'),
              TagSelector(tags: widget.event.tags, onAdd: (String t) {widget.event.addTag(t);}, onRemove: (String t) {widget.event.removeTag(t);}),
              paddedText('Change date:'),
              datePicker(),
              timePicker(),
              paddedText('Change priority:'),
              priorityDropdown(),
              paddedText('Change recurrence:'),
              recurText(),
              paddedText('Change sub-events:'),
              subEventPicker(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
            ],
          ),
        ),),
      bottomSheet: bottomButtons(),
    );
  }
}
