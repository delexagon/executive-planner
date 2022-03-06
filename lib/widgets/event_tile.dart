import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';
import 'package:executive_planner/widgets/event_list_display.dart';


class EventTile extends StatefulWidget {
  final Event event;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final EventList? setToColor;

  const EventTile({
    required this.event, Key? key, this.onTap, this.onLongPress, this.setToColor
  }) : super(key: key);

  @override
  _EventTileState createState() => _EventTileState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventTileState extends State<EventTile> {

  bool isExpanded = false;

  /// Pads text a standard amount.
  Widget paddedText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget _buildPanel() {
    Decoration? decoration;
    Widget? icon;
    Widget? tile;
    if(widget.setToColor != null && widget.setToColor!.contains(widget.event)) {
      decoration = BoxDecoration(color: Colors.lightBlueAccent.withOpacity(0.1));
    }
    if(widget.event.subevents.length > 0) {
      if(!isExpanded) {
        icon = IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: () {
            isExpanded = true;
            setState(() {});
          }
        );
      } else {
        icon = IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            onPressed: () {
              isExpanded = false;
              setState(() {});
            }
        );
      }
    }
    tile = Container(
      decoration: decoration,
      child: ListTile(
        title: Text(widget.event.name),
        subtitle: Text(widget.event.dateString()),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!(widget.event);
            setState(() {});
          }
        },
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress!(widget.event);
            setState(() {});
          }
        },
        trailing: icon,
      )
    );
    if(isExpanded) {
      return Column(
        children: [
          tile,
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: EventListDisplay(
              events: widget.event.subevents,
              onLongPress: widget.onLongPress,
            ),
          ),
        ]
      );
    } else {
      return tile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPanel();
  }
}