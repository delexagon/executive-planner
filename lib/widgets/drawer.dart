
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/jason.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExecutiveDrawer extends StatelessWidget {
  const ExecutiveDrawer({required this.update, required this.events, this.calledFromRoot = false, Key? key, required this.onEventListChanged, required this.headlist,}) : super(key: key);
  final EventList events;
  final Function() update;
  final bool calledFromRoot;

  final Function(Event? e) onEventListChanged;
  // TODO: Make this structure have to carry over less data from page to page?
  final EventList headlist;

  /// Loads new page when search results are submitted, generating a new
  /// [ExecutiveHomePage].
  Future _showCompleted(BuildContext context, EventList events) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExecutiveHomePage(
          title: 'Completed events',
          events: events.searchCompleted(),
          showCompleted: true,
          onEventListChanged: onEventListChanged,
          headlist: headlist,
        ),
      ),
    );
  }


  void exportData([String loc = 'events']) {
    if(calledFromRoot) {
      Clipboard.setData(ClipboardData(text: masterList.toJason()));
    } else {
      Clipboard.setData(ClipboardData(text: Set<Event>.from(events.list).toJason()));
    }
  }

  void importData(BuildContext context) {
    Clipboard.getData('text/plain').then((ClipboardData? value) {
      if (value != null && value.text != null && value.text != '') {
        Navigator.popUntil(context, ModalRoute.withName('/'));
        masterList.loadMaster(value.text!);
      }
    });
  }

  void setSort(Comparator<Event>? value) {
    if(value != null) {
      EventList.sortFunc = value;
      events.sort();
    }
  }

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
              setSort(value);
            },),
          RadioListTile<Comparator<Event>>(
            title: const Text('Sort by date'),
            value: Event.dateCompare,
            groupValue: EventList.sortFunc,
            onChanged: (Comparator<Event>? value) {
              setSort(value);
            },),
          RadioListTile<Comparator<Event>>(
            title: const Text('Sort by priority'),
            value: Event.priorityCompare,
            groupValue: EventList.sortFunc,
            onChanged: (Comparator<Event>? value) {
              setSort(value);
            },),
          const Divider(),
          TextButton(
            onPressed:
            () => _showCompleted(context, events),
            child: const Text('Completed events'),
          ),
          const Divider(),
          TextButton(
            onPressed: exportData,
            child: const Text('Export to clipboard'),
          ),
          TextButton(
            onLongPress: () => importData(context),
            onPressed: null,
            child: const Text('Import from clipboard'),
          ),
          const Divider(),
          TextButton(
            onLongPress: () => masterList.saveMaster(null, 'backup'),
            onPressed: null,
            child: const Text('Backup data'),
          ),
          TextButton(
            onLongPress: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              masterList.initMaster('backup');
            },
            onPressed: null,
            child: const Text('Restore backup'),
          ),
    ],),);
  }
}
