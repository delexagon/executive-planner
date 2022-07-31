
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/misc.dart';
import 'package:executive_planner/pages/forms/event_add_form.dart';
import 'package:executive_planner/pages/home_page.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';

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

  /// Loads new page when search results are submitted, generating a new
  /// [ExecutiveHomePage].
  Future _showSubevents(BuildContext context, bool showCompleted) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecutiveHomePage(
          showCompleted: false,
          title: 'Subevents',
          events: widget.event.subevents.makeList(),
          headlist: widget.event.subevents,
        ),
      ),
    );
    setState(() {});
  }

  Future<Event?> _addEventForm(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAddForm(headlist: widget.event.observer!),
      ),
    );
  }

  // TODO: User should be able to quickly add subevents to all events.
  /// Builds a single tile.
  /// Very long, because there are a number of variations for how tiles should look.
  Widget _buildPanel() {
    final Widget addButton = TextButton(
      onPressed: () {
        _addEventForm(context).then((Event? e) {
          if(e!=null) {
            widget.event.addSubevent(e);
            setState(() {});
          }
        });
      },
      child: const Text('Add subevent'),);
    final Widget goToButton = TextButton(
      onPressed: () {
        _showSubevents(context, false);
        setState(() {});
      },
      child: const Text('Go to subevents'),);
    Decoration? decoration;
    Widget? icon;
    Widget? tile;
    if(widget.setToColor != null && widget.setToColor!.contains(widget.event)) {
      decoration = BoxDecoration(color: Colors.lightBlueAccent.withOpacity(0.1));
    }
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
    final TextStyle titleColor = TextStyle(color: getEventColor(widget.event));
    final int length = widget.event.subevents.length;
    final String title = length == 0 ? widget.event.name : '${widget.event.name} ($length)';
    tile = GestureDetector(
      onSecondaryLongPress: () {
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
            title,
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
          Row(
            children: [
              addButton,
              goToButton,
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: EventListDisplay(
              events: widget.event.subevents.makeList().sort(),
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
    return _buildPanel();
  }
}
