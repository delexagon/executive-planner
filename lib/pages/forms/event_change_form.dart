import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/forms/event_form.dart';
import 'package:executive_planner/widgets/tag_selector.dart';
import 'package:flutter/material.dart';

/// Allows a user to modify an existing event or add a new event.
class EventChangeForm extends EventForm {
  EventChangeForm({
    required EventList events,
    required Event event,
    Key? key,})
      : super(key: key, old: event, event: Event.copy(event), events: events);

  @override
  _EventChangeFormState createState() => _EventChangeFormState();
}

class _EventChangeFormState extends EventFormState {

  @override
  Widget bottomButtons() {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: padded(10,10,
              makeButton('Change Event', confirmButtonColor, () {
                Navigator.pop(context, widget.event);
              }),),),
          Align(
            alignment: Alignment.centerRight,
            child: padded(10,10,
              makeButton('Remove Event', backButtonColor, () {
                Navigator.pop(context, null);
              }),),),],),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an event'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.pop(context, widget.old);
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
              paddedText('Change priority:'),
              priorityDropdown(),
              paddedText('Change recurrence:'),
              recurText(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
            ],
          ),
        ),),
      bottomSheet: bottomButtons(),
    );
  }
}
