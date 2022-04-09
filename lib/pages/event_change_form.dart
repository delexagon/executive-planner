// ignore_for_file: unnecessary_string_interpolations, avoid_redundant_argument_values, avoid_dynamic_calls

import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/recurrence.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:executive_planner/widgets/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: We may want to change this to an InheritedWidget?
/// Allows a user to modify an existing event or add a new event.
class EventChangeForm extends StatefulWidget {
  const EventChangeForm(
      {required this.event,
      required this.isNew,
      required this.events,
      Key? key,})
      : super(key: key);

  /// The event this form is considering. This must be provided so the resulting
  /// event can be handled by the caller of the form.
  final Event event;

  /// EventList held for the search display when adding subevents.
  final EventList events;

  /// Makes this form change between adding a new event or changing an existing
  /// event.
  final bool isNew;

  /// [event]:
  /// The event this form is considering. This must be provided so the resulting
  /// event can be handled by the caller of the form.
  ///
  /// [isNew]:
  /// Makes this form change between adding a new event or changing an existing
  /// event.
  ///
  /// [events]:
  /// EventList held for the search display when adding subevents.
  

  @override
  _EventChangeFormState createState() => _EventChangeFormState();
}

class _EventChangeFormState extends State<EventChangeForm> {
  final MaterialColor _backButtonColor = Colors.grey;
  final MaterialColor _confirmButtonColor = Colors.blue;

  /// Generates a widget which changes the time of the event if the date is
  /// already set.
  Widget timePicker() {
    return TextButton(
        onPressed: () {
          showTimePicker(
            initialTime: const TimeOfDay(hour: 0, minute: 0),
            context: context,
          ).then((TimeOfDay? time) {
            if (widget.event.date != null && time != null) {
              setState(() {
                widget.event.date = DateTime(
                    widget.event.date!.year,
                    widget.event.date!.month,
                    widget.event.date!.day,
                    time.hour,
                    time.minute,);
              });
            }
          });
        },
        child: const Text('Change time'),);
  }

  Widget priorityDropdown() {
    final List<DropdownMenuItem<int>> items = Event.priorities.map((String value) {
      return DropdownMenuItem<int>(
        value: Event.priorities.indexOf(value),
        child: Text(value),
      );
    }).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: DropdownButton<int>(
        value: widget.event.priority.index,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        underline: Container(
          height: 2,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onChanged: (int? newValue) {
          widget.event.priority = Priority.values[newValue!];
          setState(() {});
        },
        items: items,
      ),
    );
  }

  /// Generates a widget which allows the user to set the date of an event.
  /// Currently, setting a date resets the time.
  Widget datePicker() {
    return TextButton(
        onPressed: () {
          showDatePicker(
            context: context,
            firstDate: DateTime(DateTime.now().year - 2),
            lastDate: DateTime(DateTime.now().year + 10),
            initialDate: DateTime.now(),
          ).then((DateTime? date) {
            setState(() {
              widget.event.date = date;
            });
          });
        },
        child: Text(widget.event.dateString()),);
  }

  /// Generates a widget which allows the user to set the date of an event.
  /// Currently, setting a date resets the time.
  Widget subEventPicker() {
    return TextButton(
      onPressed: () {
        _search(context);
      },
      child: const Text('Set subevents'),
    );
  }

  /// The text field that the user enters the event description into
  Widget descriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextField(
        maxLines: 3,
        onChanged: (String descStr) {
          widget.event.description = descStr;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.event.description,
        ),
      ),
    );
  }

  /// Pads text a standard amount.
  Widget paddedText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  /// Changes the name of the event.
  Widget eventNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        onChanged: (String name) {
          setState(() {
            widget.event.name = name;
          });
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.event.name,
        ),
      ),
    );
  }

  /// A button which allows the user to add/remove an event.
  Widget changeEventButton() {
    Widget changeText;
    if (widget.isNew) {
      changeText = const Text('Add event', style: TextStyle(fontSize: 30));
    } else {
      changeText = const Text('Remove event', style: TextStyle(fontSize: 30));
    }
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, true);
      },
      style: ElevatedButton.styleFrom(
        primary: _confirmButtonColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      child: changeText,
    );
  }

  Widget cancelButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, false);
      },
      style: ElevatedButton.styleFrom(
        primary: _backButtonColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 30)),
    );
  }

  Widget recurText() {
    if(widget.event.recur == null) {
      return TextButton(
        onPressed: () {
          widget.event.recur = Recurrence();
          setState(() {});
        },
        child: const Text('Make recurring event'),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () {
              widget.event.recur = null;
              setState(() {});
            },
            child: const Text('Stop event from recurring'),
          ),
          _recurChanger(),
        ],
      );
    }
  }

  Widget _recurChanger() {
    final List<Widget> typeboxes = <Widget>[];
    for(int i = 0; i < Break.timeStrs.length; i++) {
      typeboxes.add(padded(1,1,
        SizedBox(
          width: 75,
          child: TextField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly],
            onChanged: (String descStr) {
              if(widget.event.recur != null && descStr != '') {
                widget.event.recur!.spacing.times[i] = int.parse(descStr);
              }
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: i == 4 ? 'Min' : '${Break.timeStrs[i]}',
      ),),),),);
    }
    return SizedBox(
      height: 35,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: typeboxes,
      ),
    );
  }


  // ============ //
  //     Tags     //
  // ============ //

  // Input box for adding/searching tags
  Widget tagSelector() {
    final Widget tagAdder = TextField(
      controller: _searchTextEditingController,
      textInputAction: TextInputAction.search,
      onSubmitted: (String tag) {
        setState(() {
          widget.event.addTag(tag);
          widget.events.addTagToMasterList(tag);
        });
        _searchTextEditingController.clear();
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Add a tag',
      ),
    );

    return tagAdder;
  }

  // searchTextEditingController listens for text being typed into tagSelector input
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  String get _searchText => _searchTextEditingController.text.trim();

  // Initialize listener
  @override
  void initState() {
    super.initState();
    _searchTextEditingController.addListener(() => refreshState(() {}));
  }
  void refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
  }

  // Displays tag suggestions according to queries from incomplete text being typed in
  // searchTextEditingController sends over the text being typed in, which searches for matching tags in the master tag list in event_list.dart.
  // TODO: Find a way for the master tag list to persist through reloads. Can maybe link to EventList in some way?
  Widget _buildSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_searchText.isNotEmpty)
        const Text('Suggestions'),
      Wrap(
        alignment: WrapAlignment.start,
        children: _filterSearchResultList()
            .asList()
            .where((tagModel) =>
                widget.events.getTagMasterList().contains(tagModel),)
            .map((tagModel) => tagChip(
                  tagModel: tagModel,
                  onTap: () => {
                    setState(() {
                      widget.event.addEventTag(tagModel);
                      _searchTextEditingController.clearComposing();
                    })
                  },
                  action: 'Add',
                  color: Colors.lightBlueAccent,
                  accentColor: const Color.fromARGB(255, 54, 149, 193),
                ),)
            .toList(),
      ),
    ],);
  }

  // Displays tag suggestions
  Padding _displayTagWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _filterSearchResultList().isNotEmpty
          ? _buildSuggestionWidget()
          : const Text('No Labels added'),
    );
  }

  // Queries the master tag list based on the text being typed in.
  TagList _filterSearchResultList() {
    if (_searchText.isEmpty) return widget.event.tags;
    return widget.events.getTagMasterList().queryTags(_searchText);
  }

  // Defines how each tag will appear in the tag widget
  Widget tagChip({
    required EventTag tagModel,
    required VoidCallback onTap,
    String? action,
    Color? color,
    Color? accentColor,
  }) {
    return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text(
                  '${tagModel.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            if (action == 'Remove') Positioned(
              right: 0,
              child: CircleAvatar(
                backgroundColor: accentColor,
                radius: 8.0,
                child: const Icon(
                  Icons.clear,
                  size: 10.0,
                  color: Colors.white,
                ),
              ),
            ) else const SizedBox.shrink()
          ],
        ),);
  }

  // Displays selected tags
  Widget tagDisplay() {
    return widget.event.tags.length > 0
        ? Column(
          children: [
            Wrap(
              children: widget.event.tags
                  .asList()
                  .map((tagModel) => tagChip(
                        tagModel: tagModel,
                        onTap: () => setState(() {
                          widget.event.tags.removeEventTag(tagModel);
                        },),
                        action: 'Remove',
                        color: Colors.deepOrangeAccent,
                        accentColor: Colors.orange.shade600,
                      ),)
                  .toSet()
                  .toList(),
            ),
            
          ],)
        : Container();
  }

  // Main wrapper for all tag widgets
  Widget tagPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              tagDisplay(),
              tagSelector(),
              _displayTagWidget(),
      ],),
    );
  }

  /// Basically a copy of the _search function in [ExecutiveHomePage], but
  /// the functionality is different:
  /// Only selected events are given as the EventList, rather than all in search results.
  /// Changes subevents list to the subevents found by the search.
  Future _search(BuildContext context) async {
    if (Overlay.of(context) != null) {
      final OverlayState overlayState = Overlay.of(context)!;
      OverlayEntry overlayEntry;
      // Flutter doesn't allow you to reference overlayEntry before it is created,
      // even though the buttons in search need to reference it.
      Function removeOverlayEntry = () {};
      overlayEntry = OverlayEntry(builder: (context) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Card(
                child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Theme.of(context).canvasColor),
                      child: AdvancedSearch(
                        selectedOnly: true,
                        events: widget.events,
                        onSubmit: (EventList e) {
                          widget.event.subevents = e;
                          removeOverlayEntry();
                        },
                        onExit: () {
                          removeOverlayEntry();
      },),),),),);},);
      removeOverlayEntry = () {
        overlayEntry.remove();
      };
      overlayState.insert(overlayEntry);
    }
  }

  Widget padded(double vert, double hor, Widget other) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vert, horizontal: hor),
      child: other,
    );
  }

  // TODO: Let the user collapse features which are used less often.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Change an event'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              paddedText('Event name:'),
              eventNameField(),
              paddedText('Event description:'),
              descriptionField(),
              paddedText('Select tags:'),
              tagPicker(),
              paddedText('Change date:'),
              datePicker(),
              timePicker(),
              paddedText('Change priority:'),
              priorityDropdown(),
              paddedText('Change recurrence:'),
              recurText(),
              paddedText('Change sub-events:'),
              subEventPicker(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 40)),
            ],
          ),
        ),),
        bottomSheet: SizedBox(
          height: 70,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: padded(10,10,changeEventButton()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: padded(10,10,cancelButton()),
        ),],),),
    );
  }
}
