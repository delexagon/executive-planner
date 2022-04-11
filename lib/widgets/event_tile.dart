import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';

// TODO: Taps are having a delayed response for some reason.
/// An individual event tile. This class should only be called by [EventListDisplay].
/// This class also calls more [EventListDisplay]s.
class EventTile extends StatefulWidget {
  /// Only [EventListDisplay] should call this function.
  const EventTile({
    required this.event, Key? key, required this.showCompleted, this.onTap, this.onLongPress, this.setToColor, this.onDrag,
  }) : super(key: key);

  final Event event;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final Function(Event e)? onDrag;
  final Set<Event>? setToColor;
  final bool showCompleted;

  @override
  _EventTileState createState() => _EventTileState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _EventTileState extends State<EventTile> {

  bool isExpanded = false;
  bool descMode = false;

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

  // TODO: User should be able to quickly add subevents to all events.
  /// Builds a single tile.
  /// Very long, because there are a number of variations for how tiles should look.
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
          },
        );
      } else {
        icon = IconButton(
            icon: const Icon(Icons.arrow_drop_up),
            onPressed: () {
              isExpanded = false;
              setState(() {});
            },
        );
      }
    }
    final TextStyle titleColor = TextStyle(color: priorityColors[widget.event.priority.index]);
    tile = GestureDetector(
      onDoubleTap: () {
        if (widget.onDrag != null) {
          widget.onDrag!(widget.event);
          setState(() {});
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (widget.onDrag != null) {
          widget.onDrag!(widget.event);
          setState(() {});
        }
      },
      child: Container(
        decoration: decoration,
        child: ListTile(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!(widget.event);
              setState(() {});
            } else {
              descMode = !descMode;
              setState(() {});
            }
          },
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress!(widget.event);
              setState(() {});
            }
          },
          title: Text(
            widget.event.name,
            style: titleColor,
          ),
          subtitle: Text(widget.event.subtitleString(descMode: descMode)),
          trailing: icon,
        ),
      ),
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
              showCompleted: widget.showCompleted,
              onDrag: widget.onDrag,
            ),
          ),
        ],
      );
    } else {
      return tile;
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.event.update();
    return _buildPanel();
  }
}
