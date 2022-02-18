import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';
import 'package:executive_planner/file_io.dart';
import 'package:executive_planner/pages/event_change_form.dart';

class ExecutiveHomePage extends StatefulWidget {
  const ExecutiveHomePage({Key? key, required this.title, required this.storage,
    required this.events}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  /// The title text, placed in the center of the appbar.
  final String title;
  /// This remains an object instead of static functions in case we ever need to
  /// change how our data is stored.
  final FileStorage storage;
  /// Holds ALL EVENTS in the program.
  static final EventList masterList = EventList();
  /// Holds the events considered by this particular HomePage.
  /// Necessary to consider and selectively show searches.
  final EventList events;

  /// Initializes the HomePage masterList to whatever is stored in files.
  static void initMaster() {
    FileStorage storage = FileStorage();
    storage.readFile().then((Map<String, dynamic>? json) {
      if (json != null) {
        EventList events = EventList.fromJson(json);
        ExecutiveHomePage.masterList.combine(events);
      }
    });
  }

  /// Adds event to both current and masterList.
  void addMEvent(Event e) {
    masterList.add(e);
    if(events != masterList) {
      events.add(e);
    }
    events.sort(Event.dateCompare);
  }

  /// Removes event from both current and masterList.
  void removeMEvent(Event e) {
    masterList.remove(e);
    if(events != masterList) {
      events.remove(e);
    }
  }

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

// TODO: EventCreationForm should not arbitrarily access widget
class _ExecutiveHomePageState extends State<ExecutiveHomePage> {
  _ExecutiveHomePageState() {
    search = _searchIcon();
  }

  /// Stores the searchbar/search icon for display.
  late Widget search;

  /// Creates a list of widgets displaying the data in events.
  Widget _buildEventList() {
    List<Widget> widgets= <Widget>[];
    for(int i = 0; i < widget.events.length; i++) {
      widgets.add(_buildEventRow(widget.events[i]));
      widgets.add(const Divider());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: widgets,
      ),
    );
  }

  /// Creates a widget displaying the info of a single event.
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
        _changeEventList(context, event: e);
      }
    );
  }

  /// Generates a search icon which can be tapped to become a text field.
  Widget _searchIcon() {
    return IconButton(
      onPressed: () {
        search = _searchBar();
        setState(() {});
      },
      icon: const Icon(Icons.search),
    );
  }

  // TODO: Make this look less terrible.
  /// A text field that allows the user to search.
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: SizedBox(
        width: 200,
        height: 4,
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (String search) {
            _searchEventList(context, search);
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            hintText: "Search",
          ),
        )
      )
    );
  }

  /// Sorts events, saves the data to disk, resets the searchbar to an icon
  /// and regenerates the display.
  void _update() {
    widget.events.sort(Event.dateCompare);
    widget.storage.write(ExecutiveHomePage.masterList.toJson());
    search = _searchIcon();
    setState(() {});
  }

  /// Changes pages to EventChangeForm, allowing editing of events.
  /// If event is uninitialized, this will give an screen for adding a new event.
  /// Otherwise, it will edit a current event.
  void _changeEventList(BuildContext context, {Event? event}) async {
    bool isNew = (event == null);
    event ??= Event();
    bool? changeList = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventChangeForm(event: event!, isNew: isNew)),
    );
    changeList ??= false;
    if(changeList) {
      if(isNew) {
        widget.addMEvent(event);
      } else {
        widget.removeMEvent(event);
      }
    }
    _update();
  }

  /// Creates new HomePage fitting only the search criteria.
  void _searchEventList(BuildContext context, String searchStr) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExecutiveHomePage(
        title: searchStr, storage: widget.storage,
        events: widget.events.search(searchStr)),
      )
    );
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
        automaticallyImplyLeading: true,
        actions: [
          search,
        ],
        centerTitle: true,
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
          _changeEventList(context);
        },
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}