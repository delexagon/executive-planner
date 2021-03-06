
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/forms/event_form.dart';
import 'package:executive_planner/widgets/tag_selector.dart';
import 'package:flutter/material.dart';

/// Allows a user to modify an existing event or add a new event.
class EventChangeForm extends EventForm {
  EventChangeForm({
    required Event event,
    required ListObserver headlist,
    Key? key,})
      : super(key: key, old: event, headlist: headlist, event: Event.copy(event), title: 'Change ${event.name}');

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
                widget.old!.copy(widget.event);
                Navigator.pop(context, widget.event);
              }),),),
          Align(
            alignment: Alignment.centerRight,
            child: padded(10,10,
              makeButton('Remove Event', backButtonColor, () {
                widget.old!.observer?.notify(NotificationType.eventRemove, event: widget.old);
                Navigator.pop(context, widget.old);
              }),),),],),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
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
              TagSelector(tags: widget.event.tags, onAdd: (String t) {widget.event.addTag(t);}, onRemove: (String t) {widget.event.removeTag(t);}, headlist: widget.headlist,),
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
