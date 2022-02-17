import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';
import 'package:executive_planner/pages/home_page.dart';

// TODO: Clean up import chain

// TODO: We may want to change this to an InheritedWidget?
class EventCreationForm extends StatefulWidget {
  const EventCreationForm({Key? key}) : super(key: key);
  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventCreationFormState extends State<EventCreationForm> {
  String name = "Unnamed Event";
  DateTime? date;
  TimeOfDay? time;

  Event buildEvent() {
    Event e = Event(name: name);
    if(date != null) {
      if(time != null) {
        e.date = DateTime(
            date!.year, date!.month, date!.day, time!.hour, time!.minute);
      } else {
        e.date = DateTime(date!.year, date!.month, date!.day);
      }
      e.date = e.date!.toUtc();
    }
    return e;
  }

  void pushEvent() {
    ExecutiveHomePage.addEvent(buildEvent());
  }

  Widget timePicker() {
    return TextButton(
        onPressed: () {
          showTimePicker(
            initialTime: const TimeOfDay(hour: 0, minute: 0),
            context: context,
          ).then((TimeOfDay? time) {
            this.time = time;
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
            this.date = date;
          });
        },
        child: const Text("Change date")
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
          this.name = name;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Unnamed Event',
        ),
      ),
    );
  }

  Widget addEventButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
      child: TextButton(
        onPressed: () {
          pushEvent();
          Navigator.pop(context);
        },
        // Add a textButtonTheme instead?
        child: const Text("Add event", style: TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Create an event"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          paddedText("Event name:"),
          eventNameField(),
          paddedText("Date:"),
          datePicker(),
          paddedText("Time:"),
          timePicker(),
          addEventButton(),
        ],
      ),
    );
  }
}