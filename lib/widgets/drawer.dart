
import 'package:executive_planner/backend/event_list.dart';
import 'package:flutter/material.dart';

class ExecutiveDrawer extends StatelessWidget {
  const ExecutiveDrawer({required this.sortChange, required this.showCompleted, required this.exportEvents, required this.importEvents, Key? key}) : super(key: key);

  final Function(Comparator<Event>? value) sortChange;
  final Function() showCompleted;
  final Function() exportEvents;
  final Function() importEvents;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 70,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .primaryColorLight,
              ),
              child: Text(
                'Executive Planner',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),),),
          const Divider(),
          RadioListTile<Comparator<Event>>(
            title: const Text('Sort by name'),
            value: Event.nameCompare,
            groupValue: EventList.sortFunc,
            onChanged: (Comparator<Event>? value) {
              sortChange(value);
            },),
          RadioListTile<Comparator<Event>>(
            title: const Text('Sort by date'),
            value: Event.dateCompare,
            groupValue: EventList.sortFunc,
            onChanged: (Comparator<Event>? value) {
              sortChange(value);
            },),
          RadioListTile<Comparator<Event>>(
            title: const Text('Sort by priority'),
            value: Event.priorityCompare,
            groupValue: EventList.sortFunc,
            onChanged: (Comparator<Event>? value) {
              sortChange(value);
            },),
          const Divider(),
          TextButton(
            onPressed: showCompleted,
            child: const Text('Completed events'),
          ),
          const Divider(),
          TextButton(
            onPressed: exportEvents,
            child: const Text('Export to clipboard'),
          ),
          TextButton(
            onLongPress: importEvents,
            onPressed: null,
            child: const Text('Import from clipboard'),
          ),
    ],),);
  }
}
