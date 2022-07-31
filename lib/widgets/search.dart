
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';

/// The search widget is an overlay allowing to search for and select a list of events.
class AdvancedSearch extends StatefulWidget {
  AdvancedSearch({
    Key? key, this.selectedOnly = false, this.onSubmit, EventList? events, this.onExit,
  }) : super(key: key) {
    if(events != null) {
      this.events = events;
    } else {
      this.events = ListObserver.top.makeList();
    }
  }

  /// Stores the events that are being searched from.
  late final EventList events;
  /// A function which is called when the X button is pressed.
  final Function? onExit;
  /// A function called with the EventList
  final Function(EventList e, bool showCompleted)? onSubmit;
  /// States whether the search will only return selected items, or whether it
  /// will return all items currently in the search results when it is submitted.
  final bool selectedOnly;

  /// [events]
  /// Stores the events that are being searched from.
  ///
  /// [onExit]
  /// A function which is called when the X button is pressed.
  ///
  /// [onSubmit]
  /// A function that gives the searched EventList when submitted.
  ///
  /// [selectedOnly]
  /// States whether the search will only return selected items, or whether it
  /// will return all items currently in the search results when it is submitted.
  

  @override
  _AdvancedSearchState createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  /// All currently shown events in the search; modified as the user changes search terms
  Set<Event> currentEvents = <Event>{};
  /// Events the user has specially selected; only modified by user
  Set<Event> selectedEvents = <Event>{};

  @override
  void initState() {
    super.initState();
    currentEvents = widget.events.toSet();
  }

  String searchStr = '';

  EventList? searchNameByString(String str) {
    final EventList events = widget.events.searchName(str);
    if(events.length > 0) {
      return events;
    }
    return null;
  }

  EventList? searchTagByString(String str) {
    final EventList events = widget.events.searchTags(str);
    if(events.length > 0) {
      return events;
    }
    return null;
  }

  EventList? searchDateByString(String str) {
    if(str.toLowerCase().trim() == 'reminder') {
      return widget.events.noDate();
    }
    DateTime start;
    DateTime end;
    final List<String> strs = str.split('-');
    try {
      start = userDateFormat.parse(strs[0].trim());
    } catch(e) {
      return null;
    }
    try {
      end = userDateFormat.parse(strs[1].trim());
    } catch(e) {
      return widget.events.searchDate(start);
    }
    return widget.events.searchRange(start, end);
  }

  EventList? searchPriorityByString(String str) {
    final int index = Event.priorities.indexOf(str.toTitleCase());
    if(index > -1) {
      return widget.events.searchPriority(Priority.values[index]);
    }
    return null;
  }

  EventList? searchCompletedByString(String str) {
    if(searchTypesEnabled[searchTypesEnabled.length-2] == null || 'completed'.startsWith(str.toLowerCase().trim())) {
      return widget.events.searchCompleted();
    }
    return null;
  }

  EventList? searchByString(int i, String str) {
    if(i == 0) {
      return searchNameByString(str);
    } else if(i == 1) {
      return searchTagByString(str);
    } else if(i == 2) {
      return searchPriorityByString(str);
    } else if(i == 3) {
      return searchDateByString(str);
    } else if(i == 4) {
      return widget.events.searchRecurrence();
    } else if(i == 5) {
      return searchCompletedByString(str);
    }
    return null;
  }

  /// Search types which are enabled.
  /// In order: name, tag, priority, date
  /// If modified, please also update the typeCheckboxes() function.
  List<bool?> searchTypesEnabled = [true, true, false, false, false, false,];

  // TODO: Make this function have less time complexity?
  /// Recalculates search based on the new search terms.
  void redoSearch() {
    currentEvents = <Event>{};
    final List<String> strs = searchStr.split(',');
    for (int index = 0; index < strs.length; index++) {
      strs[index] = strs[index].trim();
      for (int i = 0; i < searchTypesEnabled.length; i++) {
        if (searchTypesEnabled[i] == true) {
          final EventList? toAdd = searchByString(i, strs[index]);
          if (toAdd != null) {
            for (int qq = 0; qq < toAdd.length; qq++) {
              currentEvents.add(toAdd[qq]);
            }
          }
        }
      }
    }
    for(int index = 0; index < strs.length; index++) {
      strs[index] = strs[index].trim();
      for(int i = 0; i < searchTypesEnabled.length; i++) {
        if(searchTypesEnabled[i] == null) {
          final EventList? toRemove = searchByString(i, strs[index]);
          if(toRemove != null) {
            for(int qq = 0; qq < toRemove.length; qq++) {
              currentEvents.remove(toRemove[qq]);
            }
          }
        }
      }
    }
    currentEvents = currentEvents.union(selectedEvents);
  }

  /// The text field that the user enters their search into; search results are
  /// recalculated as the user enters stuff.
  Widget searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField(
        maxLines: 3,
        onChanged: (String searchStr) {
          this.searchStr = searchStr;
          redoSearch();
          setState(() {});
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Search',
        ),
      ),
    );
  }

  /// Generates a list of checkboxes which allow the user to select search types.
  /// Not currently used.
  Widget typeCheckboxes() {
    final List<String> searchTypes = ['Name', 'Tags', 'Priority', 'Date', 'Recurs', 'Complete'];
    final List<Widget> checkboxes = <Widget>[];
    for(int i = 0; i < searchTypes.length; i++) {
      checkboxes.add(
        Flexible(
          child: CheckboxListTile(
            tristate: true,
            title: Text(searchTypes[i]),
            value: searchTypesEnabled[i],
            onChanged: (bool? value) {
              searchTypesEnabled[i] = value;
              redoSearch();
              setState(() {});
      },),),);
      checkboxes.add(const VerticalDivider(width: 20));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child:SizedBox(
        width: 1150,
        height: 40,
        child: Row(
          children: checkboxes,
    ),),);
  }

  /// This displays all currently searched events.
  /// If you tap on events here, they remain permanently present in the search.
  Widget listView() {
    return Expanded(
      child: SingleChildScrollView(
        child: EventListDisplay(
          events: EventList(list: currentEvents.toList()).sort(),
          showCompleted: searchTypesEnabled[searchTypesEnabled.length-2] == true,
          setToColor: selectedEvents,
          onTap: (Event e) {
            if(selectedEvents.contains(e)) {
              selectedEvents.remove(e);
            } else {
              selectedEvents.add(e);
            }
    },),),);
  }

  /// A row containing buttons which complete and exit the search.
  Widget searchButton() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: TextButton(
              onPressed: () {
                if(widget.onSubmit != null && selectedEvents.isNotEmpty) {
                  widget.onSubmit!(EventList(list: selectedEvents.toList()), searchTypesEnabled[searchTypesEnabled.length-2] == true);
                }
              },
              child: const Text('OK', style: TextStyle(fontSize: 20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: TextButton(
              onPressed: () {
                selectedEvents = selectedEvents.union(currentEvents);
                setState(() {});
              },
              child: const Text('Select All', style: TextStyle(fontSize: 20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: TextButton(
              onPressed: () {
                selectedEvents.removeAll(currentEvents);
                setState(() {});
              },
              child: const Text('Remove All', style: TextStyle(fontSize: 20)),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              iconSize: 30,
              onPressed: () {
                widget.onExit!();
    },),],),);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        searchButton(),
        const Divider(),
        searchField(),
        const Divider(),
        typeCheckboxes(),
        listView(),
      ],
    );
  }
}
