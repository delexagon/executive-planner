
import 'package:executive_planner/backend/events/event.dart';
import 'package:executive_planner/backend/events/event_list.dart';
import 'package:executive_planner/backend/events/list_wrapper_observer.dart';
import 'package:executive_planner/pages/forms/event_change_form.dart';
import 'package:executive_planner/widgets/drawer.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  // Currently, the calendar will never show completed events.
  const CalendarView({required this.events, Key? key, required this.headlist}) : super(key: key);
  final EventList events;
  final ListObserver headlist;

  @override
  _CalendarState createState() => _CalendarState();
}

// TODO: This may not update because the selected day list keeps changing. Check this
class _CalendarState extends State<CalendarView> {
  late EventList _selectedEventsList;

  // Default to month view
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late final ValueNotifier<List<Event>> _selectedEvents;
  // The events that are currently selected, as an EventList for EventListDisplay

  @override
  void initState() {
    super.initState();
    widget.headlist.addFunc(this, () {setState(() {});});
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    _selectedEventsList = _getEventListForDay(_focusedDay);
  }

  @override
  void dispose() {
    widget.headlist.removeFunc(this);
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<Event?> _changeEventForm(BuildContext context, {required Event event}) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventChangeForm(
          headlist: widget.headlist,
          event: event,
        ),
      ),
    );
  }

  EventList _getEventListForDay(DateTime day) {
    return widget.events.searchDate(day);
  }

  // Converts _getEventListForDay into List<Events>
  List<Event> _getEventsForDay(DateTime day) {
    return _getEventListForDay(day).asList();
  }

  EventList _getEventListForRange(DateTime start, DateTime end) {
    return widget.events.searchRange(start, end);
  }

  // Converts _getEventListForRange into List<Events>
  // ignore: unused_element
  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    return _getEventListForRange(start, end).asList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(selectedDay, _selectedDay)) {
      setState(() {
        _selectedEventsList = widget.events.searchDate(selectedDay);
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      _selectedEvents.value = _selectedEventsList.asList();
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
    // Since start and end dates could be null
    if (start != null && end != null) {
      _selectedEventsList = _getEventListForRange(start, end);
      _selectedEvents.value = _selectedEventsList.asList();
    } else if (start != null) {
      _selectedEventsList = _getEventListForDay(start);
      _selectedEvents.value = _selectedEventsList.asList();
    } else if (end != null) {
      _selectedEventsList = _getEventListForDay(end);
      _selectedEvents.value = _selectedEventsList.asList();
    }
  }

  Widget calendar() {
    return TableCalendar<Event>(
      firstDay: DateTime.utc(2022),
      lastDay: DateTime.utc(2023),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      calendarFormat: _calendarFormat,
      rangeSelectionMode: _rangeSelectionMode,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      // Customize UI using CalendarStyle
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      onDaySelected: _onDaySelected,
      onRangeSelected: _onRangeSelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
        if (format == CalendarFormat.month) {
          _rangeStart = DateTime(_focusedDay.year, _focusedDay.month);
          if (_focusedDay.month == 2) {
            _rangeEnd = DateTime(_focusedDay.year, _focusedDay.month, 28);
          } else if (_focusedDay.month == 4 ||
              _focusedDay.month == 6 ||
              _focusedDay.month == 9 ||
              _focusedDay.month == 11) {
            _rangeEnd = DateTime(_focusedDay.year, _focusedDay.month, 30);
          } else {
            _rangeEnd = DateTime(_focusedDay.year, _focusedDay.month, 31);
          }
        } else if (format == CalendarFormat.twoWeeks) {
          _rangeStart = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day - _focusedDay.weekday + 1,);
          _rangeEnd = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day + (14 - _focusedDay.weekday),);
        } else if (format == CalendarFormat.week) {
          _rangeStart = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day - _focusedDay.weekday + 1,);
          _rangeEnd = DateTime(_focusedDay.year, _focusedDay.month,
            _focusedDay.day + (7 - _focusedDay.weekday),);
        }
        _onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }


  Widget title() {
    final List<Widget> widgets = <Widget>[];
    widgets.add(const Text('Calendar'));
    widgets.add(
      IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.list_alt),
      ),);
    return Row(
      children: widgets,
    );
  }

  // TODO: Stop this trash from throwing errors whenever you change the size of the calendar
  @override
  Widget build(BuildContext context) {
    // We manually set the height of the calendar container, because apparently there's
    // no way to check this during run time. Otherwise, the scrollable size would be
    // infinite and it wouldn't render.
    double calendarHeight = 350;
    if(_calendarFormat == CalendarFormat.twoWeeks) {
      calendarHeight = 200;
    } else if(_calendarFormat == CalendarFormat.week) {
      calendarHeight = 140;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: title(),
      ),
      drawer: ExecutiveDrawer(
        events: widget.events,
        headlist: widget.headlist,
      ),
      body: Column(
            children: [
              SizedBox(
                height: calendarHeight,
                child: calendar(),
              ),
              Expanded(
                child:  SingleChildScrollView (
                  child: EventListDisplay(
                    events: _selectedEventsList,
                    showCompleted: true,
                    onLongPress: (Event e) {
                      _changeEventForm(context, event: e).then((Event? copy) {
                        if(copy == null) {
                          widget.headlist.notify(NotificationType.eventRemove, event: e);
                        } else if (e != copy) {
                          e.copy(copy);
                          widget.events.sort();
                        }
                        if(_selectedDay != null) {
                          _selectedEventsList = widget.events.searchDate(_selectedDay!);
                        }
    });},),),),],),);
  }
}
