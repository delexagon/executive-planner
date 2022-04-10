import 'package:executive_planner/backend/event_list.dart';
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/widgets/bottom_nav_bar.dart';
import 'package:executive_planner/widgets/event_list_display.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


class CalendarView extends StatefulWidget {
  CalendarView({required this.events, Key? key}) : super(key: key) {
    masterList.manageEventList(events);
  }
  final EventList events;
  @override
  _CalendarState createState() => _CalendarState();
}

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
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    _selectedEventsList = _getEventListForDay(_focusedDay);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              masterList.removeManagedEventList(widget.events);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: TableCalendar<Event>(
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
            ),
          ),
          Expanded(
            flex: 4,
            child: EventListDisplay(
                events: _selectedEventsList,
              ),
          ),
        ]

      ,),
      bottomNavigationBar: NavBarDisplay(
        events: widget.events,
        selectedIndex: 1,

      ),
    );
  }
}
