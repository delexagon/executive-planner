import 'package:flutter/material.dart';

import 'package:executive_planner/widgets/event_tile.dart';
import 'package:executive_planner/event_list.dart';

/// EventListDisplay displays all events in events in a list, surprise surprise.
/// onLongPress will be called depending on which event tile is pressed, and will
/// recursively be given to subevents.
/// Note that this widget has an arbitrary size, and must be wrapped in a scrollable
/// widget.
class EventListDisplay extends StatefulWidget {
  final EventList events;
  final Function(Event e)? onLongPress;

  const EventListDisplay({required this.events, Key? key, this.onLongPress}) : super(key: key);

  @override
  _EventListDisplayState createState() => _EventListDisplayState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventListDisplayState extends State<EventListDisplay> {

  List<Widget> _buildPanel() {
    List<Widget> tiles = <Widget>[];

    for(int i = 0; i < widget.events.length; i++) {
      tiles.add(EventTile(
          event: widget.events[i],
          onLongPress: widget.onLongPress)
      );
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildPanel(),
    );
  }
}