
import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/backend/recurrence.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:executive_planner/widgets/search.dart';
import 'package:executive_planner/widgets/tag_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class EventForm extends StatefulWidget {
  const EventForm({
    required this.event,
    required this.events,
    required this.old,
    Key? key,})
      : super(key: key);

  final Event event;
  final Event? old;
  /// EventList held for the search display when adding subevents.
  final EventList events;

}

abstract class _EventFormState<T extends EventForm> extends State<T> {
  final MaterialColor _backButtonColor = Colors.grey;
  final MaterialColor _confirmButtonColor = Colors.blue;

  /// Generates a widget which changes the time of the event if the date is
  /// already set.
  Widget timePicker() {
    return TextButton(
      onPressed: () {
        showTimePicker(
          initialTime: const TimeOfDay(hour: 0, minute: 0),
          context: context,
        ).then((TimeOfDay? time) {
          if (widget.event.date != null && time != null) {
            setState(() {
              widget.event.date = DateTime(
                widget.event.date!.year,
                widget.event.date!.month,
                widget.event.date!.day,
                time.hour,
                time.minute,);
            });
          }
        });
      },
      child: const Text('Change time'),);
  }

  Widget priorityDropdown() {
    final List<DropdownMenuItem<int>> items = Event.priorities.map((String value) {
      return DropdownMenuItem<int>(
        value: Event.priorities.indexOf(value),
        child: Text(value),
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: DropdownButton<int>(
        value: widget.event.priority.index,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        underline: Container(
          height: 2,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onChanged: (int? newValue) {
          widget.event.priority = Priority.values[newValue!];
          setState(() {});
        },
        items: items,
      ),
    );
  }

  /// Generates a widget which allows the user to set the date of an event.
  /// Currently, setting a date resets the time.
  Widget datePicker() {
    return TextButton(
      onPressed: () {
        showDatePicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 2),
          lastDate: DateTime(DateTime.now().year + 10),
          initialDate: DateTime.now(),
        ).then((DateTime? date) {
          setState(() {
            widget.event.date = date;
          });
        });
      },
      child: Text(widget.event.dateString()),);
  }

  /// Generates a widget which allows the user to set the date of an event.
  /// Currently, setting a date resets the time.
  Widget subEventPicker() {
    return TextButton(
      onPressed: () {
        _search(context);
      },
      child: const Text('Set subevents'),
    );
  }

  /// The text field that the user enters the event description into
  Widget descriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField(
        maxLines: 3,
        onChanged: (String descStr) {
          widget.event.description = descStr;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.event.description,
        ),
      ),
    );
  }

  /// Pads text a standard amount.
  Widget paddedText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  /// Changes the name of the event.
  Widget eventNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        onChanged: (String name) {
          setState(() {
            widget.event.name = name;
          });
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.event.name,
        ),
      ),
    );
  }

  Widget recurText() {
    if(widget.event.recur == null) {
      return TextButton(
        onPressed: () {
          widget.event.recur = Recurrence();
          widget.event.addTag('Recurring');
          setState(() {});
        },
        child: const Text('Make recurring event'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              widget.event.recur = null;
              widget.event.removeTag('Recurring');
              setState(() {});
            },
            child: const Text('Stop event from recurring'),
          ),
          _recurChanger(),
        ],
      );
    }
  }

  Widget _recurChanger() {
    final List<Widget> typeboxes = <Widget>[];
    for(int i = 0; i < Break.timeStrs.length; i++) {
      typeboxes.add(padded(1,1,
        SizedBox(
          width: 75,
          child: TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly],
            onChanged: (String descStr) {
              if(widget.event.recur != null && descStr != '') {
                widget.event.recur!.spacing.times[i] = int.parse(descStr);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: i == Break.timeStrs.length-1 ? 'Min' : Break.timeStrs[i],
            ),),),),);
    }
    return SizedBox(
      height: 35,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: typeboxes,
      ),
    );
  }

  /// Basically a copy of the _search function in [ExecutiveHomePage], but
  /// the functionality is different:
  /// Only selected events are given as the EventList, rather than all in search results.
  /// Changes subevents list to the subevents found by the search.
  Future _search(BuildContext context) async {
    if (Overlay.of(context) != null) {
      final OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry;
      // Flutter doesn't allow you to reference overlayEntry before it is created,
      // even though the buttons in search need to reference it.
      Function removeOverlayEntry = () {};
      overlayEntry = OverlayEntry(builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Card(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).canvasColor),
                child: AdvancedSearch(
                  selectedOnly: true,
                  events: widget.events,
                  onSubmit: (EventList e) {
                    widget.event.subevents = e;
                    removeOverlayEntry();
                  },
                  onExit: () {
                    removeOverlayEntry();
                  },),),),),);},);
      removeOverlayEntry = () {
        overlayEntry.remove();
      };
      overlayState.insert(overlayEntry);
    }
  }

  Widget makeButton(String text, MaterialColor color, Function onPressed) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        primary: color,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      child: Text(text, style: const TextStyle(fontSize: 25)),
    );
  }

  Widget bottomButtons();

}

// TODO: Pull this class apart into component subclasses
/// Allows a user to modify an existing event or add a new event.
class EventAddForm extends EventForm {
  EventAddForm({
    required EventList events,
    Key? key,})
      : super(key: key, old: null, event: Event(), events: events);

  @override
  _EventAddFormState createState() => _EventAddFormState();
}

class _EventAddFormState extends _EventFormState {

  @override
  Widget bottomButtons() {
    final Widget leftButton = makeButton('Add Event', _confirmButtonColor, () {
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
              TagSelector(tags: widget.event.tags, events: widget.events, onSubmit: (String t) {widget.events.addTagToMasterList(t);}),
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

// TODO: Pull this class apart into component subclasses
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

class _EventChangeFormState extends _EventFormState {

  @override
  Widget bottomButtons() {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: padded(10,10,
              makeButton('Change Event', _confirmButtonColor, () {
                Navigator.pop(context, widget.event);
          }),),),
          Align(
            alignment: Alignment.centerRight,
            child: padded(10,10,
              makeButton('Remove Event', _backButtonColor, () {
                Navigator.pop(context, null);
    }),),),],),);
  }

  // TODO: Let the user collapse features which are used less often.
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
              TagSelector(tags: widget.event.tags, events: widget.events, onSubmit: (String t) {widget.events.addTagToMasterList(t);}),
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

// TODO: Pull this class apart into component subclasses
/// Allows a user to modify an existing event or add a new event.
class EventMassForm extends EventForm {
  EventMassForm({
    required EventList events,
    Key? key,})
      : super(key: key, old: null, event: Event(), events: events);

  @override
  _EventMassFormState createState() => _EventMassFormState();
}

class _EventMassFormState extends _EventFormState {
  TagList tags = TagList(tags: []);

  // TODO: Add an "are you sure" overlay
  @override
  Widget bottomButtons() {
    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: padded(10,10,
              makeButton('Change Events', _confirmButtonColor, () {
                Navigator.pop(context, MassEditor(widget.event, tags, updateTypesEnabled, markForDeletion: false));
              }),),),
          Align(
            alignment: Alignment.centerRight,
            child: padded(10,10,
              makeButton('Remove Events', _backButtonColor, () {
                Navigator.pop(context, MassEditor(widget.event, tags, updateTypesEnabled, markForDeletion: true));
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

  // TODO: Let the user collapse features which are used less often.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit All Events'),
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
              paddedText('Select tags to add:'),
              TagSelector(tags: widget.event.tags, events: widget.events, onSubmit: (String t) {widget.events.addTagToMasterList(t);}),
              paddedText('Select tags to remove:'),
              TagSelector(tags: tags, events: widget.events, onSubmit: (String t) {}),
              paddedText('Change date:'),
              datePicker(),
              timePicker(),
              paddedText('Change priority:'),
              priorityDropdown(),
              paddedText('Change recurrence:'),
              recurText(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
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
