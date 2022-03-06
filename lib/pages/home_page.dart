import 'package:flutter/material.dart';
import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/file_io.dart';
import 'package:executive_planner/pages/event_change_form.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:executive_planner/widgets/search.dart';

// TODO: Automatically hide unwanted events (subevents, trash, completed?)
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
  _ExecutiveHomePageState();

  /// Generates a search icon which can be tapped to become a text field.
  Widget _searchIcon() {
    return IconButton(
      onPressed: () {
        _search(context);
      },
      icon: const Icon(Icons.search),
    );
  }

  void _goToSearchPage(BuildContext context, EventList events) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExecutiveHomePage(
          title: "Search results", storage: widget.storage,
          events: events,
        )
      )
    );
    _update();
  }

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
                  onSubmit: (EventList e) {
                    _goToSearchPage(context, e);
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

  /// Sorts events, saves the data to disk, resets the searchbar to an icon
  /// and regenerates the display.
  void _update() {
    widget.storage.write(ExecutiveHomePage.masterList.toJson());
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
      MaterialPageRoute(builder: (context) => EventChangeForm(event: event!, events: widget.events, isNew: isNew)),
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
          _searchIcon(),
        ],
        centerTitle: true,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: EventListDisplay(
          events: widget.events,
          onLongPress: (Event e) {
            _changeEventList(context, event: e);
          }
        ),
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