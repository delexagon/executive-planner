import 'package:flutter/material.dart';

import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:executive_planner/backend/event_list.dart';

/// The search widget is an overlay allowing to search for and select a list of events
/// "events"
// TODO: Events modified in search screens are probably left unmodified in the original eventlist
// TODO: Make search use more than just name
class AdvancedSearch extends StatefulWidget {
  final EventList events;
  final Function? onExit;
  final Function(EventList e)? onSubmit;
  final bool selectedOnly;

  const AdvancedSearch({
    required this.events, this.selectedOnly = false, Key? key, this.onSubmit, this.onExit
  }) : super(key: key);

  @override
  _AdvancedSearchState createState() => _AdvancedSearchState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _AdvancedSearchState extends State<AdvancedSearch> {
  EventList currentEvents = EventList();
  EventList selectedEvents = EventList();

  /// Search types which are enabled.
  /// In order: name, tag, priority, location, date
  /// If modified, please also update the typeCheckboxes() function.
  // TODO: Make this used in searching
  List<bool> searchTypesEnabled = [true, false, false, false, false];

  @override
  void initState() {
    super.initState();
    currentEvents.combine(widget.events);
  }

  // TODO: Make redoing searches faster?
  void redoSearch(String searchStr) {
    currentEvents = widget.events.search(searchStr);
    for(int i = 0; i < selectedEvents.length; i++) {
      if(!currentEvents.contains(selectedEvents[i])) {
        currentEvents.add(selectedEvents[i]);
      }
    }
  }

  /// Changes the search.
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

  // TODO: Make this take up way less space
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

  /// This displays all currently selected events
  /// If you long press on events here, they remain permanently selected in the search
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

  /// A button which completes the search.
  // TODO: Decide if the X and
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