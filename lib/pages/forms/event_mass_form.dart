
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:executive_planner/pages/forms/event_form.dart';
import 'package:executive_planner/widgets/tag_selector.dart';
import 'package:flutter/material.dart';

/// Allows a user to modify an existing event or add a new event.
class EventMassForm extends EventForm {
  EventMassForm({
    required ListObserver headlist,
    Key? key,})
      : super(key: key, old: null, headlist: headlist, title: 'Change all events', event: MassEditor());

  
  @override
  _EventMassFormState createState() => _EventMassFormState();
}

class _EventMassFormState extends EventFormState {
  TagList tags = TagList(tags: {});

  @override
  Widget bottomButtons() {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: padded(10,10,
              makeButton('Change Events', confirmButtonColor, () {
                Navigator.pop(context, MassEditor.copy(widget.event, tags, updateTypesEnabled, markForDeletion: false));
              }),),),
          Align(
            alignment: Alignment.centerRight,
            child: padded(10,10,
              makeButton('Remove Events', backButtonColor, () {
                Navigator.pop(context, MassEditor.copy(widget.event, tags, updateTypesEnabled, markForDeletion: true));
              }),),),],),);
  }

  /// The selected fields which the user wishes to update. Tags will automatically
  /// be updated if they are entered.
  List<bool> updateTypesEnabled = [false, false, false, false, false,];

  Widget typeCheckboxes() {
    final List<String> updateStrs = ['Name', 'Description', 'Date', 'Priority', 'Recurrence'];
    final List<Widget> checkboxes = <Widget>[];
    for(int i = 0; i < updateTypesEnabled.length && i < updateStrs.length; i++) {
      checkboxes.add(
        Flexible(
          child: CheckboxListTile(
            title: Text(updateStrs[i]),
            value: updateTypesEnabled[i],
            onChanged: (bool? value) {
              updateTypesEnabled[i] = !updateTypesEnabled[i];
              setState(() {});
            },),),);
      checkboxes.add(const VerticalDivider(width: 20));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:SizedBox(
        width: 900,
        height: 50,
        child: Row(
          children: checkboxes,
        ),),);
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
              paddedText('Select tags to add:'),
              TagSelector(tags: widget.event.tags, onAdd: (String t) {widget.event.addTag(t);}, onRemove: (String t) {widget.event.removeTag(t);}, headlist: widget.headlist,),
              paddedText('Select tags to remove:'),
              TagSelector(tags: tags, onAdd: (String t) {tags.addTag(t);}, onRemove: (String t) {tags.removeTag(t);}, headlist: widget.headlist,),
              paddedText('Change date:'),
              datePicker(),
              paddedText('Change priority:'),
              priorityDropdown(),
              paddedText('Change recurrence:'),
              recurText(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 66)),
            ],
          ),
        ),),
      bottomSheet: SizedBox(
        height: 120,
        child: Column(
          children: [
            typeCheckboxes(),
            bottomButtons(),
          ],
        ),
      ),
    );
  }
}
