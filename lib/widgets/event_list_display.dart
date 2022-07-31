

import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/widgets/event_tile.dart';
import 'package:flutter/material.dart';

/// EventListDisplay displays all events in events in a list, surprise surprise.
/// onLongPress will be called depending on which event tile is pressed, and will
/// recursively be given to subevents.
/// Note that this widget has an arbitrary size, and must be wrapped in a scrollable
/// widget.
class EventListDisplay extends StatefulWidget {
  const EventListDisplay({
    required this.events,
    Key? key,
    required this.showCompleted,
    this.onTap,
    this.onLongPress,
    this.setToColor,
    this.onDrag,
  }) : super(key: key);

  final EventList events;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final Function(Event e)? onDrag;
  final bool showCompleted;

  /// Events in this list, if present, are colored light blue.
  final Set<Event>? setToColor;

  @override
  _EventListDisplayState createState() => _EventListDisplayState();
}

class _EventListDisplayState extends State<EventListDisplay> {
  List<Widget> _buildPanel() {
    final List<Widget> tiles = <Widget>[];
    if (widget.events.length != 0) {
      for (int i = 0; i < widget.events.length; i++) {
        final Event e = widget.events[i];
        if(!widget.showCompleted && e.isComplete) {
          continue;
        }
        tiles.add(const Divider());
        tiles.add(
          EventTile(
            event: e,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            showCompleted: widget.showCompleted,
            onDrag: (Event e) {
              widget.onDrag?.call(e);
            },
            setToColor: widget.setToColor,
          ),
        );
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(
      children: _buildPanel(),
    ),);
  }
}
