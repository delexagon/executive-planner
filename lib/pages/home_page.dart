import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';
import 'package:executive_planner/file_io.dart';
import 'package:executive_planner/pages/event_change_form.dart';

class ExecutiveHomePage extends StatefulWidget {
  const ExecutiveHomePage({Key? key, required this.title, required this.storage}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final FileStorage storage;
  // For some reason, the page is generated twice. _events MUST be persistent.
  // Static is the only way I know to fix this.
  // TODO: Fix _events.
  static final EventList _events = EventList();

  static void addEvent(Event e) {
    _events.add(e);
    _events.sort();
  }

  // TODO: Make a more reasonable way to remove events.
  static void removeEvent(Event e) {
    _events.remove(e);
  }

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

// TODO: EventCreationForm should not arbitrarily access widget
class _ExecutiveHomePageState extends State<ExecutiveHomePage> {

  @override
  void initState() {
    super.initState();
    widget.storage.readFile().then((Map<String, dynamic>? json) {
      if(json != null) {
        EventList events = EventList.fromJson(json);
        ExecutiveHomePage._events.combine(events);
        setState(() {});
      }
    });
  }

  Widget _buildEventList() {
    List<Widget> widgets= <Widget>[];
    for(int i = 0; i < ExecutiveHomePage._events.length; i++) {
      widgets.add(_buildEventRow(ExecutiveHomePage._events[i]));
      widgets.add(const Divider());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: widgets,
      ),
    );
  }

  Widget _buildEventRow(Event e) {
    Widget name = Text(e.name);
    Widget date;
    if(e.date != null) {
      date = Text(e.dateString());
    } else {
      date = const Text("Reminder");
    }
    return ListTile(
      title: name,
      subtitle: date,
      onLongPress: () {
        _changeEventList(context, e);
      }
    );
  }

  void _update() {
    ExecutiveHomePage._events.sort();
    widget.storage.write(ExecutiveHomePage._events.toJson());
    setState(() {});
  }

  void _changeEventList(BuildContext context, Event? e) async {
    bool isNew = (e == null);
    e ??= Event();
    bool? changeList = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventChangeForm(event: e!, isNew: isNew)),
    );
    changeList ??= false;
    if(changeList) {
      if(isNew) {
        ExecutiveHomePage.addEvent(e);
      } else {
        ExecutiveHomePage.removeEvent(e);
      }
    }
    _update();
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
          _changeEventList(context, null);
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}