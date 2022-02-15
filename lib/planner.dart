import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';

class ExecutiveHomePage extends StatefulWidget {
  ExecutiveHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final _events = EventList();

  void addEvent(Event e) {
    _events.add(e);
  }

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

// todo: EventCreationForm should return something, not arbitrarily access widget
class _ExecutiveHomePageState extends State<ExecutiveHomePage> {

  Widget _buildEventList() {
    return ListView.builder(
      itemCount: (widget._events.length)*2,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if(i.isOdd) {
          return const Divider();
        }

        final index = i ~/ 2;
        return _buildEventRow(widget._events[index]);
      }
    );
  }

  Widget _buildEventRow(Event e) {
    return ListTile(
      title: Text(e.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _buildEventList()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EventCreationForm form = EventCreationForm(widget);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => form),
          ).then((_) => setState(() {}));
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// todo: We may want to change this to an InheritedWidget
class EventCreationForm extends StatefulWidget {
  EventCreationForm(this.parent, {Key? key}) : super(key: key);
  final Event e = Event();
  final ExecutiveHomePage parent;

  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventCreationFormState extends State<EventCreationForm> {
  // Create a text controller. Later, use it to retrieve the
  // current value of the TextField.
  final nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    super.dispose();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Text(
              "Set event name:",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              onChanged: (String name) {
                widget.e.name = name;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Unnamed Event',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.parent.addEvent(widget.e);
              Navigator.pop(context);
            },
            child: const Text("Add event"),
          ),
        ],
      ),
    );
  }
}