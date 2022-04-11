import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/jason.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/calendar.dart';
import 'package:executive_planner/pages/forms/event_add_form.dart';
import 'package:executive_planner/pages/forms/event_change_form.dart';
import 'package:executive_planner/pages/forms/event_mass_form.dart';
import 'package:executive_planner/widgets/bottom_nav_bar.dart';
import 'package:executive_planner/widgets/drawer.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:executive_planner/widgets/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: Automatically hide unwanted events (subevents, trash, completed?)
/// The starting page of the application.
///
/// Generated by the [_search] function in [ExecutiveHomePage] and by [main].
/// Only displays events in [events].
class ExecutiveHomePage extends StatefulWidget {
  ExecutiveHomePage({
    Key? key,
    required this.title,
    required this.events,
    this.isRoot,
  }) : super(key: key) {
    masterList.manageEventList(events);
  }

  /// The title text, placed in the center of the appbar.
  final String title;

  /// Holds the events considered by this particular HomePage.
  /// Necessary to consider and selectively show searches.
  final EventList events;

  final ExecutiveHomePage? isRoot;

  /// Adds event to both current and masterList.
  void addEvent(Event e) {
    masterList.add(e);
    masterList.saveMaster();
    events.add(e);
  }

  /// Removes event from both current and masterList.
  void removeEvent(Event e) {
    masterList.remove(e);
    masterList.saveMaster();
  }

  /// Removes event from both current and masterList.
  void clearEvents() {
    for(int i = 0; i < events.length; i++) {
      masterList.remove(events[i]);
    }
    masterList.saveMaster();
  }

  @override
  State<ExecutiveHomePage> createState() => _ExecutiveHomePageState();
}

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

  /// Loads new page when search results are submitted, generating a new
  /// [ExecutiveHomePage].
  Future _goToSearchPage(BuildContext context, EventList events) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecutiveHomePage(
          title: 'Search results',
          events: events,
          isRoot: widget.isRoot ?? widget,
        ),
      ),
    );
    setState(() {});
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
                    events: widget.isRoot == null ? masterList.toEventList() : widget.events,
                    onSubmit: (EventList e) {
                      _goToSearchPage(context, e);
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
        builder: (context) => EventChangeForm(
          event: event,
          events: widget.events,
        ),
      ),
    );
  }

  Future<Event?> _addEventForm(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAddForm(
          events: widget.events,
        ),
      ),
    );
  }

  Future<MassEditor?> _massEventForm(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventMassForm(
          events: widget.events,
        ),
      ),
    );
  }

  void showCompleted() {
    _goToSearchPage(context, masterList.toEventList().searchTags('Completed'));
    setState(() {});
  }

  void setSort(Comparator<Event>? value) {
    if(value != null) {
      setState(() {
        EventList.sortFunc = value;
        widget.events.sort();
        setState(() {});
      });
    }
  }

  void exportData() {
    Clipboard.setData(ClipboardData(text: Set<Event>.from(widget.events.list).toJason()));
  }

  void importData() {
    Clipboard.getData('text/plain').then((ClipboardData? value) {
      if (value != null && value.text != null && value.text != '') {
        if(widget.isRoot != null) {
          masterList.removeManagedEventList(widget.events);
        }
        Navigator.popUntil(context, ModalRoute.withName('/'));
        masterList.loadMaster(value.text!);
        final ExecutiveHomePage root = widget.isRoot ?? widget;
        root.events.union(masterList.toEventList()).searchTags(
            'Completed', appears: false,);
      } else {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    });
    setState(() {});
  }

  /// Our wonderful "Title"
  Widget definitelyATitle() {
    final List<Widget> widgets = <Widget>[];
    if(widget.isRoot != null) {
      widgets.add(
        IconButton(
          onPressed: () {
            masterList.removeManagedEventList(widget.events);
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
              ),),);},
        icon: const Icon(Icons.calendar_today),
    ),);
    return Row(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _searchIcon(),
        ],
        centerTitle: false,
        title: definitelyATitle(),
      ),
      // Hamburger :)
      drawer: ExecutiveDrawer(sortChange: setSort, showCompleted: showCompleted, exportEvents: exportData, importEvents: importData),
      body: EventListDisplay(
        events: widget.events,
        onLongPress: (Event e) {
          _changeEventForm(context, event: e).then((Event? copy) {
            if(copy == null) {
              widget.removeEvent(e);
            } else if (e == copy) {
            } else {
              e.copy(copy);
              widget.events.sort();
            }
            setState(() {});
          });
        },
        onDrag: (Event e) {
          e.complete();
          widget.events.remove(e);
        },
      ),
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
                    setState(() {});
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBarDisplay(
        events: widget.events,
        selectedIndex: 0,
    ),);
  }
}
