
import 'package:executive_planner/backend/events/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Tuple<T1, T2> {
  Tuple(this.first, this.second);
  T1 first;
  T2 second;
}

List<String> specialTags = ['Overdue', 'Displayed', 'Leading'];
List<Color> priorityColors = [Colors.black, Colors.blue, Colors.green, Colors.orange, Colors.red.shade900,];

Color getEventColor(Event e) {
  if(!e.hasTag('Overdue')) {
    return priorityColors[e.priority.index];
  } else {
    return Colors.red;
  }
}

DateFormat userDateFormat = DateFormat('M/d/yy');

Widget padded(double vert, double hor, Widget? other) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: vert, horizontal: hor),
    child: other,
  );
}

extension TitleCase on String {
  String toTitleCase() {
    if(length > 0) {
      return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
    }
    return '';
  }
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime? other) {
    if(other == null) {
      return false;
    }
    return year == other.year && month == other.month
        && day == other.day;
  }

  bool isSameMoment(DateTime? other) {
    if(other == null) {
      return false;
    }
    return other.isAtSameMomentAs(other);
  }
}
