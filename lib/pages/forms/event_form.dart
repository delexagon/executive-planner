
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/backend/recurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class EventForm extends StatefulWidget {
  const EventForm({
    required this.event,
    required this.old,
    required this.title,
    required this.headlist,
    Key? key,})
      : super(key: key);

  final ListObserver headlist;
  final Event event;
  final Event? old;
  final String title;

}

abstract class EventFormState<T extends EventForm> extends State<T> {
  final MaterialColor backButtonColor = Colors.grey;
  final MaterialColor confirmButtonColor = Colors.blue;

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

  AppBar appBar() {
    return AppBar(
      title: Text(widget.title),
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );
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
    final Widget dateButton = TextButton(
      onPressed: () {
        int hour = 23;
        int minute = 59;
        if(widget.event.date != null) {
          hour = widget.event.date!.hour;
          minute = widget.event.date!.minute;
        }
        showDatePicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 2),
          lastDate: DateTime(DateTime.now().year + 10),
          initialDate: DateTime.now(),
        ).then((DateTime? date) {
          setState(() {
            widget.event.date = date;
            if(widget.event.date != null) {
              widget.event.date = DateTime(date!.year, date.month, date.day, hour, minute);
            } else {
              widget.event.date = null;
            }
          });
        });
      },
      child: Text(widget.event.dateString()),);
    if(widget.event.date != null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [dateButton, timePicker()]);
    }
    return dateButton;
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
      String hintText;
      if(widget.event.recur!.spacing.times[i] != 0) {
        hintText = widget.event.recur!.spacing.times[i].toString();
      } else {
        hintText = i == Break.timeStrs.length-1 ? 'Min' : Break.timeStrs[i];
      }
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
              hintText: hintText,
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
