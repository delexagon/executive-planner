
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/calendar.dart';
import 'package:executive_planner/pages/forms/event_add_form.dart';
import 'package:executive_planner/pages/forms/event_change_form.dart';
import 'package:executive_planner/pages/forms/event_mass_form.dart';
import 'package:executive_planner/widgets/drawer.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:executive_planner/widgets/search.dart';
import 'package:flutter/material.dart';

/// The starting page of the application.
///
/// Generated by the [_search] function in [ExecutiveHomePage] and by [main].
/// Only displays events in [events].
class ExecutiveHomePage extends StatefulWidget {
  const ExecutiveHomePage({
    Key? key,
    required this.showCompleted,
    required this.title,
    required this.events,
    required this.onEventListChanged,
    required this.headlist,
  }) : super(key: key);

  /// The title text, placed in the center of the appbar.
  final String title;

  final Function(Event? e) onEventListChanged;
  // TODO: Make this structure have to carry over less data from page to page?
  final EventList headlist;

  /// Holds the events considered by this particular HomePage.
  /// Necessary to consider and selectively show searches.
  final EventList events;
  final bool showCompleted;

  void addEvent(Event e) {
    e.headlist = headlist;
    events.add(e);
  }

  /// Removes event from both current and masterList.
  void clearEvents() {
    while(events.length > 0) {
      masterList.remove(events[0]);
    }
    masterList.saveMaster();
  }

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

class _ExecutiveHomePageState extends State<ExecutiveHomePage> {
  _ExecutiveHomePageState();

  @override
  void initState() {
    super.initState();
    widget.events.onChanged = onEventListChanged;
  }

  void onEventListChanged(Event? e) {
    if(e != null && widget.events.onChanged == null) {
      if(widget.events.contains(e)) {
        widget.events.remove(e);
      } else {
        widget.events.add(e);
      }
    }
    setState(() {
    });
    widget.onEventListChanged(e);
  }

  EventList dailyTasks = EventList();

  /// Generates a search icon which can be tapped to become a text field.
  Widget _searchIcon() {
    return IconButton(
      onPressed: () {
        _search(context);
      },
      icon: const Icon(Icons.search),
    );
  }

  /// Loads new page when search results are submitted, generating a new
  /// [ExecutiveHomePage].
  Future _goToSearchPage(BuildContext context, EventList events, bool showCompleted) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecutiveHomePage(
          showCompleted: showCompleted,
          title: 'Search results',
          events: events,
          // Recursively update every search widget.
          onEventListChanged: onEventListChanged,
          headlist: widget.headlist,
        ),
      ),
    );
  }

  /// Generates an [AdvancedSearch] as an [OverlayEntry].
  ///
  /// Search results are all pushed to new [ExecutiveHomePage] screen.
  Future _search(BuildContext context) async {
    if (Overlay.of(context) != null) {
      final OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry;
      // Flutter doesn't allow you to reference overlayEntry before it is created,
      // even though the buttons in search need to reference it.
      Function removeOverlayEntry = () {};
      overlayEntry = OverlayEntry(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Card(
              child: Center(
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Theme.of(context).canvasColor),
                  child: AdvancedSearch(
                    events: masterList.rootWidget == widget ? masterList.toEventList() : widget.events,
                    onSubmit: (EventList e, bool showCompleted) {
                      _goToSearchPage(context, e, showCompleted);
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

  Future<Event?> _changeEventForm(BuildContext context, {required Event event}) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventChangeForm(event: event),
      ),
    );
  }

  Future<Event?> _addEventForm(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAddForm(),
      ),
    );
  }

  Future<MassEditor?> _massEventForm(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventMassForm(),
      ),
    );
  }

  Widget showDailyTasks() {
    const double buttonDiameter = 110;
    final List<Widget> widgets = <Widget>[];
    for(int i = 0; i < dailyTasks.length; i++) {
      if(dailyTasks[i].isComplete) {
        continue;
      }
      widgets.add(
        SizedBox(
          width: buttonDiameter,
          height: buttonDiameter,
          child: padded(3,3,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              primary: getEventColor(dailyTasks[i],), // <-- Button color
              onPrimary: Theme.of(context).canvasColor, // <-- Splash color
            ),
            onPressed: () {
              dailyTasks[i].complete();
              widget.events.sort();
              if(dailyTasks[i].date != null && dailyTasks[i].date!.isAfter(DateTime.now().add(const Duration(days: 1)))) {
                dailyTasks.remove(dailyTasks[i]);
              }
            },
            child: Text('${dailyTasks[i].name} ${dailyTasks[i].timeString()}', style: TextStyle (
              color: Theme.of(context).canvasColor,
    ),),),),),);}
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
        child: padded(5,5,
          SizedBox(
              width: buttonDiameter * dailyTasks.length,
              child: Row(
                children: widgets,
    ),),),);
  }

  /// Our wonderful "Title"
  Widget definitelyATitle() {
    final List<Widget> widgets = <Widget>[];
    if(widget != masterList.rootWidget) {
      widgets.add(
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      );
    }
    widgets.add(Text(widget.title));
    widgets.add(
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarView(
                events: widget.events,
                onEventListChanged: onEventListChanged,
                headlist: widget.headlist,
              ),),);},
        icon: const Icon(Icons.calendar_today),
    ),);
    return Row(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Make 'displayed' variable
    dailyTasks = widget.events.searchTags('Displayed').searchBefore(DateTime.now().add(const Duration(days:1)));
    return Scaffold(
      appBar: AppBar(
        actions: [
          _searchIcon(),
        ],
        centerTitle: false,
        title: definitelyATitle(),
      ),
      // Hamburger :)
      drawer: ExecutiveDrawer(
        update: () => {setState(() {})},
        events: widget.events,
        onEventListChanged: onEventListChanged,
        headlist: widget.headlist,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            showDailyTasks(),
            EventListDisplay(
              showCompleted: widget.showCompleted,
              events: widget.events,
              onLongPress: (Event e) {
                _changeEventForm(context, event: e).then((Event? copy) {
                  if(copy == null) {
                    return;
                  } else if (copy == e) {
                    masterList.remove(e);
                  } else {
                    e.copy(copy);
                    widget.events.sort();
                  }
                  setState(() {});
                });
              },
              onDrag: (Event e) {
                e.complete();
                widget.events.sort();
                setState(() {});
      },)],),),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          padded(3,3,
            FloatingActionButton(
              heroTag: 'btnSingle',
              onPressed: () {
                _addEventForm(context).then((Event? e) {
                  if(e != null) {
                    widget.addEvent(e);
                  }
                });
              },
              tooltip: 'Add Event',
              child: const Icon(Icons.add),
            ),
          ),
          padded(3,3,
            FloatingActionButton(
              heroTag: 'btnMass',
              onPressed: () {
                // TODO: Make a structure that means that this isn't accessing events individually
                _massEventForm(context).then((MassEditor? e) {
                  if(e != null) {
                    if(e.markForDeletion) {
                      widget.clearEvents();
                    } else {
                      for(int i = 0; i < widget.events.length; i++) {
                        widget.events[i].integrate(e);
                      }
                    }
                    masterList.saveMaster();
                    setState(() {});
                  }
                });
              },
              tooltip: 'Mass edit',
              child: const Icon(Icons.all_inclusive),
    ),),],),);}
}
