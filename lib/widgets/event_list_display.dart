import 'package:flutter/material.dart';

import 'package:executive_planner/widgets/event_tile.dart';
import 'package:executive_planner/backend/event_list.dart';

/// EventListDisplay displays all events in events in a list, surprise surprise.
/// onLongPress will be called depending on which event tile is pressed, and will
/// recursively be given to subevents.
/// Note that this widget has an arbitrary size, and must be wrapped in a scrollable
/// widget.
class EventListDisplay extends StatefulWidget {
  final EventList events;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final Function(Event e)? onDrag;
  final Function(EventList events)? searchFunc;

  /// Events in this list, if present, are colored light blue.
  final EventList? setToColor;

  const EventListDisplay({
    required this.events, Key? key, this.onTap, this.onLongPress, this.setToColor,
    this.onDrag, this.searchFunc,
  }) : super(key: key);


  @override
  _EventListDisplayState createState() => _EventListDisplayState();
}

class _EventListDisplayState extends State<EventListDisplay> {

  List<Widget> _buildPanel() {
    if(widget.searchFunc != null) {
      widget.searchFunc!(widget.events);
    }
    List<Widget> tiles = <Widget>[];
    for(int i = 0; i < widget.events.length; i++) {
      tiles.add(const Divider());
      tiles.add(EventTile(
        event: widget.events[i],
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onDrag: (Event e) {
          if(widget.onDrag != null) {
            widget.onDrag!(e);
            setState(() {});
          }
        },
        setToColor: widget.setToColor,
      ));
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