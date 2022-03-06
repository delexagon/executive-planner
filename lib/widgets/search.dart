import 'package:flutter/material.dart';

import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:executive_planner/backend/event_list.dart';

// TODO: Events modified in search screens are probably left unmodified in the original eventlist
// TODO: Make search use more than just name
/// The search widget is an overlay allowing to search for and select a list of events.
class AdvancedSearch extends StatefulWidget {
  /// Stores the events that are being searched from.
  final EventList events;
  /// A function which is called when the X button is pressed.
  final Function? onExit;
  /// A function called with the EventList
  final Function(EventList e)? onSubmit;
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
  const AdvancedSearch({
    Key? key, required this.events, this.selectedOnly = false, this.onSubmit, this.onExit
  }) : super(key: key);

  @override
  _AdvancedSearchState createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  /// All currently shown events in the search; modified as the user changes search terms
  EventList currentEvents = EventList();
  /// Events the user has specially selected; only modified by user
  EventList selectedEvents = EventList();

  // TODO: Make this used in searching
  /// Search types which are enabled.
  /// In order: name, tag, priority, location, date
  /// If modified, please also update the typeCheckboxes() function.
  List<bool> searchTypesEnabled = [true, false, false, false, false];

  /// Initializes search to include all events in list.
  @override
  void initState() {
    super.initState();
    currentEvents.combine(widget.events);
  }

  // TODO: Add other methods of searching
  /// Recalculates search based on the new search terms.
  void redoSearch(String searchStr) {
    currentEvents = widget.events.search(searchStr);
    for(int i = 0; i < selectedEvents.length; i++) {
      if(!currentEvents.contains(selectedEvents[i])) {
        currentEvents.add(selectedEvents[i]);
      }
    }
  }

  /// The text field that the user enters their search into; search results are
  /// recalculated as the user enters stuff.
  Widget searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField(
        maxLines: 3,
        onChanged: (String searchStr) {
          redoSearch(searchStr);
          setState(() {});
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Search",
        ),
      ),
    );
  }

  // TODO: Make this take up way less UI space
  /// Generates a list of checkboxes which allow the user to select search types.
  /// Not currently used.
  Widget typeCheckboxes() {
    List<String> searchTypes = ["Name", "Tags", "Priority", "Location", "Date"];
    List<Widget> checkboxes = <Widget>[];
    for(int i = 0; i < searchTypesEnabled.length && i < searchTypes.length; i++) {
      checkboxes.add(
        CheckboxListTile(
          title: Text(searchTypes[i]),
          value: searchTypesEnabled[i],
          onChanged: (bool? value) {
            searchTypesEnabled[i] = !searchTypesEnabled[i];
            setState(() { });
          },
        )
      );
    }
    return Column(children: checkboxes);
  }

  /// This displays all currently searched events.
  /// If you tap on events here, they remain permanently present in the search.
  Widget listView() {
    return Expanded(
      child: SingleChildScrollView(
        child: EventListDisplay(
          events: currentEvents,
          setToColor: selectedEvents,
          onTap: (Event e) {
            if(selectedEvents.contains(e)) {
              selectedEvents.remove(e);
            } else {
              selectedEvents.add(e);
            }
          }
        ),
      )
    );
  }

  /// A row containing buttons which complete and exit the search.
  Widget searchButton() {
    return Center(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              iconSize: 30,
              onPressed: () {
                if(widget.onExit != null) {
                  widget.onExit!();
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextButton(
                onPressed: () {
                  if(widget.onSubmit != null) {
                    if(!widget.selectedOnly) {
                      widget.onSubmit!(currentEvents);
                    } else {
                      widget.onSubmit!(selectedEvents);
                    }
                  }
                },
                child: const Text("OK", style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        searchButton(),
        const Divider(),
        searchField(),
        const Divider(),
        listView(),
      ],
    );
  }
}