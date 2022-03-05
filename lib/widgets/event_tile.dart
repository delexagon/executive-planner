import 'package:flutter/material.dart';
import 'package:executive_planner/event_list.dart';
import 'package:executive_planner/widgets/event_list_display.dart';

class EventTile extends StatefulWidget {
  final Event event;
  final Function(Event e)? onLongPress;

  const EventTile({required this.event, Key? key, this.onLongPress}) : super(key: key);

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
    if(!isExpanded) {
      return Column(
        children: [
          ListTile(
            title: Text(widget.event.name),
            subtitle: Text(widget.event.dateString()),
            onTap: () {
              isExpanded = true;
              setState(() {});
            },
            onLongPress: () {
              if(widget.onLongPress != null) {
                widget.onLongPress!(widget.event);
              }
            }
          )
        ]
      );
    } else {
      return Column(
          children: [
            ListTile(
                title: Text(widget.event.name),
                subtitle: Text(widget.event.dateString()),
                onTap: () {
                  isExpanded = false;
                  setState(() {});
                },
                onLongPress: () {
                  if(widget.onLongPress != null) {
                    widget.onLongPress!(widget.event);
                  }
                }
            ),
            EventListDisplay(
              events: widget.event.subevents,
              onLongPress: widget.onLongPress,
            ),
          ]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPanel();
  }
}