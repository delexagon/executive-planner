import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';

// TODO: We may want to change this to an InheritedWidget?
class EventChangeForm extends StatefulWidget {
  final Event event;
  final bool isNew;

  const EventChangeForm({required this.event, required this.isNew, Key? key}) : super(key: key);

  @override
  _EventChangeFormState createState() => _EventChangeFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventChangeFormState extends State<EventChangeForm> {

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

  Widget paddedText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

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
          paddedText("Change date:"),
          datePicker(),
          timePicker(),
          changeEventButton(),
        ],
      ),
    );
  }
}