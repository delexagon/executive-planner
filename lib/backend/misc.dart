import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateFormat userDateFormat = DateFormat('M/d/yy');

Widget padded(double vert, double hor, Widget? other) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: vert, horizontal: hor),
    child: other,
  );
}

extension TitleCase on String {
  String toTitleCase() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
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
