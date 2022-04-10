import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';

// TODO: Taps are having a delayed response for some reason.
/// An individual event tile. This class should only be called by [EventListDisplay].
/// This class also calls more [EventListDisplay]s.
class EventTile extends StatefulWidget {
  /// Only [EventListDisplay] should call this function.
  const EventTile({
    required this.event, Key? key, this.onTap, this.onLongPress, this.setToColor, this.onDrag,
  }) : super(key: key);

  final Event event;
  final Function(Event e)? onTap;
  final Function(Event e)? onLongPress;
  final Function(Event e)? onDrag;
  final Set<Event>? setToColor;

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
    TextStyle titleColor;
    if(widget.event.priority == Priority.low) {
      titleColor = const TextStyle(color: Colors.blue);
    } else if(widget.event.priority == Priority.medium) {
      titleColor = const TextStyle(color: Colors.green);
    } else if(widget.event.priority == Priority.high) {
      titleColor = const TextStyle(color: Colors.orange);
    } else if(widget.event.priority == Priority.critical) {
      titleColor = TextStyle(color: Colors.red.shade900);
    } else {
      titleColor = const TextStyle(color: Colors.black);
    }
    String subtitleString = '';
    if(!descMode) {
      subtitleString += widget.event.dateString();
      if(widget.event.recur != null) {
        subtitleString += '\n${widget.event.recur!.toString()}';
      }
      if(widget.event.tags.isNotEmpty) {
        subtitleString += '\nTags: ${widget.event.tagsString()}';
      }
    } else {
      subtitleString = widget.event.description;
    }
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
          subtitle: Text(subtitleString),
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
              onDrag: widget.onDrag,
            ),
          ),
        ],
      );
    } else {
      return tile;
    }
  }

  // TODO: Updating events should probably notify the home page somehow.
  @override
  Widget build(BuildContext context) {
    widget.event.update();
    return _buildPanel();
  }
}
