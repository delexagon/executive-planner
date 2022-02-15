import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';

class ExecutiveHomePage extends StatefulWidget {
  const ExecutiveHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ExecutiveHomePage> createState() {
    return _ExecutiveHomePageState();
  }
}

class _ExecutiveHomePageState extends State<ExecutiveHomePage> {
  final _events = EventList();

  void _incrementCounter() {
    _events.addEvent(Event(name: "Woah new event dropped"));
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  Widget _buildEventList() {
    return ListView.builder(
      itemCount: (_events.length)*2,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if(i.isOdd) {
          return const Divider();
        }

        final index = i ~/ 2;
        return _buildEventRow(_events[index]);
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
