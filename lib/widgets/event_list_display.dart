import 'package:flutter/material.dart';

import 'package:executive_planner/widgets/event_tile.dart';
import 'package:executive_planner/backend/event_list.dart';

/// EventListDisplay displays all events in events in a list, surprise surprise.
/// onLongPress will be called depending on which event tile is pressed, and will
/// recursively be given to subevents.
/// Note that this widget has an arbitrary size, and must be wrapped in a scrollable
/// widget.
class EventListDisplay extends StatelessWidget {
  final EventList events;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final Function(Event e)? onDrag;

  /// Events in this list, if present, are colored light blue.
  final EventList? setToColor;

  const EventListDisplay({
    required this.events, Key? key, this.onTap, this.onLongPress, this.setToColor, this.onDrag
  }) : super(key: key);

  List<Widget> _buildPanel() {
    List<Widget> tiles = <Widget>[];
    for(int i = 0; i < events.length; i++) {
      tiles.add(const Divider());
      tiles.add(EventTile(
        event: events[i],
        onTap: onTap,
        onLongPress: onLongPress,
        onDrag: onDrag,
        setToColor: setToColor,
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