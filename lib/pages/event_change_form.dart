import 'package:flutter/material.dart';
import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/widgets/search.dart';

// TODO: We may want to change this to an InheritedWidget?
/// Allows a user to modify an existing event or add a new event.
class EventChangeForm extends StatefulWidget {
  /// The event this form is considering. This must be provided so the resulting
  /// event can be handled by the caller of the form.
  final Event event;
  /// EventList held for the search display when adding subevents.
  final EventList events;
  /// Makes this form change between adding a new event or changing an existing
  /// event.
  final bool isNew;

  /// [event]:
  /// The event this form is considering. This must be provided so the resulting
  /// event can be handled by the caller of the form.
  ///
  /// [isNew]:
  /// Makes this form change between adding a new event or changing an existing
  /// event.
  ///
  /// [events]:
  /// EventList held for the search display when adding subevents.
  const EventChangeForm({required this.event, required this.isNew, required this.events, Key? key}) : super(key: key);

  @override
  _EventChangeFormState createState() => _EventChangeFormState();
}

class _EventChangeFormState extends State<EventChangeForm> {

  /// Generates a widget which changes the time of the event if the date is
  /// already set.
  Widget timePicker() {
    return TextButton(
        onPressed: () {
          showTimePicker(
            initialTime: const TimeOfDay(hour: 0, minute: 0),
            context: context,
          ).then((TimeOfDay? time) {
            if(widget.event.date != null && time != null) {
              setState(() {
                widget.event.date = DateTime(
                    widget.event.date!.year, widget.event.date!.month, widget.event.date!.day,
                    time.hour, time.minute
                );
              });
            }
          });
        },
        child: const Text("Change time")
    );
  }

  Widget priorityDropdown() {
    List<DropdownMenuItem<int>> items = Event.priorities.map((String value) {
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
        iconSize: 24,
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
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
        child: Text(widget.event.dateString())
    );
  }

  /// Generates a widget which allows the user to set the date of an event.
  /// Currently, setting a date resets the time.
  Widget subEventPicker() {
    return TextButton(
        onPressed: () {
          _search(context);
        },
        child: const Text("Set subevents"),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  /// Changes the name of the event.
  Widget eventNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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

  /// A button which allows the user to add/remove an event.
  Widget changeEventButton() {
    Widget changeText;
    if(widget.isNew) {
      changeText = const Text("Add event", style: TextStyle(fontSize: 20));
    } else {
      changeText = const Text("Remove event", style: TextStyle(fontSize: 20));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: changeText,
      ),
    );
  }

  /// Basically a copy of the _search function in [ExecutiveHomePage], but
  /// the functionality is different:
  /// Only selected events are given as the EventList, rather than all in search results.
  /// Changes subevents list to the subevents found by the search.
  void _search(BuildContext context) async {
    if(Overlay.of(context) != null) {
      OverlayState overlayState = Overlay.of(context)!;
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
                      decoration: const BoxDecoration(color: Colors.white),
                      child: AdvancedSearch(
                        events: widget.events,
                        selectedOnly: true,
                        onSubmit: (EventList e) {
                          widget.event.subevents = e;
                          removeOverlayEntry();
                        },
                        onExit: () {
                          removeOverlayEntry();
                        },
                      ),
                    )
                )
            )
        );
      });
      removeOverlayEntry = () {overlayEntry.remove();};
      overlayState.insert(overlayEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Change an event"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          paddedText("Event name:"),
          eventNameField(),
          paddedText("Event description:"),
          descriptionField(),
          paddedText("Change date:"),
          datePicker(),
          timePicker(),
          paddedText("Change priority:"),
          priorityDropdown(),
          paddedText("Change sub-events:"),
          subEventPicker(),
          changeEventButton(),
        ],
      ),
    );
  }
}